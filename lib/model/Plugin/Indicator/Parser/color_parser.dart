//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:stock_charts/core/number_core.dart';
import 'package:stock_charts/model/Plugin/Indicator/Core/exp_core.dart';
import 'package:stock_charts/model/Plugin/Indicator/Parser/sub_parser.dart';
import 'package:tuple/tuple.dart';

typedef F = Tuple2<bool, ExpColorType> Function(String);

class ColorParser extends SubParser {
  late List<F> _binds;
  late Map<String, EnExpLineType> _types;
  late Map<String, EnExpLineThick> _thicks;
  late Map<String, String> _colors;

  ColorParser() {
    _binds = [
      colorType,
      lineThick,
      colorString,
    ];

    _types = {
      "DOTLINE": EnExpLineType.DOTLINE,
      "STICK": EnExpLineType.STICK,
      "COLORSTICK": EnExpLineType.COLORSTICK,
    };

    _thicks = {
      "LINETHICK1": EnExpLineThick.LINETHICK1,
      "LINETHICK2": EnExpLineThick.LINETHICK2,
      "LINETHICK3": EnExpLineThick.LINETHICK3,
      "LINETHICK4": EnExpLineThick.LINETHICK4,
      "LINETHICK5": EnExpLineThick.LINETHICK5,
      "LINETHICK6": EnExpLineThick.LINETHICK6,
      "LINETHICK7": EnExpLineThick.LINETHICK7,
      "LINETHICK8": EnExpLineThick.LINETHICK8,
      "LINETHICK9": EnExpLineThick.LINETHICK9,
    };

    _colors = {
      "COLORBLACK": "000000",
      "COLORWHITE": "FFFFFF",
      "COLORRED": "FF0000",
      "COLORGREEN": "00FF00",
      "COLORBLUE": "0000FF",
      "COLORGRAY": "808080",
      "COLORMAGENTA": "E04080",
      "COLORLICYAN": "2F4640",
    };
  }

  bool check(String name) {
    if (_types.containsKey(name)) return true;
    if (_thicks.containsKey(name)) return true;
    if (_colors.containsKey(name)) return true;
    if (checkCustomColor(name)) return true;
    return false;
  }

  Tuple2<bool, ExpColorType> process(String name) {
    bool ok = false;
    ExpColorType expColor;

    for (F f in _binds) {
      var tuple2 = f(name);
      bool ok = tuple2.item1;
      if (ok) return tuple2;
    }
    return emptyRet();
  }

  Tuple2<bool, ExpColorType> emptyRet([bool ok = false]) {
    return Tuple2(ok, ExpColorType());
  }

  bool checkCustomColor(String name) {
    // COLORE123456
    if (name.length != 11) return false;
    if (!name.startsWith("COLOR")) return false;
    for (int i = 5; i < 11; ++i) {
      var c = name[i].codeUnitAt(0);
      if (c >= '0'.codeUnitAt(0) && c <= '9'.codeUnitAt(0)) continue;
      if (c >= 'A'.codeUnitAt(0) && c <= 'F'.codeUnitAt(0)) continue;
      return false;
    }
    return true;
  }

  Tuple2<bool, ExpColorType> colorType(String name) {
    if (!_types.containsKey(name)) return emptyRet();

    var expColor = ExpColorType();
    expColor.type = _types[name]!;
    return Tuple2(true, expColor);
  }

  Tuple2<bool, ExpColorType> lineThick(String name) {
    if (!_thicks.containsKey(name)) return emptyRet();

    var expColor = ExpColorType();
    expColor.thick = _thicks[name]!;
    return Tuple2(true, expColor);
  }

  Tuple2<bool, ExpColorType> colorString(String name) {
    if (!_colors.containsKey(name)) {
      if (!checkCustomColor(name)) return emptyRet();

      var expColor = ExpColorType();
      expColor.color = name.substring(5);
      return Tuple2(true, expColor);
    }
    var expColor = ExpColorType();
    expColor.color = _colors[name]!;
    return Tuple2(true, expColor);
  }
}
