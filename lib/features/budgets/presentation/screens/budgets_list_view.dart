import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/budget_provider.dart';
import '../../domain/entities/budget.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';

class BudgetsListView extends StatefulWidget {
  const BudgetsListView({super.key});

  @override
  State<BudgetsListView> createState() => _BudgetsListViewState();
}

class _BudgetsListViewState extends State<BudgetsListView> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  String get _monthKey => BudgetProvider.monthKey(_selectedMonth);

  String get _previousMonthKey {
    final prev = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    return BudgetProvider.monthKey(prev);
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
    final bp = context.read<BudgetProvider>();
    bp.setMonth(_monthKey);
    // Refresh rollover check after month changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final txs = context.read<TransactionProvider>().transactions;
      bp.checkRollover(txs);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger rollover check whenever transactions/budgets change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bp = context.read<BudgetProvider>();
      final txs = context.read<TransactionProvider>().transactions;
      bp.checkRollover(txs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final transactions = context.watch<TransactionProvider>().transactions;
    final categories = context.watch<CategoryProvider>().categories;
    final categoryMap = {for (final c in categories) c.id: c};

    final budgets = budgetProvider.budgets;
    final totalBudgeted = budgetProvider.totalBudgeted;
    final spentMap = budgetProvider.spentByCategoryMap(_monthKey, transactions);
    final totalSpent = budgetProvider.totalSpentFromMap(spentMap);
    final globalProgress = totalBudgeted > 0 ? totalSpent / totalBudgeted : 0.0;

    final unbudgetedTotal = budgetProvider.unbudgetedSpent(spentMap);
    final unbudgetedMap = budgetProvider.unbudgetedByCategory(spentMap);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        _MonthSelector(
          month: _selectedMonth,
          onPrevious: () => _changeMonth(-1),
          onNext: () => _changeMonth(1),
        ),
        const SizedBox(height: 16),

        _SummaryCard(
          totalBudgeted: totalBudgeted,
          totalSpent: totalSpent,
          progress: globalProgress,
        ),
        const SizedBox(height: 20),

        // Rollover button (reads pre-computed bool)
        if (budgetProvider.hasRolloverAvailable && budgets.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _RolloverButton(
              onTap: () async {
                await budgetProvider.applyRollover(
                  _previousMonthKey,
                  _monthKey,
                  transactions,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Roulement appliqué avec succès')),
                  );
                }
              },
            ),
          ),

        // Budget cards
        if (budgets.isEmpty)
          _EmptyBudgets()
        else
          ...budgets.map((b) {
            final cat = categoryMap[b.categoryId];
            final spent = spentMap[b.categoryId] ?? 0.0;
            return _BudgetCard(
              budget: b,
              category: cat,
              spent: spent,
              onTap: () => _showBudgetDetail(context, b, cat, spent, transactions),
              onLongPress: () => _showEditBudget(context, b, categories),
            );
          }),

        // Unbudgeted section
        if (unbudgetedTotal > 0) ...[
          const SizedBox(height: 20),
          _UnbudgetedSection(
            total: unbudgetedTotal,
            byCategory: unbudgetedMap,
            categoryMap: categoryMap,
          ),
        ],

        const SizedBox(height: 16),

        Center(
          child: TextButton.icon(
            onPressed: () => _showAddBudget(context, categories, budgets),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter un budget'),
          ),
        ),
      ],
    );
  }

  void _showAddBudget(
    BuildContext context,
    List<Category> categories,
    List<Budget> existingBudgets,
  ) {
    final expenseCategories = categories
        .where((c) => c.type == CategoryType.EXPENSE)
        .where((c) => !existingBudgets.any((b) => b.categoryId == c.id))
        .toList();

    if (expenseCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les catégories ont déjà un budget'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BudgetFormSheet(
        categories: expenseCategories,
        month: _monthKey,
      ),
    );
  }

  void _showEditBudget(
    BuildContext context,
    Budget budget,
    List<Category> categories,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BudgetEditSheet(budget: budget),
    );
  }

  void _showBudgetDetail(
    BuildContext context,
    Budget budget,
    Category? category,
    double spent,
    List<Transaction> transactions,
  ) {
    final monthTransactions = transactions
        .where((t) =>
            t.categoryId == budget.categoryId &&
            t.transactionType == TransactionType.OUTGOING &&
            BudgetProvider.monthKey(t.date) == _monthKey)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BudgetDetailSheet(
        budget: budget,
        category: category,
        spent: spent,
        transactions: monthTransactions,
      ),
    );
  }
}

// ─────────────── Month Selector ───────────────

class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : ext.emptyState,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            visualDensity: VisualDensity.compact,
          ),
          Text(
            DateFormat('MMMM yyyy', 'fr').format(month),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─────────────── Summary Card ───────────────

class _SummaryCard extends StatelessWidget {
  final double totalBudgeted;
  final double totalSpent;
  final double progress;

  const _SummaryCard({
    required this.totalBudgeted,
    required this.totalSpent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final remaining = totalBudgeted - totalSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ext.balanceGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget total',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                  Text(
                    '${_fmt(totalBudgeted)} BIF',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Dépensé',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                  Text(
                    '${_fmt(totalSpent)} BIF',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.9
                    ? const Color(0xFFFF6B6B)
                    : progress > 0.75
                        ? const Color(0xFFFFB800)
                        : const Color(0xFF00C48C),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% utilisé',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withAlpha(180),
                ),
              ),
              Text(
                'Reste: ${_fmt(remaining.clamp(0, double.infinity))} BIF',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────── Budget Card ───────────────

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final Category? category;
  final double spent;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _BudgetCard({
    required this.budget,
    this.category,
    required this.spent,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    final effective = budget.effectiveAmount;
    final progress = effective > 0 ? spent / effective : 0.0;
    final color = _progressColor(progress, ext);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : ext.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 40 : 20),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category?.icon ?? '📌',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? 'Catégorie',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_fmt(spent)} / ${_fmt(effective)} BIF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ext.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (budget.rolloverAmount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(isDark ? 30 : 15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${_fmt(budget.rolloverAmount)} report',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: ext.emptyState,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Rollover Button ───────────────

class _RolloverButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RolloverButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.replay_rounded, size: 18),
      label: const Text('Appliquer le roulement du mois précédent'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// ─────────────── Empty State ───────────────

class _EmptyBudgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun budget défini',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Définissez des plafonds par catégorie\npour mieux contrôler vos dépenses.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ext.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Budget Form Sheet (Add) ───────────────

class _BudgetFormSheet extends StatefulWidget {
  final List<Category> categories;
  final String month;

  const _BudgetFormSheet({
    required this.categories,
    required this.month,
  });

  @override
  State<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<_BudgetFormSheet> {
  final _amountController = TextEditingController();
  Category? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ext.textTertiary.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nouveau budget',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text('Catégorie', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categories.map((cat) {
              final selected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary.withAlpha(20)
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Plafond mensuel (BIF)', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: const InputDecoration(hintText: '50000'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(
                'Créer le budget',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_selectedCategory == null || _amountController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final catName = _selectedCategory!.name;
    context.read<BudgetProvider>().addBudget(Budget(
          categoryId: _selectedCategory!.id!,
          amount: amount,
          month: widget.month,
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Budget "$catName" ajouté')),
    );
  }
}

// ─────────────── Budget Edit Sheet ───────────────

class _BudgetEditSheet extends StatefulWidget {
  final Budget budget;
  const _BudgetEditSheet({required this.budget});

  @override
  State<_BudgetEditSheet> createState() => _BudgetEditSheetState();
}

class _BudgetEditSheetState extends State<_BudgetEditSheet> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.budget.amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ext.textTertiary.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Modifier le budget',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text('Nouveau plafond (BIF)', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<BudgetProvider>()
                        .deleteBudget(widget.budget.id!);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget supprimé')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ext.expense,
                    side: BorderSide(color: ext.expense),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Supprimer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount == null || amount <= 0) return;
                    context.read<BudgetProvider>().updateBudget(
                          widget.budget.copyWith(amount: amount),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget mis à jour')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────── Budget Detail Sheet ───────────────

class _BudgetDetailSheet extends StatelessWidget {
  final Budget budget;
  final Category? category;
  final double spent;
  final List<Transaction> transactions;

  const _BudgetDetailSheet({
    required this.budget,
    this.category,
    required this.spent,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final remaining = budget.effectiveAmount - spent;
    final progress =
        budget.effectiveAmount > 0 ? spent / budget.effectiveAmount : 0.0;
    final color = _progressColor(progress, ext);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ext.textTertiary.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    category?.icon ?? '📌',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name ?? 'Budget',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_fmt(spent)} / ${_fmt(budget.effectiveAmount)} BIF',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: ext.emptyState,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                remaining >= 0
                    ? 'Il vous reste ${_fmt(remaining)} BIF'
                    : 'Dépassé de ${_fmt(-remaining)} BIF',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: remaining >= 0 ? ext.income : ext.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Transactions (${transactions.length})',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune dépense ce mois',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ext.textTertiary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (_, i) {
                          final t = transactions[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(8)
                                  : ext.emptyState,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.description,
                                        style: theme.textTheme.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        DateFormat('dd MMM').format(t.date),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: ext.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-${_fmt(t.amount)} BIF',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ext.expense,
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
      },
    );
  }
}

// ─────────────── Unbudgeted Section ───────────────

class _UnbudgetedSection extends StatelessWidget {
  final double total;
  final Map<int, double> byCategory;
  final Map<int?, Category> categoryMap;

  const _UnbudgetedSection({
    required this.total,
    required this.byCategory,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.warning.withAlpha(isDark ? 20 : 10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ext.warning.withAlpha(isDark ? 40 : 25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: ext.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dépenses non budgétées',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ext.warning,
                  ),
                ),
              ),
              Text(
                '${_fmt(total)} BIF',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ext.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...byCategory.entries.map((e) {
            final cat = categoryMap[e.key];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(cat?.icon ?? '📌', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat?.name ?? 'Catégorie #${e.key}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '${_fmt(e.value)} BIF',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────── Helpers ───────────────

Color _progressColor(double progress, AppThemeExtension ext) {
  if (progress > 0.9) return ext.expense;
  if (progress > 0.75) return ext.warning;
  return ext.income;
}

String _fmt(double amount) {
  final formatter = NumberFormat('#,##0', 'fr');
  return formatter.format(amount);
}
