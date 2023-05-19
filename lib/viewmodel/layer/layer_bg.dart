//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../../core/utils.dart';
import '../../graphics/graphics.dart';
import '../../graphics/painter.dart';
import '../../model/chart_model.dart';
import '../chart_context.dart';
import '../chart_coordinate.dart';
import '../chart_props.dart';
import '../chart_layer.dart';

class LayerBG extends ChartLayer {
  // x
  List<Real> xAxisPos = [];
  List<Rect> xAxisRect = [];
  List<String> xAxisDate = [];
  // y
  List<Real> yAxisPos = [];
  List<Rect> ylAxisRect = [];
  List<Rect> yrAxisRect = [];
  List<String> ylAxisPrice = [];
  List<String> yrAxisPrice = [];

  @override
  void init(ChartModel model, ChartProps props, ChartContext context) {}

  @override
  void onContextChanged(
      ChartModel model, ChartProps props, ChartContext context) {
    var stockCore = model.stockCore;
    var coordinate = ChartCoordinate(props, context);

    // x
    xAxisPos.clear();
    xAxisRect.clear();
    xAxisDate.clear();
    Real textWidth = props.xAxisTextWidth;
    Real textHalfWidth = textWidth / 2;
    switch (props.xAxisType) {
      case EnXAxisType.yyyyMM:
      default:
        for (int index = context.beginIndex;
            index < context.endIndex;
            index++) {
          String dt =
              NumberUtils.toTimeStr(stockCore.timestamp[index], "yyyy-MM");
          if (xAxisPos.isNotEmpty) {
            if (dt == xAxisDate.last) continue;
          }
          Real x = coordinate.index2pos(index);
          xAxisPos.add(x);
          xAxisRect.add(Rect(x - textHalfWidth, context.rectXAxis.top() + 1,
              textWidth, context.rectXAxis.height() - 2));
          xAxisRect.last.moveInside(context.rectXAxis);
          xAxisDate.add(dt);
        }
        if (xAxisPos.length >= 2) {
          xAxisPos.removeAt(0);
          xAxisRect.removeAt(0);
          xAxisDate.removeAt(0);
        }
        for (int i = xAxisPos.length - 1; i >= 1; i--) {
          var pre = xAxisDate[i - 1];
          var cur = xAxisDate[i];
          if (cur.substring(0, 4) == pre.substring(0, 4))
            cur = cur.substring(5);
        }
        break;
    }
    for (int i = 1; i < xAxisPos.length;) {
      var rect0 = xAxisRect[i - 1];
      var rect1 = xAxisRect[i];
      if (rect0.right() >= rect1.left()) {
        xAxisPos.removeAt(i);
        xAxisRect.removeAt(i);
        xAxisDate.removeAt(i);
      } else {
        i++;
      }
    }

    // y
    yAxisPos.clear();
    ylAxisRect.clear();
    yrAxisRect.clear();
    ylAxisPrice.clear();
    yrAxisPrice.clear();
    Real stepHeight = props.yAxisGridStepHeight;
    Real stepHalfHeight = stepHeight / 2;
    for (Real y = context.rectChart.bottom() - props.yAxisGridStart;
        y >= context.rectChart.top() + stepHalfHeight;
        y -= stepHeight) {
      yAxisPos.add(y);
      ylAxisRect.add(Rect(context.rectYLAxis.left() + 1, y - stepHalfHeight,
          context.rectYLAxis.width() - 2, stepHeight));
      yrAxisRect.add(Rect(context.rectYRAxis.left() + 1, y - stepHalfHeight,
          context.rectYRAxis.width() - 2, stepHeight));
      ylAxisRect.last.moveInside(context.rectYLAxis);
      yrAxisRect.last.moveInside(context.rectYRAxis);
      ylAxisPrice
          .add(NumberUtils.toStr(coordinate.pos2price(y), props.precision));
      yrAxisPrice
          .add(NumberUtils.toStr(coordinate.pos2price(y), props.precision));
    }
  }

  @override
  void onPaint(ChartModel model, ChartProps props, ChartContext context,
      Painter painter) {
    painter.fillRect(context.rectView, Pen(props.colorViewBG));
    painter.fillRect(context.rectXAxis, Pen(props.colorXAxisBG));
    painter.fillRect(context.rectYLAxis, Pen(props.colorYLAxisBG));
    painter.fillRect(context.rectYRAxis, Pen(props.colorYRAxisBG));
    painter.fillRect(context.rectChart, Pen(props.colorChartBG));
    painter.fillRect(context.rectInnerChart, Pen(props.colorInnerChartBG));

    // x
    for (int i = 0; i < xAxisPos.length; i++) {
      var x = xAxisPos[i];
      painter.drawLine(
          Line(x, context.rectChart.top(), x, context.rectChart.bottom()),
          props.axisGridStyle);
    }
    for (int i = 0; i < xAxisDate.length; i++) {
      painter.drawString(xAxisRect[i], xAxisDate[i], props.xAxisTextFont);
    }
    painter.drawLine(
        Line.fromPoints(
            context.rectXAxis.topLeft(), context.rectXAxis.topRight()),
        props.axisLineStyle);

    // y
    for (int i = 0; i < yAxisPos.length; i++) {
      var y = yAxisPos[i];
      painter.drawLine(
          Line(context.rectChart.left(), y, context.rectChart.right(), y),
          props.axisGridStyle);
    }
    for (int i = 0; i < ylAxisPrice.length; i++) {
      painter.drawString(ylAxisRect[i], ylAxisPrice[i], props.ylAxisTextFont);
    }
    for (int i = 0; i < yrAxisPrice.length; i++) {
      painter.drawString(yrAxisRect[i], yrAxisPrice[i], props.yrAxisTextFont);
    }
    painter.drawLine(
        Line.fromPoints(
            context.rectYLAxis.topRight(), context.rectYLAxis.bottomRight()),
        props.axisLineStyle);
    painter.drawLine(
        Line.fromPoints(
            context.rectYRAxis.topLeft(), context.rectYRAxis.bottomLeft()),
        props.axisLineStyle);
  }
}
