//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:flutter/material.dart';

import '../model/chart_model.dart';
import 'chart_context.dart';
import 'chart_layer.dart';
import 'chart_props.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key});
  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  // [0]
  ChartModel m_model = ChartModel();
  ChartProps m_props = ChartProps();
  ChartContext m_context = ChartContext();

  // [1]
  List<ChartLayer> m_layers = [];

  PointerEvent? _event;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: CustomPaint(
        size: const Size(400, 300),
        painter: MyPainter(
            _event != null ? _event!.localPosition : const Offset(100, 100)),
      ),
      onPointerDown: (PointerDownEvent event) => setState(() => _event = event),
      onPointerMove: (PointerMoveEvent event) => setState(() => _event = event),
      onPointerUp: (PointerUpEvent event) => setState(() => _event = event),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.cursor);
  Offset cursor;

  @override
  void paint(Canvas canvas, Size size) {
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
