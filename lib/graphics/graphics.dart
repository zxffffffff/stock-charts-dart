//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

typedef Real = double;
const Real RealNull = -1.7976931348623158e+308;

class Point {
  Real x;
  Real y;

  Point([Real _x = RealNull, Real _y = RealNull])
      : x = _x,
        y = _y;

  Point set(Real _x, Real _y) {
    x = _x;
    y = _y;
    return this;
  }

  void clear() {
    x = RealNull;
    y = RealNull;
  }

  bool valid() {
    if (x.isNaN || x.isInfinite) return false;
    if (y.isNaN || y.isInfinite) return false;
    return (x != RealNull && y != RealNull);
  }
}

class Size {
  Real width;
  Real height;

  Size([Real _width = 0, Real _height = 0])
      : width = _width,
        height = _height;

  Size set(Real _width, Real _height) {
    width = _width;
    height = _height;
    return this;
  }

  void clear() {
    width = 0;
    height = 0;
  }

  bool valid() {
    return (width >= 0 && height >= 0);
  }
}

class Rect {
  Point point;
  Size size;

  Rect(
      [Real _x = RealNull,
      Real _y = RealNull,
      Real _width = 0,
      Real _height = 0])
      : point = Point(_x, _y),
        size = Size(_width, _height);

  Rect.fromPointAndSize(Point _point, Size _size)
      : point = _point,
        size = _size;

  Rect set(Real _x, Real _y, Real _width, Real _height) {
    point.x = _x;
    point.y = _y;
    size.width = _width;
    size.height = _height;
    return this;
  }

  void clear() {
    point.clear();
    size.clear();
  }

  Rect moveInside(Rect parent, {List<Real> padding = const [1, 1, 0, 0]}) {
    if (left() < parent.left() + padding[0]) {
      point.x = parent.left() + padding[0];
    }
    if (top() < parent.top() + padding[1]) {
      point.y = parent.top() + padding[1];
    }
    if (right() > parent.right() - padding[2]) {
      point.x = parent.right() - padding[2] - width();
    }
    if (bottom() > parent.bottom() - padding[3]) {
      point.y = parent.bottom() - padding[3] - height();
    }
    return this;
  }

  Rect clipInside(Rect parent, {List<Real> padding = const [0, 0, 0, 0]}) {
    Real offset_l = (parent.left() + padding[0]) - left();
    if (offset_l > 0) {
      point.x -= offset_l;
      size.width -= offset_l;
    }
    Real offset_t = (parent.top() + padding[1]) - top();
    if (offset_t > 0) {
      point.y -= offset_t;
      size.height -= offset_t;
    }
    Real offset_r = right() - (parent.right() - padding[2]);
    if (offset_r > 0) size.width -= offset_r;
    Real offset_b = bottom() - (parent.bottom() - padding[3]);
    if (offset_b > 0) size.height -= offset_b;

    if (!valid()) clear();
    return this;
  }

  bool valid() {
    return (point.valid() && size.valid());
  }

  bool contains(Point point) {
    if (!valid() || !point.valid()) return false;
    return (point.x >= left() &&
        point.x < right() &&
        point.y >= top() &&
        point.y < bottom());
  }

  Real left() {
    return point.x;
  }

  Real right() {
    return point.x + size.width;
  }

  Real top() {
    return point.y;
  }

  Real bottom() {
    return point.y + size.height;
  }

  Real width() {
    return size.width;
  }

  Real height() {
    return size.height;
  }

  Real centerX() {
    return left() + width() / 2;
  }

  Real centerY() {
    return top() + height() / 2;
  }

  Point center() {
    return Point(centerX(), centerY());
  }

  Point topLeft() {
    return Point(left(), top());
  }

  Point topRight() {
    return Point(right(), top());
  }

  Point bottomLeft() {
    return Point(left(), bottom());
  }

  Point bottomRight() {
    return Point(right(), bottom());
  }
}

class Line {
  Point first;
  Point second;

  Line(
      [Real _x1 = RealNull,
      Real _y1 = RealNull,
      Real _x2 = RealNull,
      Real _y2 = RealNull])
      : first = Point(_x1, _y1),
        second = Point(_x2, _y2);

  Line.fromPoints(Point _point1, Point _point2)
      : first = _point1,
        second = _point2;

  Line set(Real _x1, Real _y1, Real _x2, Real _y2) {
    first.x = _x1;
    first.y = _y1;
    second.x = _x2;
    second.y = _y2;
    return this;
  }

  void clear() {
    first.clear();
    second.clear();
  }

  bool valid() {
    return (first.valid() && second.valid());
  }
}

class Stick {
  Rect rect;
  Line line;
  int flag;

  Stick([
    Real _x = RealNull,
    Real _y = RealNull,
    Real _width = 0,
    Real _height = 0,
    Real _high = RealNull,
    Real _low = RealNull,
    int _flag = 0,
  ])  : rect = Rect(_x, _y, _width, _height),
        line = Line(_x + _width / 2, _high, _x + _width / 2, _low),
        flag = _flag;

  Stick.fromRectAndLine(Rect _rect, Line _line, [int _flag = 0])
      : rect = _rect,
        line = _line,
        flag = _flag;

  Stick set(Real _x, Real _y, Real _width, Real _height, Real _high, Real _low,
      int _flag) {
    rect.set(_x, _y, _width, _height);
    line.set(rect.centerX(), _high, rect.centerX(), _low);
    flag = _flag;
    return this;
  }

  void clear() {
    rect.clear();
    line.clear();
    flag = 0;
  }

  bool valid() {
    return (rect.valid() && line.valid());
  }

  Real left() {
    return rect.left();
  }

  Real right() {
    return rect.right();
  }

  Real top() {
    return rect.top();
  }

  Real bottom() {
    return rect.bottom();
  }

  Real width() {
    return rect.width();
  }

  Real height() {
    return rect.height();
  }

  Real high() {
    return line.first.y;
  }

  Real low() {
    return line.second.y;
  }

  Real height2() {
    return low() - high();
  }

  Real centerX() {
    return left() + width() / 2;
  }

  Real centerY() {
    return high() + height2() / 2;
  }

  Point center() {
    return Point(centerX(), centerY());
  }
}
