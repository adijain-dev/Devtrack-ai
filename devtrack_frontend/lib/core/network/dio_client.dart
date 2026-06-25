import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

/// Provider that exposes a configured instance of [Dio] with JWT injection.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Dynamic Base URL:
  // - Android Emulator → 10.0.2.2 maps to host localhost
  // - iOS simulator / Web → localhost works directly
  String baseUrl = 'http://localhost:8080';
  if (!kIsWeb && Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8080';
  }

  dio.options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
    headers: {'Accept': 'application/json'},
  );

  // Interceptor: attach JWT from secure storage to every request
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
