import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class Utils {
  static Color? parseBackgroundColor(String? backgroundColor) {
    if (backgroundColor == null) return null;
    return Color.fromARGB(
        int.parse(backgroundColor.substring(0,2), radix: 16),
        int.parse(backgroundColor.substring(2,4), radix: 16),
        int.parse(backgroundColor.substring(4,6), radix: 16),
        int.parse(backgroundColor.substring(6,8), radix: 16)
    );
  }

  static log(String str) {
    if (kDebugMode) {
      print(str);
    }
  }
}