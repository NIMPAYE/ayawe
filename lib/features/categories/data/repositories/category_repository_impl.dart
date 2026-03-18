import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<Category>> getCategories() async {
    final models = await _localDataSource.getCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final models = await _localDataSource.getCategoriesByType(type);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final model = await _localDataSource.getCategoryById(id);
    return model?.toEntity();
  }

  @override
  Future<int> createCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    return await _localDataSource.createCategory(model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDataSource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _localDataSource.deleteCategory(id);
  }
}
