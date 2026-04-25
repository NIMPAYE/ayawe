import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsMonthBarChartSection extends StatelessWidget {
  const StatsMonthBarChartSection({
    super.key,
    required this.daily,
    required this.currencyLabel,
  });

  final List<DailyCashPoint> daily;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final moneyFmt = NumberFormat.compact(locale: 'fr');
    final fullFmt = NumberFormat('#,##0', 'fr');

    if (daily.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxExpense = daily
        .map((d) => d.expense)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxExpense <= 0 ? 1.0 : maxExpense * 1.15;

    return StatsFuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consommation journalière',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dépenses par jour du mois',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: ext.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.surfaceContainerHigh,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final i = group.x.toInt();
                      if (i < 0 || i >= daily.length) return null;
                      final e = daily[i].expense;
                      return BarTooltipItem(
                        '${daily[i].day.day}/${daily[i].day.month}\n${fullFmt.format(e)} $currencyLabel',
                        GoogleFonts.poppins(
                          color: theme.colorScheme.onSurface,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY > 0 ? maxY / 4 : 1,
                      getTitlesWidget: (v, m) => Text(
                        moneyFmt.format(v),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: ext.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: daily.length > 14 ? 5 : 2,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= daily.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${daily[i].day.day}',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: ext.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: theme.dividerColor.withAlpha(80),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < daily.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: daily[i].expense,
                          width: daily.length > 20 ? 4 : 7,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          color: theme.colorScheme.primary.withAlpha(200),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
