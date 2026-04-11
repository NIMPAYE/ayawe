import 'package:flutter/material.dart';

/// État UI de l’écran Statistiques (onglet, année, catégorie du rapport).
class StatsProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  late int _selectedYear;
  int? _selectedCategoryId;

  StatsProvider() {
    _selectedYear = DateTime.now().year;
  }

  int get selectedTabIndex => _selectedTabIndex;

  int get selectedYear => _selectedYear;

  int? get selectedCategoryId => _selectedCategoryId;

  void setTab(int index) {
    if (index == _selectedTabIndex) return;
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setYear(int year) {
    if (year == _selectedYear) return;
    _selectedYear = year;
    notifyListeners();
  }

  void setCategoryId(int? id) {
    if (id == _selectedCategoryId) return;
    _selectedCategoryId = id;
    notifyListeners();
  }
}
