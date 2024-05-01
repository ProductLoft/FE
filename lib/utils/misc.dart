import 'package:speaksharp/const/consts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

String getAuthUrl() {
  return '$baseUrl$loginUri';
}

Uri getUploadUrl() {
  return Uri.parse('$baseUrl$uploadUri');
}

Uri getAudioStatusUrl(int audioId) {
  return Uri.parse('$baseUrl$jobStatusUri?job_id=$audioId');
}

Uri getDownloadZipUrl() {
  return Uri.parse('$baseUrl$downloadZipUri');
}

Uri getDownloadAudioJsonUrl() {
  return Uri.parse('$baseUrl$downloadAudioJsonUri');
}

Uri getClientEventUploadUrl() {
  return Uri.parse('$baseUrl$clientEventUploadUri');
}

String getCurrentTime() {
  return DateTime.now().toIso8601String();
}

Future<String> getInsightsDirPath(int audioId) async {
  final dir = await getApplicationDocumentsDirectory();
  return join(dir.path, '$insightPath/$audioId');
}
