import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'database_interface.dart';

class StubDatabase implements DatabasePlatform {
  @override
  Future<void> init() async {
    throw UnimplementedError();
  }

  @override
  Future<Database> openDatabaseFile(
    String pathOrData, {
    Uint8List? bytes,
  }) async {
    throw UnimplementedError();
  }
}

DatabasePlatform getDatabasePlatform() => StubDatabase();
