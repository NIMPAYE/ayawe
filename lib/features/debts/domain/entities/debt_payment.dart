class DebtPayment {
  final int? id;
  final int debtId;
  final int accountId;
  final int? transactionId;
  final double amount;
  final DateTime date;
  final String note;

  const DebtPayment({
    this.id,
    required this.debtId,
    required this.accountId,
    this.transactionId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  DebtPayment copyWith({
    int? id,
    int? debtId,
    int? accountId,
    int? transactionId,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return DebtPayment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
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
    return other is DebtPayment &&
        other.id == id &&
        other.debtId == debtId &&
        other.accountId == accountId &&
        other.transactionId == transactionId &&
        other.amount == amount &&
        other.date == date &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        debtId.hashCode ^
        accountId.hashCode ^
        transactionId.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        note.hashCode;
  }

  @override
  String toString() {
    return 'DebtPayment(id: $id, debtId: $debtId, amount: $amount, date: $date)';
  }
}
