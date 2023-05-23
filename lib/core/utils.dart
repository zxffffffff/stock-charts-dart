//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:intl/intl.dart';

import 'number_core.dart';

class Utils {
  static String to8bitStr(String str) {
    if (str.isEmpty) return str;

    String ret = "";
    for (int i = 0; i < str.length; ++i) {
      String c = str[i];
      if (c.codeUnitAt(0) < 0 || c.codeUnitAt(0) > 127) {
        ret += "%u${(int.parse(c)).toRadixString(16).toUpperCase()}";
        continue;
      } else {
        ret += c;
      }
    }
    return ret;
  }

  static bool checkEmpty(String str) {
    if (str.isEmpty) return true;

    for (int i = 0; i < str.length; ++i) {
      String c = str[i];
      if (c != '\r' &&
          c != '\n' &&
          c != '\t' &&
          c != '\v' &&
          c != ' ' &&
          c != ';') {
        return false;
      }
    }
    return true;
  }

  static bool isLetter(String character) {
    return character.isNotEmpty &&
        character.runes.every((codeUnit) {
          return ("a".codeUnitAt(0) <= codeUnit &&
                  codeUnit <= "z".codeUnitAt(0)) ||
              ("A".codeUnitAt(0) <= codeUnit && codeUnit <= "Z".codeUnitAt(0));
        });
  }

  static bool isDigit(String character) {
    return character.isNotEmpty &&
        character.runes.every((codeUnit) {
          return ("0".codeUnitAt(0) <= codeUnit &&
              codeUnit <= "9".codeUnitAt(0));
        });
  }
}

class NumberUtils {
  static String toStr(Number price, [int precision = 2, String sNull = "--"]) {
    if (price == NumberNull) return sNull;
    return price.toStringAsFixed(precision);
  }

  static String toTimeStr(Number timestamp,
      [String format = "yyyy-MM-dd HH:mm:ss"]) {
    var date = DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
    var formattedDate = DateFormat(format).format(date);
    return formattedDate;
  }

  static int toTimestamp(String timeStr,
      [String format = "yyyy-MM-dd HH:mm:ss"]) {
    var formatter = new DateFormat(format);
    var dateTime = formatter.parse(timeStr);
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }
}
