import '../models/budget_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<List<BudgetModel>> getBudgetsByMonth(String month);
  Future<BudgetModel?> getBudgetForCategory(int categoryId, String month);
  Future<int> createBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(int id);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final DatabaseHelper _databaseHelper;

  BudgetLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('budgets', orderBy: 'month DESC');
    return maps.map((m) => BudgetModel.fromMap(m)).toList();
  }

  @override
  Future<List<BudgetModel>> getBudgetsByMonth(String month) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );
    return maps.map((m) => BudgetModel.fromMap(m)).toList();
  }

  @override
  Future<BudgetModel?> getBudgetForCategory(int categoryId, String month) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'budgets',
      where: 'category_id = ? AND month = ?',
      whereArgs: [categoryId, month],
    );
    if (maps.isNotEmpty) return BudgetModel.fromMap(maps.first);
    return null;
  }

  @override
  Future<int> createBudget(BudgetModel budget) async {
    final db = await _databaseHelper.database;
    return await db.insert('budgets', budget.toMap());
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    final db = await _databaseHelper.database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  @override
  Future<void> deleteBudget(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
