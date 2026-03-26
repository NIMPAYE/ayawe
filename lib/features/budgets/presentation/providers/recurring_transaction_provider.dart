import 'package:flutter/material.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../accounts/domain/entities/account.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  final RecurringTransactionRepository _repository;

  RecurringTransactionProvider(this._repository);

  List<RecurringTransaction> _items = [];
  bool _isLoading = false;
  String? _error;

  List<RecurringTransaction> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<RecurringTransaction> get activeItems =>
      _items.where((rt) => rt.isActive).toList();

  List<RecurringTransaction> get overdueItems =>
      _items.where((rt) => rt.isOverdue).toList();

  List<RecurringTransaction> get dueSoonItems =>
      _items.where((rt) => rt.isActive && (rt.isDueSoon || rt.isOverdue)).toList()
        ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

  /// Total upcoming OUTGOING expenses per currency for the rest of the month
  Map<Currency, double> upcomingExpensesByCurrency(
    Map<int?, Account> accountMap,
  ) {
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final result = <Currency, double>{};
    for (final rt in activeItems) {
      if (rt.transactionType != TransactionType.OUTGOING) continue;
      final account = accountMap[rt.accountId];
      if (account == null) continue;
      final occurrences = rt.projectOccurrences(now, endOfMonth);
      final amount = rt.amount * occurrences.length;
      result[account.currency] = (result[account.currency] ?? 0) + amount;
    }
    return result;
  }

  /// Balance per currency, then remaining after deducting upcoming fixed expenses
  Map<Currency, double> remainingByCurrency(
    Map<Currency, double> balanceByCurrency,
    Map<int?, Account> accountMap,
  ) {
    final upcoming = upcomingExpensesByCurrency(accountMap);
    final result = <Currency, double>{};
    for (final entry in balanceByCurrency.entries) {
      result[entry.key] = entry.value - (upcoming[entry.key] ?? 0);
    }
    return result;
  }

  Future<void> loadRecurring() async {
    _setLoading(true);
    _clearError();
    try {
      _items = await _repository.getAll();
    } catch (e) {
      _setError('Erreur chargement récurrentes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addRecurring(RecurringTransaction rt) async {
    try {
      await _repository.create(rt);
      await loadRecurring();
    } catch (e) {
      _setError('Erreur ajout récurrente: $e');
    }
  }

  Future<void> updateRecurring(RecurringTransaction rt) async {
    try {
      await _repository.update(rt);
      await loadRecurring();
    } catch (e) {
      _setError('Erreur mise à jour récurrente: $e');
    }
  }

  Future<void> deleteRecurring(int id) async {
    try {
      await _repository.delete(id);
      await loadRecurring();
    } catch (e) {
      _setError('Erreur suppression récurrente: $e');
    }
  }

  Future<void> toggleActive(RecurringTransaction rt) async {
    await updateRecurring(rt.copyWith(isActive: !rt.isActive));
  }

  /// After the user confirms, advance the nextDueDate to the next occurrence
  Future<void> advanceNextDueDate(RecurringTransaction rt) async {
    final updated = rt.copyWith(nextDueDate: rt.nextDateAfterDue);
    await updateRecurring(updated);
  }

  /// Build a Transaction entity from a RecurringTransaction for confirmation
  Transaction buildTransaction(RecurringTransaction rt) {
    return Transaction(
      accountId: rt.accountId,
      categoryId: rt.categoryId,
      amount: rt.amount,
      date: DateTime.now(),
      description: rt.description,
      transactionType: rt.transactionType,
    );
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
}
