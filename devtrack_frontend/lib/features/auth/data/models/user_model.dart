import '../../domain/entities/user.dart';

/// Data layer model for User that adds serialization capability.
/// By extending the domain [User], we keep our business logic
/// insulated from database/API JSON structures.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  /// Factory constructor to parse the JSON response from Spring Boot.
  /// Spring Boot returns fields like 'id', 'username' (which is the user's name), and 'email'.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  /// Converts this [UserModel] back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
    };
  }
}
