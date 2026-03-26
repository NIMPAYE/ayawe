import 'package:flutter/material.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/debt_payment.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/debt_payment_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../../presentation/providers/main_provider.dart';
import '../../../../core/services/notification_service.dart';

class DebtProvider extends ChangeNotifier {
  final DebtRepository _debtRepository;
  final DebtPaymentRepository _paymentRepository;

  DebtProvider(this._debtRepository, this._paymentRepository);

  List<Debt> _debts = [];
  bool _isLoading = false;
  String? _error;

  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Debt> get lentDebts =>
      _debts.where((d) => d.type == DebtType.LENT && !d.isSettled).toList();

  List<Debt> get borrowedDebts =>
      _debts.where((d) => d.type == DebtType.BORROWED && !d.isSettled).toList();

  List<Debt> get activeDebts =>
      _debts.where((d) => !d.isSettled).toList();

  List<Debt> get settledDebts =>
      _debts.where((d) => d.isSettled).toList();

  List<Debt> get overdueDebts =>
      _debts.where((d) => d.isOverdue).toList();

  List<Debt> get dueSoonDebts =>
      _debts.where((d) => d.isDueSoon || d.isOverdue).toList();

  double get totalReceivable =>
      lentDebts.fold(0.0, (sum, d) => sum + d.remainingAmount);

  double get totalPayable =>
      borrowedDebts.fold(0.0, (sum, d) => sum + d.remainingAmount);

  // ───────── CRUD ─────────

  Future<void> loadDebts() async {
    _setLoading(true);
    _clearError();
    try {
      _debts = await _debtRepository.getAll();
    } catch (e) {
      _setError('Erreur chargement dettes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addDebt({
    required String personName,
    required DebtType type,
    required double amount,
    required int accountId,
    required int categoryId,
    required String currency,
    String description = '',
    DateTime? dueDate,
    required TransactionProvider transactionProvider,
    required MainProvider mainProvider,
  }) async {
    try {
      final txType = type == DebtType.LENT
          ? TransactionType.OUTGOING
          : TransactionType.INCOMING;
      final txDesc = type == DebtType.LENT
          ? 'Prêt: $personName'
          : 'Emprunt: $personName';

      final tx = Transaction(
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        date: DateTime.now(),
        description: txDesc + (description.isNotEmpty ? ' – $description' : ''),
        transactionType: txType,
      );

      await transactionProvider.addTransaction(tx);

      final allTx = transactionProvider.transactions;
      final createdTx = allTx.isNotEmpty ? allTx.first : null;

      final debt = Debt(
        personName: personName,
        type: type,
        totalAmount: amount,
        remainingAmount: amount,
        currency: currency,
        description: description,
        createdDate: DateTime.now(),
        dueDate: dueDate,
        accountId: accountId,
        transactionId: createdTx?.id,
      );

      await _debtRepository.create(debt);

      if (dueDate != null) {
        final debts = await _debtRepository.getAll();
        final created = debts.first;
        await NotificationService.scheduleDebtReminder(
          debtId: created.id!,
          personName: personName,
          isLent: type == DebtType.LENT,
          dueDate: dueDate,
        );
      }

      await mainProvider.loadAllData();
      return true;
    } catch (e) {
      _setError('Erreur ajout dette: $e');
      return false;
    }
  }

  Future<void> updateDebt(Debt debt) async {
    try {
      await _debtRepository.update(debt);

      if (debt.dueDate != null && !debt.isSettled) {
        await NotificationService.scheduleDebtReminder(
          debtId: debt.id!,
          personName: debt.personName,
          isLent: debt.type == DebtType.LENT,
          dueDate: debt.dueDate!,
        );
      } else {
        await NotificationService.cancelDebtReminder(debt.id!);
      }

      await loadDebts();
    } catch (e) {
      _setError('Erreur mise à jour dette: $e');
    }
  }

  Future<void> deleteDebt(int id) async {
    try {
      await NotificationService.cancelDebtReminder(id);
      await _debtRepository.delete(id);
      await loadDebts();
    } catch (e) {
      _setError('Erreur suppression dette: $e');
    }
  }

  // ───────── Payments ─────────

  Future<List<DebtPayment>> getPayments(int debtId) async {
    try {
      return await _paymentRepository.getByDebtId(debtId);
    } catch (e) {
      _setError('Erreur chargement paiements: $e');
      return [];
    }
  }

  Future<bool> recordPayment({
    required Debt debt,
    required int accountId,
    required int categoryId,
    required double amount,
    required String note,
    required TransactionProvider transactionProvider,
    required MainProvider mainProvider,
  }) async {
    try {
      final txType = debt.type == DebtType.LENT
          ? TransactionType.INCOMING
          : TransactionType.OUTGOING;
      final txDesc = debt.type == DebtType.LENT
          ? 'Remboursement: ${debt.personName}'
          : 'Remboursement à: ${debt.personName}';

      final tx = Transaction(
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        date: DateTime.now(),
        description: txDesc + (note.isNotEmpty ? ' – $note' : ''),
        transactionType: txType,
      );

      await transactionProvider.addTransaction(tx);

      final allTx = transactionProvider.transactions;
      final createdTx = allTx.isNotEmpty ? allTx.first : null;

      final payment = DebtPayment(
        debtId: debt.id!,
        accountId: accountId,
        transactionId: createdTx?.id,
        amount: amount,
        date: DateTime.now(),
        note: note,
      );
      await _paymentRepository.create(payment);

      final newRemaining = (debt.remainingAmount - amount).clamp(0.0, double.infinity);
      final settled = newRemaining <= 0;

      await _debtRepository.update(debt.copyWith(
        remainingAmount: newRemaining,
        isSettled: settled,
      ));

      if (settled) {
        await NotificationService.cancelDebtReminder(debt.id!);
      }

      await mainProvider.loadAllData();
      return true;
    } catch (e) {
      _setError('Erreur paiement: $e');
      return false;
    }
  }

  Future<void> removePayment(DebtPayment payment, Debt debt) async {
    try {
      await _paymentRepository.delete(payment.id!);
      final newRemaining =
          (debt.remainingAmount + payment.amount).clamp(0.0, debt.totalAmount);
      await _debtRepository.update(debt.copyWith(
        remainingAmount: newRemaining,
        isSettled: false,
      ));
      await loadDebts();
    } catch (e) {
      _setError('Erreur suppression paiement: $e');
    }
  }

  Future<void> settleDebt(Debt debt) async {
    try {
      await _debtRepository.update(debt.copyWith(
        remainingAmount: 0,
        isSettled: true,
      ));
      await NotificationService.cancelDebtReminder(debt.id!);
      await loadDebts();
    } catch (e) {
      _setError('Erreur règlement dette: $e');
    }
  }

  // ───────── Private ─────────

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
