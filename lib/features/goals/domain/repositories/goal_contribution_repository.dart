import '../entities/goal_contribution.dart';

abstract class GoalContributionRepository {
  Future<List<GoalContribution>> getAll();
  Future<List<GoalContribution>> getByGoalId(int goalId);
  Future<int> create(GoalContribution contribution);
  Future<void> delete(int id);
}
