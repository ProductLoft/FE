import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'user_models.dart'; // Import your data model
import 'package:lang_fe/const/consts.dart';



// Create and manage database from here. Creation of new models need to be registered here.
//
class DatabaseHelper {
  static const _databaseName = DB_PATH;
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
      $userIdColumn integer primary key autoincrement, 
      $nameColumn text not null,
      $usernameColumn text not null,
      $cookieColumn text not null,
      $emailColumn text not null
      );
    ''');
      }
}
