// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lang_fe/provider/app_basic_provider.dart';
import 'package:lang_fe/req/client_event_upload.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:lang_fe/utils/navigator_util.dart';
import 'package:provider/provider.dart';
import 'package:web_startup_analyzer/web_startup_analyzer.dart';

import 'constants.dart';
import 'firebase_options.dart';
import 'home.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAuth.instance.useAuthEmulator('f9a5-128-237-82-3.ngrok-free.app', 443);

  auth = FirebaseAuth.instanceFor(app: app);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var analyzer = WebStartupAnalyzer(additionalFrameCount: 10);
  debugPrint(json.encode(analyzer.startupTiming));
  analyzer.onFirstFrame.addListener(() {
    debugPrint(json.encode({'firstFrame': analyzer.onFirstFrame.value}));
  });
  analyzer.onFirstPaint.addListener(() {
    debugPrint(json.encode({
      'firstPaint': analyzer.onFirstPaint.value?.$1,
      'firstContentfulPaint': analyzer.onFirstPaint.value?.$2,
    }));
  });
  analyzer.onAdditionalFrames.addListener(() {
    debugPrint(json.encode({
      'additionalFrames': analyzer.onAdditionalFrames.value,
    }));
  });

  debugPrint(json.encode({'version': Platform.version}));

  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) async {
    debugPrint('onError===start==');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final ConnectivityResult checkConnectivity =
        await (Connectivity().checkConnectivity());

    await clientEventUpload({
      "event_type": 'client_error_occurred',
      "event_code": '0001',
      "event_message": 'FlutterError.onError',
      "stack_trace": details.toString(),
      "thread_info": jsonEncode({
        "software_version": packageInfo.version,
        "app_name": packageInfo.appName,
        "app_build_number": packageInfo.buildNumber,
        "os_info": {
          "system": Platform.operatingSystem,
          "system_version": Platform.operatingSystemVersion
        },
        "network_info": checkConnectivity.toString()
      })
    });

    debugPrint('onError===end');
  };

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool useMaterial3 = true;
  ThemeMode themeMode = ThemeMode.system;
  ColorSeed colorSelected = ColorSeed.baseColor;
  ColorImageProvider imageSelected = ColorImageProvider.leaves;
  ColorScheme? imageColorScheme = const ColorScheme.light();
  ColorSelectionMethod colorSelectionMethod = ColorSelectionMethod.colorSeed;

  bool get useLightMode => switch (themeMode) {
        ThemeMode.system =>
          View.of(context).platformDispatcher.platformBrightness ==
              Brightness.light,
        ThemeMode.light => true,
        ThemeMode.dark => false
      };

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelectionMethod = ColorSelectionMethod.colorSeed;
      colorSelected = ColorSeed.values[value];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppBasicInfoProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '',
          themeMode: themeMode,
          theme: ThemeData(
            colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
                ? colorSelected.color
                : null,
            useMaterial3: useMaterial3,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
                ? colorSelected.color
                : imageColorScheme!.primary,
            useMaterial3: useMaterial3,
            brightness: Brightness.dark,
          ),
          home: Home(
            useLightMode: useLightMode,
            colorSelected: colorSelected,
            // imageSelected: imageSelected,
            handleBrightnessChange: handleBrightnessChange,
            handleColorSelect: handleColorSelect,
            // handleImageSelect: handleImageSelect,
            // colorSelectionMethod: colorSelectionMethod,
          ),
          // navigatorObservers: [MyNavigatorObserver()],
        ));
  }
}
