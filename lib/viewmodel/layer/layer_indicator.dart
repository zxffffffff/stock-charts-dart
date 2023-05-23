//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../../core/number_core.dart';
import '../../graphics/painter.dart';
import '../../model/Plugin/Indicator/Core/exp_core.dart';
import '../../model/Plugin/plugin_indicator.dart';
import '../../model/chart_model.dart';
import '../chart_context.dart';
import '../chart_props.dart';
import '../chart_layer.dart';

class LayerIndicator extends ChartLayer {
  @override
  void init(ChartModel model, ChartProps props, ChartContext context) {}

  @override
  Pair<Number, Number> getMinMax(
      ChartModel model, ChartProps props, ChartContext context) {
    var plugin = model.getPlugin(PluginIndicator) as PluginIndicator;
    var indicators = plugin.getIndicators();

    var minmax = Pair(NumberNull, NumberNull);
    for (var indicator in indicators) {
      for (var exp in indicator.indexCore.exps) {
        var minmax2 = exp.core.getMinMax(context.beginIndex, context.endIndex);
        minmax.first = NumberCore.getMinNumber(minmax.first, minmax2.first);
        minmax.second = NumberCore.getMaxNumber(minmax.second, minmax2.second);
      }
    }
    return minmax;
  }

  @override
  void onContextChanged(
      ChartModel model, ChartProps props, ChartContext context) {
    var plugin = model.getPlugin(PluginIndicator) as PluginIndicator;
    var indicators = plugin.getIndicators();

    int indexCnt = indicators.length;
    areaIndexs.clear();
    for (int i = 0; i < indexCnt; i += 1) {
      var index = StChartAreaIndex();
      areaIndexs.add(index);
      var areaExps = index.exps;
      var indicator = indicators[i];
      int expCnt = indicator.indexCore.exps.length;
      areaExps.clear();
      for (int j = 0; j < expCnt; j += 1) {
        var exp = StChartAreaExp();
        var indicatorExp = indicator.indexCore.exps[j];
        switch (indicatorExp.drawingType.type) {
          case EnDrawingType.None:
          case EnDrawingType.Number:
          case EnDrawingType.Text:
            exp = createLineExp(model, props, context, indicatorExp.core);
            break;
          case EnDrawingType.Candlestick:
            // zxf todo
            break;
        }
        exp.colors[0] = Color.fromHex(indicatorExp.colorType.color);
        areaExps.add(exp);
      }
    }
  }

  @override
  void onPaint(ChartModel model, ChartProps props, ChartContext context,
      Painter painter) {
    for (var index in areaIndexs) {
      for (var exp in index.exps) {
        switch (exp.type) {
          case EnChartAreaExpType.Stick:
            painter.drawStick(exp.sticks, props.riseColor, props.fallColor);
            break;
          case EnChartAreaExpType.Line:
            painter.drawPath(exp.lines, Pen(exp.colors[0]));
            break;
          case EnChartAreaExpType.None:
            break;
        }
      }
    }
  }
}
