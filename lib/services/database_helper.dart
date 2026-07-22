import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/expense.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    if (!kIsWeb &&
        (Platform.isWindows ||
            Platform.isLinux ||
            Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, "expense_tracker.db");

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      ),
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute("""
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        merchant TEXT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        account TEXT,
        paymentMethod TEXT,
        currency TEXT,
        project TEXT,
        isIncome INTEGER,
        isFavorite INTEGER,
        isBusinessExpense INTEGER,
        isTaxDeductible INTEGER,
        isConfidential INTEGER,
        isRecurring INTEGER,
        recurringFrequency TEXT,
        enableReminder INTEGER,
        tags TEXT,
        receiptImagePath TEXT,
        voiceNotePath TEXT
      )
    """);
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      List<String> columnsToAdd = [
        "merchant TEXT",
        "account TEXT",
        "paymentMethod TEXT",
        "currency TEXT",
        "project TEXT",
        "isIncome INTEGER",
        "isFavorite INTEGER",
        "isBusinessExpense INTEGER",
        "isTaxDeductible INTEGER",
        "isConfidential INTEGER",
        "isRecurring INTEGER",
        "recurringFrequency TEXT",
        "enableReminder INTEGER",
        "tags TEXT",
        "receiptImagePath TEXT",
        "voiceNotePath TEXT"
      ];

      for (String column in columnsToAdd) {
        try {
          await db.execute("ALTER TABLE expenses ADD COLUMN $column");
        } catch (_) {}
      }
    }
  }

  Future<bool> registerUser(
      String email,
      String password,
      ) async {
    final db = await database;

    final existing = await db.query(
      "users",
      where: "email=?",
      whereArgs: [email],
    );

    if (existing.isNotEmpty) {
      return false;
    }

    await db.insert(
      "users",
      {
        "email": email,
        "password": password,
      },
    );

    return true;
  }

  Future<bool> loginUser(
      String email,
      String password,
      ) async {
    final db = await database;

    final result = await db.query(
      "users",
      where: "email=? AND password=?",
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;

    return await db.insert(
      "expenses",
      expense.toMap(),
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;

    final result = await db.query(
      "expenses",
      orderBy: "date DESC",
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;

    return await db.update(
      "expenses",
      expense.toMap(),
      where: "id=?",
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;

    return await db.delete(
      "expenses",
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future closeDatabase() async {
    final db = await database;
    db.close();
  }
}