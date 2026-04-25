import '../../accounts/domain/entities/account.dart';
import '../../categories/domain/entities/category.dart';
import '../../transactions/domain/entities/transaction.dart';
import 'stats_models.dart';

/// Agrégations pures pour les statistiques (hors UI).
class StatsAggregator {
  StatsAggregator._();

  /// Seuil de montant max(mois courant, mois précédent) pour filtrer le bruit.
  static const double noiseAmountThreshold = 500;

  /// Variation minimale en % (quand le % est défini) pour afficher une tendance.
  static const double noisePercentThreshold = 5;

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime addMonths(DateTime monthStart, int delta) =>
      DateTime(monthStart.year, monthStart.month + delta, 1);

  /// Six mois calendaires se terminant par le mois de [reference] (inclus).
  static List<DateTime> lastSixMonthStarts(DateTime reference) {
    final first = startOfMonth(reference);
    return List.generate(6, (i) => addMonths(first, i - 5));
  }

  static bool _inMonthRange(
    DateTime transactionDay,
    DateTime monthStartInclusive,
    DateTime nextMonthStart,
  ) {
    return !transactionDay.isBefore(monthStartInclusive) &&
        transactionDay.isBefore(nextMonthStart);
  }

  /// Revenus vs dépenses par mois. Les transferts sont exclus.
  static List<MonthlyCashFlowPoint> cashFlowLast6Months(
    List<Transaction> transactions,
    DateTime reference,
  ) {
    final months = lastSixMonthStarts(reference);
    final points = <MonthlyCashFlowPoint>[];

    for (final m in months) {
      final next = addMonths(m, 1);
      var income = 0.0;
      var expense = 0.0;

      for (final t in transactions) {
        if (t.transactionType == TransactionType.TRANSFER) continue;
        final day = startOfDay(t.date);
        if (!_inMonthRange(day, m, next)) continue;
        switch (t.transactionType) {
          case TransactionType.INCOMING:
            income += t.amount;
            break;
          case TransactionType.OUTGOING:
            expense += t.amount;
            break;
          case TransactionType.TRANSFER:
            break;
        }
      }
      points.add(MonthlyCashFlowPoint(
        month: m,
        income: income,
        expense: expense,
      ));
    }
    return points;
  }

  /// Dépenses [OUTGOING] pour une catégorie dépense sur une année (12 mois).
  static CategoryMonthlySeries categoryExpenseYearSeries(
    List<Transaction> transactions,
    Category category,
    int year,
  ) {
    final amounts = List<double>.filled(12, 0);
    final id = category.id;
    if (id == null) {
      return CategoryMonthlySeries(
        categoryId: -1,
        categoryName: category.name,
        year: year,
        monthlyAmounts: amounts,
      );
    }

    for (final t in transactions) {
      if (t.transactionType != TransactionType.OUTGOING) continue;
      if (t.categoryId != id) continue;
      if (t.date.year != year) continue;
      amounts[t.date.month - 1] += t.amount;
    }

    return CategoryMonthlySeries(
      categoryId: id,
      categoryName: category.name,
      year: year,
      monthlyAmounts: amounts,
    );
  }

  /// Tendances mois courant vs mois précédent (catégories dépense uniquement).
  static List<TrendInsight> expenseTrendsMonthOverMonth(
    List<Transaction> transactions,
    List<Category> expenseCategories,
    DateTime reference,
  ) {
    final curStart = startOfMonth(reference);
    final curEnd = addMonths(curStart, 1);
    final prevStart = addMonths(curStart, -1);

    final insights = <TrendInsight>[];

    for (final c in expenseCategories) {
      final id = c.id;
      if (id == null) continue;

      var current = 0.0;
      var previous = 0.0;

      for (final t in transactions) {
        if (t.transactionType != TransactionType.OUTGOING) continue;
        if (t.categoryId != id) continue;
        final day = startOfDay(t.date);
        if (_inMonthRange(day, curStart, curEnd)) {
          current += t.amount;
        } else if (_inMonthRange(day, prevStart, curStart)) {
          previous += t.amount;
        }
      }

      if (current == 0 && previous == 0) continue;

      final firstThis = previous == 0 && current > 0;
      double? pct;
      TrendDirection dir = TrendDirection.neutral;

      if (previous > 0) {
        final rawPct = ((current - previous) / previous) * 100;
        if (rawPct.abs() < noisePercentThreshold &&
            (current - previous).abs() < noiseAmountThreshold) {
          continue;
        }
        pct = rawPct;
        if (rawPct > 0) {
          dir = TrendDirection.increase;
        } else if (rawPct < 0) {
          dir = TrendDirection.decrease;
        }
      } else if (firstThis) {
        dir = TrendDirection.increase;
      } else if (current == 0 && previous > 0) {
        pct = -100;
        dir = TrendDirection.decrease;
        if (previous < noiseAmountThreshold) continue;
      }

      insights.add(TrendInsight(
        categoryId: id,
        categoryName: c.name,
        currentMonthTotal: current,
        previousMonthTotal: previous,
        percentChange: pct,
        direction: dir,
        firstActivityThisMonth: firstThis,
      ));
    }

    insights.sort((a, b) {
      final da = a.percentChange != null
          ? a.percentChange!.abs()
          : a.currentMonthTotal;
      final db = b.percentChange != null
          ? b.percentChange!.abs()
          : b.currentMonthTotal;
      return db.compareTo(da);
    });

    return insights;
  }

  static List<Category> expenseCategoriesOnly(List<Category> categories) {
    return categories
        .where((c) => c.type == CategoryType.EXPENSE && c.id != null)
        .toList();
  }

  static Map<int, Currency> _accountIdToCurrency(List<Account> accounts) {
    final map = <int, Currency>{};
    for (final a in accounts) {
      final id = a.id;
      if (id != null) map[id] = a.currency;
    }
    return map;
  }

  static bool _matchesCurrency(
    Transaction t,
    Map<int, Currency> accountCurrency,
    Currency currency,
  ) {
    return accountCurrency[t.accountId] == currency;
  }

  /// Jours calendaires du mois de [monthReference] (1er … dernier).
  static List<DateTime> daysInMonth(DateTime monthReference) {
    final start = startOfMonth(monthReference);
    final end = addMonths(start, 1);
    final days = <DateTime>[];
    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  /// Revenus et dépenses du mois (hors transferts), comptes [currency] uniquement.
  static MonthSummaryTotals monthSummaryForCurrency(
    List<Transaction> transactions,
    List<Account> accounts,
    Currency currency,
    DateTime monthReference,
  ) {
    final accCur = _accountIdToCurrency(accounts);
    final monthStart = startOfMonth(monthReference);
    final monthEnd = addMonths(monthStart, 1);
    var income = 0.0;
    var expense = 0.0;

    for (final t in transactions) {
      if (t.transactionType == TransactionType.TRANSFER) continue;
      if (!_matchesCurrency(t, accCur, currency)) continue;
      final day = startOfDay(t.date);
      if (!_inMonthRange(day, monthStart, monthEnd)) continue;
      switch (t.transactionType) {
        case TransactionType.INCOMING:
          income += t.amount;
          break;
        case TransactionType.OUTGOING:
          expense += t.amount;
          break;
        case TransactionType.TRANSFER:
          break;
      }
    }
    return MonthSummaryTotals(income: income, expense: expense);
  }

  /// Une entrée par jour du mois (0 si aucune opération ce jour-là).
  static List<DailyCashPoint> dailySeriesForMonthCurrency(
    List<Transaction> transactions,
    List<Account> accounts,
    Currency currency,
    DateTime monthReference,
  ) {
    final accCur = _accountIdToCurrency(accounts);
    final monthStart = startOfMonth(monthReference);
    final monthEnd = addMonths(monthStart, 1);
    final days = daysInMonth(monthReference);
    final incomeByDay = <int, double>{};
    final expenseByDay = <int, double>{};

    for (final t in transactions) {
      if (t.transactionType == TransactionType.TRANSFER) continue;
      if (!_matchesCurrency(t, accCur, currency)) continue;
      final day = startOfDay(t.date);
      if (!_inMonthRange(day, monthStart, monthEnd)) continue;
      final key = day.millisecondsSinceEpoch;
      switch (t.transactionType) {
        case TransactionType.INCOMING:
          incomeByDay[key] = (incomeByDay[key] ?? 0) + t.amount;
          break;
        case TransactionType.OUTGOING:
          expenseByDay[key] = (expenseByDay[key] ?? 0) + t.amount;
          break;
        case TransactionType.TRANSFER:
          break;
      }
    }

    return days
        .map(
          (d) => DailyCashPoint(
            day: d,
            income: incomeByDay[d.millisecondsSinceEpoch] ?? 0,
            expense: expenseByDay[d.millisecondsSinceEpoch] ?? 0,
          ),
        )
        .toList();
  }

  /// Dépenses OUTGOING par catégorie dépense, tri décroissant par montant.
  static List<ExpenseCategoryBreakdown> expenseBreakdownMonthCurrency(
    List<Transaction> transactions,
    List<Account> accounts,
    List<Category> categories,
    Currency currency,
    DateTime monthReference,
  ) {
    final accCur = _accountIdToCurrency(accounts);
    final monthStart = startOfMonth(monthReference);
    final monthEnd = addMonths(monthStart, 1);
    final expenseCats = expenseCategoriesOnly(categories);
    final nameById = <int, String>{
      for (final c in expenseCats)
        if (c.id != null) c.id!: c.name,
    };
    final totals = <int, double>{};

    for (final t in transactions) {
      if (t.transactionType != TransactionType.OUTGOING) continue;
      if (!_matchesCurrency(t, accCur, currency)) continue;
      final day = startOfDay(t.date);
      if (!_inMonthRange(day, monthStart, monthEnd)) continue;
      final id = t.categoryId;
      if (!nameById.containsKey(id)) continue;
      totals[id] = (totals[id] ?? 0) + t.amount;
    }

    final list = totals.entries
        .map(
          (e) => ExpenseCategoryBreakdown(
            categoryId: e.key,
            categoryName: nameById[e.key] ?? '—',
            amount: e.value,
          ),
        )
        .toList();
    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }
}
