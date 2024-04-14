import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:lang_fe/req/reqest_utils.dart';
import 'package:lang_fe/utils/misc.dart';

Future<int?> uploadAudio(String filePath, String isSampleVoice) async{
  debugPrint('Uploading audio file: $filePath');
  var headers = await getHeaders();
  debugPrint('Headers: $headers');
  debugPrint('Headers: ${getUploadUrl().toString()}');
  debugPrint('Headers: ${await FirebaseAuth.instance.currentUser?.getIdToken(true)}');

  var request = http.MultipartRequest('POST', getUploadUrl());

  if(isSampleVoice == 'True'){
    request.fields.addAll({
      'records_starts_on': getCurrentTime(),
      'is_sample_voice': isSampleVoice
    });

     debugPrint('params:111');
  }else{
    request.fields.addAll({
      'records_starts_on': getCurrentTime(),
    });
    debugPrint('params:222');
  }
  
  request.files.add(await http.MultipartFile.fromPath('audio_file', filePath));
  request.headers.addAll(headers);
  debugPrint('Request: ${request.toString()}');
  http.StreamedResponse response = await request.send();
  // debugPrint('Response: ${response.statusCode}');
  // debugPrint('Response: ${await response.stream.bytesToString()}');
  var resp = json.decode(await response.stream.bytesToString());
  if (response.statusCode >= 200 && response.statusCode < 300) {
    int audioRecordId = resp['audio_record_id'] as int;

    return audioRecordId;
    // return 1;
  }

  return null;
}
