//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../core/data_binding.dart';

import '../core/stock_core.dart';

const String ID_ChartPluginChanged = "ID_ChartPluginChanged";

class ChartPlugin with DataBinding {
  void init(StockCore stockCore) {
    // override
  }

  void onStockCoreChanged(StockCore stockCore) {
    // override
  }
}
