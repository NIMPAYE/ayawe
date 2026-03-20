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

  Map<Currency, double> get balanceByCurrency {
    final map = <Currency, double>{};
    for (final account in _accounts) {
      map[account.currency] = (map[account.currency] ?? 0) + account.currentBalance;
    }
    return map;
  }

  double totalBalanceFor(Currency currency) =>
      balanceByCurrency[currency] ?? 0.0;

  /// Primary currency is the one with the most accounts, fallback to BIF.
  Currency get primaryCurrency {
    if (_accounts.isEmpty) return Currency.BIF;
    final counts = <Currency, int>{};
    for (final a in _accounts) {
      counts[a.currency] = (counts[a.currency] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @Deprecated('Use balanceByCurrency instead')
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
