import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final String currency;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.category,
    this.currency = 'BIF',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final isExpense = transaction.transactionType == TransactionType.OUTGOING;
    final color = isExpense ? ext.expense : ext.income;
    final sign = isExpense ? '-' : '+';

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Category icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(12)
                    : ext.emptyState,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                category?.icon ?? (isExpense ? '📤' : '📥'),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),

            // Description + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('yyyy-MM-dd').format(transaction.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Amount
            Text(
              '$currency $sign${_fmt(transaction.amount)}',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(double amount) {
  final formatter = NumberFormat('#,##0.00', 'fr');
  return formatter.format(amount);
}
