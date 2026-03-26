import 'package:flutter/material.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../features/accounts/presentation/providers/account_provider.dart';
import '../../features/transactions/presentation/providers/transaction_provider.dart';
import '../../features/goals/presentation/providers/goal_provider.dart';
import '../../features/categories/presentation/providers/category_provider.dart';
import '../../features/budgets/presentation/providers/budget_provider.dart';
import '../../features/budgets/presentation/providers/recurring_transaction_provider.dart';
import '../../features/debts/presentation/providers/debt_provider.dart';
import '../../core/services/notification_service.dart';

class MainProvider extends ChangeNotifier {
  final AccountProvider accountProvider;
  final TransactionProvider transactionProvider;
  final GoalProvider goalProvider;
  final CategoryProvider categoryProvider;
  final BudgetProvider budgetProvider;
  final RecurringTransactionProvider recurringTransactionProvider;
  final DebtProvider debtProvider;

  MainProvider({
    required this.accountProvider,
    required this.transactionProvider,
    required this.goalProvider,
    required this.categoryProvider,
    required this.budgetProvider,
    required this.recurringTransactionProvider,
    required this.debtProvider,
  }) {
    accountProvider.addListener(_onChildChanged);
    transactionProvider.addListener(_onChildChanged);
    goalProvider.addListener(_onChildChanged);
    categoryProvider.addListener(_onChildChanged);
    budgetProvider.addListener(_onChildChanged);
    recurringTransactionProvider.addListener(_onChildChanged);
    debtProvider.addListener(_onChildChanged);
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
    budgetProvider.removeListener(_onChildChanged);
    recurringTransactionProvider.removeListener(_onChildChanged);
    debtProvider.removeListener(_onChildChanged);
    super.dispose();
  }

  bool get isLoading => 
      accountProvider.isLoading || 
      transactionProvider.isLoading || 
      goalProvider.isLoading || 
      categoryProvider.isLoading ||
      budgetProvider.isLoading ||
      recurringTransactionProvider.isLoading ||
      debtProvider.isLoading;

  String? get error => 
      accountProvider.error ?? 
      transactionProvider.error ?? 
      goalProvider.error ?? 
      categoryProvider.error ??
      budgetProvider.error ??
      recurringTransactionProvider.error ??
      debtProvider.error;

  // Computed properties
  Map<Currency, double> get balanceByCurrency => accountProvider.balanceByCurrency;
  Currency get primaryCurrency => accountProvider.primaryCurrency;
  double get totalExpenses => transactionProvider.totalExpenses;
  double get totalIncome => transactionProvider.totalIncome;
  double get totalReceivable => debtProvider.totalReceivable;
  double get totalPayable => debtProvider.totalPayable;

  Future<void> loadAllData() async {
    await Future.wait([
      accountProvider.loadAccounts(),
      transactionProvider.loadTransactions(),
      goalProvider.loadGoals(),
      categoryProvider.loadCategories(),
      budgetProvider.loadBudgets(),
      recurringTransactionProvider.loadRecurring(),
      debtProvider.loadDebts(),
    ]);
    NotificationService.scheduleDailyReminder(
      hasTransactionToday: transactionProvider.hasTransactionToday,
    );
  }

  void refreshAll() {
    loadAllData();
  }
}
