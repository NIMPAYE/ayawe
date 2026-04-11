// Données agrégées pour l’écran Statistiques (cash flow, catégories, tendances).

class MonthlyCashFlowPoint {
  /// Premier jour du mois (normalisé).
  final DateTime month;
  final double income;
  final double expense;

  const MonthlyCashFlowPoint({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}

class CategoryMonthlySeries {
  final int categoryId;
  final String categoryName;
  final int year;
  /// Index 0 = janvier … 11 = décembre.
  final List<double> monthlyAmounts;

  CategoryMonthlySeries({
    required this.categoryId,
    required this.categoryName,
    required this.year,
    required this.monthlyAmounts,
  }) : assert(monthlyAmounts.length == 12);

  double get yearlyTotal =>
      monthlyAmounts.fold<double>(0, (a, b) => a + b);
}

enum TrendDirection { increase, decrease, neutral }

class TrendInsight {
  final int categoryId;
  final String categoryName;
  final double currentMonthTotal;
  final double previousMonthTotal;
  /// `null` si [previousMonthTotal] == 0 (pas de base pour un pourcentage).
  final double? percentChange;
  final TrendDirection direction;
  final bool firstActivityThisMonth;

  const TrendInsight({
    required this.categoryId,
    required this.categoryName,
    required this.currentMonthTotal,
    required this.previousMonthTotal,
    required this.percentChange,
    required this.direction,
    required this.firstActivityThisMonth,
  });
}
