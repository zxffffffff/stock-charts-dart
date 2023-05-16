//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'dart:ui';
import 'painter.dart';

class PainterFlutter extends Painter {
  Canvas canvas;
  PainterFlutter(this.canvas);

  @override
  void save() {}

  @override
  void restore() {}
}
