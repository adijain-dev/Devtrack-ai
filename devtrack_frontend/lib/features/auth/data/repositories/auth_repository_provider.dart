import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_repository_impl.dart';

/// Riverpod provider for the [AuthRepository] interface.
/// UI and State layers should depend on the interface (AuthRepository)
/// rather than the implementation (AuthRepositoryImpl) to remain loosely coupled.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepositoryImpl(dio);
});
