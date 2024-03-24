
import 'package:lang_fe/const/consts.dart';

String getAuthUrl() {
  return '$baseUrl$loginUri';
}

String getCurrentTime() {
  return DateTime.now().toIso8601String();
}