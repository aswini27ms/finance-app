import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline fallback when the backend is unreachable.
class LocalStorageService {
  static const _foldersKey = 'local_folders';
  static const _expensesKey = 'local_expenses';
  static const _incomesKey = 'local_incomes';
  static const _balanceKey = 'local_balance';

  static Future<List<Map<String, dynamic>>> getFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_foldersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> saveFolders(List<Map<String, dynamic>> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_foldersKey, jsonEncode(folders));
  }

  static Future<List<Map<String, dynamic>>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_expensesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> saveExpenses(List<Map<String, dynamic>> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expensesKey, jsonEncode(expenses));
  }

  static Future<List<Map<String, dynamic>>> getIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_incomesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> saveIncomes(List<Map<String, dynamic>> incomes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_incomesKey, jsonEncode(incomes));
  }

  static Future<double?> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey);
  }

  static Future<void> saveBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_foldersKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_incomesKey);
    await prefs.remove(_balanceKey);
  }
}
