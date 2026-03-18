import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../../features/accounts/domain/entities/account.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');
  
  AccountType _accountType = AccountType.CASH;
  Currency _currency = Currency.BIF;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Account',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildAccountTypeSelector(),
                    const SizedBox(height: 20),
                    _buildCurrencySelector(),
                    const SizedBox(height: 20),
                    _buildBalanceField(),
                  ],
                ),
              ),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Name',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'e.g., Cash Wallet, Lumicash',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: AccountType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _accountType = type),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accountType == type ? Colors.green[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accountType == type ? Colors.green : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<AccountType>(
                        value: type,
                        groupValue: _accountType,
                        onChanged: (value) => setState(() => _accountType = value!),
                        activeColor: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getTypeDisplay(type),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _accountType == type ? Colors.green : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: Currency.values.map((currency) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: currency == Currency.USD ? 0 : 8),
                child: GestureDetector(
                  onTap: () => setState(() => _currency = currency),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _currency == currency ? Colors.blue[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _currency == currency ? Colors.blue : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        Radio<Currency>(
                          value: currency,
                          groupValue: _currency,
                          onChanged: (value) => setState(() => _currency = value!),
                          activeColor: Colors.blue,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currency.toString().split('.').last,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _currency == currency ? Colors.blue : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBalanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Initial Balance',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _balanceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            prefixText: '${_currency.toString().split('.').last} ',
            hintText: '0.00',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a balance';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getTypeDisplay(AccountType type) {
    switch (type) {
      case AccountType.CASH:
        return '💵 Cash - Physical money';
      case AccountType.MOBILE_MONEY:
        return '📱 Mobile Money - Lumicash/Econet';
      case AccountType.BANK:
        return '🏦 Bank - Bank account';
    }
  }

  void _saveAccount() {
    if (!_formKey.currentState!.validate()) return;

    final account = Account(
      name: _nameController.text,
      type: _accountType,
      currentBalance: double.parse(_balanceController.text),
      currency: _currency,
    );

    context.read<AppProvider>().addAccount(account);
    Navigator.pop(context);
  }
}
