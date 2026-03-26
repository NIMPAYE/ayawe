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
  bool _hasRolloverAvailable = false;

  List<Budget> get budgets => _budgets;
  String get currentMonth => _currentMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRolloverAvailable => _hasRolloverAvailable;

  double get totalBudgeted =>
      _budgets.fold(0.0, (sum, b) => sum + b.effectiveAmount);

  /// Single-pass: build a map of categoryId -> total OUTGOING spent for `month`.
  Map<int, double> spentByCategoryMap(
    String month,
    List<Transaction> transactions,
  ) {
    final map = <int, double>{};
    for (final t in transactions) {
      if (t.transactionType != TransactionType.OUTGOING) continue;
      if (_monthKey(t.date) != month) continue;
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  double spentForCategory(
    int categoryId,
    String month,
    List<Transaction> transactions,
  ) {
    return spentByCategoryMap(month, transactions)[categoryId] ?? 0.0;
  }

  /// Total spent across all budgeted categories (uses pre-computed map).
  double totalSpentFromMap(Map<int, double> spentMap) {
    double total = 0;
    for (final b in _budgets) {
      total += spentMap[b.categoryId] ?? 0;
    }
    return total;
  }

  /// Total and per-category for expenses outside any budget definition.
  double unbudgetedSpent(Map<int, double> spentMap) {
    final budgetedIds = _budgets.map((b) => b.categoryId).toSet();
    double total = 0;
    for (final entry in spentMap.entries) {
      if (!budgetedIds.contains(entry.key)) {
        total += entry.value;
      }
    }
    return total;
  }

  Map<int, double> unbudgetedByCategory(Map<int, double> spentMap) {
    final budgetedIds = _budgets.map((b) => b.categoryId).toSet();
    return {
      for (final entry in spentMap.entries)
        if (!budgetedIds.contains(entry.key)) entry.key: entry.value,
    };
  }

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

  /// Pre-check rollover availability. Call after loadBudgets or setMonth.
  Future<void> checkRollover(List<Transaction> transactions) async {
    final prev = _previousMonth(_currentMonth);
    try {
      final prevBudgets = await _budgetRepository.getBudgetsByMonth(prev);
      final spentMap = spentByCategoryMap(prev, transactions);
      _hasRolloverAvailable = prevBudgets.any((b) {
        final spent = spentMap[b.categoryId] ?? 0;
        return b.effectiveAmount - spent > 0;
      });
    } catch (_) {
      _hasRolloverAvailable = false;
    }
    notifyListeners();
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

  Future<void> applyRollover(
    String fromMonth,
    String toMonth,
    List<Transaction> transactions,
  ) async {
    try {
      final prevBudgets = await _budgetRepository.getBudgetsByMonth(fromMonth);
      final spentMap = spentByCategoryMap(fromMonth, transactions);

      for (final prev in prevBudgets) {
        final spent = spentMap[prev.categoryId] ?? 0;
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
      _hasRolloverAvailable = false;
      await loadBudgets(toMonth);
    } catch (e) {
      _setError('Erreur rollover: $e');
    }
  }

  void setMonth(String month) {
    _currentMonth = month;
    _hasRolloverAvailable = false;
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

  static String monthKey(DateTime date) => _monthKey(date);

  static String _previousMonth(String monthKey) {
    final parts = monthKey.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]) - 1;
    if (month < 1) {
      month = 12;
      year--;
    }
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
