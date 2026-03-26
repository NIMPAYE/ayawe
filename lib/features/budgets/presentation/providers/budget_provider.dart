import 'package:flutter/material.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _budgetRepository;

  BudgetProvider(this._budgetRepository);

  List<Budget> _budgets = [];
  String _currentMonth = _monthKey(DateTime.now());
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  String get currentMonth => _currentMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBudgeted =>
      _budgets.fold(0.0, (sum, b) => sum + b.effectiveAmount);

  Future<void> loadBudgets([String? month]) async {
    if (month != null) _currentMonth = month;
    _setLoading(true);
    _clearError();
    try {
      _budgets = await _budgetRepository.getBudgetsByMonth(_currentMonth);
    } catch (e) {
      _setError('Erreur chargement budgets: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _budgetRepository.createBudget(budget);
      await loadBudgets();
    } catch (e) {
      _setError('Erreur ajout budget: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _budgetRepository.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      _setError('Erreur mise à jour budget: $e');
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _budgetRepository.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      _setError('Erreur suppression budget: $e');
    }
  }

  /// Compute total spent for a category in a given month from the transaction list
  double spentForCategory(
    int categoryId,
    String month,
    List<Transaction> transactions,
  ) {
    return transactions
        .where((t) =>
            t.categoryId == categoryId &&
            t.transactionType == TransactionType.OUTGOING &&
            _monthKey(t.date) == month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total spent across all budgeted categories
  double totalSpent(List<Transaction> transactions) {
    double total = 0;
    for (final b in _budgets) {
      total += spentForCategory(b.categoryId, _currentMonth, transactions);
    }
    return total;
  }

  /// Apply rollover: carry savings from previousMonth into currentMonth budgets.
  /// Creates or updates budgets for toMonth with rolloverAmount set.
  Future<void> applyRollover(
    String fromMonth,
    String toMonth,
    List<Transaction> transactions,
  ) async {
    try {
      final prevBudgets = await _budgetRepository.getBudgetsByMonth(fromMonth);
      for (final prev in prevBudgets) {
        final spent = spentForCategory(prev.categoryId, fromMonth, transactions);
        final remaining = prev.effectiveAmount - spent;
        if (remaining <= 0) continue;

        final existing = await _budgetRepository.getBudgetForCategory(
          prev.categoryId,
          toMonth,
        );

        if (existing != null) {
          await _budgetRepository.updateBudget(
            existing.copyWith(rolloverAmount: remaining),
          );
        } else {
          await _budgetRepository.createBudget(Budget(
            categoryId: prev.categoryId,
            amount: prev.amount,
            month: toMonth,
            rolloverAmount: remaining,
          ));
        }
      }
      await loadBudgets(toMonth);
    } catch (e) {
      _setError('Erreur rollover: $e');
    }
  }

  /// Check if previous month has any savings that can be rolled over
  Future<bool> hasRolloverAvailable(
    String fromMonth,
    List<Transaction> transactions,
  ) async {
    try {
      final prevBudgets = await _budgetRepository.getBudgetsByMonth(fromMonth);
      for (final prev in prevBudgets) {
        final spent = spentForCategory(prev.categoryId, fromMonth, transactions);
        if (prev.effectiveAmount - spent > 0) return true;
      }
    } catch (_) {}
    return false;
  }

  void setMonth(String month) {
    _currentMonth = month;
    loadBudgets(month);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  static String _monthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Helper for UI to compute month key
  static String monthKey(DateTime date) => _monthKey(date);
}
