//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import '../../../../core/number_core.dart';
import 'exp_core.dart';

enum EnStockRely {
  None,
  VOLV, // 虚拟成交量
  NoAdj, // 依赖不复权数据
  UQStock, // （期权）依赖正股数据
}

typedef StockRelyData = Map<EnStockRely, NumberCore>;

class IndexFormula {
  String name = "";
  String expression = "";
  Map<String, int> params = {};
}

class IndexCore {
  List<ExpCore> exps = [];
  bool err = false;
  String errExpression = "";
  String errWord = "";
}

class StIndicator {
  IndexFormula formula = IndexFormula();
  IndexCore indexCore = IndexCore();
}
