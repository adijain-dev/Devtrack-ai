import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Implementation of the [AuthRepository] interface.
/// Communicates with the Spring Boot backend using the [Dio] client.
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Status code 200 represents success
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // We will receive a JWT in data['token']
        // For now we will return the user, and we'll handle token storage in state management.
        return UserModel.fromJson(data);
      } else {
        throw Exception('Server returned an unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Custom handling for Dio network exceptions
      final errorMessage = e.response?.data['message'] ?? 'Failed to log in. Please check your connection.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned an unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to register. Please check your credentials.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred during registration.');
    }
  }
}
