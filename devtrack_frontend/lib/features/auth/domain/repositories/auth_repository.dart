import '../entities/user.dart';

/// Abstract interface contract defining authentication actions.
/// Following Clean Architecture, the domain layer does not care about *how*
/// we fetch data (SQL, REST, Firebase), only *what* operations are possible.
abstract class AuthRepository {
  /// Authenticates user with [email] and [password].
  /// Returns the logged in [User].
  Future<User> login(String email, String password);

  /// Registers a new user account with [name], [email], and [password].
  Future<void> register(String name, String email, String password);

  /// Refreshes the access token using [refreshToken].
  /// Returns map with 'accessToken' and 'refreshToken'.
  Future<Map<String, String>> refreshToken(String refreshToken);

  /// Requests a password reset code for [email].
  Future<String> forgotPassword(String email);

  /// Resets user password using [email], [resetCode], and [newPassword].
  Future<void> resetPassword(String email, String resetCode, String newPassword);

  /// Updates profile details [name] and optional [avatarUrl].
  Future<User> updateProfile(String name, String? avatarUrl);

  /// Changes the user password given [currentPassword] and [newPassword].
  Future<void> changePassword(String currentPassword, String newPassword);
}
