import '../../domain/entities/user.dart';

/// Data layer model for User that adds serialization capability.
/// By extending the domain [User], we keep our business logic
/// insulated from database/API JSON structures.
class UserModel extends User {
  final String? token;
  final String? refreshToken;

  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    this.token,
    this.refreshToken,
  });

  /// Factory constructor to parse the JSON response from Spring Boot.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  /// Converts this [UserModel] back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      if (token != null) 'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}
