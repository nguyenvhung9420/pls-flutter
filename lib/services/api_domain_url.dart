import 'package:flutter/foundation.dart';

class APIDomain {
  static String get apiDomainUrl {
    if (kReleaseMode == false) {
      return "http://0.0.0.0";
    }
    return "https://imls-staging.referror.com";
  }
}
