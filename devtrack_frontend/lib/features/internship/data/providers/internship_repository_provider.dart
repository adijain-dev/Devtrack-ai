import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/internship_repository.dart';
import '../repositories/internship_repository_impl.dart';
import '../../../../core/network/dio_client.dart'; // provides dioProvider

/// Provides an [InternshipRepository] using the shared Dio instance.
final internshipRepositoryProvider = Provider<InternshipRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InternshipRepositoryImpl(dio);
});
