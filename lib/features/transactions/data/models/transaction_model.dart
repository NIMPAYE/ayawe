import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.accountId,
    required super.categoryId,
    required super.amount,
    required super.date,
    required super.description,
    required super.transactionType,
  });

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      date: entity.date,
      description: entity.description,
      transactionType: entity.transactionType,
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      accountId: map['account_id'],
      categoryId: map['category_id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      description: map['description'] ?? '',
      transactionType: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['transaction_type'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'transaction_type': transactionType.toString().split('.').last,
    };
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      description: description,
      transactionType: transactionType,
    );
  }
}
