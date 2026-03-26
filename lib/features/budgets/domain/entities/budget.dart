class Budget {
  final int? id;
  final int categoryId;
  final double amount;
  final String month; // 'YYYY-MM'
  final double rolloverAmount;

  const Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    this.rolloverAmount = 0.0,
  });

  double get effectiveAmount => amount + rolloverAmount;

  Budget copyWith({
    int? id,
    int? categoryId,
    double? amount,
    String? month,
    double? rolloverAmount,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.amount == amount &&
        other.month == month &&
        other.rolloverAmount == rolloverAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        amount.hashCode ^
        month.hashCode ^
        rolloverAmount.hashCode;
  }

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, amount: $amount, month: $month, rolloverAmount: $rolloverAmount)';
  }
}
