//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:flutter/material.dart';
import '../core/number_core.dart';
import '../graphics/graphics.dart' as stock_charts;
import '../graphics/painter_flutter.dart' as stock_charts;
import '../model/chart_model.dart';
import 'chart_context.dart';
import 'chart_layer.dart';
import 'chart_props.dart';

class ChartView extends StatefulWidget {
  // [0]
  final ChartModel model;
  final ChartProps props = ChartProps();

  // [1]
  final List<ChartLayer> layers = [];

  ChartView(this.model, {super.key});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  // [0]
  final ChartContext ctx = ChartContext();

  PointerEvent? _event;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  // [2]
  void calcContext() {
    var stockCore = widget.model.stockCore;
    var props = widget.props;

    // [0] content
    ctx.rectXAxis.set(
        ctx.rectView.left() + props.ylAxisWidth,
        ctx.rectView.bottom() - props.xAxisHeight,
        ctx.rectView.width() - props.ylAxisWidth - props.yrAxisWidth,
        props.xAxisHeight);
    ctx.rectYLAxis.set(ctx.rectView.left(), ctx.rectView.top(),
        props.ylAxisWidth, ctx.rectView.height());
    ctx.rectYRAxis.set(ctx.rectView.right() - props.yrAxisWidth,
        ctx.rectView.top(), props.yrAxisWidth, ctx.rectView.height());
    ctx.rectChart.set(
        ctx.rectView.left() + props.ylAxisWidth,
        ctx.rectView.top(),
        ctx.rectView.width() - props.ylAxisWidth - props.yrAxisWidth,
        ctx.rectView.height() - props.xAxisHeight);
    ctx.rectInnerChart.set(
        ctx.rectChart.left() + props.paddingLeft,
        ctx.rectChart.top() + props.paddingTop,
        ctx.rectChart.width() - props.paddingLeft - props.paddingRight,
        ctx.rectChart.height() - props.paddingTop - props.paddingBottom);

    // invalid size
    if (!ctx.rectInnerChart.valid()) {
      // assert(false);
      return;
    }

    // [1] x
    int stockCnt = stockCore.getSize();
    stock_charts.Real stockWidth = stockCnt * ctx.nodeWidth;
    stock_charts.Real viewWidth = ctx.rectInnerChart.width();
    switch (props.xCoordType) {
      case EnXCoordinateType.Fill:
        ctx.nodeWidth = viewWidth / (stockCnt + 1);
        ctx.viewCount = stockCnt;
        ctx.endIndex = stockCnt;
        ctx.beginIndex = 0;
        break;
      case EnXCoordinateType.Cover:
      default:
        if (stockWidth <= viewWidth) {
          if (ctx.viewCount != stockCnt) {
            ctx.viewCount = stockCnt;
            ctx.endIndex = stockCnt;
            ctx.beginIndex = 0;
          }
        } else {
          int viewCount = (viewWidth / ctx.nodeWidth).floor();
          if (ctx.viewCount != viewCount) {
            ctx.viewCount = viewCount;
            ctx.endIndex = stockCnt;
            ctx.beginIndex = ctx.endIndex - ctx.viewCount;
          }
        }
        break;
    }
    assert(ctx.viewCount >= 0);
    assert(ctx.endIndex >= 0);
    assert(ctx.beginIndex >= 0);
    assert(ctx.beginIndex <= ctx.endIndex);
    assert(ctx.endIndex <= stockCnt);
    assert(ctx.endIndex - ctx.beginIndex <= ctx.viewCount);

    // [2] y
    ctx.minPrice = NumberNull;
    ctx.maxPrice = NumberNull;
    for (var layer in widget.layers) {
      var minmax = layer.getMinMax(ctx.beginIndex, ctx.endIndex);
      ctx.minPrice = NumberCore.min(minmax.first, ctx.minPrice);
      ctx.maxPrice = NumberCore.max(minmax.second, ctx.maxPrice);
    }

    calcLayers();
    // todo fire(ID_ChartContextChanged);
  }

  void calcLayers() {
    for (var layer in widget.layers) {
      layer.onContextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: CustomPaint(
        size: const Size(400, 300),
        painter: MyPainter(ctx, widget.layers,
            _event != null ? _event!.localPosition : const Offset(100, 100)),
      ),
      onPointerDown: (PointerDownEvent event) => setState(() => _event = event),
      onPointerMove: (PointerMoveEvent event) => setState(() => _event = event),
      onPointerUp: (PointerUpEvent event) => setState(() => _event = event),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.ctx, this.layers, this.cursor);
  final ChartContext ctx;
  final List<ChartLayer> layers;
  Offset cursor;

  @override
  void paint(Canvas canvas, Size size) {
    var painter = stock_charts.PainterFlutter(canvas);
    for (var layer in layers) {
      painter.save();
      layer.onPaint(painter);
      painter.restore();
    }

    var rect = Offset.zero & size;
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = const Color(0xFFDCC48C);
    canvas.drawLine(cursor, rect.topLeft, paint);
    canvas.drawLine(cursor, rect.topRight, paint);
    canvas.drawLine(cursor, rect.bottomLeft, paint);
    canvas.drawLine(cursor, rect.bottomRight, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
