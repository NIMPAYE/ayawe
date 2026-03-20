import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _transactionType = TransactionType.OUTGOING;
  Account? _selectedAccount;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // For simplicity, we'll use mock data here
    // In a real app, you would load from repositories
    if (mounted) {
      setState(() {
        _accounts = context.read<AccountProvider>().accounts;
        _categories = [
          // Mock categories - in real app, load from repository
          const Category(
            name: 'Transport',
            type: CategoryType.EXPENSE,
            icon: '🚌',
          ),
          const Category(name: 'Meals', type: CategoryType.EXPENSE, icon: '🍔'),
          const Category(name: 'Salary', type: CategoryType.INCOME, icon: '💼'),
        ];
        if (_accounts.isNotEmpty) _selectedAccount = _accounts.first;
        if (_categories.isNotEmpty) {
          final filteredCategories = _categories
              .where(
                (c) =>
                    c.type ==
                    (_transactionType == TransactionType.OUTGOING
                        ? CategoryType.EXPENSE
                        : CategoryType.INCOME),
              )
              .toList();
          if (filteredCategories.isNotEmpty) {
            _selectedCategory = filteredCategories.first;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Transaction',
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
                    _buildTransactionTypeSelector(),
                    const SizedBox(height: 20),
                    _buildAccountSelector(),
                    const SizedBox(height: 20),
                    _buildCategorySelector(),
                    const SizedBox(height: 20),
                    _buildAmountField(),
                    const SizedBox(height: 20),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildDateSelector(),
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

  Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _setTransactionType(TransactionType.OUTGOING),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _transactionType == TransactionType.OUTGOING
                        ? Colors.red[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _transactionType == TransactionType.OUTGOING
                          ? Colors.red
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: _transactionType == TransactionType.OUTGOING
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Expense',
                        style: GoogleFonts.poppins(
                          color: _transactionType == TransactionType.OUTGOING
                              ? Colors.red
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _setTransactionType(TransactionType.INCOMING),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _transactionType == TransactionType.INCOMING
                        ? Colors.green[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _transactionType == TransactionType.INCOMING
                          ? Colors.green
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: _transactionType == TransactionType.INCOMING
                            ? Colors.green
                            : Colors.grey[600],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Income',
                        style: GoogleFonts.poppins(
                          color: _transactionType == TransactionType.INCOMING
                              ? Colors.green
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_accounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No accounts available. Create an account first.',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<Account>(
            value: _selectedAccount,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _accounts.map((account) {
              return DropdownMenuItem(
                value: account,
                child: Row(
                  children: [
                    Text(account.typeDisplay.split(' ')[0]),
                    const SizedBox(width: 8),
                    Text(
                      '${account.name} (${account.currentBalance.toStringAsFixed(2)} ${account.currencySymbol})',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAccount = value;
              });
            },
          ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final filteredCategories = _categories
        .where(
          (c) =>
              c.type ==
              (_transactionType == TransactionType.OUTGOING
                  ? CategoryType.EXPENSE
                  : CategoryType.INCOME),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Category>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: filteredCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Text(category.icon),
                  const SizedBox(width: 8),
                  Text(category.name, style: GoogleFonts.poppins()),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (BIF)',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
            prefixText: 'BIF ',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
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

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'e.g., Taxi to downtown',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: GoogleFonts.poppins(),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Transaction',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _setTransactionType(TransactionType type) {
    setState(() {
      _transactionType = type;
      // Reset category
      final filteredCategories = _categories
          .where(
            (c) =>
                c.type ==
                (_transactionType == TransactionType.OUTGOING
                    ? CategoryType.EXPENSE
                    : CategoryType.INCOME),
          )
          .toList();
      if (filteredCategories.isNotEmpty) {
        _selectedCategory = filteredCategories.first;
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccount == null || _selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final transaction = Transaction(
      accountId: _selectedAccount!.id!,
      categoryId: _selectedCategory!.id!,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      description: _descriptionController.text,
      transactionType: _transactionType,
    );

    context.read<TransactionProvider>().addTransaction(transaction);
    Navigator.pop(context);
  }
}
