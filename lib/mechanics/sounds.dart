// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js';

import 'package:flutter/foundation.dart';

playPopSound() {
  if (kIsWeb) {
    context.callMethod("playPop");
  }
}
