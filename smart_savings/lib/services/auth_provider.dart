import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

// Auth state model
class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final double? userBalance;
  final String? error;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.userName,
    this.userEmail,
    this.userBalance,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? userId,
    String? userName,
    String? userEmail,
    double? userBalance,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userBalance: userBalance ?? this.userBalance,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Check if a saved token exists
      await ApiService.init();
      final response = await AuthService.getCurrentUser();
      if (response['user'] != null) {
        final user = response['user'];
        state = state.copyWith(
          isAuthenticated: true,
          userId: user['_id']?.toString(),
          userName: user['name']?.toString(),
          userEmail: user['email']?.toString(),
          userBalance: user['balance'] != null ? (user['balance'] as num).toDouble() : null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      // No saved session or token expired
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        final user = response['user'];
        state = state.copyWith(
          isAuthenticated: true,
          token: response['token']?.toString(),
          userId: user['id']?.toString(),
          userName: user['name']?.toString(),
          userEmail: user['email']?.toString(),
          userBalance: user['balance'] != null ? (user['balance'] as num).toDouble() : 50000,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(
        error: response['message']?.toString() ?? 'Registration failed',
        isLoading: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await AuthService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        final user = response['user'];
        state = state.copyWith(
          isAuthenticated: true,
          token: response['token']?.toString(),
          userId: user['id']?.toString(),
          userName: user['name']?.toString(),
          userEmail: user['email']?.toString(),
          userBalance: user['balance'] != null ? (user['balance'] as num).toDouble() : 50000,
          isLoading: false,
        );
        return true;
      }

      state = state.copyWith(
        error: response['message']?.toString() ?? 'Login failed',
        isLoading: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (_) {
      // Ignore errors on logout
    } finally {
      state = AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateBalance(double balance) {
    state = state.copyWith(userBalance: balance);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Auth state selectors
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});

final userNameProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userName;
});

final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userEmail;
});

final userBalanceProvider = Provider<double>((ref) {
  return ref.watch(authProvider).userBalance ?? 50000;
});
