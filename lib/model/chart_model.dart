//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../core/stock_core.dart';
import 'chart_plugin.dart';

class ChartModel {
  // [0]
  final StockCore stockCore;

  // [1]
  final List<ChartPlugin> plugins = [];

  ChartModel(this.stockCore);
}
