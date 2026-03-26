import '../entities/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransaction>> getAll();
  Future<List<RecurringTransaction>> getActive();
  Future<RecurringTransaction?> getById(int id);
  Future<int> create(RecurringTransaction rt);
  Future<void> update(RecurringTransaction rt);
  Future<void> delete(int id);
}
