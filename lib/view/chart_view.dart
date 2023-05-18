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
import '../viewmodel/chart_viewmodel.dart';

class ChartView extends StatefulWidget {
  final ChartViewModel vm;

  ChartView(this.vm, {super.key});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
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
        painter: MyPainter(widget.vm),
      ),
      onPointerDown: (PointerDownEvent event) => setState(() => _event = event),
      onPointerMove: (PointerMoveEvent event) => setState(() => _event = event),
      onPointerUp: (PointerUpEvent event) => setState(() => _event = event),
    );
  }
}

class MyPainter extends CustomPainter {
  final ChartViewModel vm;
  MyPainter(this.vm);
  Offset cursor = Offset(0, 0);

  @override
  void paint(Canvas canvas, Size size) {
    final painter = stock_charts.PainterFlutter(canvas);
    vm.onPaint(painter);

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
