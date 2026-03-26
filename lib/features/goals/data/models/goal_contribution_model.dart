import '../../domain/entities/goal_contribution.dart';

class GoalContributionModel extends GoalContribution {
  const GoalContributionModel({
    super.id,
    required super.goalId,
    required super.accountId,
    super.transactionId,
    required super.amount,
    required super.date,
    super.note,
  });

  factory GoalContributionModel.fromEntity(GoalContribution entity) {
    return GoalContributionModel(
      id: entity.id,
      goalId: entity.goalId,
      accountId: entity.accountId,
      transactionId: entity.transactionId,
      amount: entity.amount,
      date: entity.date,
      note: entity.note,
    );
  }

  factory GoalContributionModel.fromMap(Map<String, dynamic> map) {
    return GoalContributionModel(
      id: map['id'],
      goalId: map['goal_id'],
      accountId: map['account_id'],
      transactionId: map['transaction_id'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'account_id': accountId,
      'transaction_id': transactionId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  GoalContribution toEntity() {
    return GoalContribution(
      id: id,
      goalId: goalId,
      accountId: accountId,
      transactionId: transactionId,
      amount: amount,
      date: date,
      note: note,
    );
  }
}
