import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/debt_provider.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/debt_payment.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../../presentation/providers/main_provider.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Dettes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          final debts = provider.debts;

          if (debts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 64,
                    color: ext.textTertiary.withAlpha(100),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aucune dette',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ext.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enregistrez vos prêts et emprunts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.textTertiary.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(context),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Nouvelle dette'),
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
                if (provider.lentDebts.isNotEmpty) ...[
                  _SectionLabel('On me doit'),
                  const SizedBox(height: 12),
                  ...provider.lentDebts.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DebtCard(debt: d),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (provider.borrowedDebts.isNotEmpty) ...[
                  _SectionLabel('Je dois'),
                  const SizedBox(height: 12),
                  ...provider.borrowedDebts.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DebtCard(debt: d),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (provider.settledDebts.isNotEmpty) ...[
                  _SectionLabel('Réglés'),
                  const SizedBox(height: 12),
                  ...provider.settledDebts.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DebtCard(debt: d),
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
        label: const Text('Nouvelle dette'),
      ),
    );
  }

  void _showForm(BuildContext context, {Debt? debt}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DebtFormSheet(debt: debt),
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
  final DebtProvider provider;
  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');
    final net = provider.totalReceivable - provider.totalPayable;

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
                'Bilan des dettes',
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
                  '${provider.activeDebts.length} active${provider.activeDebts.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'On me doit',
                  amount: fmt.format(provider.totalReceivable),
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFF00E5A0),
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.white.withAlpha(40),
              ),
              Expanded(
                child: _SummaryStat(
                  label: 'Je dois',
                  amount: fmt.format(provider.totalPayable),
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFFF8E8E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solde net',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${net >= 0 ? '+' : ''}${fmt.format(net)}',
                  style: TextStyle(
                    color: net >= 0
                        ? const Color(0xFF00E5A0)
                        : const Color(0xFFFF8E8E),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(160),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DEBT CARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DebtCard extends StatelessWidget {
  final Debt debt;
  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');

    Color accent;
    IconData statusIcon;
    if (debt.isSettled) {
      accent = ext.income;
      statusIcon = Icons.check_circle_rounded;
    } else if (debt.isOverdue) {
      accent = ext.expense;
      statusIcon = Icons.warning_rounded;
    } else {
      accent = debt.type == DebtType.LENT
          ? const Color(0xFF00C9A7)
          : const Color(0xFFFF7B7B);
      statusIcon = debt.type == DebtType.LENT
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded;
    }

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
          child: Padding(
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
                      child: Icon(statusIcon, color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.personName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            debt.typeDisplay,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${fmt.format(debt.remainingAmount)} ${debt.currency}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        if (!debt.isSettled && debt.remainingAmount != debt.totalAmount)
                          Text(
                            'sur ${fmt.format(debt.totalAmount)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ext.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (!debt.isSettled) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: debt.progress.clamp(0.0, 1.0),
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
                        '${(debt.progress * 100).toStringAsFixed(0)}% remboursé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: accent,
                        ),
                      ),
                      if (debt.dueDate != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: debt.isOverdue ? ext.expense : ext.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy', 'fr').format(debt.dueDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: debt.isOverdue ? ext.expense : ext.textTertiary,
                                fontWeight: debt.isOverdue ? FontWeight.w600 : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
                if (debt.isSettled)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ext.income.withAlpha(isDark ? 30 : 18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Réglé',
                        style: TextStyle(
                          color: ext.income,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DebtDetailSheet(debt: debt),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DEBT DETAIL SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DebtDetailSheet extends StatefulWidget {
  final Debt debt;
  const _DebtDetailSheet({required this.debt});

  @override
  State<_DebtDetailSheet> createState() => _DebtDetailSheetState();
}

class _DebtDetailSheetState extends State<_DebtDetailSheet> {
  List<DebtPayment>? _payments;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final payments =
        await context.read<DebtProvider>().getPayments(widget.debt.id!);
    if (mounted) setState(() => _payments = payments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final fmt = NumberFormat('#,##0', 'fr');

    final debt = context.select<DebtProvider, Debt?>((p) =>
        p.debts.where((d) => d.id == widget.debt.id).firstOrNull) ??
        widget.debt;

    Color accent;
    if (debt.isSettled) {
      accent = ext.income;
    } else if (debt.isOverdue) {
      accent = ext.expense;
    } else {
      accent = debt.type == DebtType.LENT
          ? const Color(0xFF00C9A7)
          : const Color(0xFFFF7B7B);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
            const SizedBox(height: 20),

            // Header
            _buildHeader(theme, ext, isDark, fmt, debt, accent),
            const SizedBox(height: 24),

            // Progress
            _buildProgress(theme, ext, isDark, fmt, debt, accent),
            const SizedBox(height: 24),

            // Stats
            _buildStats(theme, ext, isDark, fmt, debt),
            const SizedBox(height: 24),

            // Actions
            if (!debt.isSettled) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _PaymentSheet(debt: debt),
                        );
                      },
                      icon: const Icon(Icons.payment_rounded, size: 18),
                      label: const Text('Enregistrer un paiement'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => _confirmSettle(debt),
                  child: const Text('Marquer comme réglé'),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Payment history
            _buildPaymentHistory(theme, ext, isDark, fmt, debt, accent),
            const SizedBox(height: 24),

            // Delete button
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
                        builder: (_) => _DebtFormSheet(debt: debt),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(debt),
                    icon: Icon(Icons.delete_rounded, size: 18, color: ext.expense),
                    label: Text('Supprimer', style: TextStyle(color: ext.expense)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ext.expense.withAlpha(100)),
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

  Widget _buildHeader(
    ThemeData theme,
    AppThemeExtension ext,
    bool isDark,
    NumberFormat fmt,
    Debt debt,
    Color accent,
  ) {
    final typeIcon = debt.type == DebtType.LENT
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withAlpha(isDark ? 30 : 18),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(typeIcon, color: accent, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                debt.personName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withAlpha(isDark ? 20 : 12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  debt.statusDisplay,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(
    ThemeData theme,
    AppThemeExtension ext,
    bool isDark,
    NumberFormat fmt,
    Debt debt,
    Color accent,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Remboursé',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ext.textTertiary,
              ),
            ),
            Text(
              '${(debt.progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: debt.progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: accent.withAlpha(isDark ? 25 : 30),
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payé: ${fmt.format(debt.totalAmount - debt.remainingAmount)} ${debt.currency}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Reste: ${fmt.format(debt.remainingAmount)} ${debt.currency}',
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
    ThemeData theme,
    AppThemeExtension ext,
    bool isDark,
    NumberFormat fmt,
    Debt debt,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(6) : ext.emptyState,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _StatRow(
            label: 'Type',
            value: debt.typeDisplay,
            icon: debt.type == DebtType.LENT
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Montant total',
            value: '${fmt.format(debt.totalAmount)} ${debt.currency}',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Date de création',
            value: DateFormat('dd MMM yyyy', 'fr').format(debt.createdDate),
            icon: Icons.calendar_today_rounded,
          ),
          if (debt.dueDate != null) ...[
            const SizedBox(height: 12),
            _StatRow(
              label: 'Échéance',
              value: DateFormat('dd MMM yyyy', 'fr').format(debt.dueDate!),
              icon: Icons.event_rounded,
              valueColor: debt.isOverdue ? ext.expense : null,
            ),
          ],
          if (debt.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            _StatRow(
              label: 'Description',
              value: debt.description,
              icon: Icons.notes_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(
    ThemeData theme,
    AppThemeExtension ext,
    bool isDark,
    NumberFormat fmt,
    Debt debt,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des paiements',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (_payments == null)
          const Center(child: CircularProgressIndicator())
        else if (_payments!.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(6) : ext.emptyState,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Aucun paiement enregistré',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ext.textTertiary,
                ),
              ),
            ),
          )
        else
          ..._payments!.map((p) => Dismissible(
                key: ValueKey(p.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: ext.expense.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_rounded, color: ext.expense),
                ),
                confirmDismiss: (_) => _confirmRemovePayment(p, debt),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(6)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white.withAlpha(10) : ext.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withAlpha(isDark ? 20 : 12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.payment_rounded,
                            color: accent, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${fmt.format(p.amount)} ${debt.currency}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (p.note.isNotEmpty)
                              Text(
                                p.note,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: ext.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yy', 'fr').format(p.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ext.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Future<bool> _confirmRemovePayment(DebtPayment payment, Debt debt) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce paiement ?'),
        content: const Text(
            'Le montant remboursé sera restauré sur la dette.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await context.read<DebtProvider>().removePayment(payment, debt);
      _loadPayments();
    }
    return false;
  }

  Future<void> _confirmSettle(Debt debt) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marquer comme réglé ?'),
        content: const Text(
            'Cette dette sera considérée comme entièrement remboursée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await context.read<DebtProvider>().settleDebt(debt);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete(Debt debt) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette dette ?'),
        content: const Text(
            'Cette action est irréversible. L\'historique des paiements sera également supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Supprimer',
                style: TextStyle(color: context.appTheme.expense)),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await context
          .read<DebtProvider>()
          .deleteDebt(debt.id!, mainProvider: context.read<MainProvider>());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dette "${debt.personName}" supprimée')),
        );
      }
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: ext.textTertiary),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: ext.textTertiary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PAYMENT SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PaymentSheet extends StatefulWidget {
  final Debt debt;
  const _PaymentSheet({required this.debt});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
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
    final isDark = theme.brightness == Brightness.dark;
    final accounts = context.watch<AccountProvider>().accounts;
    final fmt = NumberFormat('#,##0', 'fr');

    final isRepayingMe = widget.debt.type == DebtType.LENT;
    final title = isRepayingMe
        ? '${widget.debt.personName} rembourse'
        : 'Rembourser ${widget.debt.personName}';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
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
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reste: ${fmt.format(widget.debt.remainingAmount)} ${widget.debt.currency}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ext.textTertiary,
              ),
            ),
            const SizedBox(height: 24),

            // Account selector
            Text(
              isRepayingMe ? 'Compte de réception' : 'Compte à débiter',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...accounts.map((acc) {
              final selected = _selectedAccount?.id == acc.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedAccount = acc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary.withAlpha(isDark ? 25 : 12)
                        : isDark
                            ? Colors.white.withAlpha(6)
                            : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : isDark
                              ? Colors.white.withAlpha(10)
                              : ext.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acc.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${fmt.format(acc.currentBalance)} ${acc.currencySymbol}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: ext.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Amount
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Montant',
                suffixText: widget.debt.currency,
                hintText: '0',
              ),
            ),
            const SizedBox(height: 14),

            // Note
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                hintText: 'Ex: Paiement partiel',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Submit
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
                        'Confirmer le paiement',
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
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide')),
      );
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un compte')),
      );
      return;
    }
    if (amount > widget.debt.remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Le montant dépasse le reste de la dette')),
      );
      return;
    }

    // For BORROWED debts (I'm paying back), check account balance
    if (widget.debt.type == DebtType.BORROWED &&
        amount > _selectedAccount!.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solde insuffisant sur ce compte')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final categories = context.read<CategoryProvider>().categories;
    int categoryId;
    if (widget.debt.type == DebtType.LENT) {
      categoryId = categories
              .where((c) => c.name == 'Loan Repayment')
              .firstOrNull
              ?.id ??
          categories
              .where((c) => c.type == CategoryType.INCOME)
              .first
              .id!;
    } else {
      categoryId = categories
              .where((c) => c.name == 'Remboursement dette')
              .firstOrNull
              ?.id ??
          categories
              .where((c) => c.type == CategoryType.EXPENSE)
              .first
              .id!;
    }

    final success = await context.read<DebtProvider>().recordPayment(
          debt: widget.debt,
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
                'Paiement de ${NumberFormat('#,##0', 'fr').format(amount)} ${widget.debt.currency} enregistré'),
          ),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du paiement')),
        );
      }
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DEBT FORM SHEET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DebtFormSheet extends StatefulWidget {
  final Debt? debt;
  const _DebtFormSheet({this.debt});

  @override
  State<_DebtFormSheet> createState() => _DebtFormSheetState();
}

class _DebtFormSheetState extends State<_DebtFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DebtType _type = DebtType.LENT;
  Account? _selectedAccount;
  DateTime? _dueDate;
  bool _isSaving = false;

  bool get _isEdit => widget.debt != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final d = widget.debt!;
      _nameCtrl.text = d.personName;
      _amountCtrl.text = d.totalAmount.toStringAsFixed(0);
      _descCtrl.text = d.description;
      _type = d.type;
      _dueDate = d.dueDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final accounts = context.watch<AccountProvider>().accounts;
    final fmt = NumberFormat('#,##0', 'fr');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 20),
              Text(
                _isEdit ? 'Modifier la dette' : 'Nouvelle dette',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // Type toggle
              if (!_isEdit) ...[
                Text(
                  'Type',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TypeToggle(
                        label: 'J\'ai prêté',
                        subtitle: 'On me doit',
                        icon: Icons.arrow_downward_rounded,
                        isSelected: _type == DebtType.LENT,
                        color: const Color(0xFF00C9A7),
                        onTap: () => setState(() => _type = DebtType.LENT),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeToggle(
                        label: 'J\'ai emprunté',
                        subtitle: 'Je dois',
                        icon: Icons.arrow_upward_rounded,
                        isSelected: _type == DebtType.BORROWED,
                        color: const Color(0xFFFF7B7B),
                        onTap: () => setState(() => _type = DebtType.BORROWED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Person name
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: _type == DebtType.LENT
                      ? 'Nom de l\'emprunteur'
                      : 'Nom du créancier',
                  prefixIcon: const Icon(Icons.person_rounded),
                  hintText: 'Ex: Jean',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 14),

              // Amount
              if (!_isEdit) ...[
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    suffixText: _selectedAccount?.currencySymbol ?? 'BIF',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Montant invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],

              // Account selector (only for new debts)
              if (!_isEdit) ...[
                Text(
                  _type == DebtType.LENT
                      ? 'Compte à débiter'
                      : 'Compte de réception',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ...accounts.map((acc) {
                  final selected = _selectedAccount?.id == acc.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAccount = acc),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                                .withAlpha(isDark ? 25 : 12)
                            : isDark
                                ? Colors.white.withAlpha(6)
                                : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : isDark
                                  ? Colors.white.withAlpha(10)
                                  : ext.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${fmt.format(acc.currentBalance)} ${acc.currencySymbol}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: ext.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),
              ],

              // Description
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  hintText: 'Ex: Achat au marché',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),

              // Due date
              GestureDetector(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Échéance (optionnel)',
                    prefixIcon: Icon(Icons.event_rounded),
                  ),
                  child: Text(
                    _dueDate != null
                        ? DateFormat('dd MMMM yyyy', 'fr').format(_dueDate!)
                        : 'Aucune échéance',
                    style: TextStyle(
                      color: _dueDate != null ? null : context.appTheme.textTertiary,
                    ),
                  ),
                ),
              ),
              if (_dueDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _dueDate = null),
                    child: const Text('Retirer l\'échéance'),
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
                          _isEdit ? 'Enregistrer' : 'Créer la dette',
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
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEdit) {
      setState(() => _isSaving = true);
      var updated = widget.debt!.copyWith(
        personName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
      if (_dueDate != widget.debt!.dueDate) {
        updated = _dueDate == null
            ? updated.clearDueDate()
            : updated.copyWith(dueDate: _dueDate);
      }
      await context.read<DebtProvider>().updateDebt(updated);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${_nameCtrl.text}" mis à jour')),
        );
      }
      return;
    }

    // New debt
    final categoryProvider = context.read<CategoryProvider>();
    if (categoryProvider.isLoading || categoryProvider.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catégories non chargées. Réessayez dans un instant.'),
        ),
      );
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un compte')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    // For LENT debts, check account balance
    if (_type == DebtType.LENT &&
        amount > _selectedAccount!.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solde insuffisant sur ce compte')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final categories = categoryProvider.categories;
    int categoryId;
    if (_type == DebtType.LENT) {
      final fromName =
          categories.where((c) => c.name == 'Prêt accordé').firstOrNull?.id;
      final fromType = categories
          .where((c) => c.type == CategoryType.EXPENSE)
          .firstOrNull
          ?.id;
      final picked = fromName ?? fromType;
      if (picked == null) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune catégorie de dépense trouvée.')),
        );
        return;
      }
      categoryId = picked;
    } else {
      final fromName =
          categories.where((c) => c.name == 'Other Income').firstOrNull?.id;
      final fromType =
          categories.where((c) => c.type == CategoryType.INCOME).firstOrNull?.id;
      final picked = fromName ?? fromType;
      if (picked == null) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune catégorie de revenu trouvée.')),
        );
        return;
      }
      categoryId = picked;
    }

    final success = await context.read<DebtProvider>().addDebt(
          personName: _nameCtrl.text.trim(),
          type: _type,
          amount: amount,
          accountId: _selectedAccount!.id!,
          categoryId: categoryId,
          currency: _selectedAccount!.currency.symbol,
          description: _descCtrl.text.trim(),
          dueDate: _dueDate,
          transactionProvider: context.read<TransactionProvider>(),
          mainProvider: context.read<MainProvider>(),
        );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dette "${_nameCtrl.text}" créée')),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création')),
        );
      }
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TYPE TOGGLE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _TypeToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(isDark ? 25 : 15)
              : isDark
                  ? Colors.white.withAlpha(6)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : theme.colorScheme.onSurfaceVariant, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? color.withAlpha(180)
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
