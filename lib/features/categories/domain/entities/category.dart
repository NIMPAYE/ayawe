enum CategoryType { EXPENSE, INCOME }

class Category {
  final int? id;
  final String name;
  final CategoryType type;
  final String icon;

  const Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  Category copyWith({
    int? id,
    String? name,
    CategoryType? type,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }

  String get typeDisplay {
    switch (type) {
      case CategoryType.EXPENSE:
        return '📉 Expense';
      case CategoryType.INCOME:
        return '📈 Income';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ type.hashCode ^ icon.hashCode;
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type, icon: $icon)';
  }
}

// Predefined categories for Burundian context
class PredefinedCategories {
  static List<Category> get expenses => [
    const Category(name: 'Transport', type: CategoryType.EXPENSE, icon: '🚌'),
    const Category(name: 'Meals', type: CategoryType.EXPENSE, icon: '🍔'),
    const Category(name: 'Internet', type: CategoryType.EXPENSE, icon: '📱'),
    const Category(name: 'Phone Credit', type: CategoryType.EXPENSE, icon: '💳'),
    const Category(name: 'Rent', type: CategoryType.EXPENSE, icon: '🏠'),
    const Category(name: 'Groceries', type: CategoryType.EXPENSE, icon: '🛒'),
    const Category(name: 'Healthcare', type: CategoryType.EXPENSE, icon: '🏥'),
    const Category(name: 'Education', type: CategoryType.EXPENSE, icon: '📚'),
    const Category(name: 'Entertainment', type: CategoryType.EXPENSE, icon: '🎮'),
    const Category(name: 'Other', type: CategoryType.EXPENSE, icon: '📌'),
  ];

  static List<Category> get income => [
    const Category(name: 'Salary', type: CategoryType.INCOME, icon: '💼'),
    const Category(name: 'Business', type: CategoryType.INCOME, icon: '💼'),
    const Category(name: 'Gift Received', type: CategoryType.INCOME, icon: '🎁'),
    const Category(name: 'Loan Repayment', type: CategoryType.INCOME, icon: '💰'),
    const Category(name: 'Other Income', type: CategoryType.INCOME, icon: '📌'),
  ];

  static List<Category> get debt => [
    const Category(name: 'Prêt accordé', type: CategoryType.EXPENSE, icon: '🤝'),
    const Category(name: 'Remboursement dette', type: CategoryType.EXPENSE, icon: '💸'),
  ];
}
