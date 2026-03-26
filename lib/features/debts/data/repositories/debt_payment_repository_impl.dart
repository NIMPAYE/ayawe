import '../../domain/entities/debt_payment.dart';
import '../../domain/repositories/debt_payment_repository.dart';
import '../datasources/debt_payment_local_datasource.dart';
import '../models/debt_payment_model.dart';

class DebtPaymentRepositoryImpl implements DebtPaymentRepository {
  final DebtPaymentLocalDataSource _dataSource;

  DebtPaymentRepositoryImpl(this._dataSource);

  @override
  Future<List<DebtPayment>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<DebtPayment>> getByDebtId(int debtId) async {
    final models = await _dataSource.getByDebtId(debtId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> create(DebtPayment payment) async {
    return await _dataSource.create(DebtPaymentModel.fromEntity(payment));
  }

  @override
  Future<void> delete(int id) async {
    await _dataSource.delete(id);
  }
}
