import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/providers/main_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/transactions/presentation/screens/add_transaction_screen.dart';
import 'features/accounts/presentation/screens/add_account_screen.dart';
import 'features/accounts/presentation/screens/accounts_screen.dart';
import 'features/goals/presentation/screens/goals_screen.dart';
import 'features/accounts/presentation/providers/account_provider.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';
import 'features/goals/presentation/providers/goal_provider.dart';
import 'features/categories/presentation/providers/category_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AyaweApp());
}

class AyaweApp extends StatelessWidget {
  const AyaweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountProvider>(
          create: (context) =>
              AccountProvider(di.sl(), di.sl())..loadAccounts(),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (context) =>
              TransactionProvider(di.sl(), di.sl())..loadTransactions(),
        ),
        ChangeNotifierProvider<GoalProvider>(
          create: (context) => GoalProvider(di.sl())..loadGoals(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(di.sl())..loadCategories(),
        ),
        ChangeNotifierProvider<MainProvider>(
          create: (context) => MainProvider(
            accountProvider: context.read<AccountProvider>(),
            transactionProvider: context.read<TransactionProvider>(),
            goalProvider: context.read<GoalProvider>(),
            categoryProvider: context.read<CategoryProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Ayawe - Personal Finance Manager',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const HomeScreen(),
        routes: {
          '/add_transaction': (context) => const AddTransactionScreen(),
          '/add_account': (context) => const AddAccountScreen(),
          '/accounts': (context) => const AccountsScreen(),
          '/goals': (context) => const GoalsScreen(),
        },
      ),
    );
  }
}
