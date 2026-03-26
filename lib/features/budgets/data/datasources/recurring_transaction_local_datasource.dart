import '../models/recurring_transaction_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class RecurringTransactionLocalDataSource {
  Future<List<RecurringTransactionModel>> getAll();
  Future<List<RecurringTransactionModel>> getActive();
  Future<RecurringTransactionModel?> getById(int id);
  Future<int> create(RecurringTransactionModel rt);
  Future<void> update(RecurringTransactionModel rt);
  Future<void> delete(int id);
}

class RecurringTransactionLocalDataSourceImpl
    implements RecurringTransactionLocalDataSource {
  final DatabaseHelper _databaseHelper;

  RecurringTransactionLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<RecurringTransactionModel>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'recurring_transactions',
      orderBy: 'next_due_date ASC',
    );
    return maps.map((m) => RecurringTransactionModel.fromMap(m)).toList();
  }

  @override
  Future<List<RecurringTransactionModel>> getActive() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'recurring_transactions',
      where: 'is_active = 1',
      orderBy: 'next_due_date ASC',
    );
    return maps.map((m) => RecurringTransactionModel.fromMap(m)).toList();
  }

  @override
  Future<RecurringTransactionModel?> getById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return RecurringTransactionModel.fromMap(maps.first);
    return null;
  }

  @override
  Future<int> create(RecurringTransactionModel rt) async {
    final db = await _databaseHelper.database;
    return await db.insert('recurring_transactions', rt.toMap());
  }

  @override
  Future<void> update(RecurringTransactionModel rt) async {
    final db = await _databaseHelper.database;
    await db.update(
      'recurring_transactions',
      rt.toMap(),
      where: 'id = ?',
      whereArgs: [rt.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
