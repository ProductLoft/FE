// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lang_fe/provider/app_basic_provider.dart';
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

  runApp(const App());
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   reportErrorAndLog(details);
  // };

  // runZoned(
  //   () => runApp(App()),
  //   zoneSpecification: ZoneSpecification(
  //     print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
  //       collectLog(line);
  //     },
  //   ),
  //   onError: (Object obj, StackTrace stack) {
  //     var details = makeDetails(obj, stack);
  //     reportErrorAndLog(details);
  //   },
  // );
}

// void collectLog(String line){
//      //收集日志
// }
// void reportErrorAndLog(FlutterErrorDetails details){
//      //上报错误和日志逻辑
// }

// FlutterErrorDetails makeDetails(Object obj, StackTrace stack){
//     // 构建错误信息
// }

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
  // ColorSelectionMethod colorSelectionMethod = ColorSelectionMethod.colorSeed;

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
            // colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            //     ? colorSelected.color
            //     : null,
            // colorScheme: colorSelectionMethod == ColorSelectionMethod.image
            //     ? imageColorScheme
            //     : null,
            useMaterial3: useMaterial3,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            // colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            //     ? colorSelected.color
            //     : imageColorScheme!.primary,
            useMaterial3: useMaterial3,
            brightness: Brightness.dark,
          ),
          home: Home(
            useLightMode: useLightMode,
            // colorSelected: colorSelected,
            // imageSelected: imageSelected,
            handleBrightnessChange: handleBrightnessChange,
            // handleColorSelect: handleColorSelect,
            // handleImageSelect: handleImageSelect,
            // colorSelectionMethod: colorSelectionMethod,
          ),
          // navigatorObservers: [MyNavigatorObserver()],
        ));
  }
}
