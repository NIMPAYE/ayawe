class GoalContribution {
  final int? id;
  final int goalId;
  final int accountId;
  final int? transactionId;
  final double amount;
  final DateTime date;
  final String note;

  const GoalContribution({
    this.id,
    required this.goalId,
    required this.accountId,
    this.transactionId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  GoalContribution copyWith({
    int? id,
    int? goalId,
    int? accountId,
    int? transactionId,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return GoalContribution(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      accountId: accountId ?? this.accountId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoalContribution &&
        other.id == id &&
        other.goalId == goalId &&
        other.accountId == accountId &&
        other.transactionId == transactionId &&
        other.amount == amount &&
        other.date == date &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        goalId.hashCode ^
        accountId.hashCode ^
        transactionId.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        note.hashCode;
  }

  @override
  String toString() {
    return 'GoalContribution(id: $id, goalId: $goalId, amount: $amount, date: $date)';
  }
}
