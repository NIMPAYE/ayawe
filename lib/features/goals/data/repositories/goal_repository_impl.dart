import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource _localDataSource;

  GoalRepositoryImpl(this._localDataSource);

  @override
  Future<List<Goal>> getGoals() async {
    final models = await _localDataSource.getGoals();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Goal?> getGoalById(int id) async {
    final model = await _localDataSource.getGoalById(id);
    return model?.toEntity();
  }

  @override
  Future<int> createGoal(Goal goal) async {
    final model = GoalModel.fromEntity(goal);
    return await _localDataSource.createGoal(model);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final model = GoalModel.fromEntity(goal);
    await _localDataSource.updateGoal(model);
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _localDataSource.deleteGoal(id);
  }

  @override
  Future<List<Goal>> getAchievedGoals() async {
    final models = await _localDataSource.getAchievedGoals();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Goal>> getOverdueGoals() async {
    final models = await _localDataSource.getOverdueGoals();
    return models.map((model) => model.toEntity()).toList();
  }
}
