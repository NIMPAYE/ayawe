import 'package:flutter/material.dart';

import '../../../accounts/domain/entities/account.dart';

/// État UI de l’écran Statistiques (devise pour le tableau de bord du mois).
class StatsProvider extends ChangeNotifier {
  Currency _selectedCurrency = Currency.BIF;

  Currency get selectedCurrency => _selectedCurrency;

  void setCurrency(Currency currency) {
    if (currency == _selectedCurrency) return;
    _selectedCurrency = currency;
    notifyListeners();
  }
}
