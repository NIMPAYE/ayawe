import '../entities/debt.dart';

abstract class DebtRepository {
  Future<List<Debt>> getAll();
  Future<Debt?> getById(int id);
  Future<int> create(Debt debt);
  Future<void> update(Debt debt);
  Future<void> delete(int id);
}
