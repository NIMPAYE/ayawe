import '../entities/account.dart';
import '../repositories/account_repository.dart';

class CreateAccountUseCase {
  final AccountRepository _repository;

  CreateAccountUseCase(this._repository);

  Future<int> call(Account account) async {
    return await _repository.createAccount(account);
  }
}
