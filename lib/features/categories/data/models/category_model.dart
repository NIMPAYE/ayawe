import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    required super.type,
    required super.icon,
  });

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      icon: entity.icon,
    );
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: CategoryType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      icon: map['icon'] ?? '📌',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'icon': icon,
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      type: type,
      icon: icon,
    );
  }
}
