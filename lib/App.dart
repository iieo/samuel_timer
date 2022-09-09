import 'dart:async';
import 'background.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  void reset() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for (int i = 0; i < 2; i++) {
      await preferences.setInt("clock$i", 0);
    }
    await preferences.setBool("reset", true);
  }

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
              children: const [
                TimeView(clockIndex: 0, title: "Arbeiten"),
                TimeView(clockIndex: 1, title: "Meditieren"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                TimeView(clockIndex: 2, title: "Schlafen"),
                TimeView(clockIndex: 3, title: "Lernen"),
              ],
            ),
            ElevatedButton(onPressed: reset, child: const Text("Reset"))
          ]),
        ),
      ]))),
    );
  }
}

class TimeView extends StatefulWidget {
  final int clockIndex;
  final String title;

  const TimeView({super.key, required this.clockIndex, required this.title});

  @override
  State<TimeView> createState() => _TimeViewState();
}

class _TimeViewState extends State<TimeView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter1;
  late double size;

  String _toTimeFormat(int count) {
    int seconds = count % 60;
    int minutes = (count ~/ 60) % 60;
    int hours = (count ~/ 3600) % 24;
    int days = (count ~/ 86400);
    return "${days.toString().padLeft(1, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  double calcSize(SharedPreferences prefs) {
    int totalTime = 0;
    int clockTime = prefs.getInt("clock${widget.clockIndex}") ?? 0;
    for (int i = 0; i < 2; i++) {
      totalTime += prefs.getInt("clock$i") ?? 0;
    }
    return max(
        (MediaQuery.of(context).size.width - 150) * (clockTime / totalTime),
        100);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _counter1,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.setInt("activeClock", widget.clockIndex);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(size, size),
                shape: const CircleBorder(),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.title),
                  Text(_toTimeFormat(snapshot.data!)),
                ],
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
      return prefs.getInt("clock${widget.clockIndex}") ?? 0;
    });
    _prefs.then((SharedPreferences prefs) =>
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
          prefs.reload();
          setState(() {
            _counter1 =
                Future(() => prefs.getInt("clock${widget.clockIndex}") ?? 0);
            size = calcSize(prefs);
          });
        }));
  }
}
