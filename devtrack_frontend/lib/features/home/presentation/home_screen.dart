import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final name = authState.user?.name ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevTrack AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, $name 👋',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('What would you like to track today?',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Analytics & Streaks Card
            InkWell(
              onTap: () => context.go('/analytics'),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 24,
                      child: Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Analytics & Streaks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'View status distributions, category progress, and daily streak details.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feature cards grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _FeatureCard(
                    icon: Icons.work_outline,
                    label: 'Internships',
                    subtitle: 'Track applications',
                    color: const Color(0xFF6200EE),
                    onTap: () => context.go('/internships'),
                  ),
                  _FeatureCard(
                    icon: Icons.code,
                    label: 'DSA Tracker',
                    subtitle: 'Track DSA questions',
                    color: Colors.orange,
                    onTap: () => context.go('/dsa'),
                  ),
                  _FeatureCard(
                    icon: Icons.auto_awesome,
                    label: 'AI Resume',
                    subtitle: 'Coming in Phase 4',
                    color: Colors.teal,
                    onTap: () {},
                    disabled: true,
                  ),
                  _FeatureCard(
                    icon: Icons.mic,
                    label: 'Mock Interview',
                    subtitle: 'Coming in Phase 4',
                    color: Colors.pink,
                    onTap: () {},
                    disabled: true,
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  radius: 28,
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
