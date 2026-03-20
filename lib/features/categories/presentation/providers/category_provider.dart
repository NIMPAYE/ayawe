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
