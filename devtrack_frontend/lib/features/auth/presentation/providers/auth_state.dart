import '../../domain/entities/user.dart';

/// Enum representing the current status of the authentication flow.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Represents the current state of authentication in the UI.
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? token; // In-memory cache of the JWT token for API requests

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.token,
  });

  /// Helper method to clone the state with modified properties.
  /// This implements the "immutability" pattern, which is standard in Riverpod.
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
    );
  }
}
