import '../entities/account.dart';
import '../repositories/account_repository.dart';

class GetAccountsUseCase {
  final AccountRepository _repository;

  GetAccountsUseCase(this._repository);

  Future<List<Account>> call() async {
    return await _repository.getAccounts();
  }
}
