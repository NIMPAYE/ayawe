import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../datasources/recurring_transaction_local_datasource.dart';
import '../models/recurring_transaction_model.dart';

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  final RecurringTransactionLocalDataSource _localDataSource;

  RecurringTransactionRepositoryImpl(this._localDataSource);

  @override
  Future<List<RecurringTransaction>> getAll() async {
    final models = await _localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<RecurringTransaction>> getActive() async {
    final models = await _localDataSource.getActive();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RecurringTransaction?> getById(int id) async {
    final model = await _localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<int> create(RecurringTransaction rt) async {
    final model = RecurringTransactionModel.fromEntity(rt);
    return await _localDataSource.create(model);
  }

  @override
  Future<void> update(RecurringTransaction rt) async {
    final model = RecurringTransactionModel.fromEntity(rt);
    await _localDataSource.update(model);
  }

  @override
  Future<void> delete(int id) async {
    await _localDataSource.delete(id);
  }
}
