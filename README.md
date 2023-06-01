# stock-charts-dart
基于 Dart 实现股票图表和技术指标，提供 Flutter Demo。
- 基于 Dart Package 可直接引入，遵循MVVM设计模式，方便阅读和修改。
- 指标（Model/Plugin/Indicator）模仿富途牛牛实现，可定制开发。
- 抽象绘图 (Graphics/Painter) 支持 Flutter 框架和鼠标/键盘交互。

## 使用(Usage)
```dart
// stock
final StockCore stockCore = Candlestick();

// model
var model = ChartModel(stockCore);
model.addPlugin(PluginIndicator());

// viewmodel
var vm = ChartViewModel(model);
vm.addLayer(LayerBG());
vm.addLayer(LayerStock());
vm.addLayer(LayerIndicator());

// view(Flutter)
var view = ChartView(vm);
```

## 作者说明
- 精力有限，偶尔维护，有需要可以联系我答疑解惑（zxffffffff@outlook.com, 1337328542@qq.com）。
- `star >= 100` 可以考虑更新绘图、叠加、复权等功能。
- C++（Qt）原始版本：https://github.com/zxffffffff/stock-charts-cpp.git

## 参数控制
![image](https://github.com/zxffffffff/stock-charts-cpp/blob/main/doc/stock-chart-0.png)

## 指标管理（模仿富途牛牛）
![image](https://github.com/zxffffffff/stock-charts-cpp/blob/main/doc/stock-chart-1.png)

## 目录结构
![image](https://github.com/zxffffffff/stock-charts-cpp/blob/main/doc/stock-chart-src.png)

## 架构图
![image](https://github.com/zxffffffff/stock-charts-cpp/blob/main/doc/architecture.png)
