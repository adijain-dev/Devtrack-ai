import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../domain/entities/ai_result.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final Dio _dio;

  AiRepositoryImpl(this._dio);

  @override
  Future<AiResult> generateResumeBullets({
    required String role,
    required String experience,
    String? additionalContext,
  }) async {
    try {
      final response = await _dio.post('/api/ai/resume-bullets', data: {
        'role': role,
        'experience': experience,
        'additionalContext': additionalContext,
      });
      return AiResult(
        content: response.data['content'] as String,
        historyId: response.data['historyId'] as int?,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to generate resume bullets');
    }
  }

  @override
  Future<List<ResumeHistoryItem>> getResumeHistory() async {
    try {
      final response = await _dio.get('/api/ai/resume-history');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => ResumeHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch resume history');
    }
  }

  @override
  Future<void> deleteResumeHistory(int id) async {
    try {
      await _dio.delete('/api/ai/resume-history/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete resume history');
    }
  }

  @override
  Future<Uint8List> exportResumePdf({
    String? candidateName,
    String? candidateEmail,
    required String role,
    required String experience,
    required String bullets,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ai/resume/export-pdf',
        data: {
          'candidateName': candidateName,
          'candidateEmail': candidateEmail,
          'role': role,
          'experience': experience,
          'bullets': bullets,
        },
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to export resume PDF');
    }
  }

  @override
  Future<Uint8List> downloadResumeHistoryPdf(int id) async {
    try {
      final response = await _dio.get(
        '/api/ai/resume-history/$id/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to download resume PDF');
    }
  }

  @override
  Future<AiResult> startInterviewSession({
    required String topic,
    required String difficulty,
  }) async {
    try {
      final response = await _dio.post('/api/ai/interview/start', data: {
        'topic': topic,
        'difficulty': difficulty,
      });
      return AiResult(
        content: response.data['content'] as String,
        sessionId: response.data['sessionId'] as int?,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to start interview session');
    }
  }

  @override
  Future<AiResult> getInterviewQuestion({
    required String topic,
    required String difficulty,
  }) async {
    try {
      final response = await _dio.post('/api/ai/interview/question', data: {
        'topic': topic,
        'difficulty': difficulty,
      });
      return AiResult(content: response.data['content'] as String);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to get interview question');
    }
  }

  @override
  Future<AiResult> evaluateAnswer({
    required String topic,
    required String previousQuestion,
    required String userAnswer,
    int? sessionId,
  }) async {
    try {
      final response = await _dio.post('/api/ai/interview/evaluate', data: {
        'topic': topic,
        'previousQuestion': previousQuestion,
        'userAnswer': userAnswer,
        'sessionId': ?sessionId,
      });
      return AiResult(
        content: response.data['content'] as String,
        sessionId: response.data['sessionId'] as int?,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to evaluate answer');
    }
  }

  @override
  Future<List<InterviewSessionItem>> getInterviewHistory() async {
    try {
      final response = await _dio.get('/api/ai/interview-history');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => InterviewSessionItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch interview history');
    }
  }

  @override
  Future<InterviewSessionItem> getInterviewSession(int id) async {
    try {
      final response = await _dio.get('/api/ai/interview-history/$id');
      return InterviewSessionItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch interview session');
    }
  }

  @override
  Future<void> deleteInterviewSession(int id) async {
    try {
      await _dio.delete('/api/ai/interview-history/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete interview session');
    }
  }
}
