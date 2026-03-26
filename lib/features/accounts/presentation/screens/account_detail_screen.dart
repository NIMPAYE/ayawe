import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/account.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../providers/account_provider.dart';

class AccountDetailScreen extends StatelessWidget {
  final Account account;
  const AccountDetailScreen({super.key, required this.account});

  static const _typeIcons = {
    AccountType.CASH: Icons.payments_outlined,
    AccountType.MOBILE_MONEY: Icons.phone_android_rounded,
    AccountType.BANK: Icons.account_balance_rounded,
  };

  static const _typeColors = {
    AccountType.CASH: Color(0xFF00C48C),
    AccountType.MOBILE_MONEY: Color(0xFFFFB800),
    AccountType.BANK: Color(0xFF6C5CE7),
  };

  static const _typeLabels = {
    AccountType.CASH: 'Cash',
    AccountType.MOBILE_MONEY: 'Mobile Money',
    AccountType.BANK: 'Banque',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _typeColors[account.type] ?? theme.colorScheme.primary;

    final allTransactions = context.watch<TransactionProvider>().transactions;
    final categories = context.watch<CategoryProvider>().categories;
    final allAccounts = context.watch<AccountProvider>().accounts;

    final accountMap = {for (final a in allAccounts) a.id: a};

    final transactions = allTransactions
        .where((t) =>
            t.accountId == account.id || t.toAccountId == account.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final categoryMap = {for (final c in categories) c.id: c};

    // Category breakdown (exclude transfers from category totals)
    final categoryTotals = <int, double>{};
    for (final t in transactions) {
      if (t.transactionType == TransactionType.TRANSFER) continue;
      categoryTotals[t.categoryId] =
          (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = transactions
        .where((t) => t.transactionType == TransactionType.OUTGOING)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalReceived = transactions
        .where((t) => t.transactionType == TransactionType.INCOMING)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalTransferOut = transactions
        .where((t) =>
            t.transactionType == TransactionType.TRANSFER &&
            t.accountId == account.id)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalTransferIn = transactions
        .where((t) =>
            t.transactionType == TransactionType.TRANSFER &&
            t.toAccountId == account.id)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          account.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: transactions.isEmpty
          ? _buildEmpty(context)
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _AccountHeader(
                  account: account,
                  accent: accent,
                  totalReceived: totalReceived,
                  totalSpent: totalSpent,
                  totalTransferIn: totalTransferIn,
                  totalTransferOut: totalTransferOut,
                ),
                const SizedBox(height: 24),

                if (sortedCategories.isNotEmpty) ...[
                  Text('Répartition par catégorie',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...sortedCategories.map((entry) {
                    final cat = categoryMap[entry.key];
                    final total = entry.value;
                    final maxAmount = sortedCategories.first.value;
                    return _CategoryBar(
                      category: cat,
                      amount: total,
                      fraction: maxAmount > 0 ? total / maxAmount : 0,
                      currency: account.currencySymbol,
                      accent: accent,
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                Text('Historique', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                ...transactions.map((t) {
                  String? peerAccountName;
                  bool isTransferIncoming = false;
                  if (t.transactionType == TransactionType.TRANSFER) {
                    isTransferIncoming = t.toAccountId == account.id;
                    final peerId =
                        isTransferIncoming ? t.accountId : t.toAccountId;
                    peerAccountName = accountMap[peerId]?.name;
                  }
                  return _TransactionTile(
                    transaction: t,
                    category: categoryMap[t.categoryId],
                    currency: account.currencySymbol,
                    currentAccountId: account.id!,
                    peerAccountName: peerAccountName,
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text('Aucune transaction', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Ce compte n\'a pas encore de transactions enregistrées.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ext.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Account Header ───────────────

class _AccountHeader extends StatelessWidget {
  final Account account;
  final Color accent;
  final double totalReceived;
  final double totalSpent;
  final double totalTransferIn;
  final double totalTransferOut;

  const _AccountHeader({
    required this.account,
    required this.accent,
    required this.totalReceived,
    required this.totalSpent,
    required this.totalTransferIn,
    required this.totalTransferOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : ext.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accent.withAlpha(isDark ? 50 : 30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AccountDetailScreen._typeIcons[account.type] ?? Icons.wallet,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AccountDetailScreen._typeLabels[account.type] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_fmt(account.currentBalance)} ${account.currencySymbol}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: account.currentBalance >= 0
                            ? ext.income
                            : ext.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Entrées',
                  amount: totalReceived,
                  currency: account.currencySymbol,
                  color: ext.income,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Sorties',
                  amount: totalSpent,
                  currency: account.currencySymbol,
                  color: ext.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),

          if (totalTransferIn > 0 || totalTransferOut > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Reçu (transfert)',
                    amount: totalTransferIn,
                    currency: account.currencySymbol,
                    color: theme.colorScheme.primary,
                    icon: Icons.call_received_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Envoyé (transfert)',
                    amount: totalTransferOut,
                    currency: account.currencySymbol,
                    color: theme.colorScheme.tertiary,
                    icon: Icons.call_made_rounded,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 20 : 12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 40 : 25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ext.textTertiary,
                  ),
                ),
                Text(
                  '${_fmt(amount)} $currency',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Category Breakdown Bar ───────────────

class _CategoryBar extends StatelessWidget {
  final Category? category;
  final double amount;
  final double fraction;
  final String currency;
  final Color accent;

  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.fraction,
    required this.currency,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : ext.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(isDark ? 40 : 20),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category?.icon ?? '📌',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category?.name ?? 'Sans catégorie',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${_fmt(amount)} $currency',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: ext.emptyState,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Transaction Tile ───────────────

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final String currency;
  final int currentAccountId;
  final String? peerAccountName;

  const _TransactionTile({
    required this.transaction,
    this.category,
    required this.currency,
    required this.currentAccountId,
    this.peerAccountName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    final isTransfer = transaction.transactionType == TransactionType.TRANSFER;
    final bool isTransferIncoming =
        isTransfer && transaction.toAccountId == currentAccountId;

    final Color color;
    final Color bgColor;
    final String sign;
    final String iconText;
    Widget? iconWidget;

    if (isTransfer) {
      color = theme.colorScheme.primary;
      bgColor = color.withAlpha(isDark ? 25 : 15);
      sign = isTransferIncoming ? '+' : '-';
      iconText = '🔄';
      iconWidget = Icon(Icons.swap_horiz_rounded, color: color, size: 20);
    } else {
      final isExpense =
          transaction.transactionType == TransactionType.OUTGOING;
      color = isExpense ? ext.expense : ext.income;
      bgColor = isExpense ? ext.expenseSurface : ext.incomeSurface;
      sign = isExpense ? '-' : '+';
      iconText = category?.icon ?? (isExpense ? '📤' : '📥');
      iconWidget = null;
    }

    final subtitleParts = <String>[];
    if (isTransfer && peerAccountName != null) {
      subtitleParts.add(isTransferIncoming
          ? 'de $peerAccountName'
          : 'vers $peerAccountName');
    }
    if (!isTransfer && category != null) {
      subtitleParts.add(category!.name);
    }
    subtitleParts.add(DateFormat('dd MMM yyyy').format(transaction.date));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : ext.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: iconWidget ??
                Text(iconText, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleParts.join(' · '),
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
            '$sign ${_fmt(transaction.amount)} $currency',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Helpers ───────────────

String _fmt(double amount) {
  final formatter = NumberFormat('#,##0', 'fr');
  return formatter.format(amount);
}
