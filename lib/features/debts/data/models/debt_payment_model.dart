import '../../domain/entities/debt_payment.dart';

class DebtPaymentModel {
  final int? id;
  final int debtId;
  final int accountId;
  final int? transactionId;
  final double amount;
  final String date;
  final String note;

  const DebtPaymentModel({
    this.id,
    required this.debtId,
    required this.accountId,
    this.transactionId,
    required this.amount,
    required this.date,
    required this.note,
  });

  factory DebtPaymentModel.fromEntity(DebtPayment entity) {
    return DebtPaymentModel(
      id: entity.id,
      debtId: entity.debtId,
      accountId: entity.accountId,
      transactionId: entity.transactionId,
      amount: entity.amount,
      date: entity.date.toIso8601String(),
      note: entity.note,
    );
  }

  factory DebtPaymentModel.fromMap(Map<String, dynamic> map) {
    return DebtPaymentModel(
      id: map['id'] as int?,
      debtId: map['debt_id'] as int,
      accountId: map['account_id'] as int,
      transactionId: map['transaction_id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'debt_id': debtId,
      'account_id': accountId,
      'transaction_id': transactionId,
      'amount': amount,
      'date': date,
      'note': note,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  DebtPayment toEntity() {
    return DebtPayment(
      id: id,
      debtId: debtId,
      accountId: accountId,
      transactionId: transactionId,
      amount: amount,
      date: DateTime.parse(date),
      note: note,
    );
  }
}
