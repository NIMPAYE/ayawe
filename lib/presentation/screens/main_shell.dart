import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    StatsScreen(),
    BudgetsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      floatingActionButton: _CenterFAB(onTap: () => _showAddSheet(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(40),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: FontAwesomeIcons.house,
                label: 'Home',
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavItem(
                icon: FontAwesomeIcons.chartPie,
                label: 'Stats',
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              const Spacer(),
              _NavItem(
                icon: FontAwesomeIcons.bullseye,
                label: 'Budgets',
                isSelected: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _NavItem(
                icon: FontAwesomeIcons.user,
                label: 'Profil',
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _showAddSheet(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: ext.textTertiary.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Ajouter',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AddOption(
                    icon: FontAwesomeIcons.arrowRightArrowLeft,
                    label: 'Transaction',
                    color: AppColors.income,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/add_transaction');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AddOption(
                    icon: FontAwesomeIcons.wallet,
                    label: 'Compte',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/add_account');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AddOption(
                    icon: FontAwesomeIcons.tags,
                    label: 'Catégorie',
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.pop(ctx);
                      // TODO: Navigate to add category
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AddOption(
                    icon: FontAwesomeIcons.flag,
                    label: 'Objectif',
                    color: AppColors.expense,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/goals');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Center FAB ───────────────

class _CenterFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

// ─────────────── Nav Item ───────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withAlpha(25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Add Option Card ───────────────

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
