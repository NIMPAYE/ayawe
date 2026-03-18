import '../models/goal_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class GoalLocalDataSource {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel?> getGoalById(int id);
  Future<int> createGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(int id);
  Future<List<GoalModel>> getAchievedGoals();
  Future<List<GoalModel>> getOverdueGoals();
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final DatabaseHelper _databaseHelper;

  GoalLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<GoalModel>> getGoals() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => GoalModel.fromMap(map)).toList();
  }

  @override
  Future<GoalModel?> getGoalById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return GoalModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> createGoal(GoalModel goal) async {
    final db = await _databaseHelper.database;
    return await db.insert('goals', goal.toMap());
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    final db = await _databaseHelper.database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<GoalModel>> getAchievedGoals() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'current_amount >= target_amount',
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => GoalModel.fromMap(map)).toList();
  }

  @override
  Future<List<GoalModel>> getOverdueGoals() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'deadline < ? AND current_amount < target_amount',
      whereArgs: [now],
      orderBy: 'deadline ASC',
    );
    return maps.map((map) => GoalModel.fromMap(map)).toList();
  }
}
