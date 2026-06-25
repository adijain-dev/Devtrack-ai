import 'package:dio/dio.dart';
import '../../domain/entities/internship.dart';
import '../../domain/repositories/internship_repository.dart';
import '../models/internship_model.dart';

class InternshipRepositoryImpl implements InternshipRepository {
  final Dio _dio;

  InternshipRepositoryImpl(this._dio);

  @override
  Future<List<Internship>> getAll() async {
    try {
      final response = await _dio.get('/api/internships');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => InternshipModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load internships');
    }
  }

  @override
  Future<Internship> create(Internship internship) async {
    try {
      final response = await _dio.post(
        '/api/internships',
        data: InternshipModel.fromEntity(internship).toJson(),
      );
      return InternshipModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create internship');
    }
  }

  @override
  Future<Internship> update(Internship internship) async {
    try {
      final response = await _dio.put(
        '/api/internships/${internship.id}',
        data: InternshipModel.fromEntity(internship).toJson(),
      );
      return InternshipModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to update internship');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/api/internships/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete internship');
    }
  }
}
