//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:stock_charts/core/number_core.dart';
import 'package:stock_charts/model/Plugin/Indicator/Parser/sub_parser.dart';
import 'package:tuple/tuple.dart';
import '../Core/index_core.dart';

typedef F = Tuple2<bool, NumberCore> Function();

class KeywordParser extends SubParser {
  late Map<String, F> _binds;

  KeywordParser() {
    _binds = {
      "OPEN": OPEN,
      "O": OPEN,
      "HIGH": HIGH,
      "H": HIGH,
      "LOW": LOW,
      "L": LOW,
      "CLOSE": CLOSE,
      "C": CLOSE,
      "VOL": VOL,
      "V": VOL,
      "AMOUNT": VOL,
      "ISLASTBAR": ISLASTBAR,
      "VOLV": VOLV,
      "IV": IV,
    };
  }

  List<EnStockRely> stockRely(String name) {
    if (name == "VOLV") return [EnStockRely.VOLV];
    if (name == "IV") return [EnStockRely.NoAdj, EnStockRely.UQStock];
    return [];
  }

  bool check(String name) {
    return _binds.containsKey(name);
  }

  Tuple2<bool, NumberCore> process(String name) {
    F? f = _binds[name];
    if (f != null) return f();
    return emptyRet();
  }

  static Tuple2<bool, NumberCore> emptyRet([bool ok = false]) {
    return Tuple2(ok, NumberCore());
  }

  Tuple2<bool, NumberCore> OPEN() {
    return Tuple2(true, stockCore.open);
  }

  Tuple2<bool, NumberCore> HIGH() {
    return Tuple2(true, stockCore.high);
  }

  Tuple2<bool, NumberCore> LOW() {
    return Tuple2(true, stockCore.low);
  }

  Tuple2<bool, NumberCore> CLOSE() {
    return Tuple2(true, stockCore.close);
  }

  Tuple2<bool, NumberCore> VOL() {
    return Tuple2(true, stockCore.vol);
  }

  Tuple2<bool, NumberCore> ISLASTBAR() {
    int rates_total = stockCore.close.size();
    var buffer = NumberCore.withCount(rates_total, 0.0);
    buffer[rates_total - 1] = 1.0;
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> VOLV() {
    return Tuple2(true, stockExt[EnStockRely.VOLV] ?? NumberCore());
  }

  Tuple2<bool, NumberCore> IV() {
    return Tuple2(true, stockExt[EnStockRely.NoAdj] ?? NumberCore());
  }
}
