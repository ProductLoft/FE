import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lang_fe/db/user_models.dart';

import '../main.dart';

Future<Map<String, String>> getHeaders1() async {
  CustomUser? user = await UserProvider().getUser();
  return {
    'Cookie': user?.cookie ?? '',
    'X-CSRFToken': user?.csrfToken ?? '',
    // 'HTTP_AUTHORIZATION': 'Bearer $token',
  };
}

Future<Map<String, String>> getHeaders() async {
  User? user = auth.currentUser;
  var token = await user?.getIdToken(true);
  return {
    'Authorization': 'Bearer $token',
  };
}