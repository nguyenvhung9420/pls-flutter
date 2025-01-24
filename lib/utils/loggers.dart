import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLogger {
  static void showSnackBarDebug(String string, BuildContext ctx) {
    if (kDebugMode) {
      SnackBar snackBar = SnackBar(content: Text(string));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
    }
  }
}
