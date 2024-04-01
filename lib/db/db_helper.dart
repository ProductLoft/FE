import 'package:lang_fe/db/recording_models.dart';
import 'package:lang_fe/db/sample_recording_models.dart';
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
    await createUserTable(db);
    await createRecordingTable(db);
    await createSampleRecordingTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('oldVersion: $oldVersion ; newVersion: $newVersion');
    if (oldVersion == 1) {
      await createSampleRecordingTable(db);
      print("Table new_table created during upgrade.");
    }
  }
}