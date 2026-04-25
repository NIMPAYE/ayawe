import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../domain/stats_aggregator.dart';
import '../providers/stats_provider.dart';
import '../widgets/stats_category_amount_list.dart';
import '../widgets/stats_currency_tabs.dart';
import '../widgets/stats_expense_pie_section.dart';
import '../widgets/stats_month_bar_chart_section.dart';
import '../widgets/stats_month_line_chart_section.dart';
import '../widgets/stats_month_summary_cards.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final stats = context.watch<StatsProvider>();
    final tx = context.watch<TransactionProvider>();
    final categories = context.watch<CategoryProvider>();
    final accounts = context.watch<AccountProvider>();

    final now = DateTime.now();
    final monthRef = DateTime(now.year, now.month);
    final monthTitle = DateFormat.yMMMM('fr').format(monthRef);
    final currency = stats.selectedCurrency;
    final currencyLabel = currency.symbol;

    final summary = StatsAggregator.monthSummaryForCurrency(
      tx.transactions,
      accounts.accounts,
      currency,
      monthRef,
    );
    final daily = StatsAggregator.dailySeriesForMonthCurrency(
      tx.transactions,
      accounts.accounts,
      currency,
      monthRef,
    );
    final breakdown = StatsAggregator.expenseBreakdownMonthCurrency(
      tx.transactions,
      accounts.accounts,
      categories.categories,
      currency,
      monthRef,
    );

    final loading = tx.isLoading || categories.isLoading || accounts.isLoading;
    final hasAnyTxEver = tx.transactions.isNotEmpty;
    final hasMonthActivity =
        summary.income > 0 || summary.expense > 0 || breakdown.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistiques',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: ext.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                StatsCurrencyTabs(
                  selected: currency,
                  onChanged: context.read<StatsProvider>().setCurrency,
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : !hasAnyTxEver
                    ? _EmptyStats(ext: ext)
                    : !hasMonthActivity
                        ? _EmptyMonthForCurrency(
                            ext: ext,
                            currencyLabel: currencyLabel,
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                StatsMonthSummaryCards(
                                  totals: summary,
                                  currencyLabel: currencyLabel,
                                ),
                                const SizedBox(height: 16),
                                StatsExpensePieSection(
                                  breakdown: breakdown,
                                  currencyLabel: currencyLabel,
                                ),
                                const SizedBox(height: 16),
                                StatsMonthLineChartSection(
                                  daily: daily,
                                  currencyLabel: currencyLabel,
                                ),
                                const SizedBox(height: 16),
                                StatsMonthBarChartSection(
                                  daily: daily,
                                  currencyLabel: currencyLabel,
                                ),
                                const SizedBox(height: 16),
                                StatsCategoryAmountList(
                                  breakdown: breakdown,
                                  currencyLabel: currencyLabel,
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

class _EmptyStats extends StatelessWidget {
  const _EmptyStats({required this.ext});

  final AppThemeExtension ext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.query_stats_rounded, size: 64, color: ext.emptyState),
            const SizedBox(height: 20),
            Text(
              'Ajoutez des transactions pour voir vos statistiques.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: ext.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMonthForCurrency extends StatelessWidget {
  const _EmptyMonthForCurrency({
    required this.ext,
    required this.currencyLabel,
  });

  final AppThemeExtension ext;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 56, color: ext.emptyState),
            const SizedBox(height: 16),
            Text(
              'Aucune opération ce mois-ci pour les comptes en $currencyLabel.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: ext.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
