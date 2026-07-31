import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/script_model.dart';

/// Servicio singleton de acceso a la base de datos local (SQLite).
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contribia_teleprompter.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scripts (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            text TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE videos (
            id TEXT PRIMARY KEY,
            scriptId TEXT NOT NULL,
            name TEXT NOT NULL,
            filePath TEXT NOT NULL,
            durationSeconds INTEGER NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /* ---------------- Guiones ---------------- */

  Future<void> saveScript(ScriptModel script) async {
    final db = await database;
    await db.insert(
      'scripts',
      script.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScriptModel>> getAllScripts() async {
    final db = await database;
    final rows = await db.query('scripts', orderBy: 'updatedAt DESC');
    return rows.map((r) => ScriptModel.fromMap(r)).toList();
  }

  Future<ScriptModel?> getScript(String id) async {
    final db = await database;
    final rows = await db.query('scripts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ScriptModel.fromMap(rows.first);
  }

  Future<void> deleteScript(String id) async {
    final db = await database;
    await db.delete('scripts', where: 'id = ?', whereArgs: [id]);
  }

  /* ---------------- Videos ---------------- */

  Future<void> saveVideo(VideoModel video) async {
    final db = await database;
    await db.insert(
      'videos',
      video.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<VideoModel>> getAllVideos() async {
    final db = await database;
    final rows = await db.query('videos', orderBy: 'createdAt DESC');
    return rows.map((r) => VideoModel.fromMap(r)).toList();
  }

  Future<void> deleteVideo(String id) async {
    final db = await database;
    await db.delete('videos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> renameVideo(String id, String newName) async {
    final db = await database;
    await db.update(
      'videos',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
