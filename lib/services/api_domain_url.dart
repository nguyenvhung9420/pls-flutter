import 'package:flutter/foundation.dart';

class APIDomain {
  static String get apiDomainUrl {
    final String port = '5555';
    if (kReleaseMode == false) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return "http://10.0.2.2:$port";
      }
      return "http://0.0.0.0:$port";
    }
    return "https://hungnguy-299563163821.asia-southeast1.run.app";
  }
}
