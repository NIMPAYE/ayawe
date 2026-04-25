import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsCategoryAmountList extends StatelessWidget {
  const StatsCategoryAmountList({
    super.key,
    required this.breakdown,
    required this.currencyLabel,
  });

  final List<ExpenseCategoryBreakdown> breakdown;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final fmt = NumberFormat('#,##0', 'fr');

    if (breakdown.isEmpty) {
      return StatsFuturisticCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Aucune catégorie avec dépense ce mois-ci.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ext.textTertiary,
            ),
          ),
        ),
      );
    }

    return StatsFuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détail par catégorie',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: breakdown.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: ext.border.withAlpha(120)),
            itemBuilder: (context, index) {
              final row = breakdown[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.categoryName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${fmt.format(row.amount)} $currencyLabel',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ext.expense,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
