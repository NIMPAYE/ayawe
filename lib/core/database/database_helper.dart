import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'ayawe.db';
  static const int _databaseVersion = 1;

  static sqlite.Database? _database;

  Future<sqlite.Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<sqlite.Database> _initDatabase() async {
    final path = join(await sqlite.getDatabasesPath(), _databaseName);
    return await sqlite.openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(sqlite.Database db, int version) async {
    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        current_balance REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'BIF'
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '📌'
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        transaction_type TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Create goals table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0.0,
        deadline TEXT NOT NULL
      )
    ''');

    // Insert predefined categories
    await _insertPredefinedCategories(db);
  }

  Future<void> _insertPredefinedCategories(sqlite.Database db) async {
    final expenses = [
      {'name': 'Transport', 'type': 'EXPENSE', 'icon': '🚌'},
      {'name': 'Meals', 'type': 'EXPENSE', 'icon': '🍔'},
      {'name': 'Internet', 'type': 'EXPENSE', 'icon': '📱'},
      {'name': 'Phone Credit', 'type': 'EXPENSE', 'icon': '💳'},
      {'name': 'Rent', 'type': 'EXPENSE', 'icon': '🏠'},
      {'name': 'Groceries', 'type': 'EXPENSE', 'icon': '🛒'},
      {'name': 'Healthcare', 'type': 'EXPENSE', 'icon': '🏥'},
      {'name': 'Education', 'type': 'EXPENSE', 'icon': '📚'},
      {'name': 'Entertainment', 'type': 'EXPENSE', 'icon': '🎮'},
      {'name': 'Other', 'type': 'EXPENSE', 'icon': '📌'},
    ];

    final income = [
      {'name': 'Salary', 'type': 'INCOME', 'icon': '💼'},
      {'name': 'Business', 'type': 'INCOME', 'icon': '💼'},
      {'name': 'Gift Received', 'type': 'INCOME', 'icon': '🎁'},
      {'name': 'Loan Repayment', 'type': 'INCOME', 'icon': '💰'},
      {'name': 'Other Income', 'type': 'INCOME', 'icon': '📌'},
    ];

    for (final category in expenses) {
      await db.insert('categories', category);
    }

    for (final category in income) {
      await db.insert('categories', category);
    }
  }

  Future<void> _onUpgrade(sqlite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS goals');
      await db.execute('DROP TABLE IF EXISTS categories');
      await db.execute('DROP TABLE IF EXISTS accounts');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
