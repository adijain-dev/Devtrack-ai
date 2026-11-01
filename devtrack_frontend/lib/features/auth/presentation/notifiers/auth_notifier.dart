import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_state.dart';
import '../../data/repositories/auth_repository_provider.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    Future.microtask(() => checkAuth());
    return const AuthState();
  }

  Future<void> checkAuth() async {
    try {
      final token = await ref.read(secureStorageProvider).readToken();
      final refreshToken = await ref.read(secureStorageProvider).readRefreshToken();
      if (token != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          refreshToken: refreshToken,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, successMessage: null);
    try {
      final User user = await _repo.login(email, password);
      String? token;
      String? refreshToken;
      try {
        token = (user as dynamic).token as String?;
        refreshToken = (user as dynamic).refreshToken as String?;
      } catch (_) {}

      final storage = ref.read(secureStorageProvider);
      if (token != null) {
        await storage.saveToken(token);
      }
      if (refreshToken != null) {
        await storage.saveRefreshToken(refreshToken);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        refreshToken: refreshToken,
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, successMessage: null);
    try {
      await _repo.register(name, email, password);
      await login(email, password);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
    }
  }

  Future<bool> refreshToken() async {
    try {
      final currentRefreshToken = state.refreshToken ??
          await ref.read(secureStorageProvider).readRefreshToken();
      if (currentRefreshToken == null) return false;

      final tokens = await _repo.refreshToken(currentRefreshToken);
      final newAccessToken = tokens['accessToken'];
      final newRefreshToken = tokens['refreshToken'];

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        final storage = ref.read(secureStorageProvider);
        await storage.saveToken(newAccessToken);
        if (newRefreshToken != null) {
          await storage.saveRefreshToken(newRefreshToken);
        }

        state = state.copyWith(
          token: newAccessToken,
          refreshToken: newRefreshToken ?? currentRefreshToken,
          status: AuthStatus.authenticated,
        );
        return true;
      }
      return false;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, successMessage: null);
    try {
      final message = await _repo.forgotPassword(email);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        successMessage: message,
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> resetPassword(String email, String resetCode, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, successMessage: null);
    try {
      await _repo.resetPassword(email, resetCode, newPassword);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        successMessage: 'Password reset successfully! Please log in.',
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> updateProfile(String name, String? avatarUrl) async {
    try {
      final updatedUser = await _repo.updateProfile(name, avatarUrl);
      state = state.copyWith(
        user: updatedUser,
        successMessage: 'Profile updated successfully!',
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      await _repo.changePassword(currentPassword, newPassword);
      state = state.copyWith(
        successMessage: 'Password changed successfully!',
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        errorMessage: msg,
      );
      return false;
    }
  }

  void continueAsDemoUser() {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: const User(
        id: '1',
        name: 'DevTrack Explorer',
        email: 'developer@devtrack.ai',
        avatarUrl: null,
      ),
      token: 'demo-jwt-token',
      refreshToken: 'demo-refresh-token',
    );
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearAuthTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
