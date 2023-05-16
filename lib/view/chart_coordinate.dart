//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'dart:math';

import 'package:stock_charts/view/chart_context.dart';
import 'package:stock_charts/view/chart_props.dart';

import '../core/number_core.dart';
import '../graphics/graphics.dart';

class ChartCoordinate {
  final ChartProps props;
  final ChartContext ctx;

  ChartCoordinate(this.props, this.ctx);

  bool validX() {
    return (ctx.rectInnerChart.valid() &&
        ctx.viewCount > 0 &&
        ctx.nodeWidth > 0);
  }

  bool validY() {
    return (ctx.rectInnerChart.valid() &&
        ctx.minPrice != NumberNull &&
        ctx.maxPrice != NumberNull);
  }

  Real price2pos(Number price) {
    if (price == NumberNull || !validY()) return RealNull;

    switch (props.yCoordType) {
      case EnYCoordinateType.Linear:
      case EnYCoordinateType.Proportional:
      case EnYCoordinateType.Percentage:
        return ctx.rectInnerChart.bottom() -
            (price - ctx.minPrice) *
                (ctx.rectInnerChart.height() / (ctx.maxPrice - ctx.minPrice));
      case EnYCoordinateType.LogLinear:
      case EnYCoordinateType.LogProportional:
      case EnYCoordinateType.LogPercentage:
        return ctx.rectInnerChart.bottom() -
            (log(price) - log(ctx.minPrice)) *
                (ctx.rectInnerChart.height() /
                    (log(ctx.maxPrice) - log(ctx.minPrice)));
      default:
        return 0;
    }
  }

  Number pos2price(Real pos) {
    if (pos == RealNull || !validY()) return NumberNull;

    Number cache;
    switch (props.yCoordType) {
      case EnYCoordinateType.Linear:
      case EnYCoordinateType.Proportional:
      case EnYCoordinateType.Percentage:
        cache = (ctx.rectInnerChart.bottom() - pos) /
            (ctx.rectInnerChart.height() / (ctx.maxPrice - ctx.minPrice));
        return ctx.minPrice + cache;
      case EnYCoordinateType.LogLinear:
      case EnYCoordinateType.LogProportional:
      case EnYCoordinateType.LogPercentage:
        cache = (ctx.rectInnerChart.bottom() - pos) /
            (ctx.rectInnerChart.height() /
                (log(ctx.maxPrice) - log(ctx.minPrice)));
        cache = exp(cache + log(ctx.minPrice));
        cache -= exp(log(ctx.minPrice));
        return ctx.minPrice + cache;
      default:
        return NumberNull;
    }
  }

  Real index2pos(int index) {
    if (index < 0 || !validX()) return RealNull;

    int viewIndex = index - ctx.beginIndex;
    return ctx.rectInnerChart.left() +
        (viewIndex * ctx.nodeWidth) +
        (ctx.nodeWidth / 2.0 - 0.5);
  }

  int pos2index(Real pos) {
    if (pos == RealNull || !validX()) return -1;

    int viewIndex =
        ((pos - ctx.rectInnerChart.left() - (ctx.nodeWidth / 2.0 - 0.5)) /
                ctx.nodeWidth)
            .round();
    return ctx.beginIndex + viewIndex;
  }
}
