import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

/// Provider that exposes a configured instance of [Dio] with JWT injection.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Base URL:
  // - Defaults to localhost:8080 (works for Desktop, Web, and physical Android phone via 'adb reverse')
  // - Automatically falls back to 10.0.2.2:8080 if running inside an Android Emulator
  String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');

  dio.options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 5),
    contentType: 'application/json',
    headers: {'Accept': 'application/json'},
  );

  // Interceptor: attach JWT from secure storage to every request & handle emulator fallback
  final storage = ref.read(secureStorageProvider);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException err, handler) async {
        // Handle 401 Unauthorized by refreshing token
        if (err.response?.statusCode == 401 &&
            !err.requestOptions.path.contains('/api/auth/login') &&
            !err.requestOptions.path.contains('/api/auth/refreshtoken')) {
          final refreshToken = await storage.readRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
              final refreshResponse = await refreshDio.post(
                '/api/auth/refreshtoken',
                data: {'refreshToken': refreshToken},
              );
              if (refreshResponse.statusCode == 200 && refreshResponse.data is Map) {
                final newAccessToken = refreshResponse.data['accessToken']?.toString();
                final newRefreshToken =
                    refreshResponse.data['refreshToken']?.toString() ?? refreshToken;
                if (newAccessToken != null && newAccessToken.isNotEmpty) {
                  await storage.saveToken(newAccessToken);
                  await storage.saveRefreshToken(newRefreshToken);

                  // Retry the original request with new token
                  final retryOptions = err.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final response = await dio.fetch(retryOptions);
                  return handler.resolve(response);
                }
              }
            } catch (_) {
              await storage.clearAuthTokens();
            }
          }
        }

        if (!kIsWeb &&
            Platform.isAndroid &&
            err.type == DioExceptionType.connectionError &&
            err.requestOptions.baseUrl.contains('localhost')) {
          // If localhost failed on Android, retry with 10.0.2.2 (in case running inside an emulator)
          final retryOptions = err.requestOptions;
          retryOptions.baseUrl = 'http://10.0.2.2:8080';
          try {
            final response = await dio.fetch(retryOptions);
            return handler.resolve(response);
          } catch (_) {
            return handler.next(err);
          }
        }
        return handler.next(err);
      },
    ),
  );

  // Debug logging
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
    ));
  }

  return dio;
});
