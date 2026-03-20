import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/create_account_usecase.dart';

class AccountProvider extends ChangeNotifier {
  final GetAccountsUseCase _getAccountsUseCase;
  final CreateAccountUseCase _createAccountUseCase;

  AccountProvider(
    this._getAccountsUseCase,
    this._createAccountUseCase,
  );

  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance {
    double total = 0.0;
    for (final account in _accounts) {
      total += account.currentBalance;
    }
    return total;
  }

  Future<void> loadAccounts() async {
    _setLoading(true);
    _clearError();

    try {
      _accounts = await _getAccountsUseCase();
    } catch (e) {
      _setError('Error loading accounts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      await _createAccountUseCase(account);
      await loadAccounts();
    } catch (e) {
      _setError('Error adding account: $e');
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
