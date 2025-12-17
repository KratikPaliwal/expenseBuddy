import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../expense/expense_model.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      {
        'id': expense.id,
        'title': expense.title,
        'amount': expense.amount,
        'date': expense.date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<List<Expense>> getExpenses() async {
    final db = await database;
    final data = await db.query('expenses');

    return data.map((e) {
      return Expense(
        id: e['id'] as String,
        title: e['title'] as String,
        amount: (e['amount'] as num).toDouble(),
        date: DateTime.parse(e['date'] as String),
      );
    }).toList();
  }

  static Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      {
        'id': expense.id,
        'title': expense.title,
        'amount': expense.amount,
        'date': expense.date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<void> clearExpenses() async {
    final db = await database;
    await db.delete('expenses');
  }
}
