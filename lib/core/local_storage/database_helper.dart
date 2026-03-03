import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "NewsCache.db";
  static const _databaseVersion = 1;
  static const table = 'news';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        image_url TEXT NOT NULL,
        news_site TEXT NOT NULL,
        summary TEXT NOT NULL,
        published_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertNews(List<Map<String, dynamic>> newsList) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var news in newsList) {
      batch.insert(table, news, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getAllNews() async {
    Database db = await instance.database;
    return await db.query(table, orderBy: "published_at DESC");
  }

  Future<void> clearNews() async {
    Database db = await instance.database;
    await db.delete(table);
  }
}
