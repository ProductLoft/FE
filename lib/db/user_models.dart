import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lang_fe/const/consts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lang_fe/db/db_helper.dart';

// Open the database and store the reference.

class User {
  final int id;
  final String name;
  final String userName;
  final String email;
  final String cookie;

  User({
    required this.id,
    required this.name,
    required this.userName,
    required this.email,
    required this.cookie,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      userIdColumn: id,
      nameColumn: name,
      usernameColumn: userName,
      emailColumn: email,
      cookieColumn: cookie,
    };
    return map;
  }
}

class UserProvider {
  UserProvider();
  Future<User> createUser(String name,String username,String email,String cookie) async {

    Database db = await DatabaseHelper().database;
    User user = User(
      // TODO : check if id is autoincremented
      id: 1,
      name: name,
      userName: username,
      email: email,
      cookie: cookie,
    );
    print(user.toMap());
    var r = await db.insert(userTable, user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    if (r == 1) {
      if (kDebugMode) {
        print('user created');
      }
    } else {
      if (kDebugMode) {
        print('error creating user');
      }
    }
    return user;
  }

  Future<String?> getToken() {
    return getUser().then((value) => value?.cookie);
  }

  Future<User?> getUser() async {
    try {
      Database db = await DatabaseHelper().database;
      List<Map> maps = await db.query(userTable,
          columns: [userIdColumn, nameColumn, usernameColumn, emailColumn, cookieColumn]);
      if (maps.isNotEmpty) {
        return User(
          id: maps[0][userIdColumn] as int,
          name: maps[0][nameColumn] as String,
          userName: maps[0][usernameColumn] as String,
          email: maps[0][emailColumn] as String,
          cookie: maps[0][cookieColumn] as String,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('error getting user: $e');
      }
      return null;
    }
  }

  Future<bool> isLoggedin() async {
    Database db = await DatabaseHelper().database;
    var res = await db.query(userTable);
    print('res: $res');
    return res.isNotEmpty;
  }

  Future<bool> logout() async {
    Database db = await DatabaseHelper().database;
    var _ = await db.delete(userTable);
    return true;
  }
}
