import 'package:dio/dio.dart';
import '../../domain/entities/dsa_topic.dart';
import '../../domain/repositories/dsa_repository.dart';
import '../models/dsa_topic_model.dart';

import '../../../../core/storage/offline_cache_service.dart';

class DsaRepositoryImpl implements DsaRepository {
  final Dio _dio;

  DsaRepositoryImpl(this._dio);

  @override
  Future<List<DsaTopic>> getAll() async {
    try {
      final response = await _dio.get('/api/dsa');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final list = data
            .map((json) => DsaTopicModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await OfflineCacheService().cacheDsaTopics(list);
        return list;
      }
      throw Exception('Failed to load DSA topics: ${response.statusCode}');
    } on DioException catch (e) {
      final cached = await OfflineCacheService().getCachedDsaTopics();
      if (cached.isNotEmpty) return cached;
      throw Exception(e.message ?? 'Network error fetching DSA topics');
    }
  }

  @override
  Future<DsaTopic> create(DsaTopic topic) async {
    try {
      final response = await _dio.post(
        '/api/dsa',
        data: DsaTopicModel.fromEntity(topic).toJson(),
      );
      if (response.statusCode == 201) {
        return DsaTopicModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create DSA topic: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error creating DSA topic');
    }
  }

  @override
  Future<DsaTopic> update(DsaTopic topic) async {
    try {
      final response = await _dio.put(
        '/api/dsa/${topic.id}',
        data: DsaTopicModel.fromEntity(topic).toJson(),
      );
      if (response.statusCode == 200) {
        return DsaTopicModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update DSA topic: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error updating DSA topic');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final response = await _dio.delete('/api/dsa/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete DSA topic: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error deleting DSA topic');
    }
  }

  @override
  Future<List<DsaTopic>> getTopicsDueForRevision() async {
    try {
      final response = await _dio.get('/api/dsa/revisions');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => DsaTopicModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load revision topics: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error fetching revision topics');
    }
  }

  @override
  Future<DsaTopic> reviewTopic(String id) async {
    try {
      final response = await _dio.post('/api/dsa/$id/review');
      if (response.statusCode == 200) {
        return DsaTopicModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to review DSA topic: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error reviewing DSA topic');
    }
  }

  @override
  Future<Map<String, dynamic>> syncProfile({
    required String platform,
    required String username,
    bool importProblems = true,
  }) async {
    try {
      final response = await _dio.post(
        '/api/dsa/sync',
        data: {
          'platform': platform,
          'username': username,
          'importProblems': importProblems,
        },
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to sync profile: ${response.statusCode}');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error syncing profile';
      throw Exception(msg);
    }
  }
}
