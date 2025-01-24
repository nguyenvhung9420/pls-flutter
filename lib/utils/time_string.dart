import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TimeStringUtil {
  static String getCurrentLocale() {
    String locale = Intl.getCurrentLocale();
    return locale;
  }

  static String makeTimeStringWithCurrentLocale(DateTime? dateTime) {
    if (dateTime == null) return "";
    return DateFormat.yMMMd(getCurrentLocale()).add_jm().format(dateTime.toLocal()) +
        (kDebugMode ? " ${dateTime.toLocal().timeZoneName}" : "");
  }

  static String makeDateStringWithCurrentLocale(DateTime? dateTime) {
    if (dateTime == null) return "";
    return DateFormat.yMMMd(getCurrentLocale()).format(dateTime.toLocal()) +
        (kDebugMode ? " UTC${dateTime.toLocal().timeZoneName}" : "");
  }
}
