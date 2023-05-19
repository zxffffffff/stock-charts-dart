//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'dart:math';

import '../core/data_binding.dart';
import '../core/number_core.dart';
import '../graphics/graphics.dart';
import '../graphics/painter.dart';
import '../model/chart_model.dart';
import 'chart_context.dart';
import 'chart_coordinate.dart';
import 'chart_props.dart';

enum EnChartAreaExpType {
  None,
  Stick,
  Line,
}

class StChartAreaExp {
  EnChartAreaExpType type = EnChartAreaExpType.None;
  List<Point> lines = [];
  List<Stick> sticks = [];
  List<Color> colors = [Color(), Color()]; // extends
}

class StChartAreaIndex {
  List<StChartAreaExp> exps = [];
}

const String ID_ChartLayerChanged = "ID_ChartLayerChanged";

class ChartLayer with DataBinding {
  // layers-indexs-exps
  List<StChartAreaIndex> areaIndexs = [];

  void init(ChartModel model, ChartProps props, ChartContext context) {
    // override
  }

  // [1]
  Pair<Number, Number> getMinMax(
      ChartModel model, ChartProps props, ChartContext context) {
    // override
    return Pair(NumberNull, NumberNull);
  }

  // [2]
  void onContextChanged(
      ChartModel model, ChartProps props, ChartContext context) {
    // override
  }

  void onMouseMove(ChartModel model, ChartProps props, ChartContext context) {
    // override
  }

  void onMouseLeave(ChartModel model, ChartProps props, ChartContext context) {
    // override
  }

  void onPaint(ChartModel model, ChartProps props, ChartContext context,
      Painter painter) {
    // override
  }

  // [3]
  StChartAreaExp createStickExp(
      ChartModel model,
      ChartProps props,
      ChartContext context,
      NumberCore open,
      NumberCore high,
      NumberCore low,
      NumberCore close) {
    var coordinate = ChartCoordinate(props, context);

    var exp = StChartAreaExp();
    exp.type = EnChartAreaExpType.Stick;
    exp.sticks = List.filled(context.viewCount, Stick(), growable: true);
    for (int index = context.beginIndex; index < context.endIndex; index++) {
      int i = index - context.beginIndex;

      final Real xPos = coordinate.index2pos(index);
      final Number o = open[index];
      final Number c = close[index];
      final Real oPos = coordinate.price2pos(o);
      final Real hPos = coordinate.price2pos(high[index]);
      final Real lPos = coordinate.price2pos(low[index]);
      final Real cPos = coordinate.price2pos(c);

      exp.sticks[i].set(
          xPos - context.stickWidth / 2,
          min(oPos, cPos),
          context.stickWidth,
          (oPos - cPos).abs(),
          hPos,
          lPos,
          (c > o
              ? 1
              : c < o
                  ? -1
                  : 0));
    }
    return exp;
  }

  StChartAreaExp createLineExp(ChartModel model, ChartProps props,
      ChartContext context, NumberCore price) {
    var coordinate = ChartCoordinate(props, context);

    var exp = StChartAreaExp();
    exp.type = EnChartAreaExpType.Line;
    exp.lines = List.filled(context.viewCount, Point(), growable: true);
    for (int index = context.beginIndex; index < context.endIndex; index++) {
      int i = index - context.beginIndex;

      final Real xPos = coordinate.index2pos(index);
      final Real yPos = coordinate.price2pos(price[index]);

      exp.lines[i].set(xPos, yPos);
    }
    return exp;
  }
}
