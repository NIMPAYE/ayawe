import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsMonthLineChartSection extends StatelessWidget {
  const StatsMonthLineChartSection({
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
    final dayFmt = DateFormat.E('fr');
    final moneyFmt = NumberFormat.compact(locale: 'fr');

    if (daily.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVal = daily
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxVal <= 0 ? 1.0 : maxVal * 1.1;

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    for (var i = 0; i < daily.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), daily[i].income));
      expenseSpots.add(FlSpot(i.toDouble(), daily[i].expense));
    }

    return StatsFuturisticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenus et dépenses par jour',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Courbes sur le mois en cours',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: ext.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(color: ext.income, label: 'Revenus'),
              const SizedBox(width: 16),
              _LegendDot(color: ext.expense, label: 'Dépenses'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (daily.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: theme.dividerColor.withAlpha(80),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
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
                      reservedSize: 40,
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
                      interval: daily.length > 14 ? 5 : 3,
                      getTitlesWidget: (v, m) {
                        final i = v.round();
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.surfaceContainerHigh,
                    getTooltipItems: (List<LineBarSpot> spots) {
                      return spots.map((spot) {
                        final i =
                            spot.x.round().clamp(0, daily.length - 1);
                        final d = daily[i];
                        final label = dayFmt.format(d.day);
                        final isIncome = spot.barIndex == 0;
                        final val = isIncome ? d.income : d.expense;
                        final name = isIncome ? 'Revenus' : 'Dépenses';
                        return LineTooltipItem(
                          '$label\n$name: ${NumberFormat('#,##0', 'fr').format(val)} $currencyLabel',
                          GoogleFonts.poppins(
                            color: theme.colorScheme.onSurface,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: incomeSpots,
                    isCurved: true,
                    color: ext.income,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ext.income.withAlpha(35),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseSpots,
                    isCurved: true,
                    color: ext.expense,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ext.expense.withAlpha(35),
                    ),
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }
}
