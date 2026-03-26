enum DebtType { LENT, BORROWED }

class Debt {
  final int? id;
  final String personName;
  final DebtType type;
  final double totalAmount;
  final double remainingAmount;
  final String currency;
  final String description;
  final DateTime createdDate;
  final DateTime? dueDate;
  final bool isSettled;
  final int accountId;
  final int? transactionId;

  const Debt({
    this.id,
    required this.personName,
    required this.type,
    required this.totalAmount,
    required this.remainingAmount,
    this.currency = 'BIF',
    this.description = '',
    required this.createdDate,
    this.dueDate,
    this.isSettled = false,
    required this.accountId,
    this.transactionId,
  });

  double get progress =>
      totalAmount > 0 ? (totalAmount - remainingAmount) / totalAmount : 0.0;

  bool get isOverdue =>
      !isSettled && dueDate != null && DateTime.now().isAfter(dueDate!);

  int? get daysUntilDue =>
      dueDate?.difference(DateTime.now()).inDays;

  bool get isDueSoon {
    if (isSettled || dueDate == null) return false;
    final days = dueDate!.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 3;
  }

  String get statusDisplay {
    if (isSettled) return 'Réglé';
    if (isOverdue) return 'En retard';
    return 'En cours';
  }

  String get typeDisplay {
    switch (type) {
      case DebtType.LENT:
        return 'On me doit';
      case DebtType.BORROWED:
        return 'Je dois';
    }
  }

  Debt clearDueDate() {
    return Debt(
      id: id,
      personName: personName,
      type: type,
      totalAmount: totalAmount,
      remainingAmount: remainingAmount,
      currency: currency,
      description: description,
      createdDate: createdDate,
      dueDate: null,
      isSettled: isSettled,
      accountId: accountId,
      transactionId: transactionId,
    );
  }

  Debt copyWith({
    int? id,
    String? personName,
    DebtType? type,
    double? totalAmount,
    double? remainingAmount,
    String? currency,
    String? description,
    DateTime? createdDate,
    DateTime? dueDate,
    bool? isSettled,
    int? accountId,
    int? transactionId,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      isSettled: isSettled ?? this.isSettled,
      accountId: accountId ?? this.accountId,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Debt &&
        other.id == id &&
        other.personName == personName &&
        other.type == type &&
        other.totalAmount == totalAmount &&
        other.remainingAmount == remainingAmount &&
        other.currency == currency &&
        other.description == description &&
        other.createdDate == createdDate &&
        other.dueDate == dueDate &&
        other.isSettled == isSettled &&
        other.accountId == accountId &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        personName.hashCode ^
        type.hashCode ^
        totalAmount.hashCode ^
        remainingAmount.hashCode ^
        currency.hashCode ^
        description.hashCode ^
        createdDate.hashCode ^
        dueDate.hashCode ^
        isSettled.hashCode ^
        accountId.hashCode ^
        transactionId.hashCode;
  }

  @override
  String toString() {
    return 'Debt(id: $id, personName: $personName, type: $type, total: $totalAmount, remaining: $remainingAmount, settled: $isSettled)';
  }
}
