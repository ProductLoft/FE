import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lang_fe/req/reqest_utils.dart';
import '../db/recording_models.dart';
import '../utils/misc.dart';

Future<List<dynamic>> GetAudioIDJson(int audioId) async {
  AudioRecord? audioRecord =
      await AudioRecordingProvider().getRecording(audioId);
  debugPrint('Getting Speakers: ${audioRecord?.audioId}');
  var headers = await getHeaders();
  var request = http.MultipartRequest('POST', getDownloadAudioJsonUrl());
  request.fields.addAll({
    'job_id': audioRecord?.audioId.toString() ?? "-1",
  });

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode != 200) {
    throw Exception(
        'Failed to download zip file. Status code: ${response.statusCode}');
  }

  return jsonDecode(await response.stream.bytesToString()) as List<dynamic>;
}
