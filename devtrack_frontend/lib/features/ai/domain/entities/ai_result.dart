/// Domain entity for all AI-generated responses.
class AiResult {
  final String content;
  final int? sessionId;
  final int? historyId;

  const AiResult({
    required this.content,
    this.sessionId,
    this.historyId,
  });
}

class ResumeHistoryItem {
  final int id;
  final String role;
  final String? experience;
  final String? additionalContext;
  final String generatedBullets;
  final String? createdAt;

  const ResumeHistoryItem({
    required this.id,
    required this.role,
    this.experience,
    this.additionalContext,
    required this.generatedBullets,
    this.createdAt,
  });

  factory ResumeHistoryItem.fromJson(Map<String, dynamic> json) {
    return ResumeHistoryItem(
      id: json['id'] as int,
      role: json['role'] as String? ?? 'Role',
      experience: json['experience'] as String?,
      additionalContext: json['additionalContext'] as String?,
      generatedBullets: json['generatedBullets'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }
}

class InterviewSessionItem {
  final int id;
  final String topic;
  final String difficulty;
  final String? createdAt;
  final List<InterviewRoundItem> rounds;

  const InterviewSessionItem({
    required this.id,
    required this.topic,
    required this.difficulty,
    this.createdAt,
    this.rounds = const [],
  });

  factory InterviewSessionItem.fromJson(Map<String, dynamic> json) {
    final rawRounds = json['rounds'] as List<dynamic>? ?? [];
    return InterviewSessionItem(
      id: json['id'] as int,
      topic: json['topic'] as String? ?? 'Interview',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      createdAt: json['createdAt'] as String?,
      rounds: rawRounds
          .map((r) => InterviewRoundItem.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InterviewRoundItem {
  final int? id;
  final int roundNumber;
  final String question;
  final String? userAnswer;
  final String? feedback;
  final String? answeredAt;

  const InterviewRoundItem({
    this.id,
    required this.roundNumber,
    required this.question,
    this.userAnswer,
    this.feedback,
    this.answeredAt,
  });

  factory InterviewRoundItem.fromJson(Map<String, dynamic> json) {
    return InterviewRoundItem(
      id: json['id'] as int?,
      roundNumber: json['roundNumber'] as int? ?? 1,
      question: json['question'] as String? ?? '',
      userAnswer: json['userAnswer'] as String?,
      feedback: json['feedback'] as String?,
      answeredAt: json['answeredAt'] as String?,
    );
  }
}
