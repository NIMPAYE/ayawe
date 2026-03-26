import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource _localDataSource;

  BudgetRepositoryImpl(this._localDataSource);

  @override
  Future<List<Budget>> getBudgets() async {
    final models = await _localDataSource.getBudgets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Budget>> getBudgetsByMonth(String month) async {
    final models = await _localDataSource.getBudgetsByMonth(month);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Budget?> getBudgetForCategory(int categoryId, String month) async {
    final model = await _localDataSource.getBudgetForCategory(categoryId, month);
    return model?.toEntity();
  }

  @override
  Future<int> createBudget(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);
    return await _localDataSource.createBudget(model);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final model = BudgetModel.fromEntity(budget);
    await _localDataSource.updateBudget(model);
  }

  @override
  Future<void> deleteBudget(int id) async {
    await _localDataSource.deleteBudget(id);
  }
}
