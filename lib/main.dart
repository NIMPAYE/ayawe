import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/providers/app_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/add_transaction_screen.dart';
import 'presentation/screens/add_account_screen.dart';
import 'presentation/screens/accounts_screen.dart';
import 'presentation/screens/goals_screen.dart';
import 'features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'features/accounts/domain/usecases/create_account_usecase.dart';
import 'features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'features/goals/domain/repositories/goal_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AyaweApp());
}

class AyaweApp extends StatelessWidget {
  const AyaweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(
        di.sl<GetAccountsUseCase>(),
        di.sl<CreateAccountUseCase>(),
        di.sl<GetTransactionsUseCase>(),
        di.sl<CreateTransactionUseCase>(),
        di.sl<GoalRepository>(),
      )..loadData(),
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
