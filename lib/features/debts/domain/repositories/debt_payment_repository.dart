import '../entities/debt_payment.dart';

abstract class DebtPaymentRepository {
  Future<List<DebtPayment>> getAll();
  Future<List<DebtPayment>> getByDebtId(int debtId);
  Future<int> create(DebtPayment payment);
  Future<void> delete(int id);
}
