import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:speaksharp/req/reqest_utils.dart';
import 'package:speaksharp/utils/misc.dart';

Future<void> clientEventUpload(Map<String, String> params) async {
  // debugPrint('clientEventUpload params: ${jsonEncode(params)}');
  // var headers = await getHeaders();
  // debugPrint('Headers: $headers');
  // debugPrint('Headers: ${getClientEventUploadUrl().toString()}');
  //
  // final response = await http.post(getClientEventUploadUrl(),
  //     body: params, headers: headers);
  //
  // if (response.statusCode == 200) {
  //   debugPrint('clientEventUpload==body===${response.body}');
  // }
}
