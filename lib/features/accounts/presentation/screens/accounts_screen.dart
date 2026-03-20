import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/account_provider.dart';
import '../../domain/entities/account.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

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
    AccountType.MOBILE_MONEY: 'Mobile Money',
    AccountType.BANK: 'Banque',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Comptes',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          final accounts = provider.accounts;

          if (accounts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _SummaryCard(
                balanceByCurrency: provider.balanceByCurrency,
                accountCount: accounts.length,
              ),
              const SizedBox(height: 24),
              ...accounts.map(
                (account) => _AccountDetailCard(
                  account: account,
                  currencyTotal: provider.totalBalanceFor(account.currency),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_account'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun compte',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier compte pour commencer à suivre vos finances.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ext.textTertiary,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add_account'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter un compte'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Summary Card ───────────────

class _SummaryCard extends StatelessWidget {
  final Map<Currency, double> balanceByCurrency;
  final int accountCount;

  const _SummaryCard({
    required this.balanceByCurrency,
    required this.accountCount,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final entries = balanceByCurrency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde Total',
                style: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(180),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$accountCount compte${accountCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Each currency on its own line
          if (entries.isNotEmpty) ...[
            Text(
              '${_formatAmount(entries.first.value)} ${entries.first.key.symbol}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            ...entries.skip(1).map((e) => Padding(
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
          ],
        ],
      ),
    );
  }
}

// ─────────────── Account Detail Card ───────────────

class _AccountDetailCard extends StatelessWidget {
  final Account account;
  final double currencyTotal;

  const _AccountDetailCard({
    required this.account,
    required this.currencyTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = AccountsScreen._typeColors[account.type] ??
        theme.colorScheme.primary;
    final isPositive = account.currentBalance >= 0;
    final share = currencyTotal > 0
        ? (account.currentBalance / currencyTotal * 100)
        : 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountDetailScreen(account: account),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : ext.border,
        ),
      ),
      child: Column(
        children: [
          // Header: icon + name + type chip
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withAlpha(isDark ? 50 : 30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AccountsScreen._typeIcons[account.type] ?? Icons.wallet,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AccountsScreen._typeLabels[account.type] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withAlpha(isDark ? 40 : 20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  account.currencySymbol,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Balance row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(8)
                  : ext.emptyState,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde actuel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatAmount(account.currentBalance)} ${account.currencySymbol}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: isPositive ? ext.income : ext.expense,
                      ),
                    ),
                  ],
                ),
                // Share within same currency
                if (currencyTotal > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Part',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ext.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              value: share / 100,
                              strokeWidth: 3.5,
                              backgroundColor: ext.emptyState,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${share.toStringAsFixed(0)}%',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ─────────────── Helpers ───────────────

String _formatAmount(double amount) {
  final formatter = NumberFormat('#,##0', 'fr');
  return formatter.format(amount);
}
