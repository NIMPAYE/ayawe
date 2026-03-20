import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  CategoryProvider(this._categoryRepository);

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == CategoryType.EXPENSE).toList();

  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == CategoryType.INCOME).toList();

  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();
    try {
      _categories = await _categoryRepository.getCategories();
    } catch (e) {
      _setError('Error loading categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    try {
      return await _categoryRepository.getCategoriesByType(type);
    } catch (e) {
      _setError('Error loading categories by type: $e');
      return [];
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _categoryRepository.createCategory(category);
      await loadCategories();
    } catch (e) {
      _setError('Error adding category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoryRepository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      _setError('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryRepository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      _setError('Error deleting category: $e');
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
