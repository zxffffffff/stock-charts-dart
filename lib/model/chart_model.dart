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
  StockCore m_stockCore = StockCore();

  // [1]
  List<ChartPlugin> m_plugins = [];
}
