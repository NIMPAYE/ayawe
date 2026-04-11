import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../domain/stats_aggregator.dart';
import '../../domain/stats_models.dart';
import '../providers/stats_provider.dart';
import '../widgets/stats_cash_flow_section.dart';
import '../widgets/stats_category_section.dart';
import '../widgets/stats_segmented_tabs.dart';
import '../widgets/stats_trends_section.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    context.read<StatsProvider>().setTab(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final stats = context.watch<StatsProvider>();
    final tx = context.watch<TransactionProvider>();
    final categories = context.watch<CategoryProvider>();
    final account = context.watch<AccountProvider>();

    final now = DateTime.now();
    final cashPoints = StatsAggregator.cashFlowLast6Months(
      tx.transactions,
      now,
    );
    final expenseCats =
        StatsAggregator.expenseCategoriesOnly(categories.categories);
    Category? selectedCat;
    for (final c in expenseCats) {
      if (c.id == stats.selectedCategoryId) {
        selectedCat = c;
        break;
      }
    }
    selectedCat ??= expenseCats.isNotEmpty ? expenseCats.first : null;

    CategoryMonthlySeries series;
    if (selectedCat != null) {
      series = StatsAggregator.categoryExpenseYearSeries(
        tx.transactions,
        selectedCat,
        stats.selectedYear,
      );
    } else {
      series = CategoryMonthlySeries(
        categoryId: -1,
        categoryName: '—',
        year: stats.selectedYear,
        monthlyAmounts: List<double>.filled(12, 0),
      );
    }

    final trends = StatsAggregator.expenseTrendsMonthOverMonth(
      tx.transactions,
      expenseCats,
      now,
    );

    final currencyLabel = account.primaryCurrency.symbol;
    final loading = tx.isLoading || categories.isLoading;
    final hasAnyTx = tx.transactions.isNotEmpty;

    if (!loading && expenseCats.isNotEmpty) {
      final ok = stats.selectedCategoryId != null &&
          expenseCats.any((c) => c.id == stats.selectedCategoryId);
      if (!ok) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.read<StatsProvider>().setCategoryId(expenseCats.first.id);
        });
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withAlpha(
                theme.brightness == Brightness.dark ? 28 : 14,
              ),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vue d’ensemble de vos flux et habitudes',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: ext.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              StatsSegmentedTabs(
                selectedIndex: stats.selectedTabIndex,
                onChanged: _onTabSelected,
              ),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : !hasAnyTx
                        ? _EmptyStats(ext: ext)
                        : PageView(
                            controller: _pageController,
                            onPageChanged: (i) =>
                                context.read<StatsProvider>().setTab(i),
                            children: [
                              StatsCashFlowSection(
                                points: cashPoints,
                                currencyLabel: currencyLabel,
                              ),
                              StatsCategorySection(
                                series: series,
                                expenseCategories: expenseCats,
                                selectedYear: stats.selectedYear,
                                selectedCategoryId: selectedCat?.id,
                                currencyLabel: currencyLabel,
                                onYearChanged: stats.setYear,
                                onCategoryChanged: stats.setCategoryId,
                              ),
                              StatsTrendsSection(
                                insights: trends,
                                currencyLabel: currencyLabel,
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
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
