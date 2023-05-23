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

typedef F = Tuple2<bool, NumberCore> Function(List<NumberCore>);

class FunctionParser extends SubParser {
  late Map<String, F> _binds;

  FunctionParser() {
    _binds = {
      "MA": MA,
      "EMA": EMA,
      "SMA": SMA,
      "LLV": LLV,
      "LOWEST": LLV,
      "HHV": HHV,
      "HIGHEST": HHV,
      "REF": REF,
      "REFX": REFX,
      "STD": STD,
      "STDP": STDP,
      "MAX": processMAX,
      "MIN": processMIN,
      "ABS": processABS,
      "SUM": processSUM,
      "BARSLASTCOUNT": BARSLASTCOUNT,
      "BETWEEN": BETWEEN,
      "BACKSET": BACKSET,
    };
  }

  bool check(String name) {
    return _binds.containsKey(name);
  }

  Tuple2<bool, NumberCore> process(String name, List<NumberCore> inputs) {
    F? f = _binds[name];
    if (f != null) return f(inputs);
    return emptyRet();
  }

  static Tuple2<bool, NumberCore> emptyRet([bool ok = false]) {
    return Tuple2(ok, NumberCore());
  }

  Tuple2<bool, NumberCore> MA(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    if (period <= 1) {
      buffer = price;
    } else if (rates_total - begin < period) {
      //
    } else {
      int start_position;
      if (prev_calculated == 0) {
        start_position = period + begin;

        for (int i = 0; i < start_position - 1; i++) buffer[i] = NumberNull;

        Number first_value = 0;
        for (int i = begin; i < start_position; i++) first_value += price[i];

        buffer[start_position - 1] = first_value / period;
      } else {
        start_position = prev_calculated - 1;
      }

      for (int i = start_position; i < rates_total; i++)
        buffer[i] = buffer[i - 1] + (price[i] - price[i - period]) / period;
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> EMA(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    if (period <= 1) {
      buffer = price;
    } else if (rates_total - begin < period) {
      //
    } else {
      int i, limit;
      Number dSmoothFactor = 2.0 / (1.0 + period);
      if (prev_calculated == 0) {
        limit = period + begin;

        for (i = 0; i < begin; i++) buffer[i] = 0.0;

        buffer[begin] = price[begin];
        for (i = begin + 1; i < limit; i++)
          buffer[i] =
              price[i] * dSmoothFactor + buffer[i - 1] * (1.0 - dSmoothFactor);
      } else
        limit = prev_calculated - 1;

      for (i = limit; i < rates_total; i++)
        buffer[i] =
            price[i] * dSmoothFactor + buffer[i - 1] * (1.0 - dSmoothFactor);
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> SMA(List<NumberCore> inputs) {
    if (inputs.length != 3) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();
    int M = inputs[2].safeAt(0).toInt();

    if (price.empty() || period < 0 || M < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    Number Ypre = 0.0;
    Number Y = 0.0;
    Number N = period.toDouble();
    int nStar = 0;
    for (int idx = nStar; idx < rates_total; idx++) {
      if (nStar == idx) {
        Y = price[nStar];
        if (Y == NumberNull) Y = 0.0;
        Ypre = Y;
        buffer[idx] = Y;
        continue;
      }
      Y = (price[idx] * M + Ypre * (N - M)) / N;
      Ypre = Y;
      buffer[idx] = Y;
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> LLV(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    Number LLV_Func(NumberCore price, int pos, int period) {
      int sz = price.size();
      Number ret = price[pos];
      for (int i = 0; i < period; ++i) {
        int idx = pos - i;
        if (idx >= 0 && idx < sz)
          ret = NumberCore.getMinNumber(price[idx], ret);
      }
      return ret;
    }

    if (period <= 1) {
      buffer = price;
    } else {
      for (int i = 0; i < rates_total; ++i)
        buffer[i] = LLV_Func(price, i, period);
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> HHV(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    Number HHV_Func(NumberCore price, int pos, int period) {
      int sz = price.size();
      Number ret = price.safeAt(pos);
      for (int i = 0; i < period; ++i) {
        int idx = pos - i;
        if (idx >= 0 && idx < sz)
          ret = NumberCore.getMaxNumber(price[idx], ret);
      }
      return ret;
    }

    ;

    if (period <= 1) {
      buffer = price;
    } else {
      for (int i = 0; i < rates_total; ++i)
        buffer[i] = HHV_Func(price, i, period);
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> REF(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    if (period < 1) {
      buffer = price;
    } else {
      Number val = price.safeAt(0);
      for (int i = 0; i < rates_total; ++i) {
        int offset = i - period;
        if (offset >= 0 && offset < rates_total) val = price[offset];
        buffer[i] = val;
      }
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> REFX(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    if (period < 1) {
      buffer = price;
    } else {
      Number val = price.safeAt(0);
      for (int i = 0; i < rates_total; ++i) {
        int offset = i + period;
        if (offset >= 0 && offset < rates_total) val = price[offset];
        buffer[i] = val;
      }
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> STD(List<NumberCore> inputs) {
    // zxf todo
    return STDP(inputs);
  }

  Tuple2<bool, NumberCore> STDP(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    Number StdDev_Func(
        int position, NumberCore price, NumberCore ma_price, int period) {
      Number std_dev = 0.0;
      if (position >= period - 1) {
        for (int i = 0; i < period; i++)
          std_dev += pow(price[position - i] - ma_price[position], 2.0);
        std_dev = sqrt(std_dev / period);
      }
      return (std_dev);
    }

    ;

    if (period <= 1) {
      buffer = price;
    } else {
      var tuple2 = MA([price, NumberCore.fromValue(period.toDouble())]);
      bool ok = tuple2.item1;
      NumberCore MAprice = tuple2.item2;
      if (!ok) return emptyRet();

      for (int i = 0; i < rates_total; ++i)
        buffer[i] = StdDev_Func(i, price, MAprice, period);
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> processMAX(List<NumberCore> inputs) {
    if (inputs.length < 2) return emptyRet();

    NumberCore buffer = inputs[0];
    for (int i = 1; i < inputs.length; ++i) {
      buffer.max(inputs[i]);
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> processMIN(List<NumberCore> inputs) {
    if (inputs.length < 2) return emptyRet();

    NumberCore buffer = inputs[0];
    for (int i = 1; i < inputs.length; ++i) {
      buffer.min(inputs[i]);
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> processABS(List<NumberCore> inputs) {
    if (inputs.length != 1) return emptyRet();

    NumberCore buffer = inputs[0];
    for (int i = 0; i < buffer.size(); ++i) {
      Number d = buffer[i];

      if (d != NumberNull) buffer[i] = (d).abs();
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> processSUM(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore price = inputs[0];
    int period = inputs[1].safeAt(0).toInt();

    if (price.empty() || period < 0) return emptyRet(true);

    int rates_total = price.size();
    int prev_calculated = 0;
    int begin = 0;
    var buffer = NumberCore.withCount(rates_total);

    if (period < 1) {
      buffer = price;
    } else {
      for (int i = 0; i < rates_total; ++i) {
        Number val = 0.0;
        for (int j = 0; j < period; ++j) {
          int offset = i - j;
          if (offset >= 0 && offset < rates_total) val += price[offset];
        }
        buffer[i] = val;
      }
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> BARSLASTCOUNT(List<NumberCore> inputs) {
    if (inputs.length != 1) return emptyRet();

    NumberCore core = inputs[0];

    int rates_total = core.size();
    var buffer = NumberCore.withCount(rates_total, 0.0);

    int count = 0;
    for (int i = 0; i < rates_total; ++i) {
      if (core[i] != 0)
        buffer[i] = (++count).toDouble();
      else
        count = 0;
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> BETWEEN(List<NumberCore> inputs) {
    if (inputs.length != 3) return emptyRet();

    NumberCore core = inputs[0];
    Number min = inputs[1].safeAt(0);
    Number max = inputs[2].safeAt(0);

    int rates_total = core.size();
    var buffer = NumberCore.withCount(rates_total, 0.0);

    for (int i = 0; i < rates_total; ++i) {
      if (core[i] >= min && core[i] <= max) buffer[i] = 1.0;
    }
    return Tuple2(true, buffer);
  }

  Tuple2<bool, NumberCore> BACKSET(List<NumberCore> inputs) {
    if (inputs.length != 2) return emptyRet();

    NumberCore core = inputs[0];
    int val = inputs[1].safeAt(0).toInt();

    int rates_total = core.size();
    var buffer = NumberCore.withCount(rates_total, 0.0);

    for (int i = 0; i < rates_total; ++i) {
      if (core[i] != 0) {
        for (int j = 0; j < val; ++j) buffer[i - j] = 1.0;
      }
    }
    return Tuple2(true, buffer);
  }
}
