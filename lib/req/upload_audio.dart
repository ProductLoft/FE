import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'dart:typed_data';


import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lang_fe/req/reqest_utils.dart';
import 'package:lang_fe/utils/misc.dart';
import 'package:path/path.dart';

Future<int?> uploadAudio(String filePath, String isSampleVoice) async {
  // Fetch the blob data
  Uint8List audioBytes;
  if (kIsWeb) {
    http.Response blobResponse = await http.get(Uri.parse(filePath));
    audioBytes = blobResponse.bodyBytes;
  } else {
    var file = File(filePath);
    audioBytes = await file.readAsBytes();
  }
  debugPrint('Uploading audio file: $filePath');
  var headers = await getHeaders();
  debugPrint('Headers: $headers');
  debugPrint('Headers: ${getUploadUrl().toString()}');
  debugPrint(
      'Headers: ${await FirebaseAuth.instance.currentUser?.getIdToken(true)}');
  // var stream = new http.ByteStream(File(filePath) as Stream<List<int>>);
  var request = http.MultipartRequest('POST', getUploadUrl());

  if (isSampleVoice == 'True') {
    request.fields.addAll({
      'records_starts_on': getCurrentTime(),
      'is_sample_voice': isSampleVoice
    });

    debugPrint('params:111');
  } else {
    request.fields.addAll({
      'records_starts_on': getCurrentTime(),
    });
    debugPrint('params:222');
  }
  debugPrint('params:$filePath');
  request.files.add(await http.MultipartFile.fromBytes('audio_file', audioBytes,
      filename: basename(filePath)));
  request.headers.addAll(headers);
  debugPrint('Request: ${request.toString()}');
  http.StreamedResponse response = await request.send();
  // debugPrint('Response: ${response.statusCode}');
  // debugPrint('Response: ${await response.stream.bytesToString()}');
  debugPrint('Response!!!: $response');
  var resp = await json.decode(await response.stream.bytesToString());
  debugPrint('Response!!!: $resp');
  if (response.statusCode >= 200 && response.statusCode < 300) {
    int audioRecordId = resp['audio_record_id'] as int;

    return audioRecordId;
    // return 1;
  }

  return null;
}
