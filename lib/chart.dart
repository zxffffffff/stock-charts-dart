//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:flutter/material.dart';
import 'package:stock_charts/core/stock_core.dart';
import 'package:stock_charts/model/chart_model.dart';

import 'view/chart_view.dart';

class Chart extends StatefulWidget {
  const Chart({super.key});
  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartView(ChartModel(StockCore())),
        ChartView(ChartModel(StockCore())),
      ],
    );
  }
}
