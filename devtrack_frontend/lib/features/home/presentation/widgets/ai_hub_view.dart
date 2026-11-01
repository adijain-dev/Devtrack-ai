import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'glass_bento_card.dart';

class AiHubView extends ConsumerWidget {
  const AiHubView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI Studio',
          style: AppTheme.inter(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Hub Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E1065),
                    Color(0xFF1E1B4B),
                    AppColors.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.accentLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DevTrack AI Copilot',
                              style: AppTheme.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SUPERCHARGE CAREER PREP',
                              style: AppTheme.mono(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentLight,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Practice technical interviews with real-time speech-to-text evaluation and generate high-impact, ATS-optimized resume bullet points tailored to software engineering roles.',
                    style: AppTheme.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'INTELLIGENT TOOLS',
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            // AI Card 1: Resume Bullet Generator (Glassmorphism)
            GlassBentoCard(
              glowColor: AppColors.accent,
              onTap: () => context.push('/ai/resume'),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: AppColors.accentLight,
                          size: 24,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusGreenBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.statusGreen.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'ATS OPTIMIZER',
                          style: AppTheme.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusGreen,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI Resume Bullets Generator',
                    style: AppTheme.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Turn job roles & experience into quantified, high-impact bullet points with PDF export and action-verb scoring.',
                    style: AppTheme.inter(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Launch Resume Studio',
                        style: AppTheme.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.accentLight,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Card 2: AI Mock Interview (Glassmorphism)
            GlassBentoCard(
              glowColor: const Color(0xFFEC4899),
              onTap: () => context.push('/ai/interview'),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.mic_none_rounded,
                          color: Color(0xFFF472B6),
                          size: 24,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusAmberBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.statusAmber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'VOICE CHAT EVALUATION',
                          style: AppTheme.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusAmber,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI Technical Mock Interview',
                    style: AppTheme.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Simulate DSA & System Design technical interviews. Speak answers with voice dictation and receive instant scorecard evaluations.',
                    style: AppTheme.inter(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Start Voice Interview',
                        style: AppTheme.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF472B6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFF472B6),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
