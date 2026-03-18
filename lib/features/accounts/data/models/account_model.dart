import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    super.id,
    required super.name,
    required super.type,
    required super.currentBalance,
    required super.currency,
  });

  factory AccountModel.fromEntity(Account entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      currentBalance: entity.currentBalance,
      currency: entity.currency,
    );
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      type: AccountType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      currentBalance: map['current_balance']?.toDouble() ?? 0.0,
      currency: Currency.values.firstWhere(
        (e) => e.toString().split('.').last == map['currency'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'current_balance': currentBalance,
      'currency': currency.toString().split('.').last,
    };
  }

  Account toEntity() {
    return Account(
      id: id,
      name: name,
      type: type,
      currentBalance: currentBalance,
      currency: currency,
    );
  }
}
