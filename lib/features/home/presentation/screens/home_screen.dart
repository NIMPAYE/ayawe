import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/main_provider.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../goals/domain/entities/goal.dart';

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
                    Icon(Icons.error_outline_rounded,
                        color: ext.expense, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      mainProvider.error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: ext.expense),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BalanceCard(provider: mainProvider),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Mes Comptes',
                    onViewAll: () =>
                        Navigator.pushNamed(context, '/accounts'),
                  ),
                  const SizedBox(height: 12),
                  _AccountsList(accounts: accountProvider.accounts),
                  const SizedBox(height: 28),
                  _SectionHeader(title: 'Transactions Récentes'),
                  const SizedBox(height: 12),
                  _TransactionsList(
                      transactions: transactionProvider.transactions),
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
    final ext = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ext.balanceGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
          Text(
            '${_formatAmount(provider.totalBalance)} BIF',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
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
                width: 1,
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
    );
  }
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
            child: Text(
              'Tout voir',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
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
    return Column(
      children: accounts
          .take(3)
          .map((account) => _AccountCard(account: account))
          .toList(),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              account.typeDisplay.split(' ')[0],
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  account.typeDisplay,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${_formatAmount(account.currentBalance)} ${account.currencySymbol}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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
    return Column(
      children: recent
          .map((t) => _TransactionCard(transaction: t))
          .toList(),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isExpense = transaction.transactionType == TransactionType.OUTGOING;
    final color = isExpense ? ext.expense : ext.income;
    final bgColor = isExpense ? ext.expenseSurface : ext.incomeSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${transaction.amountDisplay} BIF',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
    final progressColor =
        goal.isAchieved ? ext.income : theme.colorScheme.primary;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                '${_formatAmount(goal.currentAmount)} / ${_formatAmount(goal.targetAmount)} BIF',
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: ext.textTertiary, size: 28),
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
