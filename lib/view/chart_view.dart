//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:flutter/material.dart';
import 'package:stock_charts/core/data_binding.dart';
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

class _ChartViewState extends State<ChartView> with DataBinding {
  bool _isLongPress = false;

  @override
  void initState() {
    super.initState();
    listen(widget.vm);
  }

  @override
  dispose() {
    unlisten(widget.vm);
    super.dispose();
  }

  void update() {
    if (!mounted) return;
    setState(() {});
  }

  void syncSubChart(ChartView otherChart) {
    widget.vm.setSyncOther(otherChart.vm);
  }

  @override
  void on(DataBinding sender, String id) {
    if (sender == widget.vm) {
      fire(id);
      Future.delayed(const Duration(milliseconds: 50), () {
        update();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var size = constraints.biggest;
      widget.vm.onResize(stock_charts.Rect(0, 0, size.width, size.height));

      return GestureDetector(
        onLongPress: () {
          _isLongPress = true;
        },
        onLongPressUp: () {
          _isLongPress = false;
        },
        onPanUpdate: (details) {
          if (_isLongPress) {
            widget.vm.onMouseMove(stock_charts.Point(
                details.localPosition.dx, details.localPosition.dy));
          } else {
            widget.vm.onMouseLeave();
            widget.vm.onScrollX(-details.delta.dx.round());
          }
        },
        onVerticalDragUpdate: (details) {
          widget.vm.onWheelY(details.delta.dy.round());
        },
        child: CustomPaint(
          painter: MyPainter(widget.vm),
          size: size,
        ),
      );
    }));
  }
}

class MyPainter extends CustomPainter {
  final ChartViewModel vm;
  MyPainter(this.vm);

  @override
  void paint(Canvas canvas, Size size) {
    final painter = stock_charts.PainterFlutter(canvas);
    vm.onPaint(painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
