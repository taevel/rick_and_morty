import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/character.dart';

class FavoritesDatabase {
  static final FavoritesDatabase instance = FavoritesDatabase._init();
  static Database? _database;

  FavoritesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
  }

  Future<void> addFavorite(Character character) async {
    final db = await database;
    final characterJson = json.encode(character.toJson());

    await db.insert(
      'favorites',
      {'id': character.id, 'data': characterJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;

    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Character>> getFavorites() async {
    final db = await database;
    final favoritesList = await db.query('favorites');

    return favoritesList.map((favorite) {
      final characterMap =
          json.decode(favorite['data'] as String) as Map<String, dynamic>;
      final character = Character.fromJson(characterMap);
      character.isFavorite = true;
      return character;
    }).toList();
  }

  Future<bool> isFavorite(int id) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
