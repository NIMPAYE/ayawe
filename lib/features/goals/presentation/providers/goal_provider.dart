import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_contribution.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/repositories/goal_contribution_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../../presentation/providers/main_provider.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _goalRepository;
  final GoalContributionRepository _contributionRepository;

  GoalProvider(this._goalRepository, this._contributionRepository);

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Goal> get activeGoals =>
      _goals.where((g) => !g.isAchieved && !g.isOverdue).toList();

  List<Goal> get achievedGoals =>
      _goals.where((g) => g.isAchieved).toList();

  List<Goal> get overdueGoals =>
      _goals.where((g) => g.isOverdue).toList();

  double get totalTarget =>
      _goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get totalSaved =>
      _goals.fold(0.0, (sum, g) => sum + g.currentAmount);

  // ───────── CRUD ─────────

  Future<void> loadGoals() async {
    _setLoading(true);
    _clearError();
    try {
      _goals = await _goalRepository.getGoals();
    } catch (e) {
      _setError('Erreur chargement objectifs: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      await _goalRepository.createGoal(goal);
      await loadGoals();
    } catch (e) {
      _setError('Erreur ajout objectif: $e');
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await _goalRepository.updateGoal(goal);
      await loadGoals();
    } catch (e) {
      _setError('Erreur mise à jour objectif: $e');
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _goalRepository.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      _setError('Erreur suppression objectif: $e');
    }
  }

  // ───────── Contributions ─────────

  Future<List<GoalContribution>> getContributions(int goalId) async {
    try {
      return await _contributionRepository.getByGoalId(goalId);
    } catch (e) {
      _setError('Erreur chargement contributions: $e');
      return [];
    }
  }

  /// Create a real OUTGOING transaction, record the contribution, and update the goal.
  Future<bool> contribute({
    required Goal goal,
    required int accountId,
    required int categoryId,
    required double amount,
    required String note,
    required TransactionProvider transactionProvider,
    required MainProvider mainProvider,
  }) async {
    try {
      final tx = Transaction(
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        date: DateTime.now(),
        description: 'Épargne: ${goal.name}${note.isNotEmpty ? ' – $note' : ''}',
        transactionType: TransactionType.OUTGOING,
      );

      await transactionProvider.addTransaction(tx);

      // Get the ID of the transaction we just created (latest)
      final allTx = transactionProvider.transactions;
      final createdTx = allTx.isNotEmpty ? allTx.first : null;

      final contribution = GoalContribution(
        goalId: goal.id!,
        accountId: accountId,
        transactionId: createdTx?.id,
        amount: amount,
        date: DateTime.now(),
        note: note,
      );
      await _contributionRepository.create(contribution);

      await _goalRepository.updateGoal(
        goal.copyWith(currentAmount: goal.currentAmount + amount),
      );

      await mainProvider.loadAllData();
      return true;
    } catch (e) {
      _setError('Erreur contribution: $e');
      return false;
    }
  }

  /// Remove a contribution and reverse the goal amount.
  Future<void> removeContribution(
    GoalContribution contribution,
    Goal goal,
  ) async {
    try {
      await _contributionRepository.delete(contribution.id!);
      await _goalRepository.updateGoal(
        goal.copyWith(
          currentAmount: (goal.currentAmount - contribution.amount)
              .clamp(0.0, double.infinity),
        ),
      );
      await loadGoals();
    } catch (e) {
      _setError('Erreur suppression contribution: $e');
    }
  }

  // ───────── Interest Simulation ─────────

  /// Compound interest: A = P * (1 + r/12)^m
  static double simulateInterest({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    if (principal <= 0 || annualRate <= 0 || months <= 0) return principal;
    final monthlyRate = annualRate / 12;
    return principal * pow(1 + monthlyRate, months);
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
