import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mechanics/producers.dart';
import 'view/clicker_page.dart';

late SharedPreferences prefs;

void main() {
  run();
}

void run() async {
  prefs = await SharedPreferences.getInstance();
  Data.restore();
  Timer.periodic(const Duration(seconds: 5), (timer) {
    Data.persist();
  });

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  static ThemeState theme = ThemeState();
  static NumberFormat intFormat = NumberFormat('#,##0');
  static NumberFormat floatFormat = NumberFormat('#,##0.0');

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    App.theme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blorb Clicker',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: Data.useDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const ClickerPage(),
    );
  }
}

class ThemeState with ChangeNotifier {
  void switchTheme() {
    Data.useDarkTheme = !Data.useDarkTheme;
    reload();
  }

  void reload() {
    notifyListeners();
  }
}

class Data {
  static bool useDarkTheme = false;
  static double resourceAmount = 0;
  static final List<Producer> producers = createProducers();

  static Future persist() async {
    await prefs.setBool('useDarkTheme', useDarkTheme);
    await prefs.setDouble('resourceAmount', resourceAmount);

    int producerIndex = 0;
    for (Producer producer in producers) {
      await prefs.setInt('prod${producerIndex}Count', producer.amount);
      producerIndex++;
    }
  }

  static void restore() {
    useDarkTheme = prefs.getBool('useDarkTheme') ?? false;
    resourceAmount = prefs.getDouble('resourceAmount') ?? 0;

    int producerIndex = 0;
    for (Producer producer in producers) {
      producer.amount = prefs.getInt('prod${producerIndex}Count') ?? 0;
      producer.calc();
      producerIndex++;
    }
  }

  static void reset() {
    resourceAmount = 0;

    for (Producer producer in producers) {
      producer.amount = 0;
      producer.calc();
    }

    App.theme.reload();
  }
}
