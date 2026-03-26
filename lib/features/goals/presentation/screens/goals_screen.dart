import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_contribution.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../../presentation/providers/main_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Objectifs',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          final goals = provider.goals;

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: ext.textTertiary.withAlpha(100),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aucun objectif',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ext.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Définissez un objectif d\'épargne',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.textTertiary.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(context),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Créer un objectif'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCard(provider: provider),
                const SizedBox(height: 24),
                if (provider.activeGoals.isNotEmpty) ...[
                  _SectionLabel('En cours'),
                  const SizedBox(height: 12),
                  ...provider.activeGoals.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(goal: g),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (provider.achievedGoals.isNotEmpty) ...[
                  _SectionLabel('Atteints'),
                  const SizedBox(height: 12),
                  ...provider.achievedGoals.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(goal: g),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (provider.overdueGoals.isNotEmpty) ...[
                  _SectionLabel('En retard'),
                  const SizedBox(height: 12),
                  ...provider.overdueGoals.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(goal: g),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Objectif'),
      ),
    );
  }

  void _showForm(BuildContext context, {Goal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalFormSheet(goal: goal),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SUMMARY
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SummaryCard extends StatelessWidget {
  final GoalProvider provider;
  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');
    final progress =
        provider.totalTarget > 0 ? provider.totalSaved / provider.totalTarget : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: ext.balanceGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression globale',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${provider.goals.length} objectif${provider.goals.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${fmt.format(provider.totalSaved)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'sur ${fmt.format(provider.totalTarget)} épargné',
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).clamp(0, 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  GOAL CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');

    Color accent;
    IconData statusIcon;
    if (goal.isAchieved) {
      accent = ext.income;
      statusIcon = Icons.check_circle_rounded;
    } else if (goal.isOverdue) {
      accent = ext.expense;
      statusIcon = Icons.warning_rounded;
    } else {
      accent = Color(goal.color);
      statusIcon = Icons.flag_rounded;
    }

    final hasImage = goal.imagePath != null && File(goal.imagePath!).existsSync();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(context),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(6)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(10) : ext.border,
            ),
          ),
          child: hasImage
              ? _buildImageCard(context, theme, ext, isDark, fmt, accent)
              : _buildIconCard(context, theme, ext, isDark, fmt, accent, statusIcon),
        ),
      ),
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    ThemeData theme,
    AppThemeExtension ext,
    bool isDark,
    NumberFormat fmt,
    Color accent,
  ) {
    return Stack(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: Image.file(
            File(goal.imagePath!),
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(10),
                Colors.black.withAlpha(180),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    goal.progressDisplay,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 5,
                  backgroundColor: Colors.white.withAlpha(50),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${fmt.format(goal.currentAmount)} ${goal.currency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${fmt.format(goal.targetAmount)} ${goal.currency}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconCard(
    BuildContext context,
    ThemeData theme,
    AppThemeExtension ext,
    bool isDark,
    NumberFormat fmt,
    Color accent,
    IconData statusIcon,
  ) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withAlpha(isDark ? 30 : 18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(goal.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel(goal),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                goal.progressDisplay,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 6,
              backgroundColor: accent.withAlpha(isDark ? 25 : 30),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${fmt.format(goal.currentAmount)} ${goal.currency}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${fmt.format(goal.targetAmount)} ${goal.currency}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ext.textTertiary,
                ),
              ),
            ],
          ),
          if (!goal.isAchieved) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: ext.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy', 'fr').format(goal.deadline),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ext.textTertiary,
                  ),
                ),
                const Spacer(),
                if (!goal.isOverdue)
                  Text(
                    '${goal.daysRemaining} jour${goal.daysRemaining > 1 ? 's' : ''} restant${goal.daysRemaining > 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: goal.daysRemaining <= 7
                          ? ext.warning
                          : ext.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(Goal g) {
    if (g.isAchieved) return 'Objectif atteint !';
    if (g.isOverdue) return 'Délai dépassé';
    return 'En cours';
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalDetailSheet(goal: goal),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  GOAL DETAIL SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _GoalDetailSheet extends StatefulWidget {
  final Goal goal;
  const _GoalDetailSheet({required this.goal});

  @override
  State<_GoalDetailSheet> createState() => _GoalDetailSheetState();
}

class _GoalDetailSheetState extends State<_GoalDetailSheet> {
  List<GoalContribution>? _contributions;

  @override
  void initState() {
    super.initState();
    _loadContributions();
  }

  void _loadContributions() async {
    final contribs =
        await context.read<GoalProvider>().getContributions(widget.goal.id!);
    if (mounted) setState(() => _contributions = contribs);
  }

  @override
  Widget build(BuildContext context) {
    final goal = context
        .watch<GoalProvider>()
        .goals
        .where((g) => g.id == widget.goal.id)
        .firstOrNull ?? widget.goal;

    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');
    final accounts = context.watch<AccountProvider>().accounts;
    final accountMap = {for (final a in accounts) a.id: a};

    Color accent;
    if (goal.isAchieved) {
      accent = ext.income;
    } else if (goal.isOverdue) {
      accent = ext.expense;
    } else {
      accent = Color(goal.color);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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

            // ── Header ──
            _buildHeader(goal, theme, ext, isDark, accent),
            const SizedBox(height: 24),

            // ── Progress ──
            _buildProgress(goal, theme, ext, isDark, fmt, accent),
            const SizedBox(height: 16),

            // ── Stats ──
            _buildStats(goal, theme, ext, fmt),
            const SizedBox(height: 24),

            // ── Contribute button ──
            if (!goal.isAchieved)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _ContributeSheet(goal: goal),
                    );
                  },
                  icon: const Icon(Icons.savings_rounded, size: 20),
                  label: const Text('Contribuer'),
                ),
              ),
            if (!goal.isAchieved) const SizedBox(height: 20),

            // ── Contributions history ──
            if (_contributions != null && _contributions!.isNotEmpty) ...[
              _buildContributionHistory(
                goal, theme, ext, isDark, fmt, accountMap,
              ),
              const SizedBox(height: 20),
            ],

            // ── Interest simulator ──
            _InterestSimulator(goal: goal),
            const SizedBox(height: 20),

            // ── Actions ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _GoalFormSheet(goal: goal),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => _confirmDelete(context, goal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ext.expense,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    Goal goal, ThemeData theme, AppThemeExtension ext, bool isDark, Color accent,
  ) {
    final hasImage = goal.imagePath != null && File(goal.imagePath!).existsSync();

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 140,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(goal.imagePath!), fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(160),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _statusLabel(goal),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: accent.withAlpha(isDark ? 35 : 20),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(goal.icon, style: const TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          goal.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: accent.withAlpha(isDark ? 30 : 16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _statusLabel(goal),
            style: theme.textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(
    Goal goal, ThemeData theme, AppThemeExtension ext,
    bool isDark, NumberFormat fmt, Color accent,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Épargné', style: theme.textTheme.bodySmall),
            Text(goal.progressDisplay,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: goal.progress,
            minHeight: 10,
            backgroundColor: accent.withAlpha(isDark ? 25 : 30),
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${fmt.format(goal.currentAmount)} ${goal.currency}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${fmt.format(goal.targetAmount)} ${goal.currency}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ext.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(
    Goal goal, ThemeData theme, AppThemeExtension ext, NumberFormat fmt,
  ) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            label: 'Restant',
            value: '${fmt.format(goal.remainingAmount)} ${goal.currency}',
          ),
        ),
        Container(width: 1, height: 36, color: ext.border),
        Expanded(
          child: _MiniStat(
            label: 'Deadline',
            value: DateFormat('dd MMM yyyy', 'fr').format(goal.deadline),
          ),
        ),
        if (!goal.isAchieved && !goal.isOverdue) ...[
          Container(width: 1, height: 36, color: ext.border),
          Expanded(
            child: _MiniStat(
              label: 'Jours',
              value: '${goal.daysRemaining}',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContributionHistory(
    Goal goal,
    ThemeData theme,
    AppThemeExtension ext,
    bool isDark,
    NumberFormat fmt,
    Map<int?, Account> accountMap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des contributions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ..._contributions!.take(10).map((c) {
          final account = accountMap[c.accountId];
          return Dismissible(
            key: ValueKey(c.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: ext.expense.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_rounded, color: ext.expense),
            ),
            confirmDismiss: (_) => _confirmRemoveContribution(c, goal),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(6) : ext.emptyState,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ext.income.withAlpha(isDark ? 30 : 18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: ext.income,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.note.isNotEmpty
                              ? c.note
                              : account?.name ?? 'Contribution',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat('dd MMM yyyy', 'fr').format(c.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ext.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${fmt.format(c.amount)} ${goal.currency}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ext.income,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<bool> _confirmRemoveContribution(
    GoalContribution c, Goal goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler cette contribution ?'),
        content: Text(
          'Le montant de ${NumberFormat('#,##0', 'fr').format(c.amount)} ${goal.currency} sera retiré de l\'objectif.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<GoalProvider>().removeContribution(c, goal);
      _loadContributions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribution annulée')),
        );
      }
    }
    return false;
  }

  String _statusLabel(Goal g) {
    if (g.isAchieved) return 'Objectif atteint';
    if (g.isOverdue) return 'Délai dépassé';
    return 'En cours';
  }

  void _confirmDelete(BuildContext context, Goal goal) {
    final ext = context.appTheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'objectif ?'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${goal.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await context.read<GoalProvider>().deleteGoal(goal.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${goal.name}" supprimé')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INTEREST SIMULATOR
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _InterestSimulator extends StatefulWidget {
  final Goal goal;
  const _InterestSimulator({required this.goal});

  @override
  State<_InterestSimulator> createState() => _InterestSimulatorState();
}

class _InterestSimulatorState extends State<_InterestSimulator> {
  double _rate = 5.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');
    final goal = widget.goal;

    if (goal.currentAmount <= 0) return const SizedBox.shrink();

    final months = goal.daysRemaining > 0 ? (goal.daysRemaining / 30).ceil() : 12;
    final projected = GoalProvider.simulateInterest(
      principal: goal.currentAmount,
      annualRate: _rate / 100,
      months: months,
    );
    final gain = projected - goal.currentAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(6) : ext.emptyState,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(10) : ext.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Simulateur d\'intérêts',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Si vous déposez en banque à ${_rate.toStringAsFixed(1)}% / an',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('1%', style: theme.textTheme.bodySmall),
              Expanded(
                child: Slider(
                  value: _rate,
                  min: 1,
                  max: 15,
                  divisions: 28,
                  label: '${_rate.toStringAsFixed(1)}%',
                  onChanged: (v) => setState(() => _rate = v),
                ),
              ),
              Text('15%', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dans $months mois',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: ext.textTertiary)),
                  Text(
                    '${fmt.format(projected)} ${goal.currency}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ext.income,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ext.income.withAlpha(isDark ? 25 : 12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${fmt.format(gain)} ${goal.currency}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ext.income,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CONTRIBUTE SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ContributeSheet extends StatefulWidget {
  final Goal goal;
  const _ContributeSheet({required this.goal});

  @override
  State<_ContributeSheet> createState() => _ContributeSheetState();
}

class _ContributeSheetState extends State<_ContributeSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  Account? _selectedAccount;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final fmt = NumberFormat('#,##0', 'fr');
    final accounts = context.watch<AccountProvider>().accounts;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final currencyLabel = _selectedAccount?.currencySymbol ?? widget.goal.currency;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: ext.textTertiary.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Contribuer à "${widget.goal.name}"',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Account selector
            Text('Depuis quel compte ?', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...accounts.map((a) {
              final selected = _selectedAccount?.id == a.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedAccount = a),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary.withAlpha(15)
                        : ext.emptyState,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : ext.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        a.type == AccountType.CASH
                            ? Icons.money_rounded
                            : a.type == AccountType.MOBILE_MONEY
                                ? Icons.phone_android_rounded
                                : Icons.account_balance_rounded,
                        size: 20,
                        color: selected
                            ? theme.colorScheme.primary
                            : ext.textTertiary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        '${fmt.format(a.currentBalance)} ${a.currencySymbol}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ext.textTertiary,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded,
                            size: 20, color: theme.colorScheme.primary),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Amount
            Text('Montant ($currencyLabel)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration: InputDecoration(
                hintText: 'Ex: 50000',
                suffixText: currencyLabel,
                prefixIcon: const Icon(Icons.savings_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Note
            Text('Note (optionnel)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex: Prime du mois',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 24),

            // Summary
            if (_selectedAccount != null && _amountCtrl.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(30),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_amountCtrl.text} $currencyLabel seront débités de "${_selectedAccount!.name}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Confirmer la contribution',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un compte')),
      );
      return;
    }
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }
    if (amount > _selectedAccount!.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solde insuffisant sur ce compte')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Find a savings-related category, or fallback to the first expense category
    final categories = context.read<CategoryProvider>().categories;
    final savingsCategory = categories
        .where((c) => c.name.toLowerCase().contains('saving') ||
            c.name.toLowerCase().contains('épargne') ||
            c.name.toLowerCase().contains('other'))
        .firstOrNull;
    final categoryId = savingsCategory?.id ?? categories.first.id!;

    final success = await context.read<GoalProvider>().contribute(
          goal: widget.goal,
          accountId: _selectedAccount!.id!,
          categoryId: categoryId,
          amount: amount,
          note: _noteCtrl.text.trim(),
          transactionProvider: context.read<TransactionProvider>(),
          mainProvider: context.read<MainProvider>(),
        );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contribution de ${NumberFormat('#,##0', 'fr').format(amount)} ${_selectedAccount!.currencySymbol} ajoutée !',
            ),
          ),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la contribution')),
        );
      }
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  MINI STAT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ext.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  GOAL FORM SHEET (Add / Edit)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const _goalIcons = [
  '🎯', '🏠', '💻', '🎉', '✈️', '🚗', '📱', '🎓',
  '💍', '🏋️', '🎵', '📷', '👶', '🏖️', '💰', '🎮',
];

const _goalColors = [
  0xFF7C4DFF, 0xFF448AFF, 0xFF00BFA5, 0xFFFF6D00,
  0xFFE91E63, 0xFF9C27B0, 0xFF00ACC1, 0xFF43A047,
  0xFFFF5252, 0xFF6D4C41,
];

class _GoalFormSheet extends StatefulWidget {
  final Goal? goal;
  const _GoalFormSheet({this.goal});

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _currentCtrl;
  late DateTime _deadline;
  late String _icon;
  late int _color;
  String? _imagePath;
  bool _isSaving = false;

  bool get _isEdit => widget.goal != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.goal?.name ?? '');
    _targetCtrl = TextEditingController(
      text: widget.goal != null
          ? widget.goal!.targetAmount.toStringAsFixed(0)
          : '',
    );
    _currentCtrl = TextEditingController(
      text: widget.goal != null
          ? widget.goal!.currentAmount.toStringAsFixed(0)
          : '0',
    );
    _deadline =
        widget.goal?.deadline ?? DateTime.now().add(const Duration(days: 30));
    _icon = widget.goal?.icon ?? '🎯';
    _color = widget.goal?.color ?? 0xFF7C4DFF;
    _imagePath = widget.goal?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final accent = Color(_color);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: ext.textTertiary.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                _isEdit ? 'Modifier l\'objectif' : 'Nouvel objectif',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // ── Preview ──
              Center(
                child: Column(
                  children: [
                    if (_imagePath != null && File(_imagePath!).existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(File(_imagePath!), fit: BoxFit.cover),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _imagePath = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: accent.withAlpha(isDark ? 35 : 20),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child:
                              Text(_icon, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: Text(_imagePath != null
                          ? 'Changer la photo'
                          : 'Ajouter une photo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        textStyle: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Icon selector ──
              Text('Icône', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _goalIcons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final emoji = _goalIcons[i];
                    final selected = _icon == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _icon = emoji),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected
                              ? accent.withAlpha(25)
                              : ext.emptyState,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? accent : ext.border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ── Color selector ──
              Text('Couleur', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _goalColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final c = _goalColors[i];
                    final selected = _color == c;
                    return GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                            width: selected ? 3 : 0,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Color(c).withAlpha(100),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Name ──
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'ex: Acheter un laptop',
                  prefixIcon: Text('  $_icon  ',
                      style: const TextStyle(fontSize: 20)),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 48, minHeight: 0),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 18),

              // ── Target ──
              TextFormField(
                controller: _targetCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'),
                  ),
                ],
                decoration: const InputDecoration(
                  hintText: 'Montant cible',
                  suffixText: 'BIF',
                  prefixIcon: Icon(Icons.track_changes_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (double.tryParse(v) == null) return 'Invalide';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // ── Current amount (only on create) ──
              if (!_isEdit) ...[
                TextFormField(
                  controller: _currentCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Montant initial',
                    suffixText: 'BIF',
                    prefixIcon: Icon(Icons.savings_rounded),
                  ),
                  validator: (v) {
                    if (v != null &&
                        v.isNotEmpty &&
                        double.tryParse(v) == null) {
                      return 'Invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
              ],

              // ── Deadline ──
              GestureDetector(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    DateFormat('dd MMMM yyyy', 'fr').format(_deadline),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Save ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Enregistrer' : 'Créer l\'objectif',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<GoalProvider>();

    if (_isEdit) {
      var updated = widget.goal!.copyWith(
        name: _nameCtrl.text.trim(),
        targetAmount: double.parse(_targetCtrl.text),
        deadline: _deadline,
        icon: _icon,
        color: _color,
      );
      if (_imagePath != widget.goal!.imagePath) {
        if (_imagePath == null) {
          updated = updated.clearImage();
        } else {
          updated = updated.copyWith(imagePath: _imagePath);
        }
      }
      await provider.updateGoal(updated);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${_nameCtrl.text}" mis à jour')),
        );
      }
    } else {
      final goal = Goal(
        name: _nameCtrl.text.trim(),
        targetAmount: double.parse(_targetCtrl.text),
        currentAmount: double.tryParse(_currentCtrl.text) ?? 0.0,
        deadline: _deadline,
        icon: _icon,
        color: _color,
        imagePath: _imagePath,
      );
      await provider.addGoal(goal);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Objectif "${_nameCtrl.text}" créé')),
        );
      }
    }
  }
}
