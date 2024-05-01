import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lang_fe/const/consts.dart';
import 'package:lang_fe/db/user_models.dart';

import '../main.dart';

// Future<Map<String, String>> getHeaders1() async {
//   CustomUser? user = await UserProvider().getUser();
//   return {
//     'Cookie': 'csrftoken=hMJOYlzD9z8IRGXGTH872Ky7soeOoiUj; sessionid=xtyefw3xfrqzvsur2av097hnwwzz4ump',
//     'X-CSRFToken': 'hMJOYlzD9z8IRGXGTH872Ky7soeOoiUj',
//   };
// }

Future<Map<String, String>> getHeaders() async {
  User? user = auth.currentUser;
  return {
    // 'Cookie': user?.cookie ?? '',
    // 'X-CSRFToken': user?.csrfToken ?? '',
    'Authorization': 'Bearer ${await user?.getIdToken(true)}',
  };
}

Future<String> getAudioUrl(int AudioId, int index) async {
  return '$baseUrl$downloadAuthenticAudio?job_id=$AudioId&index=$index';
}
