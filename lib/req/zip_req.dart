import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:lang_fe/req/reqest_utils.dart';

import '../utils/misc.dart';


Future<String> downloadAndExtractZip(int audioId) async {

  debugPrint('Downloading zip file for audio id: $audioId');
  String outPath = await getInsightsDirPath(audioId);
  var headers = await getHeaders();
  var request = http.MultipartRequest('POST', getDownloadZipUrl());
  request.fields.addAll({
    'job_id': audioId.toString(),
  });

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode != 200) {
    throw Exception(
        'Failed to download zip file. Status code: ${response.statusCode}');
  }
  List<int> respBytes = await response.stream.toBytes();
  int r = await extractZipFromBytes(respBytes, outPath);
  if (r == 1) {
    return outPath;
  } else {
    throw Exception('Failed to extract zip file');
  }
}

Future<int> extractZipFromBytes(List<int> bytes, String outpath) async {
  // Extract the zip using the Archive library
  debugPrint('Extracting zip to $outpath');

  try {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    // Extract the contents of the Zip archive to disk.

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$outpath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data, flush: true);
      } else {
        await Directory('$outpath/$filename').create(recursive: true);
      }
    }
  } catch (e) {
    throw Exception('Error extracting zip: $e');
  }

  debugPrint("Extracted zip to $outpath");

  return 1;
}
