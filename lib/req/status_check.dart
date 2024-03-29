import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lang_fe/db/recording_models.dart';
import 'package:lang_fe/req/reqest_utils.dart';
import 'package:lang_fe/req/zip_req.dart';
import 'package:lang_fe/utils/misc.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db_helper.dart';
import 'package:http/http.dart' as http;

Future<String> checkAudioIdStatus(int audioId) async {

  AudioRecord? audioRecord = await AudioRecordingProvider().getRecording(audioId);
  debugPrint('Checking status of audio id: $audioId, ${audioRecord?.toMap()}');
  if (audioRecord == null) {
    return "";
  } else if (audioRecord.isProcessed == 1) {
    return audioRecord.insightsDirPath;
  }

  bool audioProcessed = false;
  while (!audioProcessed) {
    debugPrint('Checking status of audio id: $audioId, ${audioRecord.audioId}');
    try {
      audioProcessed = await makeStatusCheckRequest(audioRecord.audioId??-1);
    } catch (e) {
      print('Error during network request: $e');
    }
    // Wait for a specified duration
    if (!audioProcessed) await Future.delayed(const Duration(seconds: 5));
  }

  return downloadAndExtractZip(audioRecord.audioId??-1);
}

Future<bool> makeStatusCheckRequest(int audioId) async {
  if (audioId == -1) {
    return false;
  }

  var headers = await getHeaders();

  var request = http.MultipartRequest(
      'GET', getAudioStatusUrl(audioId));

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode > 200 && response.statusCode < 300) {
    var resp = jsonDecode(await response.stream.bytesToString());
    if (resp['status'] as int == 1) {
      return true;
    } else {
      return false;
    }

  } else {
    print(response.reasonPhrase);
  }

  return true;
}
