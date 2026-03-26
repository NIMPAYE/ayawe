import '../../domain/entities/goal.dart';

class GoalModel extends Goal {
  const GoalModel({
    super.id,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.deadline,
    super.icon,
    super.color,
    super.imagePath,
    super.currency,
  });

  factory GoalModel.fromEntity(Goal entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadline: entity.deadline,
      icon: entity.icon,
      color: entity.color,
      imagePath: entity.imagePath,
      currency: entity.currency,
    );
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount']?.toDouble() ?? 0.0,
      currentAmount: map['current_amount']?.toDouble() ?? 0.0,
      deadline: DateTime.parse(map['deadline']),
      icon: map['icon'] ?? '🎯',
      color: map['color'] ?? 0xFF7C4DFF,
      imagePath: map['image_path'],
      currency: map['currency'] ?? 'BIF',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'icon': icon,
      'color': color,
      'image_path': imagePath,
      'currency': currency,
    };
  }

  Goal toEntity() {
    return Goal(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      icon: icon,
      color: color,
      imagePath: imagePath,
      currency: currency,
    );
  }
}
