import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getBudgets();
  Future<List<Budget>> getBudgetsByMonth(String month);
  Future<Budget?> getBudgetForCategory(int categoryId, String month);
  Future<int> createBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(int id);
}
