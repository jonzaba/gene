import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';

abstract class DatabasePlatform {
  Future<void> init();
  Future<Database> openDatabaseFile(String pathOrData, {Uint8List? bytes});
}
