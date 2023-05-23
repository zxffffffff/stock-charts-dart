//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'dart:math' as math;

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

typedef Number = double;
const Number NumberNull = -1.7976931348623158e+308;

typedef OperatorCompare = Number Function(Number l, Number r);

class NumberCore {
  List<Number> data; // growable: true
  List<String> other; // growable: true

  NumberCore([List<Number> data = const [], List<String> other = const []])
      : data = List<Number>.from(data),
        other = List<String>.from(other);

  NumberCore.copy(NumberCore rhs)
      : data = List<Number>.from(rhs.data),
        other = List<String>.from(rhs.other);

  NumberCore.fromValue(Number val)
      : data = List<Number>.from([val]),
        other = List<String>.from([]);

  NumberCore.withCount(int cnt, [Number val = NumberNull])
      : data = List<Number>.filled(cnt, val, growable: true),
        other = List<String>.from([]);

  bool empty() {
    return data.isEmpty;
  }

  int size() {
    return data.length;
  }

  void resize(int cnt, [Number val = NumberNull]) {
    if (cnt < data.length) {
      data.removeRange(cnt, data.length);
    } else if (cnt > data.length) {
      data.addAll(List.filled(cnt - data.length, val));
    }
  }

  void clear() {
    data.clear();
    other.clear();
  }

  Number at(int i) {
    return data[i];
  }

  Number safeAt(int i) {
    if (i < 0 || i >= data.length) {
      return NumberNull;
    }
    return data[i];
  }

  Number front() {
    return data.first;
  }

  Number back() {
    return data.last;
  }

  void fillBegin(int count, Number newVal) {
    fill(0, count, newVal);
  }

  void fillEnd(int count, Number newVal) {
    fill(size() - count, count, newVal);
  }

  void fill(int begin, int count, Number newVal) {
    int sz = data.length;
    for (int i = 0; i < count; i++) {
      int pos = begin + i;
      if (pos >= 0 && pos < sz) {
        data[pos] = newVal;
      }
    }
  }

  void replace(Number oldVal, Number newVal) {
    if (oldVal == newVal) return;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == oldVal) {
        data[i] = newVal;
      }
    }
  }

  void replaceNotNumber(Number newVal) {
    for (int i = 0; i < data.length; i++) {
      if (data[i].isNaN || data[i].isInfinite) {
        data[i] = newVal;
      }
    }
  }

  void replaceEmptyValue(Number newVal) {
    replace(NumberNull, newVal);
  }

  void swap(NumberCore rhs) {
    List<Number> tempData = data;
    List<String> tempOther = other;
    data = rhs.data;
    other = rhs.other;
    rhs.data = tempData;
    rhs.other = tempOther;
  }

  void reverse() {
    data = data.reversed.toList();
    other = other.reversed.toList();
  }

  Pair<Number, Number> getMinMax(int beginIndex, int endIndex) {
    int len = size();
    if (len == 0 ||
        beginIndex < 0 ||
        endIndex < 0 ||
        beginIndex >= len ||
        endIndex > len) {
      return Pair(NumberNull, NumberNull);
    }
    Number min = data[beginIndex];
    Number max = min;
    for (int i = beginIndex + 1; i < endIndex; i += 1) {
      Number n = data[i];
      min = NumberCore.getMinNumber(min, n);
      max = NumberCore.getMaxNumber(max, n);
    }
    return Pair(min, max);
  }

  static Number getMaxNumber(Number lhs, Number rhs) {
    if (lhs == NumberNull) {
      return rhs;
    } else if (rhs == NumberNull) {
      return lhs;
    }
    if (lhs > rhs) {
      return lhs;
    }
    return rhs;
  }

  static Number getMinNumber(Number lhs, Number rhs) {
    if (lhs == NumberNull) {
      return rhs;
    } else if (rhs == NumberNull) {
      return lhs;
    }
    if (lhs < rhs) {
      return lhs;
    }
    return rhs;
  }

  static Number abs(Number val) {
    if (val == NumberNull) return val;
    if (val < 0) return -val;
    return val;
  }

  NumberCore max(NumberCore rhs) {
    comp(Number l, Number r) => NumberCore.getMaxNumber(l, r);
    data = operatorFunc(this, rhs, comp).data;
    return this;
  }

  NumberCore min(NumberCore rhs) {
    comp(Number l, Number r) => NumberCore.getMinNumber(l, r);
    data = operatorFunc(this, rhs, comp).data;
    return this;
  }

  static NumberCore operatorMax(NumberCore lhs, NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => NumberCore.getMaxNumber(l, r);
    result.data = operatorFunc(lhs, rhs, comp).data;
    return result;
  }

  static NumberCore operatorMin(NumberCore lhs, NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => NumberCore.getMinNumber(l, r);
    result.data = operatorFunc(lhs, rhs, comp).data;
    return result;
  }

  static NumberCore getMax(NumberCore lhs, NumberCore rhs) {
    int lCnt = lhs.size();
    int rCnt = rhs.size();
    int maxCnt = math.max(lCnt, rCnt);

    if (lCnt == 0) {
      return rhs;
    } else if (rCnt == 0) {
      return lhs;
    } else if (lCnt == 1 && rCnt > 1) {
      NumberCore buffer = NumberCore.withCount(maxCnt);
      for (int i = 0; i < maxCnt; ++i) {
        buffer[i] = NumberCore.getMaxNumber(lhs[0], rhs[i]);
      }
      return buffer;
    } else if (lCnt > 1 && rCnt == 1) {
      NumberCore buffer = NumberCore.withCount(maxCnt);
      for (int i = 0; i < maxCnt; ++i) {
        buffer[i] = NumberCore.getMaxNumber(lhs[i], rhs[0]);
      }
      return buffer;
    } else {
      NumberCore buffer = NumberCore.withCount(maxCnt);
      for (int i = 0; i < maxCnt; ++i) {
        if (i < lCnt && i < rCnt) {
          buffer[i] = NumberCore.getMaxNumber(lhs[i], rhs[i]);
        }
      }
      return buffer;
    }
  }

  static NumberCore getMin(NumberCore lhs, NumberCore rhs) {
    int lCnt = lhs.size();
    int rCnt = rhs.size();
    int maxCnt = math.max(lCnt, rCnt);

    if (lCnt == 0) {
      return rhs;
    } else if (rCnt == 0) {
      return lhs;
    } else if (lCnt == 1 && rCnt > 1) {
      NumberCore buffer = NumberCore.withCount(maxCnt);
      for (int i = 0; i < maxCnt; ++i) {
        buffer[i] = NumberCore.getMinNumber(lhs[0], rhs[i]);
      }
      return buffer;
    } else if (lCnt > 1 && rCnt == 1) {
      NumberCore buffer = NumberCore.withCount(maxCnt);
      for (int i = 0; i < maxCnt; ++i) {
        buffer[i] = NumberCore.getMinNumber(lhs[i], rhs[0]);
      }
      return buffer;
    } else {
      NumberCore buffer = NumberCore.withCount(maxCnt);
      for (int i = 0; i < maxCnt; ++i) {
        if (i < lCnt && i < rCnt) {
          buffer[i] = NumberCore.getMinNumber(lhs[i], rhs[i]);
        }
      }
      return buffer;
    }
  }

  static NumberCore operatorFunc(
      NumberCore lhs, NumberCore rhs, OperatorCompare comp) {
    int lCnt = lhs.size();
    int rCnt = rhs.size();
    int maxCnt = math.max(lCnt, rCnt);
    Number l = NumberNull;
    Number r = NumberNull;

    NumberCore buffer = NumberCore.withCount(maxCnt);
    if (lCnt == 0) {
      return rhs;
    } else if (rCnt == 0) {
      return lhs;
    } else if (lCnt == 1 && rCnt > 1) {
      l = lhs[0];
      for (int i = 0; i < maxCnt; ++i) {
        r = rhs[i];
        if (l != NumberNull && r != NumberNull) {
          buffer[i] = comp(l, r);
        }
      }
    } else if (lCnt > 1 && rCnt == 1) {
      r = rhs[0];
      for (int i = 0; i < maxCnt; ++i) {
        l = lhs[i];
        if (l != NumberNull && r != NumberNull) {
          buffer[i] = comp(l, r);
        }
      }
    } else {
      for (int i = 0; i < maxCnt; ++i) {
        if (i < lCnt && i < rCnt) {
          l = lhs.safeAt(i);
          r = rhs.safeAt(i);
          if (l != NumberNull && r != NumberNull) {
            buffer[i] = comp(l, r);
          }
        }
      }
    }
    return buffer;
  }

  Number operator [](int i) {
    if (i < 0 || i >= data.length) {
      return NumberNull;
    }
    return data[i];
  }

  void operator []=(int i, Number n) {
    if (i < 0 || i >= data.length) {
      return;
    }
    data[i] = n;
  }

  NumberCore operator +(NumberCore rhs) {
    NumberCore result = NumberCore.copy(this);
    comp(Number l, Number r) => l + r;
    result.data = operatorFunc(result, rhs, comp).data;
    return result;
  }

  NumberCore operator -(NumberCore rhs) {
    NumberCore result = NumberCore.copy(this);
    comp(Number l, Number r) => l - r;
    result.data = operatorFunc(result, rhs, comp).data;
    return result;
  }

  NumberCore operator *(NumberCore rhs) {
    NumberCore result = NumberCore.copy(this);
    comp(Number l, Number r) => l * r;
    result.data = operatorFunc(result, rhs, comp).data;
    return result;
  }

  NumberCore operator /(NumberCore rhs) {
    NumberCore result = NumberCore.copy(this);
    comp(Number l, Number r) {
      if (l == 0.0) return 0.0;
      if (r == 0.0) return NumberNull;
      return l / r;
    }

    result.data = operatorFunc(result, rhs, comp).data;
    return result;
  }

  NumberCore operator %(NumberCore rhs) {
    NumberCore result = NumberCore.copy(this);
    comp(Number l, Number r) {
      if (l == 0.0) return 0.0;
      if (r == 0.0) return NumberNull;
      return (l.toInt() % r.toInt()).toDouble();
    }

    result.data = operatorFunc(result, rhs, comp).data;
    return result;
  }

  static NumberCore operatorAnd(NumberCore lhs, NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l != 0 && r != 0) ? 1.0 : 0.0;
    result.data = operatorFunc(lhs, rhs, comp).data;
    return result;
  }

  static NumberCore operatorOr(NumberCore lhs, NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l != 0 || r != 0) ? 1.0 : 0.0;
    result.data = operatorFunc(lhs, rhs, comp).data;
    return result;
  }

  NumberCore operator <(NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l < r) ? 1.0 : 0.0;
    result.data = operatorFunc(this, rhs, comp).data;
    return result;
  }

  NumberCore operator <=(NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l <= r) ? 1.0 : 0.0;
    result.data = operatorFunc(this, rhs, comp).data;
    return result;
  }

  NumberCore operator >(NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l > r) ? 1.0 : 0.0;
    result.data = operatorFunc(this, rhs, comp).data;
    return result;
  }

  NumberCore operator >=(NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l >= r) ? 1.0 : 0.0;
    result.data = operatorFunc(this, rhs, comp).data;
    return result;
  }

  static NumberCore operatorEqual(NumberCore lhs, NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l == r) ? 1.0 : 0.0;
    result.data = operatorFunc(lhs, rhs, comp).data;
    return result;
  }

  static NumberCore operatorNotEqual(NumberCore lhs, NumberCore rhs) {
    NumberCore result = NumberCore();
    comp(Number l, Number r) => (l != r) ? 1.0 : 0.0;
    result.data = operatorFunc(lhs, rhs, comp).data;
    return result;
  }

  // operator !
  static Number not(Number n) {
    return n == 0 ? 1 : 0;
  }

  // operator !
  static NumberCore operatorNot(NumberCore lhs) {
    int cnt = lhs.size();
    NumberCore result = NumberCore.withCount(cnt);
    for (int i = 0; i < cnt; ++i) {
      result.data[i] = not(lhs.at(i));
    }
    return result;
  }

  void setOther(int i, String other) {
    int sz = data.length;
    if (i < 0 || i >= sz) return;
    if (this.other.length != sz) {
      resizeOther(sz);
    }
    this.other[i] = other;
  }

  String getOther(int i) {
    int sz = math.min(other.length, data.length);
    if (i < 0 || i >= sz) return '';
    return other[i];
  }

  void resizeOther(int cnt, {String val = ''}) {
    if (cnt < other.length) {
      other.removeRange(cnt, other.length);
    } else if (cnt > other.length) {
      other.addAll(List.filled(cnt - other.length, val));
    }
  }
}
