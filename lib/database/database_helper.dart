import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'platform/database_factory.dart';
import '../models/persona.dart';
import '../models/familia.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    throw Exception("Database not initialized. Call openDatabaseFile first.");
  }

  bool get isDatabaseOpen => _database != null;

  Future<void> openDatabaseFile(String filePath, {Uint8List? bytes}) async {
    final platform = AppDatabaseFactory.getPlatform();
    await platform.init();
    _database = await platform.openDatabaseFile(filePath, bytes: bytes);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // CRUD Operations for Persona

  Future<Persona?> getPersona(int id) async {
    final db = await database;
    final maps = await db.query('Personas', where: 'ID = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Persona.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Persona>> getAllPersonas() async {
    final db = await database;
    final maps = await db.query('Personas', orderBy: 'ID ASC');
    return maps.map((e) => Persona.fromMap(e)).toList();
  }

  Future<List<Persona>> searchPersonas(String query) async {
    final db = await database;
    final maps = await db.query(
      'Personas',
      where: 'Nombre LIKE ? OR Apellido1 LIKE ? OR Apellido2 LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return maps.map((e) => Persona.fromMap(e)).toList();
  }

  Future<int> updatePersona(Persona persona) async {
    final db = await database;
    return await db.update(
      'Personas',
      persona.toMap(),
      where: 'ID = ?',
      whereArgs: [persona.id],
    );
  }

  Future<int> insertPersona(Persona persona) async {
    final db = await database;
    if (persona.id == 0) {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT MAX(ID) as maxId FROM Personas',
      );
      int maxId = result.first['maxId'] as int? ?? 0;
      persona.id = maxId + 1;
    }

    return await db.insert('Personas', persona.toMap());
  }

  // CRUD Operations for Familia

  Future<Familia?> getFamilia(int id) async {
    final db = await database;
    final maps = await db.query('Familias', where: 'ID = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Familia.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Familia>> getFamiliasWhereEsposo(int id) async {
    final db = await database;
    final maps = await db.query(
      'Familias',
      where: 'EsposoID = ?',
      whereArgs: [id],
    );
    return maps.map((e) => Familia.fromMap(e)).toList();
  }

  Future<List<Familia>> getFamiliasWhereEsposa(int id) async {
    final db = await database;
    final maps = await db.query(
      'Familias',
      where: 'EsposaID = ?',
      whereArgs: [id],
    );
    return maps.map((e) => Familia.fromMap(e)).toList();
  }

  Future<List<Persona>> getHijos(int familiaId) async {
    final db = await database;
    final maps = await db.query(
      'Personas',
      where: 'FamiliaID = ?',
      whereArgs: [familiaId],
    );
    return maps.map((e) => Persona.fromMap(e)).toList();
  }
}
