import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _type = TransactionType.OUTGOING;
  Account? _selectedAccount;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  CategoryType get _matchingCategoryType =>
      _type == TransactionType.OUTGOING
          ? CategoryType.EXPENSE
          : CategoryType.INCOME;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final accounts = context.watch<AccountProvider>().accounts;
    final allCategories = context.watch<CategoryProvider>().categories;
    final filteredCategories = allCategories
        .where((c) => c.type == _matchingCategoryType)
        .toList();

    if (_selectedAccount != null &&
        !accounts.contains(_selectedAccount)) {
      _selectedAccount = null;
    }
    if (_selectedCategory != null &&
        !filteredCategories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }

    final isExpense = _type == TransactionType.OUTGOING;
    final accentColor = isExpense ? ext.expense : ext.income;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouvelle Transaction',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  // ── Type selector ──
                  Row(
                    children: [
                      Expanded(
                        child: _TypeChip(
                          label: 'Dépense',
                          icon: Icons.arrow_upward_rounded,
                          color: ext.expense,
                          isSelected: isExpense,
                          onTap: () => _setType(TransactionType.OUTGOING),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TypeChip(
                          label: 'Revenu',
                          icon: Icons.arrow_downward_rounded,
                          color: ext.income,
                          isSelected: !isExpense,
                          onTap: () => _setType(TransactionType.INCOMING),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Amount ──
                  Text('Montant', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                    decoration: InputDecoration(
                      prefixText: _selectedAccount != null
                          ? '${_selectedAccount!.currencySymbol} '
                          : '',
                      prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      hintText: '0',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Entrez un montant';
                      if (double.tryParse(v) == null) {
                        return 'Montant invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Account ──
                  Text('Compte', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (accounts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ext.expenseSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: ext.warning, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Aucun compte. Créez-en un d\'abord.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<Account>(
                      value: _selectedAccount,
                      isExpanded: true,
                      decoration: const InputDecoration(),
                      hint: const Text('Sélectionnez un compte'),
                      items: accounts.map((a) {
                        return DropdownMenuItem(
                          value: a,
                          child: Row(
                            children: [
                              Icon(
                                _accountIcon(a.type),
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  a.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${_fmt(a.currentBalance)} ${a.currencySymbol}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: ext.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedAccount = v),
                      validator: (v) =>
                          v == null ? 'Sélectionnez un compte' : null,
                    ),
                  const SizedBox(height: 24),

                  // ── Category ──
                  Text('Catégorie', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (filteredCategories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ext.emptyState,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aucune catégorie disponible pour ce type.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ext.textTertiary,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredCategories.map((cat) {
                        final selected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accentColor.withAlpha(isDark ? 50 : 25)
                                  : isDark
                                      ? Colors.white.withAlpha(10)
                                      : ext.emptyState,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? accentColor
                                    : isDark
                                        ? Colors.white.withAlpha(15)
                                        : ext.border,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat.icon,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? accentColor
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // ── Description ──
                  Text('Description', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Taxi centre-ville',
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Entrez une description'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ── Date ──
                  Text('Date', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 18,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('dd MMMM yyyy', 'fr')
                                .format(_selectedDate),
                          ),
                          const Spacer(),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: ext.textTertiary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Save button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(
                    'Enregistrer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setType(TransactionType type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _selectedCategory = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
        ),
      );
      return;
    }

    final transaction = Transaction(
      accountId: _selectedAccount!.id!,
      categoryId: _selectedCategory!.id ?? 0,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      description: _descriptionController.text,
      transactionType: _type,
    );

    await context.read<TransactionProvider>().addTransaction(transaction);
    if (mounted) {
      await context.read<AccountProvider>().loadAccounts();
      Navigator.pop(context);
    }
  }

  IconData _accountIcon(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return Icons.payments_outlined;
      case AccountType.MOBILE_MONEY:
        return Icons.phone_android_rounded;
      case AccountType.BANK:
        return Icons.account_balance_rounded;
    }
  }
}

// ─────────────── Type Toggle Chip ───────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = context.appTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(isDark ? 40 : 20)
              : isDark
                  ? Colors.white.withAlpha(8)
                  : ext.emptyState,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color
                : isDark
                    ? Colors.white.withAlpha(15)
                    : ext.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : ext.textTertiary),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : ext.textTertiary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(double amount) {
  final formatter = NumberFormat('#,##0', 'fr');
  return formatter.format(amount);
}
