import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsMonthSummaryCards extends StatelessWidget {
  const StatsMonthSummaryCards({
    super.key,
    required this.totals,
    required this.currencyLabel,
  });

  final MonthSummaryTotals totals;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final fmt = NumberFormat('#,##0', 'fr');

    Widget card({
      required String title,
      required double value,
      required Color accent,
      required IconData icon,
    }) {
      return Expanded(
        child: StatsFuturisticCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ext.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${fmt.format(value)} $currencyLabel',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card(
          title: 'Revenus',
          value: totals.income,
          accent: ext.income,
          icon: Icons.trending_up_rounded,
        ),
        const SizedBox(width: 12),
        card(
          title: 'Dépenses',
          value: totals.expense,
          accent: ext.expense,
          icon: Icons.trending_down_rounded,
        ),
      ],
    );
  }
}
