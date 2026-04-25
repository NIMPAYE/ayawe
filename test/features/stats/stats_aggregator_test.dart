import 'package:ayawe/features/accounts/domain/entities/account.dart';
import 'package:ayawe/features/categories/domain/entities/category.dart';
import 'package:ayawe/features/stats/domain/stats_aggregator.dart';
import 'package:ayawe/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final transport = Category(
    id: 1,
    name: 'Transport',
    type: CategoryType.EXPENSE,
    icon: 'car',
  );

  group('StatsAggregator.cashFlowLast6Months', () {
    test('excludes TRANSFER and sums INCOMING and OUTGOING per month', () {
      final ref = DateTime(2026, 4, 15);
      final txs = [
        Transaction(
          accountId: 1,
          categoryId: 2,
          amount: 1000,
          date: DateTime(2026, 4, 10),
          description: 'salaire',
          transactionType: TransactionType.INCOMING,
        ),
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 200,
          date: DateTime(2026, 4, 5),
          description: 'bus',
          transactionType: TransactionType.OUTGOING,
        ),
        Transaction(
          accountId: 1,
          toAccountId: 2,
          categoryId: 0,
          amount: 500,
          date: DateTime(2026, 4, 3),
          description: 'transfert',
          transactionType: TransactionType.TRANSFER,
        ),
      ];

      final points = StatsAggregator.cashFlowLast6Months(txs, ref);
      expect(points.length, 6);
      final april = points.last;
      expect(april.month, DateTime(2026, 4, 1));
      expect(april.income, 1000);
      expect(april.expense, 200);
      expect(april.net, 800);
    });
  });

  group('StatsAggregator.categoryExpenseYearSeries', () {
    test('aggregates OUTGOING by month for category and year', () {
      final txs = [
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 100,
          date: DateTime(2026, 3, 10),
          description: 'a',
          transactionType: TransactionType.OUTGOING,
        ),
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 50,
          date: DateTime(2026, 3, 20),
          description: 'b',
          transactionType: TransactionType.OUTGOING,
        ),
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 999,
          date: DateTime(2025, 3, 1),
          description: 'old year',
          transactionType: TransactionType.OUTGOING,
        ),
      ];

      final series = StatsAggregator.categoryExpenseYearSeries(
        txs,
        transport,
        2026,
      );

      expect(series.yearlyTotal, 150);
      expect(series.monthlyAmounts[2], 150); // March index 2
      expect(series.monthlyAmounts[0], 0);
    });
  });

  group('StatsAggregator.expenseTrendsMonthOverMonth', () {
    test('first activity this month when previous month was zero', () {
      final ref = DateTime(2026, 4, 10);
      final txs = [
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 80,
          date: DateTime(2026, 4, 2),
          description: 'x',
          transactionType: TransactionType.OUTGOING,
        ),
      ];

      final insights = StatsAggregator.expenseTrendsMonthOverMonth(
        txs,
        [transport],
        ref,
      );

      expect(insights, isNotEmpty);
      final i = insights.firstWhere((e) => e.categoryId == 1);
      expect(i.firstActivityThisMonth, isTrue);
      expect(i.percentChange, isNull);
      expect(i.currentMonthTotal, 80);
      expect(i.previousMonthTotal, 0);
    });

    test('computes percent when previous month had spend', () {
      final ref = DateTime(2026, 4, 10);
      final txs = [
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 100,
          date: DateTime(2026, 3, 15),
          description: 'march',
          transactionType: TransactionType.OUTGOING,
        ),
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 120,
          date: DateTime(2026, 4, 5),
          description: 'april',
          transactionType: TransactionType.OUTGOING,
        ),
      ];

      final insights = StatsAggregator.expenseTrendsMonthOverMonth(
        txs,
        [transport],
        ref,
      );

      final i = insights.firstWhere((e) => e.categoryId == 1);
      expect(i.previousMonthTotal, 100);
      expect(i.currentMonthTotal, 120);
      expect(i.percentChange, closeTo(20, 0.01));
    });
  });

  group('StatsAggregator.lastSixMonthStarts', () {
    test('returns six month starts ending at reference month', () {
      final ref = DateTime(2026, 4, 20);
      final starts = StatsAggregator.lastSixMonthStarts(ref);
      expect(starts.first, DateTime(2025, 11, 1));
      expect(starts.last, DateTime(2026, 4, 1));
    });
  });

  final bifAccount = Account(
    id: 1,
    name: 'Cash BIF',
    type: AccountType.CASH,
    currentBalance: 0,
    currency: Currency.BIF,
  );
  final usdAccount = Account(
    id: 2,
    name: 'Bank USD',
    type: AccountType.BANK,
    currentBalance: 0,
    currency: Currency.USD,
  );

  group('StatsAggregator.monthSummaryForCurrency', () {
    test('only includes transactions on accounts with selected currency', () {
      final monthRef = DateTime(2026, 4, 5);
      final txs = [
        Transaction(
          accountId: 1,
          categoryId: 2,
          amount: 500,
          date: DateTime(2026, 4, 10),
          description: 'in',
          transactionType: TransactionType.INCOMING,
        ),
        Transaction(
          accountId: 2,
          categoryId: 2,
          amount: 999,
          date: DateTime(2026, 4, 11),
          description: 'usd in',
          transactionType: TransactionType.INCOMING,
        ),
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 100,
          date: DateTime(2026, 4, 12),
          description: 'out',
          transactionType: TransactionType.OUTGOING,
        ),
      ];
      final accounts = [bifAccount, usdAccount];

      final bif = StatsAggregator.monthSummaryForCurrency(
        txs,
        accounts,
        Currency.BIF,
        monthRef,
      );
      expect(bif.income, 500);
      expect(bif.expense, 100);

      final usd = StatsAggregator.monthSummaryForCurrency(
        txs,
        accounts,
        Currency.USD,
        monthRef,
      );
      expect(usd.income, 999);
      expect(usd.expense, 0);
    });
  });

  group('StatsAggregator.dailySeriesForMonthCurrency', () {
    test('returns one point per calendar day with sums', () {
      final monthRef = DateTime(2026, 4, 15);
      final txs = [
        Transaction(
          accountId: 1,
          categoryId: 2,
          amount: 300,
          date: DateTime(2026, 4, 1, 14, 0),
          description: 'in',
          transactionType: TransactionType.INCOMING,
        ),
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 50,
          date: DateTime(2026, 4, 1, 8, 0),
          description: 'out',
          transactionType: TransactionType.OUTGOING,
        ),
      ];
      final daily = StatsAggregator.dailySeriesForMonthCurrency(
        txs,
        [bifAccount],
        Currency.BIF,
        monthRef,
      );
      expect(daily.length, 30);
      final first = daily.first;
      expect(first.day, DateTime(2026, 4, 1));
      expect(first.income, 300);
      expect(first.expense, 50);
      expect(daily[1].income, 0);
      expect(daily[1].expense, 0);
    });
  });

  group('StatsAggregator.expenseBreakdownMonthCurrency', () {
    test('aggregates OUTGOING by expense category for month and currency', () {
      final monthRef = DateTime(2026, 4, 1);
      final food = Category(
        id: 2,
        name: 'Food',
        type: CategoryType.EXPENSE,
        icon: 'f',
      );
      final txs = [
        Transaction(
          accountId: 1,
          categoryId: 1,
          amount: 40,
          date: DateTime(2026, 4, 10),
          description: 't',
          transactionType: TransactionType.OUTGOING,
        ),
        Transaction(
          accountId: 1,
          categoryId: 2,
          amount: 60,
          date: DateTime(2026, 4, 11),
          description: 'f',
          transactionType: TransactionType.OUTGOING,
        ),
      ];
      final rows = StatsAggregator.expenseBreakdownMonthCurrency(
        txs,
        [bifAccount],
        [transport, food],
        Currency.BIF,
        monthRef,
      );
      expect(rows.length, 2);
      expect(rows[0].amount, 60);
      expect(rows[0].categoryName, 'Food');
      expect(rows[1].amount, 40);
      expect(rows[1].categoryName, 'Transport');
    });
  });
}
