import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/stats_models.dart';
import 'stats_futuristic_card.dart';

class StatsTrendsSection extends StatelessWidget {
  const StatsTrendsSection({
    super.key,
    required this.insights,
    required this.currencyLabel,
  });

  final List<TrendInsight> insights;
  final String currencyLabel;

  static String messageFor(TrendInsight i) {
    if (i.firstActivityThisMonth) {
      return 'Première dépense en ${i.categoryName} ce mois-ci.';
    }
    final pct = i.percentChange;
    if (pct == null) return '';
    if (i.direction == TrendDirection.increase) {
      return 'Vous dépensez ${pct.abs().toStringAsFixed(0)} % de plus '
          'en ${i.categoryName} ce mois-ci par rapport au mois dernier.';
    }
    if (i.direction == TrendDirection.decrease) {
      return 'Vous dépensez ${pct.abs().toStringAsFixed(0)} % de moins '
          'en ${i.categoryName} ce mois-ci par rapport au mois dernier.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0', 'fr');

    if (insights.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_outlined,
                size: 48,
                color: ext.emptyState,
              ),
              const SizedBox(height: 16),
              Text(
                'Pas assez de variation récente pour afficher des tendances.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: ext.textTertiary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: insights.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final insight = insights[index];
        final msg = messageFor(insight);
        final accent = insight.direction == TrendDirection.increase
            ? ext.expense
            : insight.direction == TrendDirection.decrease
                ? ext.income
                : theme.colorScheme.primary;

        return StatsFuturisticCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    insight.direction == TrendDirection.increase
                        ? Icons.trending_up_rounded
                        : insight.direction == TrendDirection.decrease
                            ? Icons.trending_down_rounded
                            : Icons.trending_flat_rounded,
                    color: accent,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.categoryName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (msg.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  msg,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.35,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Ce mois : ${fmt.format(insight.currentMonthTotal)} $currencyLabel · '
                'Mois dernier : ${fmt.format(insight.previousMonthTotal)} $currencyLabel',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: ext.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
