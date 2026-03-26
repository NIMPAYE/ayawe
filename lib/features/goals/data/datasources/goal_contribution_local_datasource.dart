import '../models/goal_contribution_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class GoalContributionLocalDataSource {
  Future<List<GoalContributionModel>> getAll();
  Future<List<GoalContributionModel>> getByGoalId(int goalId);
  Future<int> create(GoalContributionModel contribution);
  Future<void> delete(int id);
}

class GoalContributionLocalDataSourceImpl
    implements GoalContributionLocalDataSource {
  final DatabaseHelper _databaseHelper;

  GoalContributionLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<GoalContributionModel>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'goal_contributions',
      orderBy: 'date DESC',
    );
    return maps.map((m) => GoalContributionModel.fromMap(m)).toList();
  }

  @override
  Future<List<GoalContributionModel>> getByGoalId(int goalId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'goal_contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => GoalContributionModel.fromMap(m)).toList();
  }

  @override
  Future<int> create(GoalContributionModel contribution) async {
    final db = await _databaseHelper.database;
    return await db.insert('goal_contributions', contribution.toMap());
  }

  @override
  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'goal_contributions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
