import '../../domain/entities/recurring_transaction.dart';
import '../../../transactions/domain/entities/transaction.dart';

class RecurringTransactionModel extends RecurringTransaction {
  const RecurringTransactionModel({
    super.id,
    required super.accountId,
    required super.categoryId,
    required super.amount,
    required super.description,
    required super.transactionType,
    required super.frequency,
    required super.nextDueDate,
    super.isActive,
  });

  factory RecurringTransactionModel.fromEntity(RecurringTransaction entity) {
    return RecurringTransactionModel(
      id: entity.id,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      amount: entity.amount,
      description: entity.description,
      transactionType: entity.transactionType,
      frequency: entity.frequency,
      nextDueDate: entity.nextDueDate,
      isActive: entity.isActive,
    );
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'],
      accountId: map['account_id'],
      categoryId: map['category_id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      transactionType: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['transaction_type'],
      ),
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == map['frequency'],
      ),
      nextDueDate: DateTime.parse(map['next_due_date']),
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'transaction_type': transactionType.toString().split('.').last,
      'frequency': frequency.toString().split('.').last,
      'next_due_date': nextDueDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  RecurringTransaction toEntity() {
    return RecurringTransaction(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      description: description,
      transactionType: transactionType,
      frequency: frequency,
      nextDueDate: nextDueDate,
      isActive: isActive,
    );
  }
}
