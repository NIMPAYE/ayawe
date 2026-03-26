import '../../domain/entities/debt.dart';

class DebtModel {
  final int? id;
  final String personName;
  final String type;
  final double totalAmount;
  final double remainingAmount;
  final String currency;
  final String description;
  final String createdDate;
  final String? dueDate;
  final int isSettled;
  final int accountId;
  final int? transactionId;

  const DebtModel({
    this.id,
    required this.personName,
    required this.type,
    required this.totalAmount,
    required this.remainingAmount,
    required this.currency,
    required this.description,
    required this.createdDate,
    this.dueDate,
    required this.isSettled,
    required this.accountId,
    this.transactionId,
  });

  factory DebtModel.fromEntity(Debt entity) {
    return DebtModel(
      id: entity.id,
      personName: entity.personName,
      type: entity.type == DebtType.LENT ? 'LENT' : 'BORROWED',
      totalAmount: entity.totalAmount,
      remainingAmount: entity.remainingAmount,
      currency: entity.currency,
      description: entity.description,
      createdDate: entity.createdDate.toIso8601String(),
      dueDate: entity.dueDate?.toIso8601String(),
      isSettled: entity.isSettled ? 1 : 0,
      accountId: entity.accountId,
      transactionId: entity.transactionId,
    );
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as int?,
      personName: map['person_name'] as String,
      type: map['type'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      remainingAmount: (map['remaining_amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'BIF',
      description: map['description'] as String? ?? '',
      createdDate: map['created_date'] as String,
      dueDate: map['due_date'] as String?,
      isSettled: map['is_settled'] as int? ?? 0,
      accountId: map['account_id'] as int,
      transactionId: map['transaction_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'person_name': personName,
      'type': type,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'currency': currency,
      'description': description,
      'created_date': createdDate,
      'due_date': dueDate,
      'is_settled': isSettled,
      'account_id': accountId,
      'transaction_id': transactionId,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  Debt toEntity() {
    return Debt(
      id: id,
      personName: personName,
      type: type == 'LENT' ? DebtType.LENT : DebtType.BORROWED,
      totalAmount: totalAmount,
      remainingAmount: remainingAmount,
      currency: currency,
      description: description,
      createdDate: DateTime.parse(createdDate),
      dueDate: dueDate != null ? DateTime.parse(dueDate!) : null,
      isSettled: isSettled == 1,
      accountId: accountId,
      transactionId: transactionId,
    );
  }
}
