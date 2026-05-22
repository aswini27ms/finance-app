import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/savings_service.dart';

// ── Message model ─────────────────────────────────────────────────────────────
class CoachMessage {
  final String text;
  final bool fromUser;
  final bool isLoading;
  final bool isError;

  const CoachMessage({
    required this.text,
    required this.fromUser,
    this.isLoading = false,
    this.isError = false,
  });
}

// ── Groq API config ───────────────────────────────────────────────────────────
const _groqKey = String.fromEnvironment('GROQ_KEY');

const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
const _groqModel = 'llama-3.3-70b-versatile'; // Fast & free on Groq

// ── Provider ──────────────────────────────────────────────────────────────────
final coachMessagesProvider =
    StateNotifierProvider<CoachNotifier, List<CoachMessage>>((ref) {
  final balance = ref.watch(balanceProvider);
  final remaining = ref.watch(remainingBalanceProvider);
  final spent = ref.watch(totalSpentProvider);
  final saved = ref.watch(monthlySavedProvider);
  final score = ref.watch(healthScoreProvider);
  final folders = ref.watch(foldersProvider);

  final folderSummary = folders.maybeWhen(
    data: (list) => list
        .map((f) =>
            '${f.name}: spent ₹${f.spent.toStringAsFixed(0)} of ₹${f.budget.toStringAsFixed(0)} budget')
        .join(', '),
    orElse: () => 'No folder data',
  );

  return CoachNotifier(
    balance: balance,
    remaining: remaining,
    spent: spent,
    saved: saved,
    score: score,
    folderSummary: folderSummary,
  );
});

// ── Notifier ──────────────────────────────────────────────────────────────────
class CoachNotifier extends StateNotifier<List<CoachMessage>> {
  final double balance;
  final double remaining;
  final double spent;
  final double saved;
  final int score;
  final String folderSummary;

  // Conversation history (OpenAI-compatible format used by Groq)
  final List<Map<String, dynamic>> _history = [];

  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 1);

  Timer? _debounceTimer;

  CoachNotifier({
    required this.balance,
    required this.remaining,
    required this.spent,
    required this.saved,
    required this.score,
    required this.folderSummary,
  }) : super([
          const CoachMessage(
            text:
                "Hi! I'm your AI financial coach 👋 I can see your savings data and I'm here to help you budget smarter, cut expenses, and hit your goals. What's on your mind?",
            fromUser: false,
          ),
        ]);

  String get _systemPrompt => '''
You are a smart, friendly personal finance coach built into the Smart Savings app.
You have access to the user's real financial data:

- Bank balance: ₹${balance.toStringAsFixed(2)}
- Available (after allocations): ₹${remaining.toStringAsFixed(2)}
- Spent this month: ₹${spent.toStringAsFixed(2)}
- Saved this month: ₹${saved.toStringAsFixed(2)}
- Financial health score: $score/100
- Expense folders: $folderSummary

Guidelines:
- Be concise, warm, and practical. No fluff.
- Use the user's actual numbers when giving advice.
- Use ₹ for currency (Indian Rupees).
- Give specific, actionable tips — not generic advice.
- If asked something outside finance, gently redirect to financial topics.
- Keep responses under 200 words unless the user asks for detail.
- Use bullet points sparingly — prefer natural conversation.
''';

  /// Builds the full messages array for Groq (OpenAI-compatible format)
  List<Map<String, dynamic>> _buildMessages() {
    return [
      // System message always first
      {
        'role': 'system',
        'content': _systemPrompt,
      },
      // Full conversation history
      ..._history,
    ];
  }

  Future<void> ask(String userText) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _sendMessage(userText);
    });
  }

  Future<void> _sendMessage(String userText) async {
    // Basic rate limiting
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - elapsed);
      }
    }

    // Add user message to UI
    state = [...state, CoachMessage(text: userText, fromUser: true)];

    // Add loading bubble
    state = [
      ...state,
      const CoachMessage(text: '...', fromUser: false, isLoading: true),
    ];

    // Append to history
    _history.add({'role': 'user', 'content': userText});

    _lastRequestTime = DateTime.now();
    await _makeRequest();
  }

  Future<void> _makeRequest() async {
    if (_groqKey.isEmpty) {
      _handleError(
        'Groq API key is not configured. Run with --dart-define=GROQ_KEY=<your-key> or set GROQ_KEY in your build environment.',
      );
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_groqUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqKey',
            },
            body: jsonEncode({
              'model': _groqModel,
              'messages': _buildMessages(),
              'temperature': 0.7,
              'max_tokens': 400,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices']?[0]?['message']?['content'] as String? ??
            "Sorry, I couldn't get a response. Try again!";

        // Append assistant reply to history
        _history.add({'role': 'assistant', 'content': reply});

        final updated = state.toList();
        if (updated.isNotEmpty && updated.last.isLoading) {
          updated.removeLast();
        }
        state = [...updated, CoachMessage(text: reply, fromUser: false)];
      } else if (response.statusCode == 429) {
        _handleError(
          '⏳ Too many requests. Please wait a moment and try again.',
        );
      } else {
        final errorDetail = _extractErrorMessage(response.body);
        _handleError(
          'Error ${response.statusCode}: ${_getErrorMessage(response.statusCode)}'
          '${errorDetail != null ? '\n$errorDetail' : ''}',
        );
      }
    } on TimeoutException {
      _handleError('⏱ Request timed out. Check your internet connection.');
    } catch (e) {
      _handleError('🚫 Connection failed. Check your internet and try again.');
    }
  }

  String? _extractErrorMessage(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return data['error']?['message'] as String?;
    } catch (_) {
      return null;
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Invalid API key';
      case 403:
        return 'Access denied';
      case 429:
        return 'Rate limit reached';
      case 500:
        return 'Server error';
      default:
        return 'Unknown error';
    }
  }

  void _handleError(String msg) {
    final updated = state.toList();
    if (updated.isNotEmpty && updated.last.isLoading) {
      updated.removeLast();
    }
    state = [
      ...updated,
      CoachMessage(text: msg, fromUser: false, isError: true),
    ];
    // Remove the failed user message from history
    if (_history.isNotEmpty && _history.last['role'] == 'user') {
      _history.removeLast();
    }
  }

  void clearHistory() {
    _history.clear();
    _lastRequestTime = null;
    state = [
      const CoachMessage(
        text: "Chat cleared! What would you like to talk about?",
        fromUser: false,
      ),
    ];
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
