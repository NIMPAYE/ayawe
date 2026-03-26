enum TransactionType { OUTGOING, INCOMING, TRANSFER }

class Transaction {
  final int? id;
  final int accountId;
  final int? toAccountId;
  final int categoryId;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionType transactionType;

  const Transaction({
    this.id,
    required this.accountId,
    this.toAccountId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.description,
    required this.transactionType,
  });

  Transaction copyWith({
    int? id,
    int? accountId,
    int? toAccountId,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? description,
    TransactionType? transactionType,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
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
        return '📤 Dépense';
      case TransactionType.INCOMING:
        return '📥 Revenu';
      case TransactionType.TRANSFER:
        return '🔄 Transfert';
    }
  }

  String get amountDisplay {
    switch (transactionType) {
      case TransactionType.OUTGOING:
        return '- ${amount.toStringAsFixed(2)}';
      case TransactionType.INCOMING:
        return '+ ${amount.toStringAsFixed(2)}';
      case TransactionType.TRANSFER:
        return '~ ${amount.toStringAsFixed(2)}';
    }
  }

  bool get isTransfer => transactionType == TransactionType.TRANSFER;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.accountId == accountId &&
        other.toAccountId == toAccountId &&
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
        toAccountId.hashCode ^
        categoryId.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        description.hashCode ^
        transactionType.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, accountId: $accountId, toAccountId: $toAccountId, categoryId: $categoryId, amount: $amount, date: $date, description: $description, transactionType: $transactionType)';
  }
}
