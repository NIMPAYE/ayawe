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
}
