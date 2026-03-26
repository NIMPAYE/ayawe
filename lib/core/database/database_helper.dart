import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'ayawe.db';
  static const int _databaseVersion = 3;

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
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        current_balance REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'BIF'
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '📌'
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        to_account_id INTEGER,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        transaction_type TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (to_account_id) REFERENCES accounts (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0.0,
        deadline TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        month TEXT NOT NULL,
        rollover_amount REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        transaction_type TEXT NOT NULL,
        frequency TEXT NOT NULL,
        next_due_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

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
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN to_account_id INTEGER',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          month TEXT NOT NULL,
          rollover_amount REAL NOT NULL DEFAULT 0.0,
          FOREIGN KEY (category_id) REFERENCES categories (id)
        )
      ''');
      await db.execute('''
        CREATE TABLE recurring_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          transaction_type TEXT NOT NULL,
          frequency TEXT NOT NULL,
          next_due_date TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (account_id) REFERENCES accounts (id),
          FOREIGN KEY (category_id) REFERENCES categories (id)
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
