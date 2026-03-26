import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../providers/recurring_transaction_provider.dart';
import '../../domain/entities/recurring_transaction.dart';

class FinancialCalendarView extends StatefulWidget {
  const FinancialCalendarView({super.key});

  @override
  State<FinancialCalendarView> createState() => _FinancialCalendarViewState();
}

class _FinancialCalendarViewState extends State<FinancialCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    final transactions = context.watch<TransactionProvider>().transactions;
    final rtProvider = context.watch<RecurringTransactionProvider>();
    final categories = context.watch<CategoryProvider>().categories;
    final categoryMap = {for (final c in categories) c.id: c};

    // Group transactions by day
    final txByDay = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      txByDay.putIfAbsent(key, () => []).add(t);
    }

    // Project recurring occurrences for the focused month
    final monthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final monthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final recurringByDay = <DateTime, List<RecurringTransaction>>{};
    for (final rt in rtProvider.activeItems) {
      final dates = rt.projectOccurrences(monthStart, monthEnd);
      for (final d in dates) {
        final key = DateTime(d.year, d.month, d.day);
        recurringByDay.putIfAbsent(key, () => []).add(rt);
      }
    }

    // Events for selected day
    final selectedKey = _selectedDay != null
        ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
        : null;
    final dayTransactions = selectedKey != null ? (txByDay[selectedKey] ?? []) : <Transaction>[];
    final dayRecurring =
        selectedKey != null ? (recurringByDay[selectedKey] ?? []) : <RecurringTransaction>[];

    return Column(
      children: [
        // Calendar
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(8) : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(15) : ext.border,
            ),
          ),
          child: TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            locale: 'fr',
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focused) {
              setState(() => _focusedDay = focused);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final key = DateTime(date.year, date.month, date.day);
                final hasTx = txByDay.containsKey(key);
                final hasRecurring = recurringByDay.containsKey(key);
                if (!hasTx && !hasRecurring) return null;

                final markers = <Widget>[];
                if (hasTx) {
                  final dayTxs = txByDay[key]!;
                  final hasExpense = dayTxs.any(
                    (t) => t.transactionType == TransactionType.OUTGOING,
                  );
                  final hasIncome = dayTxs.any(
                    (t) => t.transactionType == TransactionType.INCOMING,
                  );
                  if (hasExpense) markers.add(_dot(ext.expense));
                  if (hasIncome) markers.add(_dot(ext.income));
                }
                if (hasRecurring) {
                  markers.add(_dot(theme.colorScheme.primary));
                }

                return Positioned(
                  bottom: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: markers,
                  ),
                );
              },
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: theme.colorScheme.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(40),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              defaultTextStyle: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ext.textTertiary,
              ),
              weekendStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ext.textTertiary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Day details
        Expanded(
          child: _DayDetailList(
            transactions: dayTransactions,
            recurringItems: dayRecurring,
            categoryMap: categoryMap,
            selectedDay: _selectedDay,
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─────────────── Day Detail List ───────────────

class _DayDetailList extends StatelessWidget {
  final List<Transaction> transactions;
  final List<RecurringTransaction> recurringItems;
  final Map<int?, Category> categoryMap;
  final DateTime? selectedDay;

  const _DayDetailList({
    required this.transactions,
    required this.recurringItems,
    required this.categoryMap,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    if (transactions.isEmpty && recurringItems.isEmpty) {
      return Center(
        child: selectedDay != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    size: 40,
                    color: ext.textTertiary.withAlpha(100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rien pour ce jour',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ext.textTertiary,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        if (selectedDay != null) ...[
          Text(
            DateFormat('EEEE dd MMMM', 'fr').format(selectedDay!),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Past transactions
        ...transactions.map((t) {
          final cat = categoryMap[t.categoryId];
          final isExpense = t.transactionType == TransactionType.OUTGOING;
          final isTransfer = t.transactionType == TransactionType.TRANSFER;
          final Color color;
          if (isTransfer) {
            color = theme.colorScheme.primary;
          } else {
            color = isExpense ? ext.expense : ext.income;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 30 : 15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isTransfer
                      ? Icon(Icons.swap_horiz_rounded, color: color, size: 18)
                      : Text(
                          cat?.icon ?? '📌',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${isExpense ? '-' : isTransfer ? '~' : '+'} ${_fmt(t.amount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),

        // Recurring projections
        ...recurringItems.map((rt) {
          final isExpense = rt.transactionType == TransactionType.OUTGOING;
          final color = isExpense ? ext.expense : ext.income;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(isDark ? 15 : 8),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 25),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.replay_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rt.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Prévu · ${rt.frequency.label}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isExpense ? '-' : '+'} ${_fmt(rt.amount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────── Helpers ───────────────

String _fmt(double amount) {
  final formatter = NumberFormat('#,##0', 'fr');
  return formatter.format(amount);
}
