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
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response == null) {
        throw Exception(
          'Cannot connect to backend server. Please ensure the backend is running on port 8080.',
        );
      }
      throw Exception('Server error (${e.response?.statusCode}). Please check your server.');
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
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response == null) {
        throw Exception(
          'Cannot connect to backend server. Please ensure the backend is running on port 8080.',
        );
      }
      throw Exception('Server error (${e.response?.statusCode}). Please check your server.');
    } catch (e) {
      throw Exception('An unexpected error occurred during registration.');
    }
  }

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/api/auth/refreshtoken',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return {
          'accessToken': data['accessToken']?.toString() ?? '',
          'refreshToken': data['refreshToken']?.toString() ?? refreshToken,
        };
      }
      throw Exception('Failed to refresh token');
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      throw Exception(msg ?? 'Session expired. Please log in again.');
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['message']?.toString() ?? 'Reset code sent.';
      }
      return 'Reset instructions sent.';
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      throw Exception(msg ?? 'Failed to send reset code. Please try again.');
    }
  }

  @override
  Future<void> resetPassword(String email, String resetCode, String newPassword) async {
    try {
      final response = await _dio.post(
        '/api/auth/reset-password',
        data: {
          'email': email,
          'resetCode': resetCode,
          'newPassword': newPassword,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      throw Exception(msg ?? 'Invalid or expired reset code.');
    }
  }

  @override
  Future<User> updateProfile(String name, String? avatarUrl) async {
    try {
      final response = await _dio.put(
        '/api/auth/profile',
        data: {
          'name': name,
          'avatarUrl': ?avatarUrl,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      throw Exception(msg ?? 'Failed to update profile.');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _dio.put(
        '/api/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      throw Exception(msg ?? 'Current password is incorrect.');
    }
  }
}
