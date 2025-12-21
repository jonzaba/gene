import 'database_interface.dart';
import 'stub_database.dart'
    if (dart.library.io) 'native_database.dart'
    if (dart.library.html) 'web_database.dart';

class AppDatabaseFactory {
  static DatabasePlatform getPlatform() {
    return getDatabasePlatform();
  }
}
