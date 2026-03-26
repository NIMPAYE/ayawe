import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/recurring_transaction_provider.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../../presentation/providers/main_provider.dart';

class RecurringTransactionsView extends StatelessWidget {
  const RecurringTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rtProvider = context.watch<RecurringTransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final categories = context.watch<CategoryProvider>().categories;
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accountProvider.accounts) a.id: a};

    final balanceByCurrency = accountProvider.balanceByCurrency;
    final upcomingByCurrency =
        rtProvider.upcomingExpensesByCurrency(accountMap);
    final remainingByCurrency =
        rtProvider.remainingByCurrency(balanceByCurrency, accountMap);

    final dueSoon = rtProvider.dueSoonItems;
    final allItems = rtProvider.items;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        // Alert card
        _AlertCard(
          remainingByCurrency: remainingByCurrency,
          upcomingByCurrency: upcomingByCurrency,
          balanceByCurrency: balanceByCurrency,
        ),
        const SizedBox(height: 20),

        // Due soon section
        if (dueSoon.isNotEmpty) ...[
          Text(
            'A venir',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...dueSoon.map((rt) => _RecurringCard(
                rt: rt,
                category: categoryMap[rt.categoryId],
                account: accountMap[rt.accountId],
                showConfirm: true,
                onConfirm: () => _confirmTransaction(context, rt),
                onTap: () => _showDetail(context, rt, categoryMap, accountMap),
              )),
          const SizedBox(height: 20),
        ],

        // All recurring section
        Text(
          'Toutes les récurrentes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (allItems.isEmpty)
          _EmptyRecurring()
        else
          ...allItems.map((rt) => _RecurringCard(
                rt: rt,
                category: categoryMap[rt.categoryId],
                account: accountMap[rt.accountId],
                onTap: () => _showDetail(context, rt, categoryMap, accountMap),
              )),

        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => _showAddForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une récurrente'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmTransaction(
    BuildContext context,
    RecurringTransaction rt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Text(
          'Créer la transaction "${rt.description}" de ${_fmt(rt.amount)} ${context.read<AccountProvider>().accounts.where((a) => a.id == rt.accountId).firstOrNull?.currencySymbol ?? 'BIF'} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final rtProvider = context.read<RecurringTransactionProvider>();
    final txProvider = context.read<TransactionProvider>();
    final transaction = rtProvider.buildTransaction(rt);

    await txProvider.addTransaction(transaction);
    await rtProvider.advanceNextDueDate(rt);
    if (context.mounted) {
      await context.read<MainProvider>().loadAllData();
    }
  }

  void _showDetail(
    BuildContext context,
    RecurringTransaction rt,
    Map<int?, Category> categoryMap,
    Map<int?, Account> accountMap,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecurringDetailSheet(
        rt: rt,
        category: categoryMap[rt.categoryId],
        account: accountMap[rt.accountId],
      ),
    );
  }

  void _showAddForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _RecurringFormSheet(),
    );
  }
}

// ─────────────── Alert Card ───────────────

class _AlertCard extends StatelessWidget {
  final Map<Currency, double> remainingByCurrency;
  final Map<Currency, double> upcomingByCurrency;
  final Map<Currency, double> balanceByCurrency;

  const _AlertCard({
    required this.remainingByCurrency,
    required this.upcomingByCurrency,
    required this.balanceByCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    final hasAnyNegative =
        remainingByCurrency.values.any((v) => v < 0);
    final statusColor = hasAnyNegative ? ext.expense : ext.income;

    final currencies = balanceByCurrency.keys.toList();
    if (currencies.isEmpty) currencies.add(Currency.BIF);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(isDark ? 30 : 15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasAnyNegative
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                color: statusColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasAnyNegative
                      ? 'Attention, budget serré !'
                      : 'Vos finances sont sous contrôle',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Après tes frais fixes, il te restera :',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ext.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          ...currencies.map((currency) {
            final remaining = remainingByCurrency[currency] ?? 0;
            final balance = balanceByCurrency[currency] ?? 0;
            final upcoming = upcomingByCurrency[currency] ?? 0;
            final isNeg = remaining < 0;
            final color = isNeg ? ext.expense : ext.income;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmt(remaining)} ${currency.symbol}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Solde: ${_fmt(balance)} ${currency.symbol}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ext.textTertiary,
                        ),
                      ),
                      if (upcoming > 0)
                        Text(
                          'A payer: ${_fmt(upcoming)} ${currency.symbol}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ext.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
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

// ─────────────── Recurring Card ───────────────

class _RecurringCard extends StatelessWidget {
  final RecurringTransaction rt;
  final Category? category;
  final Account? account;
  final bool showConfirm;
  final VoidCallback? onConfirm;
  final VoidCallback? onTap;

  const _RecurringCard({
    required this.rt,
    this.category,
    this.account,
    this.showConfirm = false,
    this.onConfirm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final isExpense = rt.transactionType == TransactionType.OUTGOING;
    final color = isExpense ? ext.expense : ext.income;

    Color? badgeColor;
    String? badgeText;
    if (rt.isOverdue) {
      badgeColor = ext.expense;
      badgeText = 'En retard';
    } else if (rt.isDueSoon) {
      badgeColor = ext.warning;
      badgeText = rt.daysUntilDue == 0
          ? "Aujourd'hui"
          : 'Dans ${rt.daysUntilDue}j';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : ext.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                category?.icon ?? '📌',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          rt.description,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration:
                                rt.isActive ? null : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor!.withAlpha(isDark ? 40 : 20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${rt.frequency.label} · ${DateFormat('dd MMM').format(rt.nextDueDate)}',
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
                  '${isExpense ? '-' : '+'} ${_fmt(rt.amount)} ${account?.currencySymbol ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (showConfirm && onConfirm != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Confirmer',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

// ─────────────── Empty State ───────────────

class _EmptyRecurring extends StatelessWidget {
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
              Icons.replay_rounded,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune récurrente',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Déclarez vos frais fixes (loyer, internet...)\npour anticiper vos dépenses.',
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

// ─────────────── Recurring Detail Sheet ───────────────

class _RecurringDetailSheet extends StatelessWidget {
  final RecurringTransaction rt;
  final Category? category;
  final Account? account;

  const _RecurringDetailSheet({
    required this.rt,
    this.category,
    this.account,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isExpense = rt.transactionType == TransactionType.OUTGOING;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                category?.icon ?? '📌',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rt.description,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${isExpense ? "Dépense" : "Revenu"} · ${rt.frequency.label}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ext.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(label: 'Montant', value: '${_fmt(rt.amount)} ${account?.currencySymbol ?? 'BIF'}'),
          _DetailRow(label: 'Compte', value: account?.name ?? '—'),
          _DetailRow(label: 'Catégorie', value: category?.name ?? '—'),
          _DetailRow(
            label: 'Prochaine date',
            value: DateFormat('dd MMMM yyyy', 'fr').format(rt.nextDueDate),
          ),
          _DetailRow(label: 'Statut', value: rt.isActive ? 'Actif' : 'Inactif'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<RecurringTransactionProvider>()
                        .deleteRecurring(rt.id!);
                    Navigator.pop(context);
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
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<RecurringTransactionProvider>()
                        .toggleActive(rt);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(rt.isActive ? 'Désactiver' : 'Activer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: ext.textTertiary)),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────── Recurring Form Sheet (Add) ───────────────

class _RecurringFormSheet extends StatefulWidget {
  const _RecurringFormSheet();

  @override
  State<_RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends State<_RecurringFormSheet> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.OUTGOING;
  RecurrenceFrequency _frequency = RecurrenceFrequency.MONTHLY;
  Account? _selectedAccount;
  Category? _selectedCategory;
  DateTime _nextDue = DateTime.now();

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final accounts = context.watch<AccountProvider>().accounts;
    final categories = context.watch<CategoryProvider>().categories;
    final filteredCats = categories
        .where((c) => _type == TransactionType.OUTGOING
            ? c.type == CategoryType.EXPENSE
            : c.type == CategoryType.INCOME)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                decoration: BoxDecoration(
                  color: ext.textTertiary.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nouvelle récurrente',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Type toggle
            Row(
              children: [
                _MiniChip(
                  label: 'Dépense',
                  selected: _type == TransactionType.OUTGOING,
                  onTap: () => setState(() {
                    _type = TransactionType.OUTGOING;
                    _selectedCategory = null;
                  }),
                  color: ext.expense,
                ),
                const SizedBox(width: 8),
                _MiniChip(
                  label: 'Revenu',
                  selected: _type == TransactionType.INCOMING,
                  onTap: () => setState(() {
                    _type = TransactionType.INCOMING;
                    _selectedCategory = null;
                  }),
                  color: ext.income,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text('Description', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(hintText: 'Ex: Loyer mensuel'),
            ),
            const SizedBox(height: 16),

            // Amount
            Text('Montant (BIF)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration: const InputDecoration(hintText: '100000'),
            ),
            const SizedBox(height: 16),

            // Account
            Text('Compte', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            DropdownButtonFormField<Account>(
              initialValue: _selectedAccount,
              isExpanded: true,
              hint: const Text('Sélectionner'),
              items: accounts.map((a) {
                return DropdownMenuItem(
                  value: a,
                  child: Text(a.name),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedAccount = v),
            ),
            const SizedBox(height: 16),

            // Category
            Text('Catégorie', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredCats.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary.withAlpha(20)
                          : ext.emptyState,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : ext.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          cat.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color:
                                selected ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Frequency
            Text('Fréquence', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecurrenceFrequency.values.map((f) {
                final selected = _frequency == f;
                return GestureDetector(
                  onTap: () => setState(() => _frequency = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary.withAlpha(20)
                          : ext.emptyState,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : ext.border,
                      ),
                    ),
                    child: Text(
                      f.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Next due date
            Text('Prochaine date', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _nextDue,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _nextDue = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(DateFormat('dd MMMM yyyy', 'fr').format(_nextDue)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  'Créer la récurrente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_descController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedAccount == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    context.read<RecurringTransactionProvider>().addRecurring(
          RecurringTransaction(
            accountId: _selectedAccount!.id!,
            categoryId: _selectedCategory!.id!,
            amount: amount,
            description: _descController.text,
            transactionType: _type,
            frequency: _frequency,
            nextDueDate: _nextDue,
          ),
        );
    Navigator.pop(context);
  }
}

// ─────────────── Mini Chip ───────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _MiniChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withAlpha(isDark ? 40 : 20)
              : ext.emptyState,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : ext.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? color : ext.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ─────────────── Helpers ───────────────

String _fmt(double amount) {
  final formatter = NumberFormat('#,##0', 'fr');
  return formatter.format(amount);
}
