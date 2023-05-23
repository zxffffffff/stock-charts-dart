//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'dart:math';

import '../core/data_binding.dart';
import '../core/number_core.dart';
import '../graphics/graphics.dart' as stock_charts;
import '../graphics/graphics.dart';
import '../graphics/painter.dart';
import '../model/chart_model.dart';
import '../model/chart_plugin.dart';
import 'chart_context.dart';
import 'chart_coordinate.dart';
import 'chart_layer.dart';
import 'chart_props.dart';

const String ID_ChartContextChanged = "ID_ChartContextChanged";
const String ID_OnResize = "ID_OnResize";
const String ID_OnMouseMove = "ID_OnMouseMove";
const String ID_OnMouseLeave = "ID_OnMouseLeave";
const String ID_OnScrollX = "ID_OnScrollX";
const String ID_OnWheelY = "ID_OnWheelY";
const String ID_OnDBClick = "ID_OnDBClick";

class ChartViewModel with DataBinding {
  // [0]
  final ChartModel _model;

  // [1]
  final ChartProps _props = ChartProps();
  final ChartContext _context = ChartContext();
  final List<ChartLayer> _layers = [];

  ChartViewModel(this._model) {
    listen(_model);
  }

  @override
  void on(DataBinding sender, String id) {
    if (_model == sender) {
      if (id == ID_StockCoreChanged || id == ID_ChartPluginChanged) {
        calcContext();
      }
      return;
    }

    for (var layer in _layers) {
      if (layer == sender) {
        if (id == ID_ChartLayerChanged) {
          calcContext();
        }
        return;
      }
    }

    {
      ChartViewModel other = sender as ChartViewModel;
      var ctx = other.context;

      if (id == ID_OnMouseMove || id == ID_OnMouseLeave) {
        syncMouseMove(ctx.hoverNormal.index, ctx.hoverNormal.price);
      } else if (id == ID_OnScrollX || id == ID_OnWheelY) {
        syncViewCount(ctx.viewCount, ctx.beginIndex, ctx.endIndex,
            ctx.nodeWidth, ctx.stickWidth);
      } else if (id == ID_OnDBClick) {
        syncDBClick(ctx.crossLineVisible);
      }
    }
  }

  ChartProps get props => _props;

  set props(ChartProps props) {
    props = _props;
    calcContext();
  }

  ChartContext get context => _context;

  void addLayer(ChartLayer layer) {
    _layers.add(layer);
    listen(layer);
    layer.init(_model, _props, _context);
  }

  ChartLayer? getLayer(Type layerType) {
    for (var layer in _layers) {
      // RTTI
      if (layer.runtimeType == layerType) {
        return layer;
      }
    }
    return null;
  }

  List<ChartLayer> getLayers() {
    return _layers;
  }

  // [2]
  void calcContext() {
    var stockCore = _model.stockCore;

    // [0] content
    _context.rectXAxis.set(
        _context.rectView.left() + _props.ylAxisWidth,
        _context.rectView.bottom() - _props.xAxisHeight,
        _context.rectView.width() - _props.ylAxisWidth - _props.yrAxisWidth,
        _props.xAxisHeight);
    _context.rectYLAxis.set(_context.rectView.left(), _context.rectView.top(),
        _props.ylAxisWidth, _context.rectView.height());
    _context.rectYRAxis.set(
        _context.rectView.right() - _props.yrAxisWidth,
        _context.rectView.top(),
        _props.yrAxisWidth,
        _context.rectView.height());
    _context.rectChart.set(
        _context.rectView.left() + _props.ylAxisWidth,
        _context.rectView.top(),
        _context.rectView.width() - _props.ylAxisWidth - _props.yrAxisWidth,
        _context.rectView.height() - _props.xAxisHeight);
    _context.rectInnerChart.set(
        _context.rectChart.left() + _props.paddingLeft,
        _context.rectChart.top() + _props.paddingTop,
        _context.rectChart.width() - _props.paddingLeft - _props.paddingRight,
        _context.rectChart.height() - _props.paddingTop - _props.paddingBottom);

    // invalid size
    if (!_context.rectInnerChart.valid()) {
      // assert(false);
      return;
    }

    // [1] x
    int stockCnt = stockCore.getSize();
    stock_charts.Real stockWidth = stockCnt * _context.nodeWidth;
    stock_charts.Real viewWidth = _context.rectInnerChart.width();
    switch (_props.xCoordType) {
      case EnXCoordinateType.Fill:
        _context.nodeWidth = viewWidth / (stockCnt + 1);
        _context.viewCount = stockCnt;
        _context.endIndex = stockCnt;
        _context.beginIndex = 0;
        break;
      case EnXCoordinateType.Cover:
      default:
        if (stockWidth <= viewWidth) {
          if (_context.viewCount != stockCnt) {
            _context.viewCount = stockCnt;
            _context.endIndex = stockCnt;
            _context.beginIndex = 0;
          }
        } else {
          int viewCount = (viewWidth / _context.nodeWidth).floor();
          if (_context.viewCount != viewCount) {
            _context.viewCount = viewCount;
            _context.endIndex = stockCnt;
            _context.beginIndex = _context.endIndex - _context.viewCount;
          }
        }
        break;
    }
    assert(_context.viewCount >= 0);
    assert(_context.endIndex >= 0);
    assert(_context.beginIndex >= 0);
    assert(_context.beginIndex <= _context.endIndex);
    assert(_context.endIndex <= stockCnt);
    assert(_context.endIndex - _context.beginIndex <= _context.viewCount);

    // [2] y
    _context.minPrice = NumberNull;
    _context.maxPrice = NumberNull;
    for (var layer in _layers) {
      var minmax = layer.getMinMax(_model, _props, _context);
      _context.minPrice =
          NumberCore.getMinNumber(minmax.first, _context.minPrice);
      _context.maxPrice =
          NumberCore.getMaxNumber(minmax.second, _context.maxPrice);
    }

    for (var layer in _layers) {
      layer.onContextChanged(_model, _props, _context);
    }
    fire(ID_ChartContextChanged);
  }

  // [3]
  void onPaint(Painter painter) {
    for (var layer in _layers) {
      painter.save();
      layer.onPaint(_model, _props, _context, painter);
      painter.restore();
    }
  }

  void onResize(Rect rect) {
    var view = Rect(
        rect.left() + _props.MarginLeft,
        rect.top() + _props.MarginTop,
        rect.width() - _props.MarginLeft - _props.MarginRight,
        rect.height() - _props.MarginTop - _props.MarginBottom);
    if (_context.rectView == view) return;
    _context.rectView = view;

    calcContext();
    fire(ID_OnResize);
  }

  void onMouseMove(Point point) {
    if (_context.hoverNormal.point == point) return;

    var coordinate = ChartCoordinate(_props, _context);

    // mouse event
    _context.hoverNormal.point = point;
    if (_context.rectInnerChart.contains(_context.hoverNormal.point)) {
      _context.hoverNormal.index = coordinate.pos2index(point.x);
      if (_context.hoverNormal.index > _context.endIndex - 1) {
        _context.hoverNormal.index = _context.endIndex - 1;
      }
      _context.hoverNormal.price = coordinate.pos2price(point.y);
    } else {
      _context.hoverNormal.point.clear();
      _context.hoverNormal.index = -1;
      _context.hoverNormal.price = NumberNull;
    }
    for (var layer in _layers) {
      layer.onMouseMove(_model, _props, _context);
    }
    fire(ID_OnMouseMove);
  }

  void onMouseLeave() {
    var coordinate = ChartCoordinate(_props, _context);

    // mouse event
    _context.hoverNormal.point.clear();
    _context.hoverNormal.index = -1;
    _context.hoverNormal.price = NumberNull;

    for (var layer in _layers) {
      layer.onMouseLeave(_model, _props, _context);
    }
    fire(ID_OnMouseLeave);
  }

  void onScrollX(int step) {
    if (step == 0) return;

    var stockCore = _model.stockCore;

    if (_props.xCoordType == EnXCoordinateType.Fill) return;

    // [1] x
    int stockCnt = stockCore.getSize();
    _context.beginIndex = min(
        max(0, _context.beginIndex + step * _props.scrollXStep), stockCnt - 1);
    _context.endIndex = min(_context.beginIndex + _context.viewCount, stockCnt);

    calcContext();
    fire(ID_OnScrollX);
  }

  void onWheelY(int step) {
    if (step == 0) {
      return;
    }

    var stockCore = _model.stockCore;

    if (_props.xCoordType == EnXCoordinateType.Fill) {
      return;
    }

    int stepWidth = 2 * (step).abs();
    int nodeWidth = (_context.nodeWidth + step * _props.wheelYStep).toInt();
    if (nodeWidth % 2 != 1) nodeWidth -= 1;
    _context.nodeWidth = (min(max((1), (nodeWidth)), (99))).toDouble();
    int stickWidth = (_context.nodeWidth * (0.75)).round();
    if (stickWidth % 2 != 1) stickWidth -= 1;
    _context.stickWidth = (min(max((1), (stickWidth)), (99))).toDouble();

    // [1] x
    int stockCnt = stockCore.getSize();
    Real stockWidth = stockCnt * _context.nodeWidth;
    Real viewWidth = _context.rectInnerChart.width();
    if (stockWidth <= viewWidth) {
      _context.viewCount = stockCnt;
      _context.endIndex = stockCnt;
      _context.beginIndex = _context.endIndex - _context.viewCount;
    } else {
      int viewCount = (viewWidth / _context.nodeWidth).floor();
      if (_context.hoverNormal.index < 0) {
        _context.viewCount = viewCount;
        _context.endIndex = stockCnt;
        _context.beginIndex = _context.endIndex - _context.viewCount;
      } else {
        double percent =
            (_context.hoverNormal.index - _context.beginIndex).toDouble() /
                _context.viewCount;
        _context.viewCount = viewCount;
        _context.beginIndex =
            _context.hoverNormal.index - (percent * viewCount).round();
        if (_context.beginIndex >= stockCnt) {
          _context.beginIndex = stockCnt - 1;
        }
        if (_context.beginIndex < 0) {
          _context.beginIndex = 0;
        }
        _context.endIndex =
            min(_context.beginIndex + _context.viewCount, stockCnt);
      }
    }

    calcContext();
    fire(ID_OnWheelY);
  }

  void onDBClick(Point point) {
    _context.crossLineVisible = !_context.crossLineVisible;

    calcContext();
    fire(ID_OnDBClick);
  }

  void setSyncOther(ChartViewModel other) {
    listen(other);
  }

  void syncViewCount(int viewCount, int beginIndex, int endIndex,
      Real nodeWidth, Real stickWidth) {
    if (_context.viewCount == viewCount &&
        _context.beginIndex == beginIndex &&
        _context.endIndex == endIndex &&
        _context.nodeWidth == nodeWidth &&
        _context.stickWidth == stickWidth) {
      return;
    }

    // [1] x
    _context.viewCount = viewCount;
    _context.beginIndex = beginIndex;
    _context.endIndex = endIndex;
    _context.nodeWidth = nodeWidth;
    _context.stickWidth = stickWidth;

    calcContext();
  }

  void syncMouseMove(int hoverIndex, Number hoverPrice) {
    if (_context.hoverSync.index == hoverIndex &&
        _context.hoverSync.price == hoverPrice) {
      return;
    }

    var coordinate = ChartCoordinate(_props, _context);

    // mouse event
    _context.hoverSync.point = Point(
        coordinate.index2pos(hoverIndex), coordinate.price2pos(hoverPrice));
    _context.hoverSync.index = hoverIndex;
    _context.hoverSync.price = hoverPrice;

    for (var layer in _layers) {
      layer.onMouseMove(_model, _props, _context);
    }
    fire(ID_ChartContextChanged);
  }

  void syncDBClick(bool crossLineVisible) {
    if (_context.crossLineVisible == crossLineVisible) {
      return;
    }
    _context.crossLineVisible = crossLineVisible;
    calcContext();
  }
}
