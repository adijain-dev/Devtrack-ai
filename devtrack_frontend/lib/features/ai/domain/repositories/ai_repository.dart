import 'dart:typed_data';
import '../entities/ai_result.dart';

/// Repository that calls all AI-powered backend endpoints.
abstract class AiRepository {
  Future<AiResult> generateResumeBullets({
    required String role,
    required String experience,
    String? additionalContext,
  });

  Future<List<ResumeHistoryItem>> getResumeHistory();

  Future<void> deleteResumeHistory(int id);

  Future<Uint8List> exportResumePdf({
    String? candidateName,
    String? candidateEmail,
    required String role,
    required String experience,
    required String bullets,
  });

  Future<Uint8List> downloadResumeHistoryPdf(int id);

  Future<AiResult> startInterviewSession({
    required String topic,
    required String difficulty,
  });

  Future<AiResult> getInterviewQuestion({
    required String topic,
    required String difficulty,
  });

  Future<AiResult> evaluateAnswer({
    required String topic,
    required String previousQuestion,
    required String userAnswer,
    int? sessionId,
  });

  Future<List<InterviewSessionItem>> getInterviewHistory();

  Future<InterviewSessionItem> getInterviewSession(int id);

  Future<void> deleteInterviewSession(int id);
}
