import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../db/user_models.dart';
import '../utils/misc.dart';

Future<User?> loginReq(String username, String password) async {

  final response = await http.post(
    Uri.parse(getAuthUrl()),
    body: {
      'username': username,
      'password': password
    },
  );

  if (response.statusCode == 200) {
    if (kDebugMode) {
      print('Response: ${response.body}');
      print('cookie: ${response.headers['set-cookie']}');
    }
    response.headers.forEach((key, value) {
      if (kDebugMode) {
        print('$key: $value');
      }
    });

    final body = json.decode(response.body);
    String name = body["user"]["name"] as String;
    String username = body["user"]["username"] as String;
    String email = body["user"]["email"] as String;
    String? cookie = response.headers['set-cookie'] as String;

    return User(name: name, username: username, email: email, cookie: cookie);
  }
  return null;
}