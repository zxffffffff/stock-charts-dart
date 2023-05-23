//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../../core/stock_core.dart';
import '../chart_plugin.dart';
import 'Indicator/Core/index_core.dart';
import 'Indicator/indicator_parser.dart';

class PluginIndicator extends ChartPlugin {
  late StockCore _stockCore;
  List<StIndicator> _indicators = [];

  @override
  void init(StockCore stockCore) {
    _stockCore = stockCore;
  }

  @override
  void onStockCoreChanged(StockCore stockCore) {
    _stockCore = stockCore;
    calcIndicators();
  }

  StIndicator addIndicator(IndexFormula formular) {
    StIndicator indicator = StIndicator();
    indicator.formula = formular;
    _indicators.add(indicator);
    calcIndicator(_indicators.length - 1);

    fire(ID_ChartPluginChanged);
    return indicator;
  }

  void delIndicator(StIndicator indicator) {
    _indicators.remove(indicator);

    fire(ID_ChartPluginChanged);
  }

  void delIndicators() {
    _indicators.clear();

    fire(ID_ChartPluginChanged);
  }

  List<StIndicator> getIndicators() {
    return _indicators;
  }

  StIndicator getIndicator(int i) {
    if (i < 0 || i >= _indicators.length) return StIndicator();
    return _indicators[i];
  }

  void calcIndicators() {
    for (int i = 0; i < _indicators.length; i += 1) calcIndicator(i);
  }

  void calcIndicator(int i) {
    if (i < 0 || i >= _indicators.length) return;
    var indicator = _indicators[i];

    var parser = IndicatorParser();
    parser.setFormula(indicator.formula);
    parser.setStockCore(_stockCore);
    bool ok = parser.run();
    indicator.indexCore = parser.getResult();

    fire(ID_ChartPluginChanged);
  }
}
