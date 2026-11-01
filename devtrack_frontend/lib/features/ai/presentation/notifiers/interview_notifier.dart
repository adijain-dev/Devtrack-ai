import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/ai_repository_provider.dart';
import '../../domain/entities/ai_result.dart';

/// Represents one round in the mock interview.
class InterviewRound {
  final int? id;
  final String question;
  final String? userAnswer;
  final String? feedback;

  const InterviewRound({
    this.id,
    required this.question,
    this.userAnswer,
    this.feedback,
  });

  InterviewRound copyWith({String? userAnswer, String? feedback}) =>
      InterviewRound(
        id: id,
        question: question,
        userAnswer: userAnswer ?? this.userAnswer,
        feedback: feedback ?? this.feedback,
      );
}

/// Full state of the mock interview session.
class InterviewState {
  final int? sessionId;
  final String? topic;
  final String difficulty;
  final List<InterviewRound> rounds;
  final bool isLoadingQuestion;
  final bool isLoadingFeedback;
  final String? error;
  final bool sessionStarted;
  final bool isHistoryView;

  const InterviewState({
    this.sessionId,
    this.topic,
    this.difficulty = 'Medium',
    this.rounds = const [],
    this.isLoadingQuestion = false,
    this.isLoadingFeedback = false,
    this.error,
    this.sessionStarted = false,
    this.isHistoryView = false,
  });

  /// The current round index (latest round).
  int get currentRoundIndex => rounds.isEmpty ? -1 : rounds.length - 1;

  /// Current question (from the latest round).
  InterviewRound? get currentRound =>
      rounds.isEmpty ? null : rounds.last;

  InterviewState copyWith({
    int? sessionId,
    String? topic,
    String? difficulty,
    List<InterviewRound>? rounds,
    bool? isLoadingQuestion,
    bool? isLoadingFeedback,
    String? error,
    bool clearError = false,
    bool? sessionStarted,
    bool? isHistoryView,
  }) {
    return InterviewState(
      sessionId: sessionId ?? this.sessionId,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      rounds: rounds ?? this.rounds,
      isLoadingQuestion: isLoadingQuestion ?? this.isLoadingQuestion,
      isLoadingFeedback: isLoadingFeedback ?? this.isLoadingFeedback,
      error: clearError ? null : (error ?? this.error),
      sessionStarted: sessionStarted ?? this.sessionStarted,
      isHistoryView: isHistoryView ?? this.isHistoryView,
    );
  }
}

/// Notifier managing the full interview session lifecycle with DB persistence.
class InterviewNotifier extends Notifier<InterviewState> {
  @override
  InterviewState build() => const InterviewState();

  void setTopic(String topic) =>
      state = state.copyWith(topic: topic);

  void setDifficulty(String difficulty) =>
      state = state.copyWith(difficulty: difficulty);

  /// Start a new session: persists session to DB and fetches first question.
  Future<void> startSession() async {
    if (state.topic == null || state.topic!.isEmpty) return;
    state = state.copyWith(
      sessionStarted: true,
      isHistoryView: false,
      rounds: [],
      isLoadingQuestion: true,
      clearError: true,
    );

    try {
      final repo = ref.read(aiRepositoryProvider);
      final result = await repo.startInterviewSession(
        topic: state.topic!,
        difficulty: state.difficulty,
      );

      final firstRound = InterviewRound(question: result.content);
      state = state.copyWith(
        sessionId: result.sessionId,
        rounds: [firstRound],
        isLoadingQuestion: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuestion: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Fetch next interview question from AI.
  Future<void> _fetchNextQuestion() async {
    state = state.copyWith(isLoadingQuestion: true, clearError: true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      final result = await repo.getInterviewQuestion(
        topic: state.topic!,
        difficulty: state.difficulty,
      );
      final newRound = InterviewRound(question: result.content);
      state = state.copyWith(
        rounds: [...state.rounds, newRound],
        isLoadingQuestion: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuestion: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Submit user's answer and fetch AI feedback, auto-persisting to DB session.
  Future<void> submitAnswer(String answer) async {
    if (state.currentRound == null) return;
    // Update the current round with the user's answer
    final updatedRounds = [...state.rounds];
    updatedRounds[updatedRounds.length - 1] =
        state.currentRound!.copyWith(userAnswer: answer);
    state = state.copyWith(
      rounds: updatedRounds,
      isLoadingFeedback: true,
      clearError: true,
    );

    try {
      final repo = ref.read(aiRepositoryProvider);
      final result = await repo.evaluateAnswer(
        topic: state.topic!,
        previousQuestion: state.currentRound!.question,
        userAnswer: answer,
        sessionId: state.sessionId,
      );
      final finalRounds = [...state.rounds];
      finalRounds[finalRounds.length - 1] =
          finalRounds.last.copyWith(feedback: result.content);
      state = state.copyWith(
        rounds: finalRounds,
        isLoadingFeedback: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFeedback: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Load a past session from DB history.
  void loadPastSession(InterviewSessionItem session) {
    state = InterviewState(
      sessionId: session.id,
      topic: session.topic,
      difficulty: session.difficulty,
      sessionStarted: true,
      isHistoryView: true,
      rounds: session.rounds.map((r) => InterviewRound(
        id: r.id,
        question: r.question,
        userAnswer: r.userAnswer,
        feedback: r.feedback,
      )).toList(),
    );
  }

  /// Move to the next question.
  Future<void> nextQuestion() => _fetchNextQuestion();

  /// Reset the interview session.
  void reset() => state = const InterviewState();
}

final interviewNotifierProvider =
    NotifierProvider<InterviewNotifier, InterviewState>(InterviewNotifier.new);
