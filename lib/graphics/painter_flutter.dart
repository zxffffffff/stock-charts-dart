//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'graphics.dart' as stock_charts;
import 'painter.dart' as stock_charts;

Color parseColor(stock_charts.Color color) {
  return Color.fromARGB(color.a, color.r, color.g, color.b);
}

// todo：flutter 原生不支持虚线
Paint parse(stock_charts.Pen pen) {
  Paint paint = Paint()
    ..color = parseColor(pen.color)
    ..strokeWidth = pen.lineWidth;
  return paint;
}

class PainterFlutter extends stock_charts.Painter {
  Canvas canvas;
  PainterFlutter(this.canvas);

  @override
  void save() {
    canvas.save();
  }

  @override
  void restore() {
    canvas.restore();
  }

  @override
  void drawString(stock_charts.Rect rect, String text, stock_charts.Font font) {
    TextAlign align;
    switch (font.dir) {
      case stock_charts.PaintDirection.TopLeft:
      case stock_charts.PaintDirection.CenterLeft:
      case stock_charts.PaintDirection.BottomLeft:
        align = TextAlign.left;
        break;
      case stock_charts.PaintDirection.TopCenter:
      case stock_charts.PaintDirection.Center:
      case stock_charts.PaintDirection.BottomCenter:
        align = TextAlign.center;
        break;
      case stock_charts.PaintDirection.TopRight:
      case stock_charts.PaintDirection.CenterRight:
      case stock_charts.PaintDirection.BottomRight:
        align = TextAlign.right;
        break;
    }
    // todo
    fillRect(rect, stock_charts.Pen(stock_charts.Color.fromHex("#FF000040")));
  }

  @override
  void drawRect(stock_charts.Rect rect, stock_charts.Pen pen) {
    canvas.drawRect(
        Rect.fromLTWH(rect.left(), rect.top(), rect.width(), rect.height()),
        parse(pen)..style = PaintingStyle.stroke);
  }

  @override
  void fillRect(stock_charts.Rect rect, stock_charts.Pen pen) {
    canvas.drawRect(
        Rect.fromLTWH(rect.left(), rect.top(), rect.width(), rect.height()),
        parse(pen)..style = PaintingStyle.fill);
  }

  @override
  void drawLine(stock_charts.Line line, stock_charts.Pen pen) {
    canvas.drawLine(
        Offset(line.first.x, line.first.y),
        Offset(line.second.x, line.second.y),
        parse(pen)..style = PaintingStyle.stroke);
  }

  @override
  void drawPath(List<stock_charts.Point> points, stock_charts.Pen pen) {
    var path = Path();
    path.moveTo(points.first.x, points.first.y);
    for (int i = 1; i < points.length; ++i) {
      path.lineTo(points[i].x, points[i].y);
    }
    canvas.drawPath(path, parse(pen));
  }

  @override
  void drawStick(List<stock_charts.Stick> sticks, stock_charts.Color rise,
      stock_charts.Color fall) {
    for (var stick in sticks) {
      var pen = stock_charts.Pen(stick.flag >= 0 ? rise : fall);
      fillRect(stick.rect, pen);
      drawLine(stick.line, pen);
    }
  }

  @override
  void drawStickHollow(List<stock_charts.Stick> sticks, stock_charts.Color rise,
      stock_charts.Color fall) {}

  @override
  void drawBAR(List<stock_charts.Stick> sticks, stock_charts.Color rise,
      stock_charts.Color fall) {}
}
