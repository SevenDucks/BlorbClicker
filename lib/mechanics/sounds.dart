import 'dart:js';

import 'package:flutter/foundation.dart';

playPopSound() {
  if (kIsWeb) {
    context.callMethod("playPop");
  }
}
