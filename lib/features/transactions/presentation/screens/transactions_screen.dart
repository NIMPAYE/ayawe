import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/transaction_provider.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    final transactions = context.watch<TransactionProvider>().transactions;
    final categories = context.watch<CategoryProvider>().categories;
    final accounts = context.watch<AccountProvider>().accounts;

    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by month
    final grouped = <String, List<Transaction>>{};
    for (final t in sorted) {
      final key = DateFormat('MMMM yyyy', 'fr').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: sorted.isEmpty
          ? _buildEmpty(context)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: grouped.length,
              itemBuilder: (context, sectionIndex) {
                final month = grouped.keys.elementAt(sectionIndex);
                final items = grouped[month]!;

                // Section total
                final income = items
                    .where(
                        (t) => t.transactionType == TransactionType.INCOMING)
                    .fold(0.0, (s, t) => s + t.amount);
                final expense = items
                    .where(
                        (t) => t.transactionType == TransactionType.OUTGOING)
                    .fold(0.0, (s, t) => s + t.amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sectionIndex > 0) const SizedBox(height: 12),
                    // Month header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            month[0].toUpperCase() + month.substring(1),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '+${_fmt(income)}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: ext.income,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '-${_fmt(expense)}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: ext.expense,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Transaction cards
                    ...items.map((t) {
                      final account = accountMap[t.accountId];
                      return TransactionCard(
                        transaction: t,
                        category: categoryMap[t.categoryId],
                        currency: account?.currencySymbol ?? 'BIF',
                      );
                    }),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_tx',
        onPressed: () => Navigator.pushNamed(context, '/add_transaction'),
        child: const Icon(Icons.add_rounded),
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
              'Commencez à enregistrer vos dépenses et revenus.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ext.textTertiary,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add_transaction'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter une transaction'),
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
