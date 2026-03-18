import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource _localDataSource;

  AccountRepositoryImpl(this._localDataSource);

  @override
  Future<List<Account>> getAccounts() async {
    final models = await _localDataSource.getAccounts();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Account?> getAccountById(int id) async {
    final model = await _localDataSource.getAccountById(id);
    return model?.toEntity();
  }

  @override
  Future<int> createAccount(Account account) async {
    final model = AccountModel.fromEntity(account);
    return await _localDataSource.createAccount(model);
  }

  @override
  Future<void> updateAccount(Account account) async {
    final model = AccountModel.fromEntity(account);
    await _localDataSource.updateAccount(model);
  }

  @override
  Future<void> deleteAccount(int id) async {
    await _localDataSource.deleteAccount(id);
  }

  @override
  Future<double> getTotalBalance() async {
    final accounts = await getAccounts();
    double total = 0.0;
    for (final account in accounts) {
      total += account.currentBalance;
    }
    return total;
  }
}
