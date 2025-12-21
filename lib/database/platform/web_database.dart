import 'dart:typed_data';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'database_interface.dart';

class WebDatabase implements DatabasePlatform {
  @override
  Future<void> init() async {
    databaseFactory = databaseFactoryFfiWeb;
  }

  @override
  Future<Database> openDatabaseFile(
    String pathOrData, {
    Uint8List? bytes,
  }) async {
    if (bytes != null) {
      // Write the database bytes to the virtual file system
      await databaseFactoryFfiWeb.writeDatabaseBytes(pathOrData, bytes);
    }

    // Open the database using the factory directly
    return await databaseFactoryFfiWeb.openDatabase(
      pathOrData,
      options: OpenDatabaseOptions(
        version: 1,
        onOpen: (db) {
          print('Web Database opened successfully: $pathOrData');
        },
      ),
    );
  }
}

DatabasePlatform getDatabasePlatform() => WebDatabase();
