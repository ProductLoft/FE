import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'user_models.dart'; // Import your data model
import 'package:lang_fe/const/consts.dart';

// Create and manage database from here. Creation of new models need to be registered here.
//
class DatabaseHelper {
  static const _databaseName = dbPath;
  static const _databaseVersion = 1;

  Future<Database> get database async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    create table $userTable ( 
      $userIdColumn INTEGER PRIMARY KEY AUTOINCREMENT, 
      $nameColumn TEXT NOT NULL,
      $usernameColumn TEXT NOT NULL,
      $cookieColumn TEXT NOT NULL,
      $emailColumn TEXT NOT NULL
      );
    ''');
    await db.execute('''
      create table $recordingTable (
        $recordingIdColumn INTEGER PRIMARY KEY AUTOINCREMENT,
        $filePathColumn TEXT NOT NULL,
        $commentColumn TEXT NOT NULL,
        $isProcessedColumn INTEGER NOT NULL DEFAULT 0,
        $zipPathColumn TEXT NOT NULL,
        $timestampColumn TEXT NOT NULL
      );
    ''');
  }
}
