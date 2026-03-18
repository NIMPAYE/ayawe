import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl(this._localDataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    final models = await _localDataSource.getTransactions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByAccountId(int accountId) async {
    final models = await _localDataSource.getTransactionsByAccountId(accountId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Transaction?> getTransactionById(int id) async {
    final model = await _localDataSource.getTransactionById(id);
    return model?.toEntity();
  }

  @override
  Future<int> createTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    return await _localDataSource.createTransaction(model);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _localDataSource.updateTransaction(model);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _localDataSource.deleteTransaction(id);
  }

  @override
  Future<double> getTotalExpenses() async {
    final transactions = await getTransactions();
    double total = 0.0;
    for (final transaction in transactions) {
      if (transaction.transactionType == TransactionType.OUTGOING) {
        total += transaction.amount;
      }
    }
    return total;
  }

  @override
  Future<double> getTotalIncome() async {
    final transactions = await getTransactions();
    double total = 0.0;
    for (final transaction in transactions) {
      if (transaction.transactionType == TransactionType.INCOMING) {
        total += transaction.amount;
      }
    }
    return total;
  }
}
