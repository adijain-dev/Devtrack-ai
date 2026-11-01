import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/ai_repository.dart';
import '../repositories/ai_repository_impl.dart';
import '../../../../core/network/dio_client.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AiRepositoryImpl(dio);
});
