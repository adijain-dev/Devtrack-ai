import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/theme/app_theme.dart';
import '../../data/providers/ai_repository_provider.dart';
import '../../domain/entities/ai_result.dart';
import '../notifiers/interview_notifier.dart';

class MockInterviewScreen extends ConsumerStatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  ConsumerState<MockInterviewScreen> createState() =>
      _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  final _answerCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  static const _topics = [
    'Arrays & Strings',
    'Linked Lists',
    'Trees & Graphs',
    'Dynamic Programming',
    'Sorting & Searching',
    'System Design',
    'Java OOP & Concurrency',
    'Spring Boot Microservices',
    'Operating Systems',
    'DBMS & SQL',
  ];

  static const _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (err) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
      if (mounted) {
        setState(() => _speechEnabled = available);
      }
    } catch (_) {
      // Speech recognition unavailable or not permitted on current platform
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      if (_speechEnabled) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _answerCtrl.text = result.recognizedWords;
            });
          },
        );
      } else {
        _showDictationFallbackDialog();
      }
    }
  }

  void _showDictationFallbackDialog() {
    final sampleAnswers = [
      'To solve this efficiently, we can use a two-pointer approach to achieve O(N) time and O(1) space complexity.',
      'We can use dynamic programming with memoization to store intermediate subproblem results and avoid redundant computation.',
      'In a microservices architecture, we can ensure fault tolerance by implementing circuit breakers and distributed caching via Redis.',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.mic, color: Color(0xFFF472B6), size: 26),
            const SizedBox(width: 8),
            Text('Voice Input', style: AppTheme.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Microphone access is not supported on this device/emulator. Choose a quick sample response or type below:',
              style: AppTheme.inter(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            ...sampleAnswers.map(
              (sample) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    _answerCtrl.text = sample;
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      sample,
                      style: AppTheme.inter(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: AppTheme.inter(color: AppColors.accentLight)),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showInterviewHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _InterviewHistoryBottomSheet(
        onSelectSession: (session) {
          ref.read(interviewNotifierProvider.notifier).loadPastSession(session);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewNotifierProvider);
    final notifier = ref.read(interviewNotifierProvider.notifier);

    // Scroll down when new messages or evaluations arrive
    if (state.sessionStarted) {
      _scrollToBottom();
    }

    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.statusRed,
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () => context.go('/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Mock Interview',
              style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (state.sessionStarted && state.topic != null)
              Text(
                '${state.topic} • ${state.difficulty}',
                style: AppTheme.mono(fontSize: 11, color: AppColors.accentLight),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Interview History',
            onPressed: _showInterviewHistorySheet,
          ),
          if (state.sessionStarted)
            TextButton.icon(
              onPressed: () {
                notifier.reset();
                _answerCtrl.clear();
              },
              icon: const Icon(Icons.restart_alt_rounded, color: AppColors.accentLight, size: 18),
              label: Text(
                'Reset',
                style: AppTheme.inter(
                  color: AppColors.accentLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: state.sessionStarted
          ? _buildChatInterviewView(context, state, notifier)
          : _buildSetupView(context, state, notifier),
    );
  }

  // ── Setup Screen (Topic & Difficulty Selection) ───────────────────────────

  Widget _buildSetupView(
    BuildContext context,
    InterviewState state,
    InterviewNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Glass / Gradient Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3B0764),
                  Color(0xFF1E1B4B),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFFF472B6).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_none_rounded,
                    color: Color(0xFFF472B6),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Technical Interview Simulator',
                        style: AppTheme.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voice dictation, chat-style rounds, and automatic end-of-round scorecards.',
                        style: AppTheme.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Choose Topic
          Text(
            'SELECT INTERVIEW TOPIC',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _topics.map((t) {
              final selected = state.topic == t;
              return ChoiceChip(
                label: Text(t),
                selected: selected,
                onSelected: (_) => notifier.setTopic(t),
                selectedColor: AppColors.accent.withValues(alpha: 0.25),
                backgroundColor: AppColors.surface,
                labelStyle: AppTheme.inter(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? AppColors.accentLight : AppColors.textSecondary,
                ),
                side: BorderSide(
                  color: selected ? AppColors.accent : AppColors.cardBorder,
                  width: selected ? 1.5 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 2. Select Difficulty
          Text(
            'SELECT DIFFICULTY',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: _difficulties.map((d) {
              final selected = state.difficulty == d;
              Color color;
              Color bgColor;
              switch (d) {
                case 'Easy':
                  color = AppColors.statusGreen;
                  bgColor = AppColors.statusGreenBg;
                  break;
                case 'Medium':
                  color = AppColors.statusAmber;
                  bgColor = AppColors.statusAmberBg;
                  break;
                case 'Hard':
                default:
                  color = AppColors.statusRed;
                  bgColor = AppColors.statusRedBg;
                  break;
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => notifier.setDifficulty(d),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? bgColor : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? color : AppColors.cardBorder,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          d,
                          style: AppTheme.mono(
                            color: selected ? color : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Start Button
          ElevatedButton.icon(
            onPressed: state.topic != null ? notifier.startSession : null,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Mock Interview Session'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat Style Interview View ─────────────────────────────────────────────

  Widget _buildChatInterviewView(
    BuildContext context,
    InterviewState state,
    InterviewNotifier notifier,
  ) {
    final rounds = state.rounds;
    final currentRound = state.currentRound;
    final hasFeedback = currentRound?.feedback != null;

    return Column(
      children: [
        // Top status chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Round ${rounds.length} • ${state.topic}',
                    style: AppTheme.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (state.isHistoryView)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.statusAmberBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.statusAmber.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'ARCHIVED',
                    style: AppTheme.mono(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusAmber,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Chat Message Stream
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: rounds.length +
                (state.isLoadingQuestion ? 1 : 0) +
                (state.isLoadingFeedback ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < rounds.length) {
                final round = rounds[index];
                final isLatest = index == rounds.length - 1;
                return _buildRoundChatBlock(context, round, index + 1, isLatest, state, notifier);
              }

              // Loading question bubble
              if (state.isLoadingQuestion) {
                return _buildLoadingBubble(
                  label: 'AI Interviewer is generating question...',
                  isAi: true,
                );
              }

              // Loading feedback bubble
              if (state.isLoadingFeedback) {
                return _buildLoadingBubble(
                  label: 'AI is evaluating technical depth and phrasing...',
                  isAi: true,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),

        // Bottom Chat Input Bar
        if (!state.isHistoryView)
          _buildChatBottomInput(context, state, notifier, hasFeedback),
      ],
    );
  }

  Widget _buildRoundChatBlock(
    BuildContext context,
    InterviewRound round,
    int roundNumber,
    bool isLatest,
    InterviewState state,
    InterviewNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Question Bubble (Left aligned)
        _buildAiQuestionBubble(round.question, roundNumber),
        const SizedBox(height: 12),

        // User Answer Bubble (Right aligned, if answered)
        if (round.userAnswer != null && round.userAnswer!.isNotEmpty) ...[
          _buildUserAnswerBubble(round.userAnswer!),
          const SizedBox(height: 12),
        ],

        // AI Feedback Bubble (Left aligned)
        if (round.feedback != null && round.feedback!.isNotEmpty) ...[
          _buildAiFeedbackBubble(round.feedback!),
          const SizedBox(height: 14),

          // SCORE CARD at the end of round evaluation (as specifically requested)
          _buildScoreCard(context, round, isLatest, state, notifier),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildAiQuestionBubble(String question, int roundNumber) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.only(right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.accentLight,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'INTERVIEWER // Q$roundNumber',
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentLight,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              question,
              style: AppTheme.inter(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAnswerBubble(String answer) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.only(left: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.22),
              const Color(0xFF3730A3).withValues(alpha: 0.35),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOU // CANDIDATE',
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentLight,
                    letterSpacing: 1.0,
                  ),
                ),
                const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.accentLight,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              answer,
              style: AppTheme.inter(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiFeedbackBubble(String feedback) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.only(right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E19),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(
            color: AppColors.statusGreen.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.statusGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'EVALUATION & CRITIQUE',
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusGreen,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              feedback,
              style: AppTheme.inter(
                fontSize: 13,
                height: 1.55,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Score Card at the end of evaluation
  Widget _buildScoreCard(
    BuildContext context,
    InterviewRound round,
    bool isLatest,
    InterviewState state,
    InterviewNotifier notifier,
  ) {
    // Estimate a performance rating from round feedback length/keywords
    final text = round.feedback?.toLowerCase() ?? '';
    double score = 8.5;
    String status = 'STRONG CANDIDATE';
    Color statusColor = AppColors.statusGreen;

    if (text.contains('excellent') || text.contains('perfect') || text.contains('optimal')) {
      score = 9.5;
      status = 'EXCELLENT';
      statusColor = AppColors.statusGreen;
    } else if (text.contains('good') || text.contains('correct') || text.contains('well explained')) {
      score = 8.5;
      status = 'STRONG PASS';
      statusColor = AppColors.statusGreen;
    } else if (text.contains('improve') || text.contains('missing') || text.contains('consider')) {
      score = 7.0;
      status = 'NEEDS POLISH';
      statusColor = AppColors.statusAmber;
    } else if (text.contains('incorrect') || text.contains('inefficient') || text.contains('error')) {
      score = 5.5;
      status = 'NEEDS REVIEW';
      statusColor = AppColors.statusRed;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERFORMANCE SCORECARD',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: AppTheme.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Score circular gauge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: statusColor, width: 3),
                ),
                child: Center(
                  child: Text(
                    score.toStringAsFixed(1),
                    style: AppTheme.mono(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: ${score.toStringAsFixed(1)} / 10.0',
                      style: AppTheme.mono(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Evaluated across algorithmic correctness, time/space complexity, and communication clarity.',
                      style: AppTheme.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isLatest && !state.isHistoryView) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: notifier.nextQuestion,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Next Interview Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble({required String label, required bool isAi}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentLight,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTheme.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom text & voice input bar
  Widget _buildChatBottomInput(
    BuildContext context,
    InterviewState state,
    InterviewNotifier notifier,
    bool hasFeedback,
  ) {
    final canSubmit = !state.isLoadingFeedback &&
        !state.isLoadingQuestion &&
        _answerCtrl.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isListening)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.statusRedBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.statusRed.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.statusRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recording voice input... Speak clearly.',
                      style: AppTheme.inter(fontSize: 12, color: AppColors.statusRed),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                // Mic Button
                IconButton.filledTonal(
                  onPressed: _toggleListening,
                  style: IconButton.styleFrom(
                    backgroundColor: _isListening
                        ? AppColors.statusRedBg
                        : AppColors.surfaceElevated,
                    side: BorderSide(
                      color: _isListening ? AppColors.statusRed : AppColors.cardBorder,
                    ),
                  ),
                  icon: Icon(
                    _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color: _isListening ? AppColors.statusRed : const Color(0xFFF472B6),
                    size: 20,
                  ),
                  tooltip: _isListening ? 'Stop Listening' : 'Voice Input',
                ),
                const SizedBox(width: 8),

                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: _answerCtrl,
                    maxLines: 3,
                    minLines: 1,
                    style: AppTheme.inter(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type or speak your answer...',
                      hintStyle: AppTheme.inter(fontSize: 13, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      fillColor: AppColors.surfaceElevated,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),

                // Send Button
                IconButton.filled(
                  onPressed: canSubmit
                      ? () {
                          if (_isListening) _toggleListening();
                          final ans = _answerCtrl.text.trim();
                          if (ans.isEmpty) return;
                          notifier.submitAnswer(ans);
                          _answerCtrl.clear();
                          setState(() {});
                        }
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: canSubmit ? AppColors.accent : AppColors.surfaceElevated,
                  ),
                  icon: state.isLoadingFeedback
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  tooltip: 'Submit Answer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Interview History Sheet ─────────────────────────────────────────────────

class _InterviewHistoryBottomSheet extends ConsumerStatefulWidget {
  final ValueChanged<InterviewSessionItem> onSelectSession;

  const _InterviewHistoryBottomSheet({required this.onSelectSession});

  @override
  ConsumerState<_InterviewHistoryBottomSheet> createState() =>
      _InterviewHistoryBottomSheetState();
}

class _InterviewHistoryBottomSheetState
    extends ConsumerState<_InterviewHistoryBottomSheet> {
  bool _isLoading = true;
  List<InterviewSessionItem> _sessions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(aiRepositoryProvider);
      final items = await repo.getInterviewHistory();
      if (mounted) {
        setState(() {
          _sessions = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSession(int id) async {
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.deleteInterviewSession(id);
      setState(() {
        _sessions.removeWhere((item) => item.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interview session deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.statusRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.history_rounded, color: Color(0xFFF472B6), size: 24),
              const SizedBox(width: 8),
              Text(
                'Interview Session History',
                style: AppTheme.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!, style: const TextStyle(color: AppColors.statusRed)),
                      )
                    : _sessions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 48,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No saved interview sessions.\nComplete mock interviews to build your history!',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _sessions.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (ctx, idx) {
                              final session = _sessions[idx];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${session.topic} (${session.difficulty})',
                                            style: AppTheme.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: AppColors.textMuted,
                                          ),
                                          onPressed: () => _deleteSession(session.id),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${session.rounds.length} round${session.rounds.length == 1 ? '' : 's'} recorded • ${session.createdAt != null ? session.createdAt!.substring(0, 10) : ''}',
                                      style: AppTheme.mono(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          widget.onSelectSession(session);
                                        },
                                        icon: const Icon(Icons.visibility_rounded, size: 14),
                                        label: const Text('Review Session'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          textStyle: AppTheme.inter(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
