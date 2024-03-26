import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> downloadZip(String zipUrl, String outPath) async {
  final response = await http.get(Uri.parse(zipUrl));

  if (response.statusCode != 200) {
    throw Exception(
        'Failed to download zip file. Status code: ${response.statusCode}');
  }
  int r = await extractZipFromBytes(response.bodyBytes, outPath);
  if (r == 1) {
    return outPath;
  } else {
    throw Exception('Failed to extract zip file');
  }
}

Future<int> extractZipFromBytes(List<int> bytes, String outpath) async {
  // Extract the zip using the Archive library
  final archive = ZipDecoder().decodeBytes(bytes, verify: true);

// Extract the contents of the Zip archive to disk.
  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File('$outpath/$filename')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      await Directory('$outpath/$filename').create(recursive: true);
    }
  }

  return 1;
}
