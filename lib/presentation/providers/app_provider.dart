import 'package:flutter/material.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../features/accounts/domain/usecases/get_accounts_usecase.dart';
import '../../features/accounts/domain/usecases/create_account_usecase.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions_usecase.dart';
import '../../features/transactions/domain/usecases/create_transaction_usecase.dart';
import '../../features/goals/domain/entities/goal.dart';
import '../../features/goals/domain/repositories/goal_repository.dart';

class AppProvider extends ChangeNotifier {
  final GetAccountsUseCase _getAccountsUseCase;
  final CreateAccountUseCase _createAccountUseCase;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final CreateTransactionUseCase _createTransactionUseCase;
  final GoalRepository _goalRepository;

  AppProvider(
    this._getAccountsUseCase,
    this._createAccountUseCase,
    this._getTransactionsUseCase,
    this._createTransactionUseCase,
    this._goalRepository,
  );

  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Financial calculations
  double get totalBalance {
    double total = 0.0;
    for (final account in _accounts) {
      total += account.currentBalance;
    }
    return total;
  }

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

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([_loadAccounts(), _loadTransactions(), _loadGoals()]);
    } catch (e) {
      _setError('Error loading data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadAccounts() async {
    _accounts = await _getAccountsUseCase();
    notifyListeners();
  }

  Future<void> _loadTransactions() async {
    _transactions = await _getTransactionsUseCase();
    notifyListeners();
  }

  Future<void> _loadGoals() async {
    _goals = await _goalRepository.getGoals();
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    try {
      await _createAccountUseCase(account);
      await _loadAccounts();
    } catch (e) {
      _setError('Error adding account: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _createTransactionUseCase(transaction);
      await _loadTransactions();
      await _loadAccounts(); // Reload to update balances
    } catch (e) {
      _setError('Error adding transaction: $e');
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      await _goalRepository.createGoal(goal);
      await _loadGoals();
    } catch (e) {
      _setError('Error adding goal: $e');
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
