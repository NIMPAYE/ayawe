import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Blue-Violet Primary ──
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7CF6);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primarySurface = Color(0xFFEDE9FE);
  static const Color primarySurfaceDark = Color(0xFF1E1B3A);

  // ── Semantic ──
  static const Color income = Color(0xFF00C48C);
  static const Color incomeSurface = Color(0xFFE6FAF3);
  static const Color incomeSurfaceDark = Color(0xFF0D2E23);
  static const Color expense = Color(0xFFFF6B6B);
  static const Color expenseSurface = Color(0xFFFEE8E8);
  static const Color expenseSurfaceDark = Color(0xFF2E0D0D);
  static const Color warning = Color(0xFFFFB800);
  static const Color warningSurface = Color(0xFFFFF7E0);

  // ── Light Theme Neutrals ──
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8ECF4);
  static const Color lightDivider = Color(0xFFF0F2F8);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightIcon = Color(0xFF6B7280);
  static const Color lightEmptyState = Color(0xFFF0F2F8);

  // ── Dark Theme Neutrals ──
  static const Color darkBackground = Color(0xFF0A0A12);
  static const Color darkSurface = Color(0xFF141422);
  static const Color darkCard = Color(0xFF1C1C30);
  static const Color darkBorder = Color(0xFF2A2A42);
  static const Color darkDivider = Color(0xFF22223A);
  static const Color darkTextPrimary = Color(0xFFF4F4F8);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkIcon = Color(0xFF9CA3AF);
  static const Color darkEmptyState = Color(0xFF1C1C30);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceCardLight = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF5A4BD1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceCardDark = LinearGradient(
    colors: [Color(0xFF4A3CB5), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00C48C), Color(0xFF00E5A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
