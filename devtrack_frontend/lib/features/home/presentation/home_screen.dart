import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../dsa/presentation/screens/dsa_screen.dart';
import '../../internship/presentation/screens/internship_list_screen.dart';
import 'widgets/ai_hub_view.dart';
import 'widgets/bento_dashboard_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onSelectTab(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            BentoDashboardView(onSelectTab: _onSelectTab),
            const DsaScreen(),
            const InternshipListScreen(),
            const AiHubView(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.cardBorder,
                width: 1.0,
              ),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.accent.withValues(alpha: 0.22),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return AppTheme.inter(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.accentLight : AppColors.textMuted,
                  );
                },
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: isSelected ? AppColors.accentLight : AppColors.textMuted,
                    size: 22,
                  );
                },
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onSelectTab,
              height: 64,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.accentLight),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.code_rounded),
                  selectedIcon: Icon(Icons.code_rounded, color: AppColors.accentLight),
                  label: 'DSA',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded),
                  selectedIcon: Icon(Icons.business_center_rounded, color: AppColors.accentLight),
                  label: 'Applications',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_rounded),
                  selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.accentLight),
                  label: 'AI Studio',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
