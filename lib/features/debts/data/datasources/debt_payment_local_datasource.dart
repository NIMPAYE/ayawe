import '../models/debt_payment_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class DebtPaymentLocalDataSource {
  Future<List<DebtPaymentModel>> getAll();
  Future<List<DebtPaymentModel>> getByDebtId(int debtId);
  Future<int> create(DebtPaymentModel payment);
  Future<void> delete(int id);
}

class DebtPaymentLocalDataSourceImpl implements DebtPaymentLocalDataSource {
  final DatabaseHelper _databaseHelper;

  DebtPaymentLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<DebtPaymentModel>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('debt_payments', orderBy: 'date DESC');
    return maps.map((m) => DebtPaymentModel.fromMap(m)).toList();
  }

  @override
  Future<List<DebtPaymentModel>> getByDebtId(int debtId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'debt_payments',
      where: 'debt_id = ?',
      whereArgs: [debtId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => DebtPaymentModel.fromMap(m)).toList();
  }

  @override
  Future<int> create(DebtPaymentModel payment) async {
    final db = await _databaseHelper.database;
    return await db.insert('debt_payments', payment.toMap());
  }

  @override
  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('debt_payments', where: 'id = ?', whereArgs: [id]);
  }
}
