import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/account_provider.dart';
import '../../domain/entities/account.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _accountType = AccountType.CASH;
  Currency _currency = Currency.BIF;
  bool _isSaving = false;

  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouveau Compte',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Live Preview Card ──
                    FadeTransition(
                      opacity: _heroFade,
                      child: _AccountPreview(
                        name: _nameController.text.isEmpty
                            ? _hintForType(_accountType)
                            : _nameController.text,
                        type: _accountType,
                        currency: _currency,
                        balance: double.tryParse(_balanceController.text) ?? 0,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Type Selector ──
                    _SectionLabel('Type de compte'),
                    const SizedBox(height: 12),
                    Row(
                      children: AccountType.values.map((type) {
                        final selected = _accountType == type;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: type != AccountType.values.last ? 10 : 0,
                            ),
                            child: _TypeTile(
                              icon: _iconForType(type),
                              emoji: _emojiForType(type),
                              label: _labelForType(type),
                              subtitle: _subtitleForType(type),
                              selected: selected,
                              onTap: () =>
                                  setState(() => _accountType = type),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // ── Name ──
                    _SectionLabel('Nom du compte'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: _hintForType(_accountType),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(
                              isDark ? 40 : 20,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _iconForType(_accountType),
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Currency ──
                    _SectionLabel('Devise'),
                    const SizedBox(height: 12),
                    Row(
                      children: Currency.values.map((currency) {
                        final selected = _currency == currency;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right:
                                  currency != Currency.values.last ? 10 : 0,
                            ),
                            child: _CurrencyTile(
                              flag: _currencyFlag(currency),
                              code: currency.symbol,
                              name: _currencyName(currency),
                              selected: selected,
                              onTap: () =>
                                  setState(() => _currency = currency),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // ── Initial Balance ──
                    _SectionLabel('Solde initial'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _balanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onChanged: (_) => setState(() {}),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ext.textTertiary.withAlpha(100),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: ext.balanceGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _currency.symbol,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            double.tryParse(value) == null) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Combien avez-vous actuellement dans ce compte ?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Save Button ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 40 : 12),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAccount,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_rounded, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Créer le compte',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────── Helpers ───────────────

  IconData _iconForType(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return Icons.wallet_rounded;
      case AccountType.MOBILE_MONEY:
        return Icons.phone_android_rounded;
      case AccountType.BANK:
        return Icons.account_balance_rounded;
    }
  }

  String _emojiForType(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return '💵';
      case AccountType.MOBILE_MONEY:
        return '📱';
      case AccountType.BANK:
        return '🏦';
    }
  }

  String _labelForType(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return 'Cash';
      case AccountType.MOBILE_MONEY:
        return 'Mobile';
      case AccountType.BANK:
        return 'Banque';
    }
  }

  String _subtitleForType(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return 'Espèces';
      case AccountType.MOBILE_MONEY:
        return 'Mobile money';
      case AccountType.BANK:
        return 'Compte bancaire';
    }
  }

  String _hintForType(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return 'Mon portefeuille..';
      case AccountType.MOBILE_MONEY:
        return 'Mobile cash...';
      case AccountType.BANK:
        return 'votre banque..';
    }
  }

  String _currencyFlag(Currency currency) {
    switch (currency) {
      case Currency.BIF:
        return '🇧🇮';
      case Currency.USD:
        return '🇺🇸';
    }
  }

  String _currencyName(Currency currency) {
    switch (currency) {
      case Currency.BIF:
        return 'Franc Burundais';
      case Currency.USD:
        return 'Dollar US';
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final account = Account(
      name: _nameController.text.trim(),
      type: _accountType,
      currentBalance: double.tryParse(_balanceController.text) ?? 0.0,
      currency: _currency,
    );

    try {
      await context.read<AccountProvider>().addAccount(account);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création')),
        );
      }
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  SECTION LABEL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  LIVE ACCOUNT PREVIEW
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AccountPreview extends StatelessWidget {
  final String name;
  final AccountType type;
  final Currency currency;
  final double balance;
  final bool isDark;

  const _AccountPreview({
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final formatter = NumberFormat('#,##0', 'fr');

    IconData icon;
    switch (type) {
      case AccountType.CASH:
        icon = Icons.wallet_rounded;
      case AccountType.MOBILE_MONEY:
        icon = Icons.phone_android_rounded;
      case AccountType.BANK:
        icon = Icons.account_balance_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ext.balanceGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withAlpha(isDark ? 50 : 80),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _typeLabel(type),
                      style: TextStyle(
                        color: Colors.white.withAlpha(160),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currency.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Solde',
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatter.format(balance)} ${currency.symbol}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return 'Compte Cash';
      case AccountType.MOBILE_MONEY:
        return 'Mobile Money';
      case AccountType.BANK:
        return 'Compte Bancaire';
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TYPE TILE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withAlpha(isDark ? 35 : 18)
              : isDark
                  ? Colors.white.withAlpha(6)
                  : Colors.grey.withAlpha(14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : isDark
                    ? Colors.white.withAlpha(12)
                    : Colors.grey.withAlpha(40),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 20 : 30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.primary.withAlpha(180)
                    : theme.colorScheme.onSurfaceVariant.withAlpha(160),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CURRENCY TILE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CurrencyTile extends StatelessWidget {
  final String flag;
  final String code;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.flag,
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withAlpha(isDark ? 35 : 18)
              : isDark
                  ? Colors.white.withAlpha(6)
                  : Colors.grey.withAlpha(14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : isDark
                    ? Colors.white.withAlpha(12)
                    : Colors.grey.withAlpha(40),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 20 : 30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected
                          ? theme.colorScheme.primary.withAlpha(180)
                          : theme.colorScheme.onSurfaceVariant.withAlpha(160),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
