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
    // Check authentication status asynchronously on initialization.
    Future.microtask(() => checkAuth());
    return const AuthState();
  }

  Future<void> checkAuth() async {
    try {
      final token = await ref.read(secureStorageProvider).readToken();
      if (token != null) {
        // In a production app, we would also validate the token with a profile call.
        // For now, we restore the authenticated status with the token cached in state.
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final User user = await _repo.login(email, password);
      // If the concrete user model contains a token, extract it via dynamic cast.
      String? token;
      try {
        token = (user as dynamic).token as String?;
      } catch (_) {}

      if (token != null) {
        await ref.read(secureStorageProvider).saveToken(token);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repo.register(name, email, password);
      // After successful registration, log the user in automatically.
      await login(email, password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
