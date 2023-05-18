//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:intl/intl.dart';

class NumberUtils {
  static String toTimestr(int timestamp,
      [String format = "yyyy-MM-dd HH:mm:ss"]) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
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
