import 'dart:io';
import 'dart:core';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppBasicInfoProvider extends ChangeNotifier {
  bool _isInited = false;
  String _platformVersion = '';
  String _system = '';
  String _systemVersion = '';
  String _connectivity = '';
  List<String> _pageTrackPathList = [];

  bool get isInited => _isInited;

  void initData() async {
    String _platformVersion = Platform.version;
    String _system = Platform.operatingSystem; // 获取操作系统名称
    String _systemVersion = Platform.operatingSystemVersion; // 获取操作系统版本信息

    final ConnectivityResult _checkConnectivity = await (Connectivity().checkConnectivity());

    switch (_checkConnectivity) {
      case ConnectivityResult.wifi:
        String _connectivity = 'wifi';
        break;
      case ConnectivityResult.mobile:
        String _connectivity = 'mobile';
        break;
      case ConnectivityResult.none:
        String _connectivity = 'none';
        break;
      default:
        String _connectivity = 'other';
        break;
    }

    _isInited = true;
  }

  void addPageTrack(String path){
    _pageTrackPathList?.add(path);
  }

  void clearPageTrack(){
    _pageTrackPathList?.clear();
  }
}