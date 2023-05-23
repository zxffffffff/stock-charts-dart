//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'dart:math';

import 'package:stock_charts/core/number_core.dart';
import 'package:stock_charts/model/Plugin/Indicator/Parser/sub_parser.dart';
import 'package:tuple/tuple.dart';

import '../Core/exp_core.dart';

typedef F = Tuple3<bool, ExpDrawingType, NumberCore> Function(List<NumberCore>);

class DrawingParser extends SubParser {
  late Map<String, F> _binds;

  DrawingParser() {
    _binds = {
      "DRAWNUMBER": number,
      "DRAWTEXT": text,
      "STICKLINE": stickLine,
    };
  }

  bool check(String name) {
    return _binds.containsKey(name);
  }

  Tuple3<bool, ExpDrawingType, NumberCore> process(
      String name, List<NumberCore> inputs) {
    F? f = _binds[name];
    if (f != null) return f(inputs);
    return emptyRet();
  }

  static Tuple3<bool, ExpDrawingType, NumberCore> emptyRet([bool ok = false]) {
    return Tuple3(ok, ExpDrawingType(), NumberCore());
  }

  Tuple3<bool, ExpDrawingType, NumberCore> number(List<NumberCore> inputs) {
    if (inputs.length != 3) return emptyRet();

    NumberCore cond = inputs[0];
    NumberCore price = inputs[1];
    NumberCore num = inputs[2];

    if (cond.empty() || price.empty() || num.empty()) return emptyRet(true);

    int rates_total = price.size();
    int num_total = num.size();
    var buffer = NumberCore.withCount(rates_total);

    for (int i = 0; i < rates_total; ++i) {
      Number b = cond.safeAt(i);
      if (b == 0.0 || b == NumberNull) continue;
      buffer[i] = price[i];

      Number n = (num_total == 1 ? num[0] : num.safeAt(i));
      buffer.setOther(i, n.toString());
    }

    var drawingType = ExpDrawingType();
    drawingType.type = EnDrawingType.Number;
    return Tuple3(true, drawingType, buffer);
  }

  Tuple3<bool, ExpDrawingType, NumberCore> text(List<NumberCore> inputs) {
    if (inputs.length != 3) return emptyRet();

    NumberCore cond = inputs[0];
    NumberCore price = inputs[1];
    NumberCore text = inputs[2];

    if (cond.empty() || price.empty() || text.empty()) return emptyRet(true);

    int rates_total = price.size();
    int text_total = text.size();
    var buffer = NumberCore.withCount(rates_total);

    var drawingType = ExpDrawingType();
    drawingType.type = EnDrawingType.Text;
    return Tuple3(true, drawingType, buffer);
  }

  Tuple3<bool, ExpDrawingType, NumberCore> stickLine(List<NumberCore> inputs) {
    if (inputs.length != 5) return emptyRet();

    NumberCore cond = inputs[0];
    NumberCore price = inputs[1];
    NumberCore price2 = inputs[2];
    Number width = inputs[3].safeAt(0);
    Number empty = inputs[4].safeAt(0);

    if (cond.empty() ||
        price.empty() ||
        price2.empty() ||
        width == NumberNull ||
        empty == NumberNull) return emptyRet(true);

    int rates_total = max(price.size(), price2.size());
    var buffer = NumberCore.withCount(rates_total);

    for (int i = 0; i < rates_total; ++i) {
      Number b = cond.safeAt(i);
      if (b == 0 || b == NumberNull) continue;
      buffer[i] = price.safeAt(i);
      buffer.setOther(i, price2[i].toString());
    }

    var drawingType = ExpDrawingType();
    drawingType.type = EnDrawingType.Candlestick;
    drawingType.stickWidth = width;
    drawingType.stickEmpty = empty;
    return Tuple3(true, drawingType, buffer);
  }
}
