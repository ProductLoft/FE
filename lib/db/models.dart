import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:lang_fe/const/consts.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

// names of columns
const String userTable = "user";
const String userId = "id";
const String userName = "name";
const String useruserName = "userName";
const String userPassword = "password";

// Open the database and store the reference.

class User {
  final int id;
  final String name;
  final String userName;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.userName,
    required this.password,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      userId: id,
      userName: name,
      useruserName: userName,
      userPassword: password,
    };
    return map;
  }

}

class UserProvider {
  Database db;

  UserProvider(this.db);

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $userTable ( 
  $userId integer primary key autoincrement, 
  $userName text not null,
  $useruserName text not null
  $userPassword text not null
  )
''');
    });
  }

  Future<User> insert(User user) async {
    var r = await db.insert(userTable, user.toMap());
    return user;
  }

  Future<bool> isLoggedin() async {
    var res = await db.query("select * from $userTable");
    return res.isNotEmpty;
  }

  Future<bool> logout() async {
    var r = await db.delete(userTable);
    return true;
  }


}
