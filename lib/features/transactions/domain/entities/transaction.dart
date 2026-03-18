enum TransactionType { OUTGOING, INCOMING }

class Transaction {
  final int? id;
  final int accountId;
  final int categoryId;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionType transactionType;

  const Transaction({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.description,
    required this.transactionType,
  });

  Transaction copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? description,
    TransactionType? transactionType,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  String get typeDisplay {
    switch (transactionType) {
      case TransactionType.OUTGOING:
        return '📤 Outgoing';
      case TransactionType.INCOMING:
        return '📥 Incoming';
    }
  }

  String get amountDisplay {
    final prefix = transactionType == TransactionType.OUTGOING ? '-' : '+';
    return '$prefix ${amount.toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.amount == amount &&
        other.date == date &&
        other.description == description &&
        other.transactionType == transactionType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        accountId.hashCode ^
        categoryId.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        description.hashCode ^
        transactionType.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, accountId: $accountId, categoryId: $categoryId, amount: $amount, date: $date, description: $description, transactionType: $transactionType)';
  }
}
