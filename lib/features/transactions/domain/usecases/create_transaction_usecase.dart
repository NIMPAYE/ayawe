import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository _repository;

  CreateTransactionUseCase(this._repository);

  Future<int> call(Transaction transaction) async {
    return await _repository.createTransaction(transaction);
  }
}
