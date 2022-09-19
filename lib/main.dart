import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'view/clicker_page.dart';

void main() {
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
        primarySwatch: Colors.purple,
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
    notifyListeners();
  }
}

class Data {
  static bool useDarkTheme = false;
  static double resourceAmount = 0;
}
