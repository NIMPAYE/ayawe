import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<List<Category>> getCategoriesByType(CategoryType type);
  Future<Category?> getCategoryById(int id);
  Future<int> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}
