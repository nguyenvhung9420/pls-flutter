import 'package:flutter/material.dart';

class ThemeConstant {
  static Widget sizedBox8 = const SizedBox(height: 8, width: 8);
  static Widget sizedBox16 = SizedBox(height: DoubleConstant.padding16, width: DoubleConstant.padding16);

  static EdgeInsets padding16({bool? horizontal, bool? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: (horizontal ?? true) ? DoubleConstant.padding16 : 0,
      vertical: (vertical ?? true) ? DoubleConstant.padding16 : 0,
    );
  }

  static EdgeInsets padding8({bool? horizontal, bool? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: (horizontal ?? true) ? DoubleConstant.padding8 : 0,
      vertical: (vertical ?? true) ? DoubleConstant.padding8 : 0,
    );
  }

  static double bottomPadding(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return bottomPadding;
  }
}

class DoubleConstant {
  static double padding16 = 16.0;
  static double padding8 = 8.0;
}
