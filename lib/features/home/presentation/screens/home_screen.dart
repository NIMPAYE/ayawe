import 'package:ayawe/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/main_provider.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../transactions/presentation/widgets/transaction_card.dart';
import '../../../budgets/presentation/providers/recurring_transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayawe',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<MainProvider>().refreshAll(),
          ),
        ],
      ),
      body: Consumer<MainProvider>(
        builder: (context, mainProvider, child) {
          if (mainProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (mainProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: ext.expense,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mainProvider.error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: ext.expense,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => mainProvider.refreshAll(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final accountProvider = mainProvider.accountProvider;
          final transactionProvider = mainProvider.transactionProvider;
          final goalProvider = mainProvider.goalProvider;

          return RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: () async => mainProvider.refreshAll(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BalanceCard(provider: mainProvider),
                  const SizedBox(height: 12),
                  const _RecurringAlert(),
                  const SizedBox(height: 12),
                  const _QuickActions(),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Mes Comptes',
                    onViewAll: () => Navigator.pushNamed(context, '/accounts'),
                  ),
                  const SizedBox(height: 0),
                  _AccountsList(accounts: accountProvider.accounts),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Transactions Récentes',
                    onViewAll: () =>
                        Navigator.pushNamed(context, '/transactions'),
                  ),
                  const SizedBox(height: 8),
                  _TransactionsList(
                    transactions: transactionProvider.transactions,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'Mes Objectifs'),
                  const SizedBox(height: 12),
                  _GoalsList(goals: goalProvider.goals),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────── Balance Card ───────────────

class _BalanceCard extends StatelessWidget {
  final MainProvider provider;
  const _BalanceCard({required this.provider});

  @override
  Widget build(BuildContext context) {
   // final ext = context.appTheme;
    final balances = provider.balanceByCurrency;
    final primary = provider.primaryCurrency;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient:Theme.of(context).brightness==Brightness.dark?  AppColors.primaryGradient :null,
          color: Theme.of(context).brightness==Brightness.light? AppColors.darkSurface : null ,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withAlpha(60),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 190,
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: SizedBox(
                  height: 140,
                  width: 140,
                  child: Stack(
                    children: [
                    Center(
                      child: SizedBox(
                        height: 86,
                        width: 86,
                        child: Center(
                          child: ClipPath(
                            clipper: RingClipper(innerRadiusRatio: .4),
                            child: Container(
                              color: Theme.of(context).brightness== .light? Theme.of(context).primaryColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 2),
                              height: 80,
                              width: 80,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 140,
                        width: 140,
                        color: Colors.transparent,
                        child: ClipPath(
                          clipper: RingClipper(innerRadiusRatio: .7),
                          child: Container(
                            color: Theme.of(context).brightness== .light? Colors.white.withAlpha(50):  Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            height: 140,
                            width: 140,
                          ),
                        ),
                      ),
                    ),
                  ],),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde Total',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withAlpha(180),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Primary currency in large
                    Text(
                      '${_formatAmount(balances[primary] ?? 0)} ${primary.symbol}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    // Other currencies below
                    ...balances.entries
                        .where((e) => e.key != primary)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${_formatAmount(e.value)} ${e.key.symbol}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withAlpha(160),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )),
                    const SizedBox(height: 20),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: _BalanceStat(
                            label: 'Revenus',
                            amount: provider.totalIncome,
                            icon: FontAwesomeIcons.arrowTrendUp,
                            color: const Color(0xFF00E5A0),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.white.withAlpha(40),
                        ),
                        Expanded(
                          child: _BalanceStat(
                            label: 'Dépenses',
                            amount: provider.totalExpenses,
                            icon: FontAwesomeIcons.arrowTrendDown,
                            color: const Color(0xFFFF8E8E),
                          ),
                        ),
                      ],
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

class RingClipper extends CustomClipper<Path> {
  final double innerRadiusRatio;

  RingClipper({this.innerRadiusRatio = 0.7});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width < size.height ? size.width / 2 : size.height / 2;
    final innerRadius = outerRadius * innerRadiusRatio;
    final Path outerCircle = Path()..addOval(Rect.fromCircle(center: center, radius: outerRadius));
    final Path innerCircle = Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius));

    return Path.combine(PathOperation.difference, outerCircle, innerCircle);
  }

  @override
  bool shouldReclip(RingClipper oldClipper) => oldClipper.innerRadiusRatio != innerRadiusRatio;
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, color: color, size: 12),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatAmount(amount)} BIF',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Recurring Alert ───────────────

class _RecurringAlert extends StatelessWidget {
  const _RecurringAlert();

  @override
  Widget build(BuildContext context) {
    final rtProvider = context.watch<RecurringTransactionProvider>();
    final dueSoon = rtProvider.dueSoonItems;
    if (dueSoon.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    final item = dueSoon.first;
    final isOverdue = item.isOverdue;
    final color = isOverdue ? ext.expense : ext.warning;
    final daysText = item.daysUntilDue == 0
        ? "aujourd'hui"
        : item.daysUntilDue < 0
            ? 'en retard de ${-item.daysUntilDue}j'
            : 'dans ${item.daysUntilDue} jour${item.daysUntilDue > 1 ? 's' : ''}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 25 : 12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(isDark ? 50 : 30)),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.notifications_active_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' · $daysText',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (dueSoon.length > 1)
                    TextSpan(
                      text: ' (+${dueSoon.length - 1} autres)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.textTertiary,
                      ),
                    ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Quick Actions ───────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickActionItem(
          icon: Icons.add_rounded,
          label: 'Compte',
          onTap: () => Navigator.pushNamed(context, '/add_account'),
        ),
        _QuickActionItem(
          icon: Icons.swap_horiz_rounded,
          label: 'Transférer',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(
                initialType: TransactionType.TRANSFER,
              ),
            ),
          ),
        ),
        _QuickActionItem(
          icon: Icons.category_rounded,
          label: 'Catégories',
          onTap: () => Navigator.pushNamed(context, '/categories'),
        ),
        _QuickActionItem(
          icon: Icons.flag_rounded,
          label: 'Objectifs',
          onTap: () => Navigator.pushNamed(context, '/goals'),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : theme.colorScheme.onSurface.withAlpha(18),
            ),
            child: Icon(
              icon,
              color: isDark
                  ? Colors.white.withAlpha(220)
                  : theme.colorScheme.onSurface.withAlpha(200),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Section Header ───────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text('Tout voir', style: GoogleFonts.poppins(fontSize: 13)),
          ),
      ],
    );
  }
}

// ─────────────── Accounts List ───────────────

class _AccountsList extends StatelessWidget {
  final List<Account> accounts;
  const _AccountsList({required this.accounts});

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return _EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        message: "Aucun compte. Ajoutez votre premier compte !",
      );
    }
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: accounts.length,
        separatorBuilder: (_, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _AccountCard(account: accounts[index]),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  const _AccountCard({required this.account});

  static const _typeIcons = {
    AccountType.CASH: Icons.payments_outlined,
    AccountType.MOBILE_MONEY: Icons.phone_android_rounded,
    AccountType.BANK: Icons.account_balance_rounded,
  };

  static const _typeColors = {
    AccountType.CASH: Color(0xFF00C48C),
    AccountType.MOBILE_MONEY: Color(0xFFFFB800),
    AccountType.BANK: Color(0xFF6C5CE7),
  };

  static const _typeLabels = {
    AccountType.CASH: 'Cash',
    AccountType.MOBILE_MONEY: 'Mobile',
    AccountType.BANK: 'Banque',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _typeColors[account.type] ?? theme.colorScheme.primary;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          width: 0.1,
          color: isDark ? Colors.white.withAlpha(15) : ext.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withAlpha(isDark ? 50 : 30),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primaryColorLight,width: 0.4)
                ),
                child: Icon(
                  _typeIcons[account.type] ?? Icons.wallet,
                  color: accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _typeLabels[account.type] ?? '',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ext.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row(
                  spacing: 4,
                  children: [
                    Text(
                      _formatAmount(account.currentBalance),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      account.currencySymbol,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0),
                Text(
                  account.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
         
        ],
      ),
    );
  }
}

// ─────────────── Transactions List ───────────────

class _TransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  const _TransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final recent = transactions.take(5).toList();
    if (recent.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: "Aucune transaction. Commencez à enregistrer !",
      );
    }

    final categories = context.watch<CategoryProvider>().categories;
    final accounts = context.watch<AccountProvider>().accounts;
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    return Column(
      children: recent.map((t) {
        final account = accountMap[t.accountId];
        String? toAccountName;
        if (t.isTransfer && t.toAccountId != null) {
          toAccountName = accountMap[t.toAccountId]?.name;
        }
        return TransactionCard(
          transaction: t,
          category: categoryMap[t.categoryId],
          currency: account?.currencySymbol ?? 'BIF',
          toAccountName: toAccountName,
        );
      }).toList(),
    );
  }
}

// ─────────────── Goals List ───────────────

class _GoalsList extends StatelessWidget {
  final List<Goal> goals;
  const _GoalsList({required this.goals});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return _EmptyState(
        icon: Icons.flag_outlined,
        message: "Aucun objectif. Définissez votre premier objectif !",
      );
    }
    return Column(
      children: goals.take(2).map((g) => _GoalCard(goal: g)).toList(),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final progressColor = goal.isAchieved
        ? ext.income
        : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: goal.isAchieved
                      ? ext.incomeSurface
                      : ext.expenseSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goal.statusDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: goal.isAchieved ? ext.income : ext.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 6,
              backgroundColor: ext.emptyState,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatAmount(goal.currentAmount)} / ${_formatAmount(goal.targetAmount)} ${goal.currency}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                goal.progressDisplay,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────── Empty State ───────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: ext.emptyState,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(width: 0.5,color: Theme.of(context).primaryColorLight),
                shape: BoxShape.circle
              ),
              child: Icon(icon, color: ext.textTertiary, size: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ext.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Helpers ───────────────

String _formatAmount(double amount) {
  final formatter = NumberFormat('#,##0', 'fr');
  return formatter.format(amount);
}
