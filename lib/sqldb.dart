import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Sqldb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initializeDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> initializeDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'wael.db');
    Database mydb = await openDatabase(
      path,
      version: 5, // تحديد إصدار قاعدة البيانات
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // إضافة دالة onUpgrade
    );
    return mydb;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes (
      "id" INTEGER NOT NULL PRIMARY KEY AUTO INCREMENT,
      "task" TEXT NOT NULL,
      "date" TEXT NOT NULL
    )
  ''');
    print('Created DATABASE AND TABLE');
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      print('Upgrading database from version $oldVersion to $newVersion');
      

      print('Database upgraded successfully');
    }
  }

  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database? mydb = await db;
    List<Map<String, dynamic>> response = await mydb!.rawQuery(sql);
    return response;
  }

  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}