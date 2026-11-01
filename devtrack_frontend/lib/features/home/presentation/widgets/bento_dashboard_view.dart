import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dsa/domain/entities/dsa_topic.dart';
import '../../../dsa/presentation/notifiers/dsa_notifier.dart';
import '../../../internship/domain/entities/internship.dart';
import '../../../internship/presentation/notifiers/internship_notifier.dart';
import '../../../notification/presentation/notifiers/notification_notifier.dart';
import '../../../notification/presentation/widgets/notification_center_sheet.dart';
import 'bento_card.dart';
import 'glass_bento_card.dart';
import 'neumorphic_progress_ring.dart';

class BentoDashboardView extends ConsumerWidget {
  final ValueChanged<int> onSelectTab;

  const BentoDashboardView({
    super.key,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final internshipState = ref.watch(internshipNotifierProvider);
    final dsaState = ref.watch(dsaNotifierProvider);
    final notificationState = ref.watch(notificationNotifierProvider);

    final name = authState.user?.name ?? 'Developer';
    final unreadCount = notificationState.unreadCount;

    // Internship Stats
    final internships = internshipState.internships;
    final totalApps = internships.length;
    final offerCount = internships.where((i) => i.status == InternshipStatus.offer).length;
    final interviewCount = internships.where((i) => i.status == InternshipStatus.interview).length;
    final appliedCount = internships.where((i) => i.status == InternshipStatus.applied).length;
    final rejectedCount = internships.where((i) => i.status == InternshipStatus.rejected).length;

    // DSA Stats
    final solvedCount = dsaState.solvedCount;
    final streak = dsaState.streak;
    final topics = dsaState.topics;
    final totalTopics = topics.isNotEmpty ? topics.length : 1;
    final dsaProgress = (solvedCount / totalTopics).clamp(0.0, 1.0);
    final easySolved = topics.where((t) => t.difficulty == DsaDifficulty.easy && t.isSolved).length;
    final medSolved = topics.where((t) => t.difficulty == DsaDifficulty.medium && t.isSolved).length;
    final hardSolved = topics.where((t) => t.difficulty == DsaDifficulty.hard && t.isSolved).length;

    // Upcoming interview
    final upcomingInterviews = internships
        .where((i) => i.interviewDate != null && i.interviewDate!.isNotEmpty)
        .toList()
      ..sort((a, b) => a.interviewDate!.compareTo(b.interviewDate!));
    final nextInterview = upcomingInterviews.isNotEmpty ? upcomingInterviews.first : null;

    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await Future.wait([
              ref.read(internshipNotifierProvider.notifier).fetchAll(silent: true),
              ref.read(dsaNotifierProvider.notifier).fetchAll(silent: true),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Header Bar ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $name 👋',
                            style: AppTheme.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'DEVTRACK VELOCITY // ACTIVE',
                            style: AppTheme.mono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentLight,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick theme toggle
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: isDark ? 'Light Theme' : 'Dark Theme',
                          onPressed: () {
                            ref.read(themeNotifierProvider.notifier).toggleTheme(!isDark);
                          },
                        ),
                        // Notifications
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                                color: AppColors.textSecondary,
                              ),
                              tooltip: 'Notifications',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const NotificationCenterSheet(),
                                );
                              },
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.statusRed,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: AppTheme.mono(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Profile
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: 'Profile & Settings',
                          onPressed: () => context.push('/profile'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Spaced Repetition Due Alert (if any) ─────────────────────
                if (dsaState.dueRevisionsCount > 0) ...[
                  InkWell(
                    onTap: () => onSelectTab(1),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.statusAmberBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.statusAmber.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.alarm_on_rounded,
                            color: AppColors.statusAmber,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${dsaState.dueRevisionsCount} DSA topics due for spaced repetition today',
                              style: AppTheme.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.statusAmber,
                              ),
                            ),
                          ),
                          Text(
                            'Review →',
                            style: AppTheme.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── BENTO GRID: ROW 1 (DSA & Applications) ───────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DSA Card (Left Bento Card)
                    Expanded(
                      flex: 6,
                      child: BentoCard(
                        onTap: () => onSelectTab(1),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusGreenBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.code_rounded,
                                        color: AppColors.statusGreen,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'DSA',
                                      style: AppTheme.mono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                // Streak flame pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusAmberBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.statusAmber.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🔥', style: TextStyle(fontSize: 11)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${streak}d',
                                        style: AppTheme.mono(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.statusAmber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Solved count + Neumorphic progress ring
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$solvedCount',
                                      style: AppTheme.mono(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'solved / ${topics.length}',
                                      style: AppTheme.inter(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                NeumorphicProgressRing(
                                  progress: dsaProgress,
                                  size: 46,
                                  strokeWidth: 4.5,
                                  progressColor: AppColors.statusGreen,
                                  centerChild: Text(
                                    '${(dsaProgress * 100).toInt()}%',
                                    style: AppTheme.mono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.statusGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Difficulty distribution pills
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _StatusMiniPill(
                                  label: 'E: $easySolved',
                                  color: AppColors.statusGreen,
                                  bgColor: AppColors.statusGreenBg,
                                ),
                                _StatusMiniPill(
                                  label: 'M: $medSolved',
                                  color: AppColors.statusAmber,
                                  bgColor: AppColors.statusAmberBg,
                                ),
                                _StatusMiniPill(
                                  label: 'H: $hardSolved',
                                  color: AppColors.statusRed,
                                  bgColor: AppColors.statusRedBg,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Applications Card (Right Bento Card)
                    Expanded(
                      flex: 5,
                      child: BentoCard(
                        onTap: () => onSelectTab(2),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusBlueBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.work_outline_rounded,
                                        color: AppColors.statusBlue,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'APPS',
                                      style: AppTheme.mono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                if (offerCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.statusGreenBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.statusGreen.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '★ $offerCount',
                                      style: AppTheme.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.statusGreen,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Text(
                              '$totalApps',
                              style: AppTheme.mono(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'total tracked',
                              style: AppTheme.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Status distribution
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _StatusMiniPill(
                                  label: 'Off: $offerCount',
                                  color: AppColors.statusGreen,
                                  bgColor: AppColors.statusGreenBg,
                                ),
                                _StatusMiniPill(
                                  label: 'Int: $interviewCount',
                                  color: AppColors.statusAmber,
                                  bgColor: AppColors.statusAmberBg,
                                ),
                                _StatusMiniPill(
                                  label: 'App: $appliedCount',
                                  color: AppColors.statusBlue,
                                  bgColor: AppColors.statusBlueBg,
                                ),
                                _StatusMiniPill(
                                  label: 'Rej: $rejectedCount',
                                  color: AppColors.statusRed,
                                  bgColor: AppColors.statusRedBg,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Upcoming interview quick banner (if exists)
                if (nextInterview != null) ...[
                  BentoCard(
                    onTap: () => onSelectTab(2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    borderColor: AppColors.statusAmber.withValues(alpha: 0.4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.statusAmberBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_available_rounded,
                            color: AppColors.statusAmber,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming: ${nextInterview.companyName} (${nextInterview.role})',
                                style: AppTheme.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Interview Date: ${nextInterview.interviewDate}',
                                style: AppTheme.mono(
                                  fontSize: 11,
                                  color: AppColors.statusAmber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── BENTO GRID: ROW 2 (Analytics & Velocity Preview) ──────────
                BentoCard(
                  onTap: () => context.push('/analytics'),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.insights_rounded,
                                  color: AppColors.accentLight,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'VELOCITY & CHARTS',
                                style: AppTheme.mono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'View Dashboard',
                                style: AppTheme.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentLight,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.accentLight,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Metrics Row
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'Offer Rate',
                              value: totalApps > 0
                                  ? '${((offerCount / totalApps) * 100).toStringAsFixed(0)}%'
                                  : '0%',
                              color: AppColors.statusGreen,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: AppColors.cardBorder,
                          ),
                          Expanded(
                            child: _MetricTile(
                              label: 'Interview Rate',
                              value: totalApps > 0
                                  ? '${((interviewCount / totalApps) * 100).toStringAsFixed(0)}%'
                                  : '0%',
                              color: AppColors.statusAmber,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: AppColors.cardBorder,
                          ),
                          Expanded(
                            child: _MetricTile(
                              label: 'DSA Progress',
                              value: '${(dsaProgress * 100).toStringAsFixed(0)}%',
                              color: AppColors.accentLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Pipeline balance visual strip
                      if (totalApps > 0)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 6,
                            child: Row(
                              children: [
                                if (offerCount > 0)
                                  Expanded(
                                    flex: offerCount,
                                    child: Container(color: AppColors.statusGreen),
                                  ),
                                if (interviewCount > 0)
                                  Expanded(
                                    flex: interviewCount,
                                    child: Container(color: AppColors.statusAmber),
                                  ),
                                if (appliedCount > 0)
                                  Expanded(
                                    flex: appliedCount,
                                    child: Container(color: AppColors.statusBlue),
                                  ),
                                if (rejectedCount > 0)
                                  Expanded(
                                    flex: rejectedCount,
                                    child: Container(color: AppColors.statusRed),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── BENTO GRID: ROW 3 (The 2 Glass AI Cards as requested) ─────
                // "Glass touch: use light glassmorphism (blur plus a faint gradient border)
                // only on the AI cards, like resume bullets and mock interview, so the AI features feel special."
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Resume Bullets Glass Card
                    Expanded(
                      child: GlassBentoCard(
                        glowColor: AppColors.accent,
                        onTap: () => context.push('/ai/resume'),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.accentLight,
                                    size: 18,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusGreenBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.statusGreen.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'ATS',
                                    style: AppTheme.mono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.statusGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'AI Resume',
                              style: AppTheme.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tailored bullets & PDF export',
                              style: AppTheme.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // AI Mock Interview Glass Card
                    Expanded(
                      child: GlassBentoCard(
                        glowColor: const Color(0xFFEC4899),
                        onTap: () => context.push('/ai/interview'),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEC4899).withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.mic_none_rounded,
                                    color: Color(0xFFF472B6),
                                    size: 18,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusAmberBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.statusAmber.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'VOICE',
                                    style: AppTheme.mono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.statusAmber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Mock Interview',
                              style: AppTheme.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Voice STT & chat scorecard',
                              style: AppTheme.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusMiniPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatusMiniPill({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: AppTheme.mono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppTheme.mono(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
