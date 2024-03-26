


import 'dart:async';

import 'package:lang_fe/db/user_models.dart';

Future<Map<String, String>> getHeaders() async {
  User? user = await UserProvider().getUser();
  return {
    'Cookie': user?.cookie ?? '',
    'X-CSRFToken': user?.csrfToken ?? '',
  };
}