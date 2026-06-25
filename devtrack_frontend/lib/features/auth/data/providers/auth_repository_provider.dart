import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';

/// Base URL of the Spring Boot backend (approved).
const _baseUrl = 'http://10.0.2.2:8080';

/// Provides a configured Dio instance.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  // You can add interceptors, logging, timeout settings here.
  return dio;
});

/// Exposes an AuthRepository implementation that uses Dio.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepositoryImpl(dio);
});
