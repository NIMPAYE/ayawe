import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<List<Transaction>> getTransactionsByAccountId(int accountId);
  Future<Transaction?> getTransactionById(int id);
  Future<int> createTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getTotalExpenses();
  Future<double> getTotalIncome();
}
