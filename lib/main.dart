import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/providers/main_provider.dart';
import 'presentation/screens/main_shell.dart';
import 'features/transactions/presentation/screens/add_transaction_screen.dart';
import 'features/transactions/presentation/screens/transactions_screen.dart';
import 'features/accounts/presentation/screens/add_account_screen.dart';
import 'features/accounts/presentation/screens/accounts_screen.dart';
import 'features/goals/presentation/screens/goals_screen.dart';
import 'features/categories/presentation/screens/categories_screen.dart';
import 'features/accounts/presentation/providers/account_provider.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';
import 'features/goals/presentation/providers/goal_provider.dart';
import 'features/categories/presentation/providers/category_provider.dart';
import 'features/budgets/presentation/providers/budget_provider.dart';
import 'features/budgets/presentation/providers/recurring_transaction_provider.dart';
import 'features/debts/presentation/providers/debt_provider.dart';
import 'features/debts/presentation/screens/debts_screen.dart';
import 'features/stats/presentation/providers/stats_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await initializeDateFormatting('fr');
  await di.init();
  await NotificationService.init();
  runApp(const AyaweApp());
}

class AyaweApp extends StatelessWidget {
  const AyaweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (context) =>
              AccountProvider(di.sl(), di.sl())..loadAccounts(),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (context) =>
              TransactionProvider(di.sl(), di.sl())..loadTransactions(),
        ),
        ChangeNotifierProvider<GoalProvider>(
          create: (context) => GoalProvider(di.sl(), di.sl())..loadGoals(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(di.sl())..loadCategories(),
        ),
        ChangeNotifierProvider<BudgetProvider>(
          create: (context) => BudgetProvider(di.sl())..loadBudgets(),
        ),
        ChangeNotifierProvider<RecurringTransactionProvider>(
          create: (context) =>
              RecurringTransactionProvider(di.sl())..loadRecurring(),
        ),
        ChangeNotifierProvider<DebtProvider>(
          create: (context) => DebtProvider(di.sl(), di.sl())..loadDebts(),
        ),
        ChangeNotifierProvider<StatsProvider>(
          create: (_) => StatsProvider(),
        ),
        ChangeNotifierProvider<MainProvider>(
          create: (context) => MainProvider(
            accountProvider: context.read<AccountProvider>(),
            transactionProvider: context.read<TransactionProvider>(),
            goalProvider: context.read<GoalProvider>(),
            categoryProvider: context.read<CategoryProvider>(),
            budgetProvider: context.read<BudgetProvider>(),
            recurringTransactionProvider:
                context.read<RecurringTransactionProvider>(),
            debtProvider: context.read<DebtProvider>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Ayawe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const MainShell(),
            routes: {
              '/add_transaction': (context) => const AddTransactionScreen(),
              '/transactions': (context) => const TransactionsScreen(),
              '/add_account': (context) => const AddAccountScreen(),
              '/accounts': (context) => const AccountsScreen(),
              '/goals': (context) => const GoalsScreen(),
              '/categories': (context) => const CategoriesScreen(),
              '/debts': (context) => const DebtsScreen(),
            },
          );
        },
      ),
    );
  }
}
