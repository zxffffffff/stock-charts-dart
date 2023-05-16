//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'graphics.dart';

typedef Byte = int;

class Color {
  Byte r;
  Byte g;
  Byte b;
  Byte a;

  Color([
    this.r = 0,
    this.g = 255,
    this.b = 255,
    this.a = 255,
  ]);

  Color.fromHex(String hex)
      : r = 0,
        g = 255,
        b = 255,
        a = 255 {
    int len = hex.length;
    if ((len & 1) == 1 && hex[0] == '#') {
      hex = hex.substring(1);
      len--;
    }

    int _r, _g, _b, _a;
    if (len == 6) {
      _r = int.parse(hex.substring(0, 2), radix: 16);
      _g = int.parse(hex.substring(2, 4), radix: 16);
      _b = int.parse(hex.substring(4, 6), radix: 16);
      _a = 255;
    } else if (len == 8) {
      _r = int.parse(hex.substring(0, 2), radix: 16);
      _g = int.parse(hex.substring(2, 4), radix: 16);
      _b = int.parse(hex.substring(4, 6), radix: 16);
      _a = int.parse(hex.substring(6, 8), radix: 16);
    } else {
      // windows invalid color
      _r = 0;
      _g = _b = _a = 255;
    }
    r = _r;
    g = _g;
    b = _b;
    a = _a;
  }
}

final Color ColorWhite = Color(255, 255, 255);
final Color ColorBlack = Color(0, 0, 0);
final Color ColorGray = Color(160, 160, 164);
final Color ColorDarkGray = Color(128, 128, 128);
final Color ColorLightGray = Color(192, 192, 192);
final Color ColorTransparent = Color(0, 0, 0, 0);

enum LineType {
  SolidLine, // _____
  DashLine, // _ _ _
  DotLine, // . . .
  DashDotLine, // _ . _
}

class Pen {
  Color color;
  Real lineWidth;
  LineType lineType;

  Pen(this.color, [this.lineWidth = 1, this.lineType = LineType.SolidLine]);

  Pen.fromColor([Byte r = 0, Byte g = 255, Byte b = 255, Byte a = 255])
      : color = Color(r, g, b, a),
        lineWidth = 1,
        lineType = LineType.SolidLine;
}

enum PaintDirection {
  TopLeft,
  TopCenter,
  TopRight,
  CenterLeft,
  Center,
  CenterRight,
  BottomLeft,
  BottomCenter,
  BottomRight,
}

class Font {
  Color color;
  int fontSize;
  PaintDirection dir;

  Font(this.color, [this.fontSize = 12, this.dir = PaintDirection.Center]);
}

class Painter {
  void save() {}
  void restore() {}

  void drawString(Rect rect, String text, Font font) {}
  void drawRect(Rect rect, Pen pen) {}
  void fillRect(Rect rect, Pen pen) {}
  void drawLine(Line line, Pen pen) {}
  void drawPath(List<Point> points, Pen pen) {}

  void drawStick(List<Stick> sticks, Color rise, Color fall) {}
  void drawStickHollow(List<Stick> sticks, Color rise, Color fall) {}
  void drawBAR(List<Stick> sticks, Color rise, Color fall) {}
}
