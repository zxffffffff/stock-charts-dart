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
import 'chart_plugin.dart';

const String ID_StockCoreChanged = "ID_StockCoreChanged";

class ChartModel with DataBinding {
  // [0]
  final StockCore _stockCore;

  // [1]
  final List<ChartPlugin> _plugins = [];

  ChartModel(this._stockCore);

  @override
  void on(DataBinding sender, String id) {
    if (id == ID_ChartPluginChanged) {
      fire(id);
    }
  }

  // [0]
  StockCore get stockCore => _stockCore;

  set stockCore(StockCore stockCore) {
    _stockCore.reset(stockCore);
    for (var plugin in _plugins) {
      plugin.onStockCoreChanged(_stockCore);
    }
    fire(ID_StockCoreChanged);
  }

  // [1]
  void addPlugin(ChartPlugin plugin) {
    _plugins.add(plugin);
    listen(plugin);
    plugin.init(_stockCore);
    listen(plugin);
  }

  ChartPlugin? getPlugin(Type pluginType) {
    for (var plugin in _plugins) {
      // RTTI
      if (plugin.runtimeType == pluginType) {
        return plugin;
      }
    }
    return null;
  }

  List<ChartPlugin> getPlugins() {
    return _plugins;
  }
}
