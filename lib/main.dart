import 'package:flutter/material.dart';
import 'App.dart';

import 'dart:ui';
import "dart:async";
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
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
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  int count1 = preferences.getInt("count1") ?? 0;
  int count2 = preferences.getInt("count2") ?? 0;

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    preferences.reload();
    bool time1Active = preferences.getBool("normalClockActive") ?? false;
    bool reset = preferences.getBool("reset") ?? false;

    if (reset) {
      preferences.setInt("count1", 0);
      preferences.setInt("count2", 0);
      preferences.setBool("reset", false);
      count1 = 0;
      count2 = 0;
    }

    if (!time1Active) {
      await preferences.setInt("count1", count1++);
    } else {
      await preferences.setInt("count2", count2++);
    }
  });
}
