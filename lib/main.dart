import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart';
import 'package:xml/xml.dart';

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
  static final List<Producer> producers = initProducers();

  static Future persist() async {
    await prefs.setBool('useDarkTheme', useDarkTheme);
    await prefs.setDouble('resourceAmount', resourceAmount);

    int producerIndex = 0;
    for (Producer producer in producers) {
      await prefs.setInt('prod${producerIndex}Count', producer.amount);
      for (ProducerUpgrade upgrade in producer.upgrades) {
        await prefs.setBool(
            'prod${producerIndex}Up${upgrade.tier}', upgrade.bought);
      }
      producerIndex++;
    }
  }

  static void restore() {
    useDarkTheme = prefs.getBool('useDarkTheme') ?? false;
    resourceAmount = prefs.getDouble('resourceAmount') ?? 0;

    int producerIndex = 0;
    for (Producer producer in producers) {
      producer.amount = prefs.getInt('prod${producerIndex}Count') ?? 0;
      for (ProducerUpgrade upgrade in producer.upgrades) {
        upgrade.bought =
            prefs.getBool('prod${producerIndex}Up${upgrade.tier}') ?? false;
      }
      producer.calc();
      producerIndex++;
    }

    updateProducerUpgrades();
    App.theme.reload();
  }

  static void serailize() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('data', nest: () {
      builder.element('useDarkTheme', nest: useDarkTheme);
      builder.element('resourceAmount', nest: resourceAmount);

      int producerIndex = 0;
      for (Producer producer in producers) {
        builder.element('prod${producerIndex}Count', nest: producer.amount);
        for (ProducerUpgrade upgrade in producer.upgrades) {
          builder.element(
            'prod${producerIndex}Up${upgrade.tier}',
            nest: upgrade.bought,
          );
        }
        producerIndex++;
      }
    });

    final document = builder.buildDocument();
    final bytes = utf8.encode(document.toXmlString(pretty: true));
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'BlorbClicker.blorbsv';
    html.document.body!.children.add(anchor);

    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static void deserialize() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.blorbsv';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files == null || files.length != 1) {
        return;
      }
      final file = files[0];
      if (!equal(extension(file.name), '.blorbsv')) {
        return;
      }

      html.FileReader reader = html.FileReader();
      reader.onLoadEnd.listen((e) {
        String result = utf8.decode(reader.result as List<int>);
        XmlDocument document = XmlDocument.parse(result);
        XmlElement? root = document.getElement('data');
        if (root == null) {
          return;
        }

        useDarkTheme = getBool(root, 'useDarkTheme', false);
        resourceAmount = getDouble(root, 'resourceAmount', 0);

        int producerIndex = 0;
        for (Producer producer in producers) {
          producer.amount = getInt(root, 'prod${producerIndex}Count', 0);
          for (ProducerUpgrade upgrade in producer.upgrades) {
            upgrade.bought =
                getBool(root, 'prod${producerIndex}Up${upgrade.tier}', false);
          }
          producer.calc();
          producerIndex++;
        }

        updateProducerUpgrades();
        App.theme.reload();
      });

      reader.readAsArrayBuffer(file);
    });
  }

  static bool getBool(XmlElement parent, String name, bool fallback) {
    XmlElement? element = parent.getElement(name);
    return element != null ? equals(element.text, 'true') : fallback;
  }

  static int getInt(XmlElement parent, String name, int fallback) {
    XmlElement? element = parent.getElement(name);
    return element != null ? int.parse(element.text) : fallback;
  }

  static double getDouble(XmlElement parent, String name, double fallback) {
    XmlElement? element = parent.getElement(name);
    return element != null ? double.parse(element.text) : fallback;
  }

  static void reset() {
    resourceAmount = 0;

    for (Producer producer in producers) {
      producer.amount = 0;
      for (ProducerUpgrade upgrade in producer.upgrades) {
        upgrade.bought = false;
      }
      producer.calc();
    }

    updateProducerUpgrades();
    App.theme.reload();
  }
}
