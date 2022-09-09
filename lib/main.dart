import 'package:flutter/material.dart';
import 'App.dart';

import 'dart:ui';
import 'dart:io';
import "dart:async";
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  if (Platform.isAndroid || Platform.isIOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeService();
  } else {
    startTimer();
  }
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  startTimer();
}

void startTimer() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    await preferences.reload();
    bool reset = preferences.getBool("reset") ?? false;
    if (!reset) {
      int activeClock = preferences.getInt("activeClock") ?? 0;
      int clockTime = preferences.getInt("clock$activeClock") ?? 0;
      await preferences.setInt("clock$activeClock", clockTime + 1);
    } else {
      await preferences.setBool("reset", false);
      preferences.reload();
    }
  });
}
