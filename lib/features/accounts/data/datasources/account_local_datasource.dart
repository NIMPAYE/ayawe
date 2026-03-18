import '../models/account_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class AccountLocalDataSource {
  Future<List<AccountModel>> getAccounts();
  Future<AccountModel?> getAccountById(int id);
  Future<int> createAccount(AccountModel account);
  Future<void> updateAccount(AccountModel account);
  Future<void> deleteAccount(int id);
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final DatabaseHelper _databaseHelper;

  AccountLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<AccountModel>> getAccounts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return maps.map((map) => AccountModel.fromMap(map)).toList();
  }

  @override
  Future<AccountModel?> getAccountById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> createAccount(AccountModel account) async {
    final db = await _databaseHelper.database;
    return await db.insert('accounts', account.toMap());
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    final db = await _databaseHelper.database;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  @override
  Future<void> deleteAccount(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
