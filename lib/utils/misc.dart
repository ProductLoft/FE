
import 'package:lang_fe/const/consts.dart';

String getAuthUrl() {
  return '$baseUrl$loginUri';
}

Uri getUploadUrl() {

  return Uri.parse('$baseUrl$uploadUri');
}

String getCurrentTime() {
  return DateTime.now().toIso8601String();
}