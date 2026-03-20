import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../../domain/entities/goal.dart';

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
            '${fmt.format(provider.totalSaved)} BIF',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'sur ${fmt.format(provider.totalTarget)} BIF',
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
      accent = theme.colorScheme.primary;
      statusIcon = Icons.flag_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(6)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(10) : ext.border,
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
                      color: accent.withAlpha(isDark ? 30 : 18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: accent, size: 22),
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
                    '${fmt.format(goal.currentAmount)} BIF',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${fmt.format(goal.targetAmount)} BIF',
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
        ),
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

class _GoalDetailSheet extends StatelessWidget {
  final Goal goal;
  const _GoalDetailSheet({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');

    Color accent;
    if (goal.isAchieved) {
      accent = ext.income;
    } else if (goal.isOverdue) {
      accent = ext.expense;
    } else {
      accent = theme.colorScheme.primary;
    }

    return Container(
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

          // Header
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withAlpha(isDark ? 35 : 20),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.flag_rounded, color: accent, size: 32),
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
          const SizedBox(height: 24),

          // Progress
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
                '${fmt.format(goal.currentAmount)} BIF',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${fmt.format(goal.targetAmount)} BIF',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ext.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Restant',
                  value: '${fmt.format(goal.remainingAmount)} BIF',
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: ext.border,
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Deadline',
                  value:
                      DateFormat('dd MMM yyyy', 'fr').format(goal.deadline),
                ),
              ),
              if (!goal.isAchieved && !goal.isOverdue) ...[
                Container(
                  width: 1,
                  height: 36,
                  color: ext.border,
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Jours',
                    value: '${goal.daysRemaining}',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              if (!goal.isAchieved)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddAmount(context);
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ajouter'),
                  ),
                ),
              if (!goal.isAchieved) const SizedBox(width: 10),
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
                  onPressed: () => _confirmDelete(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ext.expense,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child:
                      const Icon(Icons.delete_outline_rounded, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(Goal g) {
    if (g.isAchieved) return 'Objectif atteint';
    if (g.isOverdue) return 'Délai dépassé';
    return 'En cours';
  }

  void _showAddAmount(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter un montant'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            hintText: 'Montant',
            suffixText: 'BIF',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx);
              final updated = goal.copyWith(
                currentAmount: goal.currentAmount + amount,
              );
              await context.read<GoalProvider>().updateGoal(updated);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
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

              // Name
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'ex: Acheter un laptop',
                  prefixIcon: Icon(
                    Icons.flag_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 18),

              // Target
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

              // Current amount
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
                  hintText: 'Montant actuel',
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

              // Deadline
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

              // Save
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
                          style: const TextStyle(
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<GoalProvider>();
    final goal = Goal(
      id: widget.goal?.id,
      name: _nameCtrl.text.trim(),
      targetAmount: double.parse(_targetCtrl.text),
      currentAmount: double.tryParse(_currentCtrl.text) ?? 0.0,
      deadline: _deadline,
    );

    if (_isEdit) {
      await provider.updateGoal(goal);
    } else {
      await provider.addGoal(goal);
    }

    if (mounted) Navigator.pop(context);
  }
}
