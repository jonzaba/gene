import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_interface.dart';

class NativeDatabase implements DatabasePlatform {
  @override
  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  @override
  Future<Database> openDatabaseFile(
    String pathOrData, {
    Uint8List? bytes,
  }) async {
    return await openDatabase(
      pathOrData,
      version: 1,
      onOpen: (db) {
        print('Native Database opened successfully: $pathOrData');
      },
    );
  }
}

DatabasePlatform getDatabasePlatform() => NativeDatabase();
