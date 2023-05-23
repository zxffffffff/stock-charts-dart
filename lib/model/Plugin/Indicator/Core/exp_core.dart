//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../../../../core/number_core.dart';

class ExpInfo {
  String rename = "";
  bool renameAssign = false;
}

enum EnExpLineType {
  None,
  LINE,
  DOTLINE,
  STICK,
  COLORSTICK,
}

enum EnExpLineThick {
  None,
  LINETHICK1,
  LINETHICK2,
  LINETHICK3,
  LINETHICK4,
  LINETHICK5,
  LINETHICK6,
  LINETHICK7,
  LINETHICK8,
  LINETHICK9,
}

class ExpColorType {
  EnExpLineType type = EnExpLineType.None;
  EnExpLineThick thick = EnExpLineThick.None;
  String color = "";
}

enum EnDrawingType {
  None, // Line
  Number,
  Text,
  Candlestick,
}

class ExpDrawingType {
  EnDrawingType type = EnDrawingType.None;
  Number stickWidth = 0.0;
  Number stickEmpty = 0.0;
}

class ExpCore {
  NumberCore core = NumberCore();
  ExpInfo info = ExpInfo();
  ExpColorType colorType = ExpColorType();
  ExpDrawingType drawingType = ExpDrawingType();
}
