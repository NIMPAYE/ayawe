import '../../domain/entities/goal_contribution.dart';
import '../../domain/repositories/goal_contribution_repository.dart';
import '../datasources/goal_contribution_local_datasource.dart';
import '../models/goal_contribution_model.dart';

class GoalContributionRepositoryImpl implements GoalContributionRepository {
  final GoalContributionLocalDataSource _localDataSource;

  GoalContributionRepositoryImpl(this._localDataSource);

  @override
  Future<List<GoalContribution>> getAll() async {
    final models = await _localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<GoalContribution>> getByGoalId(int goalId) async {
    final models = await _localDataSource.getByGoalId(goalId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> create(GoalContribution contribution) async {
    final model = GoalContributionModel.fromEntity(contribution);
    return await _localDataSource.create(model);
  }

  @override
  Future<void> delete(int id) async {
    await _localDataSource.delete(id);
  }
}
