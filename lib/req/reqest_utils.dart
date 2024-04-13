


import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lang_fe/db/user_models.dart';

import '../main.dart';

Future<Map<String, String>> getHeaders() async {
  CustomUser? user = await UserProvider().getUser();
  return {
    'Cookie': user?.cookie ?? '',
    'X-CSRFToken': user?.csrfToken ?? '',
  };
}

Future<Map<String, String>> getHeaders1() async {
  User? user = auth.currentUser;
  return {
    // 'Cookie': user?.cookie ?? '',
    // 'X-CSRFToken': user?.csrfToken ?? '',
    // 'HTTP_AUTHORIZATION': 'Bearer ${await user?.getIdToken(true)}',
  };
}