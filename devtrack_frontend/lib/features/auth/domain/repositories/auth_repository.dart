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
}
