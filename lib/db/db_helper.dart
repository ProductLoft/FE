import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'user_models.dart'; // Import your data model
// import 'sample_recording_models.dart'; // Import your data model
import 'package:lang_fe/const/consts.dart';

// Create and manage database from here. Creation of new models need to be registered here.
//
class DatabaseHelper {
  static const _databaseName = dbPath;
  static const _databaseVersion = 2;

  Future<Database> get database async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    print('version: $version');
    await db.execute('''
    create table $userTable ( 
      $userIdColumn INTEGER PRIMARY KEY AUTOINCREMENT, 
      $nameColumn TEXT NOT NULL,
      $usernameColumn TEXT NOT NULL,
      $cookieColumn TEXT NOT NULL,
      $emailColumn TEXT NOT NULL,
      $csrfTokenColumn TEXT NOT NULL
      );
    ''');
    await db.execute('''
      create table $recordingTable (
        $recordingIdColumn INTEGER PRIMARY KEY AUTOINCREMENT,
        $filePathColumn TEXT NOT NULL,
        $commentColumn TEXT NOT NULL,
        $isProcessedColumn INTEGER NOT NULL DEFAULT 0,
        $insightsDirPathColumn TEXT NOT NULL,
        $timestampColumn TEXT NOT NULL,
        $audioIdColumn INTEGER NOT NULL
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('oldVersion: $oldVersion ; newVersion: $newVersion');
    if (oldVersion == 1) {
      await db.execute('''
        create table $sampleRecordTable (
          $sampleRecordIdColumn INTEGER PRIMARY KEY AUTOINCREMENT,
          $sampleRecordFilePathColumn TEXT NOT NULL,
          $sampleRecordCommentColumn TEXT NOT NULL,
          $sampleRecordIsProcessedColumn INTEGER NOT NULL DEFAULT 0,
          $sampleRecordInsightsDirPathColumn TEXT NOT NULL,
          $sampleRecordTimestampColumn TEXT NOT NULL,
          $sampleRecordAudioIdColumn INTEGER NOT NULL
        );
      ''');
      print("Table new_table created during upgrade.");
    }
  }
}