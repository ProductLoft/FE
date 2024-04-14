import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:lang_fe/req/client_event_upload.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppBasicInfoProvider extends ChangeNotifier {
  bool isInited = false;
  String appName = '';
  String appVersion = '';
  String appBuildNumber = '';
  String system = '';
  String systemVersion = '';
  String connectivity = '';
  List<String> pageTrackPathList = [];

  bool get isInitialled => isInited;

  Future<void> initDataAndAppOpenLog() async {
    system = Platform.operatingSystem; // 获取操作系统名称
    systemVersion = Platform.operatingSystemVersion; // 获取操作系统版本信息

    final ConnectivityResult checkConnectivity =
        await (Connectivity().checkConnectivity());
    connectivity = checkConnectivity.toString();

    isInited = true;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    appVersion = packageInfo.version;
    appBuildNumber = packageInfo.buildNumber;

    String deviceInfo = '';

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      deviceInfo = (await deviceInfoPlugin.deviceInfo).data.toString();
    } catch (e) {
      debugPrint('no deviceIndo ${e.toString()}');
    }

    // 提交日志
    await clientEventUpload({
      "event_type": 'important_event_occurred',
      "event_code": "0002",
      "event_message": "",
      "software_version": appVersion,
      "os_info": jsonEncode({
        "appName": appName,
        "appBuildNumber": appBuildNumber,
        "os_info": {"system": system, "systemVersion": systemVersion},
        "network_info": connectivity,
        "device_info": deviceInfo
      })
    });
  }

  void addPageTrack(String path) {
    if (pageTrackPathList.isNotEmpty) {
      String last = pageTrackPathList.last;

      if (last != path) {
        pageTrackPathList.add(path);
      }
    } else {
      pageTrackPathList.add(path);
    }
  }

  Future<void> addUserActionLog(String code) async {
    // 提交日志
    await clientEventUpload({
      "event_type": 'important_event_occurred',
      "event_code": code,
      "event_message": "",
      "software_version": appVersion,
      "os_info": jsonEncode({
        "app_name": appName,
        "app_build_number": appBuildNumber,
        "os_info": {"system": system, "system_version": systemVersion},
        "network_info": connectivity
      }),
      "operation_trace": jsonEncode(pageTrackPathList)
    });

    clearPageTrack();
  }

  void clearPageTrack() {
    pageTrackPathList.clear();
  }
}
