class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;

  const Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  Goal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
    );
  }

  double get progress {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    return targetAmount - currentAmount;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  String get progressDisplay {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  bool get isAchieved {
    return currentAmount >= targetAmount;
  }

  bool get isOverdue {
    return DateTime.now().isAfter(deadline) && !isAchieved;
  }

  String get statusDisplay {
    if (isAchieved) return '✅ Achieved';
    if (isOverdue) return '⚠️ Overdue';
    return '🎯 In Progress';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal &&
        other.id == id &&
        other.name == name &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.deadline == deadline;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        deadline.hashCode;
  }

  @override
  String toString() {
    return 'Goal(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, deadline: $deadline)';
  }
}
