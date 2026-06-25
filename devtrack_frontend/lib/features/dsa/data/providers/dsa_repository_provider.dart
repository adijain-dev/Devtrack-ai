import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/dsa_repository.dart';
import '../repositories/dsa_repository_impl.dart';

/// Riverpod provider for [DsaRepository].
final dsaRepositoryProvider = Provider<DsaRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DsaRepositoryImpl(dio);
});
