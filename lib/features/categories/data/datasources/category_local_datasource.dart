import '../models/category_model.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/category.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type);
  Future<CategoryModel?> getCategoryById(int id);
  Future<int> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(int id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CategoryLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type.toString().split('.').last],
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> createCategory(CategoryModel category) async {
    final db = await _databaseHelper.database;
    return await db.insert('categories', category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final db = await _databaseHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
