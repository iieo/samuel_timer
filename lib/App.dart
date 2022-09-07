import 'dart:async';
import 'background.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(80, 50, 250, 1),
        brightness: Brightness.dark,
      ),
      home: Scaffold(
          body: SafeArea(
              child: Stack(children: [
        Background(),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimeView(
                    prefKey: "count1", title: "Modus 1", normalClock: false),
                TimeView(
                    prefKey: "count2", title: "Modus 2", normalClock: true),
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setBool("reset", true);
                },
                child: const Text("Reset"))
          ]),
        ),
      ]))),
    );
  }
}

class TimeView extends StatefulWidget {
  final String prefKey;
  final String title;
  final bool normalClock;

  const TimeView(
      {super.key,
      required this.prefKey,
      required this.title,
      required this.normalClock});

  @override
  State<TimeView> createState() => _TimeViewState();
}

class _TimeViewState extends State<TimeView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter1;

  String _toTimeFormat(int count) {
    int seconds = count % 60;
    int minutes = (count ~/ 60) % 60;
    int hours = (count ~/ 3600) % 24;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _counter1,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.setBool("normalClockActive", widget.normalClock);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(widget.title),
                    Text(_toTimeFormat(snapshot.data!)),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _counter1 = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt(widget.prefKey) ?? 0;
    });
    _prefs.then((SharedPreferences prefs) =>
        Timer.periodic(const Duration(seconds: 1), (timer) {
          prefs.reload();
          setState(() {
            _counter1 = Future(() => prefs.getInt(widget.prefKey) ?? 0);
          });
        }));
  }
}
