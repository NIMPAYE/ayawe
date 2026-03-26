import '../models/debt_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class DebtLocalDataSource {
  Future<List<DebtModel>> getAll();
  Future<DebtModel?> getById(int id);
  Future<int> create(DebtModel debt);
  Future<void> update(DebtModel debt);
  Future<void> delete(int id);
}

class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  final DatabaseHelper _databaseHelper;

  DebtLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<DebtModel>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('debts', orderBy: 'created_date DESC');
    return maps.map((m) => DebtModel.fromMap(m)).toList();
  }

  @override
  Future<DebtModel?> getById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('debts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return DebtModel.fromMap(maps.first);
    return null;
  }

  @override
  Future<int> create(DebtModel debt) async {
    final db = await _databaseHelper.database;
    return await db.insert('debts', debt.toMap());
  }

  @override
  Future<void> update(DebtModel debt) async {
    final db = await _databaseHelper.database;
    await db.update('debts', debt.toMap(), where: 'id = ?', whereArgs: [debt.id]);
  }

  @override
  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }
}
