import 'package:dio/dio.dart';
import '../../domain/entities/dsa_topic.dart';
import '../../domain/repositories/dsa_repository.dart';
import '../models/dsa_topic_model.dart';

class DsaRepositoryImpl implements DsaRepository {
  final Dio _dio;

  DsaRepositoryImpl(this._dio);

  @override
  Future<List<DsaTopic>> getAll() async {
    try {
      final response = await _dio.get('/api/dsa');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => DsaTopicModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load DSA topics: ${response.statusCode}');
    } on DioException catch (e) {
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
}
