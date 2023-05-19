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
import '../../model/chart_model.dart';
import '../chart_context.dart';
import '../chart_props.dart';
import '../chart_layer.dart';

class LayerStock extends ChartLayer {
  @override
  void init(ChartModel model, ChartProps props, ChartContext context) {}

  @override
  Pair<Number, Number> getMinMax(
      ChartModel model, ChartProps props, ChartContext context) {
    var stockCore = model.stockCore;

    return stockCore.getMinMax(context.beginIndex, context.endIndex);
  }

  @override
  void onContextChanged(
      ChartModel model, ChartProps props, ChartContext context) {
    var stockCore = model.stockCore;
    areaIndexs = [StChartAreaIndex()];
    areaIndexs.first.exps = [StChartAreaExp()];

    switch (props.lineType) {
      case EnStockLineType.CandlestickHollow:
      case EnStockLineType.Candlestick:
      case EnStockLineType.BAR:
        areaIndexs.first.exps.first = createStickExp(model, props, context,
            stockCore.open, stockCore.high, stockCore.low, stockCore.close);
        break;
      case EnStockLineType.Line:
        areaIndexs.first.exps.first =
            createLineExp(model, props, context, stockCore.close);
        break;
    }
  }

  @override
  void onPaint(ChartModel model, ChartProps props, ChartContext context,
      Painter painter) {
    final exp = areaIndexs.first.exps.first;
    switch (props.lineType) {
      case EnStockLineType.CandlestickHollow:
        painter.drawStickHollow(exp.sticks, props.riseColor, props.fallColor);
        break;
      case EnStockLineType.Candlestick:
        painter.drawStick(exp.sticks, props.riseColor, props.fallColor);
        break;
      case EnStockLineType.BAR:
        painter.drawBAR(exp.sticks, props.riseColor, props.fallColor);
        break;
      case EnStockLineType.Line:
        painter.drawPath(exp.lines, Pen(Color(100, 100, 200)));
        break;
    }
  }
}
