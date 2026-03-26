class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String icon;
  final int color;
  final String? imagePath;
  final String currency;

  const Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.icon = '🎯',
    this.color = 0xFF7C4DFF,
    this.imagePath,
    this.currency = 'BIF',
  });

  Goal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? icon,
    int? color,
    String? imagePath,
    String? currency,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      currency: currency ?? this.currency,
    );
  }

  /// Allow explicitly clearing the image path
  Goal clearImage() {
    return Goal(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      icon: icon,
      color: color,
      imagePath: null,
      currency: currency,
    );
  }

  double get progress {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount => targetAmount - currentAmount;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  String get progressDisplay =>
      '${(progress * 100).toStringAsFixed(1)}%';

  bool get isAchieved => currentAmount >= targetAmount;

  bool get isOverdue => DateTime.now().isAfter(deadline) && !isAchieved;

  String get statusDisplay {
    if (isAchieved) return 'Atteint';
    if (isOverdue) return 'En retard';
    return 'En cours';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal &&
        other.id == id &&
        other.name == name &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.deadline == deadline &&
        other.icon == icon &&
        other.color == color &&
        other.imagePath == imagePath &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        deadline.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        imagePath.hashCode ^
        currency.hashCode;
  }

  @override
  String toString() {
    return 'Goal(id: $id, name: $name, target: $targetAmount, current: $currentAmount, currency: $currency)';
  }
}
