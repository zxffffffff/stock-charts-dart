//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'number_core.dart';

class StockCore {
  NumberCore open = NumberCore();
  NumberCore high = NumberCore();
  NumberCore low = NumberCore();
  NumberCore close = NumberCore();
  NumberCore vol = NumberCore();
  NumberCore amount = NumberCore();
  NumberCore timestamp = NumberCore();

  void reset(StockCore rhs) {
    open = rhs.open;
    high = rhs.high;
    low = rhs.low;
    close = rhs.close;
    vol = rhs.vol;
    amount = rhs.amount;
    timestamp = rhs.timestamp;
  }

  StockCore reverse() {
    open.reverse();
    high.reverse();
    low.reverse();
    close.reverse();
    vol.reverse();
    amount.reverse();
    timestamp.reverse();
    return this;
  }

  int getSize() {
    return close.size();
  }

  Pair<Number, Number> getMinMax(int beginIndex, int endIndex) {
    var minmax = high.getMinMax(beginIndex, endIndex);
    var minmax2 = low.getMinMax(beginIndex, endIndex);
    return Pair<Number, Number>(NumberCore.min(minmax.first, minmax2.first),
        NumberCore.max(minmax.second, minmax2.second));
  }
}
