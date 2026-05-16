import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Resyst Theme Primary ──
  static const Color primary = Color(0xFF354464);
  static const Color primaryLight = Color(0xFFA4C3E7);
  static const Color primaryDark = Color(0xFF1E2D45);
  static const Color primarySurface = Color(0xFFF1F2F4); 
  static const Color primarySurfaceDark = Color(0xFF243652);

  // ── Semantic ──
  static const Color income = Color(0xFF26C485);
  static const Color incomeSurface = Color(0xFFE8F8F1);
  static const Color incomeSurfaceDark = Color(0xFF154E38);
  static const Color expense = Color(0xFFDE6449);
  static const Color expenseSurface = Color(0xFFFBECE8);
  static const Color expenseSurfaceDark = Color(0xFF5A2A1F);
  static const Color warning = Color(0xFFF5A524);
  static const Color warningSurface = Color(0xFFFEF3C7);

  // ── Light Theme Neutrals ──
  static const Color lightBackground = Color(0xFFF7F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4E4E4);
  static const Color lightDivider = Color(0xFFF1F2F4);
  static const Color lightTextPrimary = Color(0xFF354464);
  static const Color lightTextSecondary = Color(0xFF8FA0B8);
  static const Color lightTextTertiary = Color(0xFF4E5C7B);
  static const Color lightIcon = Color(0xFF8FA0B8);
  static const Color lightEmptyState = Color(0xFFF1F2F4);

  // ── Dark Theme Neutrals ──
  static const Color darkBackground = Color(0xFF1E2D45);
  static const Color darkSurface = Color(0xFF243652);
  static const Color darkCard = Color(0xFF243652);
  static const Color darkBorder = Color(0xFF354464);
  static const Color darkDivider = Color(0xFF354464);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF4E5C7B);
  static const Color darkTextTertiary = Color(0xFF687897);
  static const Color darkIcon = Color(0xFF4E5C7B);
  static const Color darkEmptyState = Color(0xFF354464);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF354464), Color(0xFF4E5C7B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceCardLight = LinearGradient(
    colors: [Color(0xFF354464), Color(0xFF1E2D45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceCardDark = LinearGradient(
    colors: [Color(0xFF243652), Color(0xFF354464)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF26C485), Color(0xFF1E9B6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFDE6449), Color(0xFFB3503B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
