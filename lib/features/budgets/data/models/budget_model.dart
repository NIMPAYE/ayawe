import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    super.id,
    required super.categoryId,
    required super.amount,
    required super.month,
    super.rolloverAmount,
  });

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      month: entity.month,
      rolloverAmount: entity.rolloverAmount,
    );
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      categoryId: map['category_id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      month: map['month'],
      rolloverAmount: map['rollover_amount']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'month': month,
      'rollover_amount': rolloverAmount,
    };
  }

  Budget toEntity() {
    return Budget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      month: month,
      rolloverAmount: rolloverAmount,
    );
  }
}
