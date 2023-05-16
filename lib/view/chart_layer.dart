//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:stock_charts/core/number_core.dart';

import '../graphics/graphics.dart';
import '../graphics/painter.dart';
import '../model/chart_model.dart';
import 'chart_context.dart';
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

class ChartLayer {
  // [0]
  final ChartModel model;
  ChartProps props;
  ChartContext context;

  // [1] layers-indexs-exps
  List<StChartAreaIndex> areaIndexs = [];

  ChartLayer(this.model, this.props, this.context);

  // [1]
  Pair<Number, Number> getMinMax(int beginIndex, int endIndex) {
    return Pair(NumberNull, NumberNull);
  }

  // [2]
  void onContextChanged() {}

  void onPaint(Painter painter) {}
}
