//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../core/number_core.dart';
import '../graphics/graphics.dart';

class StMouseHover {
  Point point = Point();
  int index = -1;
  Number price = NumberNull;
}

class ChartContext {
  // [0] content
  Rect rectView = Rect();
  Rect rectXAxis = Rect();
  Rect rectYLAxis = Rect();
  Rect rectYRAxis = Rect();
  Rect rectChart = Rect();
  Rect rectInnerChart = Rect();

  // [1] x
  int viewCount = 0;
  int endIndex = 0; // lastIndex = (endIndex - 1)
  int beginIndex = 0; // = (endIndex - viewCount)
  Real nodeWidth = 7;
  Real stickWidth = 5;

  // [2] y
  Number minPrice = NumberNull;
  Number maxPrice = NumberNull;

  // mouse & keyboard
  StMouseHover hoverNormal = StMouseHover();
  StMouseHover hoverSync = StMouseHover(); // 其他Chart联动

  bool crossLineVisible = true;
}
