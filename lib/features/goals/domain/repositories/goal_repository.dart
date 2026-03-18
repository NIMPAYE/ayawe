import '../entities/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<Goal?> getGoalById(int id);
  Future<int> createGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(int id);
  Future<List<Goal>> getAchievedGoals();
  Future<List<Goal>> getOverdueGoals();
}
