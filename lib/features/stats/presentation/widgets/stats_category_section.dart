import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsCategorySection extends StatelessWidget {
  const StatsCategorySection({
    super.key,
    required this.series,
    required this.expenseCategories,
    required this.selectedYear,
    required this.selectedCategoryId,
    required this.currencyLabel,
    required this.onYearChanged,
    required this.onCategoryChanged,
  });

  final CategoryMonthlySeries series;
  final List<Category> expenseCategories;
  final int selectedYear;
  final int? selectedCategoryId;
  final String currencyLabel;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final netFmt = NumberFormat('#,##0', 'fr');
    final monthShort = DateFormat.MMM('fr');

    if (expenseCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Aucune catégorie de dépense.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: ext.textTertiary),
        ),
        ),
      );
    }

    final now = DateTime.now();
    final years = List.generate(6, (i) => now.year - i);

    final maxM = series.monthlyAmounts.reduce(
      (a, b) => a > b ? a : b,
    );
    final maxY = maxM <= 0 ? 1.0 : maxM * 1.12;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        StatsFuturisticCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Rapport par catégorie',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Année',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: selectedYear,
                    items: years
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text('$y')),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onYearChanged(v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: selectedCategoryId,
                    items: expenseCategories
                        .where((c) => c.id != null)
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: onCategoryChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StatsFuturisticCard(
          useBlur: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${series.categoryName} — $selectedYear',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total : ${netFmt.format(series.yearlyTotal)} $currencyLabel',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
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
                'Mois par mois',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
                          final m = group.x.toInt();
                          if (m < 0 || m > 11) return null;
                          return BarTooltipItem(
                            '${monthShort.format(DateTime(selectedYear, m + 1))}\n${netFmt.format(series.monthlyAmounts[m])}',
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value <= 0) return const SizedBox.shrink();
                            return Text(
                              netFmt.format(value),
                              style: GoogleFonts.poppins(
                                fontSize: 8,
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
                            final m = value.toInt();
                            if (m < 0 || m > 11) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                monthShort
                                    .format(DateTime(selectedYear, m + 1)),
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
                    barGroups: List.generate(12, (m) {
                      return BarChartGroupData(
                        x: m,
                        barRods: [
                          BarChartRodData(
                            toY: series.monthlyAmounts[m],
                            width: 8,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                            gradient: ext.expenseGradient,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
