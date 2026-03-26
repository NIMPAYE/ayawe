import '../../../transactions/domain/entities/transaction.dart';

enum RecurrenceFrequency { MONTHLY, WEEKLY, BIWEEKLY, YEARLY }

extension RecurrenceFrequencyX on RecurrenceFrequency {
  String get label {
    switch (this) {
      case RecurrenceFrequency.MONTHLY:
        return 'Mensuel';
      case RecurrenceFrequency.WEEKLY:
        return 'Hebdomadaire';
      case RecurrenceFrequency.BIWEEKLY:
        return 'Bimensuel';
      case RecurrenceFrequency.YEARLY:
        return 'Annuel';
    }
  }
}

class RecurringTransaction {
  final int? id;
  final int accountId;
  final int categoryId;
  final double amount;
  final String description;
  final TransactionType transactionType;
  final RecurrenceFrequency frequency;
  final DateTime nextDueDate;
  final bool isActive;

  const RecurringTransaction({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.transactionType,
    required this.frequency,
    required this.nextDueDate,
    this.isActive = true,
  });

  bool get isDueSoon {
    final diff = nextDueDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }

  bool get isOverdue => DateTime.now().isAfter(nextDueDate) && isActive;

  int get daysUntilDue => nextDueDate.difference(DateTime.now()).inDays;

  DateTime get nextDateAfterDue => _advance(nextDueDate);

  /// Project all occurrences within a date range (for calendar).
  /// Capped at 366 iterations to prevent infinite loops.
  List<DateTime> projectOccurrences(DateTime from, DateTime to) {
    if (!isActive) return [];
    final dates = <DateTime>[];
    var d = nextDueDate;
    if (d.isAfter(to)) return dates;
    var safety = 0;
    while (d.isBefore(from) && safety < 366) {
      d = _advance(d);
      safety++;
    }
    while (!d.isAfter(to) && safety < 366) {
      dates.add(d);
      d = _advance(d);
      safety++;
    }
    return dates;
  }

  DateTime _advance(DateTime date) {
    switch (frequency) {
      case RecurrenceFrequency.WEEKLY:
        return date.add(const Duration(days: 7));
      case RecurrenceFrequency.BIWEEKLY:
        return date.add(const Duration(days: 14));
      case RecurrenceFrequency.MONTHLY:
        return _addMonths(date, 1);
      case RecurrenceFrequency.YEARLY:
        return _addMonths(date, 12);
    }
  }

  /// Safely add months, clamping to the last day of the target month.
  /// e.g. Jan 31 + 1 month = Feb 28 (not Mar 3).
  static DateTime _addMonths(DateTime date, int months) {
    final targetMonth = date.month + months;
    final result = DateTime(date.year, targetMonth, date.day);
    // If the day overflowed into the next month, clamp to last day
    if (result.month != ((targetMonth - 1) % 12) + 1) {
      return DateTime(date.year, targetMonth + 1, 0);
    }
    return result;
  }

  RecurringTransaction copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    double? amount,
    String? description,
    TransactionType? transactionType,
    RecurrenceFrequency? frequency,
    DateTime? nextDueDate,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionType: transactionType ?? this.transactionType,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringTransaction &&
        other.id == id &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.amount == amount &&
        other.description == description &&
        other.transactionType == transactionType &&
        other.frequency == frequency &&
        other.nextDueDate == nextDueDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        accountId.hashCode ^
        categoryId.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        transactionType.hashCode ^
        frequency.hashCode ^
        nextDueDate.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'RecurringTransaction(id: $id, description: $description, amount: $amount, frequency: $frequency, nextDueDate: $nextDueDate, isActive: $isActive)';
  }
}
