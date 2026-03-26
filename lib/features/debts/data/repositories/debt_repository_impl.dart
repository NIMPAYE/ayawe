import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/debt_local_datasource.dart';
import '../models/debt_model.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource _dataSource;

  DebtRepositoryImpl(this._dataSource);

  @override
  Future<List<Debt>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Debt?> getById(int id) async {
    final model = await _dataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<int> create(Debt debt) async {
    return await _dataSource.create(DebtModel.fromEntity(debt));
  }

  @override
  Future<void> update(Debt debt) async {
    await _dataSource.update(DebtModel.fromEntity(debt));
  }

  @override
  Future<void> delete(int id) async {
    await _dataSource.delete(id);
  }
}
