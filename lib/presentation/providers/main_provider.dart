import 'package:flutter/material.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../features/accounts/presentation/providers/account_provider.dart';
import '../../features/transactions/presentation/providers/transaction_provider.dart';
import '../../features/goals/presentation/providers/goal_provider.dart';
import '../../features/categories/presentation/providers/category_provider.dart';

class MainProvider extends ChangeNotifier {
  final AccountProvider accountProvider;
  final TransactionProvider transactionProvider;
  final GoalProvider goalProvider;
  final CategoryProvider categoryProvider;

  MainProvider({
    required this.accountProvider,
    required this.transactionProvider,
    required this.goalProvider,
    required this.categoryProvider,
  }) {
    accountProvider.addListener(_onChildChanged);
    transactionProvider.addListener(_onChildChanged);
    goalProvider.addListener(_onChildChanged);
    categoryProvider.addListener(_onChildChanged);
  }

  void _onChildChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    accountProvider.removeListener(_onChildChanged);
    transactionProvider.removeListener(_onChildChanged);
    goalProvider.removeListener(_onChildChanged);
    categoryProvider.removeListener(_onChildChanged);
    super.dispose();
  }

  bool get isLoading => 
      accountProvider.isLoading || 
      transactionProvider.isLoading || 
      goalProvider.isLoading || 
      categoryProvider.isLoading;

  String? get error => 
      accountProvider.error ?? 
      transactionProvider.error ?? 
      goalProvider.error ?? 
      categoryProvider.error;

  // Computed properties
  Map<Currency, double> get balanceByCurrency => accountProvider.balanceByCurrency;
  Currency get primaryCurrency => accountProvider.primaryCurrency;
  double get totalExpenses => transactionProvider.totalExpenses;
  double get totalIncome => transactionProvider.totalIncome;

  Future<void> loadAllData() async {
    await Future.wait([
      accountProvider.loadAccounts(),
      transactionProvider.loadTransactions(),
      goalProvider.loadGoals(),
      categoryProvider.loadCategories(),
    ]);
  }

  void refreshAll() {
    loadAllData();
  }
}
