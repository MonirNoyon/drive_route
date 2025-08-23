import 'package:flutter/foundation.dart';

void printData(String text, {bool isLog = true}) {
  if (kDebugMode && isLog) {
    final pattern = RegExp('.{1,800}');
    for (final match in pattern.allMatches(text)) {
      debugPrint(match.group(0));
    }
  }
}