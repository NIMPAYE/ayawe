import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsExpensePieSection extends StatelessWidget {
  const StatsExpensePieSection({
    super.key,
    required this.breakdown,
    required this.currencyLabel,
  });

  final List<ExpenseCategoryBreakdown> breakdown;
  final String currencyLabel;

  static List<Color> _sliceColors(BuildContext context, int n) {
    final scheme = Theme.of(context).colorScheme;
    final base = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
    ];
    final out = <Color>[];
    for (var i = 0; i < n; i++) {
      final c = base[i % base.length];
      final step = i ~/ base.length;
      out.add(Color.lerp(c, scheme.surfaceContainerHighest, step * 0.12)!);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final fmt = NumberFormat('#,##0', 'fr');
    final total = breakdown.fold<double>(0, (a, b) => a + b.amount);

    if (breakdown.isEmpty || total <= 0) {
      return StatsFuturisticCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'Aucune dépense par catégorie pour cette période.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: ext.textTertiary,
              ),
            ),
          ),
        ),
      );
    }

    final colors = _sliceColors(context, breakdown.length);
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < breakdown.length; i++) {
      final b = breakdown[i];
      final pct = (b.amount / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[i],
          value: b.amount,
          title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
          radius: 52,
          titleStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      );
    }

    return StatsFuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dépenses par catégorie',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Répartition du mois (hors transferts)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: ext.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < breakdown.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[i],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                breakdown[i].categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${fmt.format(breakdown[i].amount)} $currencyLabel',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: ext.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
