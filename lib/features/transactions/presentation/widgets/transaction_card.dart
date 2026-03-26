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
  final String? toAccountName;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.category,
    this.currency = 'BIF',
    this.toAccountName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final isTransfer = transaction.transactionType == TransactionType.TRANSFER;
    final isExpense = transaction.transactionType == TransactionType.OUTGOING;

    final Color color;
    final String sign;
    final String iconFallback;

    if (isTransfer) {
      color = theme.colorScheme.primary;
      sign = '~';
      iconFallback = '🔄';
    } else if (isExpense) {
      color = ext.expense;
      sign = '-';
      iconFallback = '📤';
    } else {
      color = ext.income;
      sign = '+';
      iconFallback = '📥';
    }

    final subtitle = isTransfer && toAccountName != null
        ? 'vers $toAccountName'
        : DateFormat('dd MMM yyyy').format(transaction.date);

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
              child: isTransfer
                  ? Icon(Icons.swap_horiz_rounded,
                      color: theme.colorScheme.primary, size: 22)
                  : Text(
                      category?.icon ?? iconFallback,
                      style: const TextStyle(fontSize: 20),
                    ),
            ),
            const SizedBox(width: 14),

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
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.textTertiary,
                    ),
                  ),
                  if (isTransfer) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy').format(transaction.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ext.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isTransfer && category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 30 : 15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category!.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (isTransfer)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 30 : 15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Transfert',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isTransfer) const SizedBox(height: 4),
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
