import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../../features/accounts/data/datasources/account_local_datasource.dart';
import '../../features/accounts/data/repositories/account_repository_impl.dart';
import '../../features/accounts/domain/repositories/account_repository.dart';
import '../../features/accounts/domain/usecases/create_account_usecase.dart';
import '../../features/accounts/domain/usecases/get_accounts_usecase.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/create_transaction_usecase.dart';
import '../../features/transactions/domain/usecases/get_transactions_usecase.dart';
import '../../features/categories/data/datasources/category_local_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/goals/data/datasources/goal_local_datasource.dart';
import '../../features/goals/data/repositories/goal_repository_impl.dart';
import '../../features/goals/domain/repositories/goal_repository.dart';
import '../../features/goals/data/datasources/goal_contribution_local_datasource.dart';
import '../../features/goals/data/repositories/goal_contribution_repository_impl.dart';
import '../../features/goals/domain/repositories/goal_contribution_repository.dart';
import '../../features/budgets/data/datasources/budget_local_datasource.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/data/datasources/recurring_transaction_local_datasource.dart';
import '../../features/budgets/data/repositories/recurring_transaction_repository_impl.dart';
import '../../features/budgets/domain/repositories/recurring_transaction_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Accounts
  sl.registerLazySingleton<AccountLocalDataSource>(
    () => AccountLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CreateAccountUseCase>(
    () => CreateAccountUseCase(sl()),
  );
  sl.registerLazySingleton<GetAccountsUseCase>(
    () => GetAccountsUseCase(sl()),
  );

  // Transactions
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CreateTransactionUseCase>(
    () => CreateTransactionUseCase(sl()),
  );
  sl.registerLazySingleton<GetTransactionsUseCase>(
    () => GetTransactionsUseCase(sl()),
  );

  // Categories
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // Goals
  sl.registerLazySingleton<GoalLocalDataSource>(
    () => GoalLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<GoalRepository>(
    () => GoalRepositoryImpl(sl()),
  );

  // Goal Contributions
  sl.registerLazySingleton<GoalContributionLocalDataSource>(
    () => GoalContributionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<GoalContributionRepository>(
    () => GoalContributionRepositoryImpl(sl()),
  );

  // Budgets
  sl.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(sl()),
  );

  // Recurring Transactions
  sl.registerLazySingleton<RecurringTransactionLocalDataSource>(
    () => RecurringTransactionLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RecurringTransactionRepository>(
    () => RecurringTransactionRepositoryImpl(sl()),
  );
}
