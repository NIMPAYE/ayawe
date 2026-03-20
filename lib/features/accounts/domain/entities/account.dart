enum AccountType { CASH, MOBILE_MONEY, BANK }

enum Currency {
  BIF,
  USD;

  String get symbol {
    switch (this) {
      case Currency.BIF:
        return 'BIF';
      case Currency.USD:
        return 'USD';
    }
  }
}

class Account {
  final int? id;
  final String name;
  final AccountType type;
  final double currentBalance;
  final Currency currency;

  const Account({
    this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    required this.currency,
  });

  Account copyWith({
    int? id,
    String? name,
    AccountType? type,
    double? currentBalance,
    Currency? currency,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
    );
  }

  String get currencySymbol {
    switch (currency) {
      case Currency.BIF:
        return 'BIF';
      case Currency.USD:
        return '\$';
    }
  }

  String get typeDisplay {
    switch (type) {
      case AccountType.CASH:
        return '💵 Cash';
      case AccountType.MOBILE_MONEY:
        return '📱 Mobile Money';
      case AccountType.BANK:
        return '🏦 Bank';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.currentBalance == currentBalance &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        currentBalance.hashCode ^
        currency.hashCode;
  }

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, currentBalance: $currentBalance, currency: $currency)';
  }
}
