import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../../../core/services/notification_service.dart';

class TransactionProvider extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final CreateTransactionUseCase _createTransactionUseCase;

  TransactionProvider(
    this._getTransactionsUseCase,
    this._createTransactionUseCase,
  );

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalExpenses {
    double total = 0.0;
    for (final transaction in _transactions) {
      if (transaction.transactionType == TransactionType.OUTGOING) {
        total += transaction.amount;
      }
    }
    return total;
  }

  double get totalIncome {
    double total = 0.0;
    for (final transaction in _transactions) {
      if (transaction.transactionType == TransactionType.INCOMING) {
        total += transaction.amount;
      }
    }
    return total;
  }

  bool get hasTransactionToday {
    final now = DateTime.now();
    return _transactions.any((t) =>
        t.date.year == now.year &&
        t.date.month == now.month &&
        t.date.day == now.day);
  }

  Future<void> loadTransactions() async {
    _setLoading(true);
    _clearError();

    try {
      _transactions = await _getTransactionsUseCase();
    } catch (e) {
      _setError('Error loading transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<int?> addTransaction(Transaction transaction) async {
    try {
      final id = await _createTransactionUseCase(transaction);
      await loadTransactions();
      NotificationService.onTransactionRecorded();
      return id;
    } catch (e) {
      _setError('Error adding transaction: $e');
      return null;
    }
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
    notifyListeners();
  }
}
