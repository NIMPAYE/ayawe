import 'package:flutter/material.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _goalRepository;

  GoalProvider(this._goalRepository);

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

  Future<void> loadGoals() async {
    _setLoading(true);
    _clearError();
    try {
      _goals = await _goalRepository.getGoals();
    } catch (e) {
      _setError('Error loading goals: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      await _goalRepository.createGoal(goal);
      await loadGoals();
    } catch (e) {
      _setError('Error adding goal: $e');
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await _goalRepository.updateGoal(goal);
      await loadGoals();
    } catch (e) {
      _setError('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _goalRepository.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      _setError('Error deleting goal: $e');
    }
  }

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
    notifyListeners();
  }
}
