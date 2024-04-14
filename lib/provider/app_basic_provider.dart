import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
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

    switch (checkConnectivity) {
      case ConnectivityResult.mobile:
        connectivity = 'mobile';
      case ConnectivityResult.wifi:
        connectivity = 'wifi';
      case ConnectivityResult.ethernet:
        connectivity = 'ethernet';
      case ConnectivityResult.vpn:
        connectivity = 'vpn';
      case ConnectivityResult.bluetooth:
        connectivity = 'bluetooth';
      case ConnectivityResult.none:
        connectivity = 'none';
      default:
        connectivity = 'other';
        break;
    }

    isInited = true;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    appVersion = packageInfo.version;
    appBuildNumber = packageInfo.buildNumber;

    debugPrint(jsonEncode({
      "appName": appName,
      "version": appVersion,
      "buildNumber": appBuildNumber,
      "connectivity": checkConnectivity.toString()
    }));

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
        "network_info": connectivity
      })
    });
  }

  void addPageTrack(String path) {
    String last = pageTrackPathList.last;
    if (last != path) {
      pageTrackPathList.add(path);
    }
  }

  Future<void> addUserLoginLog() async {
    // 提交日志
    await clientEventUpload({
      "event_type": 'important_event_occurred',
      "event_code": "0004",
      "event_message": "",
      "software_version": appVersion,
      "os_info": jsonEncode({
        "appName": appName,
        "appBuildNumber": appBuildNumber,
        "os_info": {"system": system, "systemVersion": systemVersion},
        "network_info": connectivity
      }),
      "operation_trace": jsonEncode(pageTrackPathList)
    });

    clearPageTrack();
  }

  Future<void> addUserSignUpLog() async {
    // 提交日志
    await clientEventUpload({
      "event_type": 'important_event_occurred',
      "event_code": "0003",
      "event_message": "",
      "software_version": appVersion,
      "os_info": jsonEncode({
        "appName": appName,
        "appBuildNumber": appBuildNumber,
        "os_info": {"system": system, "systemVersion": systemVersion},
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
