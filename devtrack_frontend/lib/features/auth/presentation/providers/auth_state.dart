import '../../domain/entities/user.dart';

/// Enum representing the current status of the authentication flow.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Represents the current state of authentication in the UI.
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? successMessage;
  final String? token; // In-memory cache of the JWT token
  final String? refreshToken;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.token,
    this.refreshToken,
  });

  /// Helper method to clone the state with modified properties.
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? successMessage,
    String? token,
    String? refreshToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
