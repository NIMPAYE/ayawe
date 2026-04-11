import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsCashFlowSection extends StatelessWidget {
  const StatsCashFlowSection({
    super.key,
    required this.points,
    required this.currencyLabel,
  });

  final List<MonthlyCashFlowPoint> points;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final monthFmt = DateFormat.MMM('fr');

    if (points.isEmpty) {
      return _empty(context, ext);
    }

    final maxVal = points
        .map((p) => p.income > p.expense ? p.income : p.expense)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxVal <= 0 ? 1.0 : maxVal * 1.15;

    final last = points.last;
    final netFmt = NumberFormat('#,##0', 'fr');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        StatsFuturisticCard(
          useBlur: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solde net — ${monthFmt.format(last.month)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: ext.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${netFmt.format(last.net)} $currencyLabel',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: last.net >= 0 ? ext.income : ext.expense,
                ),
              ),
              Text(
                'Entrées ${netFmt.format(last.income)} · Sorties ${netFmt.format(last.expense)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: ext.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StatsFuturisticCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '6 derniers mois',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Revenus et dépenses (hors transferts)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: ext.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
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
                          if (i < 0 || i >= points.length) return null;
                          final p = points[i];
                          final label = rodIndex == 0 ? 'Entrées' : 'Sorties';
                          final v = rodIndex == 0 ? p.income : p.expense;
                          return BarTooltipItem(
                            '$label\n${netFmt.format(v)}',
                            GoogleFonts.poppins(
                              color: theme.colorScheme.onSurface,
                              fontSize: 12,
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
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            if (value <= 0) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              netFmt.format(value),
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: ext.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= points.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                monthFmt.format(points[i].month),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: ext.textTertiary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 5 ? maxY / 4 : 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: ext.border.withAlpha(100),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(points.length, (i) {
                      final p = points[i];
                      return BarChartGroupData(
                        x: i,
                        barsSpace: 6,
                        barRods: [
                          BarChartRodData(
                            toY: p.income,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            color: ext.income,
                          ),
                          BarChartRodData(
                            toY: p.expense,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            color: ext.expense,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legend(ext.income, 'Entrées'),
                  const SizedBox(width: 24),
                  _legend(ext.expense, 'Sorties'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, AppThemeExtension ext) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Aucune donnée pour le cash flow.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: ext.textTertiary),
        ),
      ),
    );
  }
}
