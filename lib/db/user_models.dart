import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lang_fe/const/consts.dart';
import 'package:lang_fe/db/db_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';

// Open the database and store the reference.

class User {
  int? id;
  final String name;
  final String username;
  final String email;
  // TODO maybe everything below needs to be in a different table
  String? cookie;
  String? csrfToken;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    this.cookie,
    this.csrfToken,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      userIdColumn: id,
      nameColumn: name,
      usernameColumn: username,
      emailColumn: email,
      cookieColumn: cookie,
      csrfTokenColumn: csrfToken,
    };
    return map;
  }
}

class UserProvider {
  UserProvider();

  //get csrf token from cookie
  String getCSRFFromCookie(String cookie) {
    List<String> cookies = cookie.split(';');
    for (var c in cookies) {
      if (c.contains('csrftoken')) {
        return c.split('=')[1];
      }
    }
    return '';
  }

  String getCookieFromResponse(Map<String, String> headers) {
    return headers['set-cookie'] ?? '';
  }



  String extractCookies(String setCookieString) {
    final cookieSegments = setCookieString.split('; ');
    List<String> cookieList = [];
    for (var c in cookieSegments) {
      cookieList = [...cookieList,...c.split(',')];
    }
    print('cookieList: $cookieList');
    final desiredCookies = cookieList.map((segment) {
      final parts = segment.split('=');
      debugPrint('parts: $parts');
      final cookieName = parts[0].toLowerCase();

      // // Handle SameSite and other attributes
      String cookieValue = (parts.length>1) ? parts[1]: '';

      return {cookieName: cookieValue};
    }).where((map) =>
    map.containsKey('csrftoken') || map.containsKey('sessionid')
    );

    return desiredCookies.map((map) => map.entries.first.key + '=' + map.entries.first.value).join('; ');
  }


  Future<User?> createUser(String name,String username,String email,String cookie) async {

    Database db = await DatabaseHelper().database;
    String csrfToken = getCSRFFromCookie(cookie);
    debugPrint('csrfToken: $csrfToken');
    User user = User(
      // TODO : check if id is autoincremented
      name: name,
      username: username,
      email: email,
      cookie: extractCookies(cookie),
      csrfToken: csrfToken,
    );
    print(user.toMap());
    var r = await db.insert(userTable, user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    if (r >= 1) {
      if (kDebugMode) {
        print('user created');
      }
    } else {
      if (kDebugMode) {
        print('error creating user $r');
        return null;
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
          columns: [userIdColumn, nameColumn, usernameColumn, emailColumn, cookieColumn, csrfTokenColumn]);
      debugPrint('maps: $maps');
      if (maps.isNotEmpty) {
        return User(
          id: maps[0][userIdColumn] as int,
          name: maps[0][nameColumn] as String,
          username: maps[0][usernameColumn] as String,
          email: maps[0][emailColumn] as String,
          cookie: maps[0][cookieColumn] as String,
          csrfToken: maps[0][csrfTokenColumn] as String,
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
