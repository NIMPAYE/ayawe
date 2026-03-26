import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/database/database_helper.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<List<TransactionModel>> getTransactionsByAccountId(int accountId);
  Future<TransactionModel?> getTransactionById(int id);
  Future<int> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(int id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TransactionLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByAccountId(int accountId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'account_id = ? OR to_account_id = ?',
      whereArgs: [accountId, accountId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> createTransaction(TransactionModel transaction) async {
    final db = await _databaseHelper.database;
    late int txId;

    await db.transaction((txn) async {
      txId = await txn.insert('transactions', transaction.toMap());

      if (transaction.transactionType == TransactionType.TRANSFER) {
        await txn.rawUpdate(
          'UPDATE accounts SET current_balance = current_balance - ? WHERE id = ?',
          [transaction.amount, transaction.accountId],
        );
        await txn.rawUpdate(
          'UPDATE accounts SET current_balance = current_balance + ? WHERE id = ?',
          [transaction.amount, transaction.toAccountId],
        );
      } else {
        final sign = transaction.transactionType == TransactionType.OUTGOING ? -1 : 1;
        await txn.rawUpdate(
          'UPDATE accounts SET current_balance = current_balance + ? WHERE id = ?',
          [transaction.amount * sign, transaction.accountId],
        );
      }
    });

    return txId;
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await _databaseHelper.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
