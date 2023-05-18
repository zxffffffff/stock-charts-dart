import 'package:flutter_test/flutter_test.dart';

import 'package:stock_charts/core/number_core.dart';

void main() {
  test('DefaultConstructor', () {
    NumberCore nc = NumberCore();
    expect(nc.empty(), true);
    expect(nc.size(), 0);
  });

  test('ValueConstructor', () {
    const Number val = 3.14159;
    NumberCore nc = NumberCore.fromValue(val);
    expect(nc.empty(), false);
    expect(nc.size(), 1);
    expect(nc[0], val);
  });

  test('CountAndValueConstructor', () {
    const int cnt = 5;
    const Number val = 42.0;
    NumberCore nc = NumberCore.withCount(cnt, val);
    expect(nc.empty(), false);
    expect(nc.size(), cnt);
    for (int i = 0; i < cnt; ++i) {
      expect(nc[i], val);
    }
  });

  test('InitializerListConstructor', () {
    NumberCore nc = NumberCore([1.0, 2.0, 3.0]);
    expect(nc.empty(), false);
    expect(nc.size(), 3);
    expect(nc[0], 1.0);
    expect(nc[1], 2.0);
    expect(nc[2], 3.0);
  });

  test('Empty', () {
    NumberCore nc = NumberCore();
    expect(nc.empty(), true);

    nc.resize(3);
    expect(nc.empty(), false);
  });

  test('Size', () {
    NumberCore nc = NumberCore();
    expect(nc.size(), 0);

    nc.resize(3);
    expect(nc.size(), 3);
  });

  test('Resize', () {
    NumberCore nc = NumberCore();
    nc.resize(3);
    expect(nc.size(), 3);
    expect(nc[0], NumberNull);
    expect(nc[1], NumberNull);
    expect(nc[2], NumberNull);

    const Number val = 42.0;
    nc.resize(5, val);
    expect(nc.size(), 5);
    expect(nc[0], NumberNull);
    expect(nc[1], NumberNull);
    expect(nc[2], NumberNull);
    expect(nc[3], val);
    expect(nc[4], val);

    nc.resize(2);
    expect(nc.size(), 2);
    expect(nc[0], NumberNull);
    expect(nc[1], NumberNull);
  });

  test('Clear', () {
    NumberCore nc = NumberCore([1.0, 2.0, 3.0]);
    expect(nc.empty(), false);
    expect(nc.size(), 3);

    nc.clear();
    expect(nc.empty(), true);
    expect(nc.size(), 0);
  });

  test('At', () {
    NumberCore nc = NumberCore([1.0, 2.0, 3.0]);
    expect(nc.at(0), 1.0);
    expect(nc.at(1), 2.0);
    expect(nc.at(2), 3.0);

    nc[1] = 42.0;
    expect(nc.at(1), 42.0);
  });

  test('SafeAt', () {
    NumberCore nc = NumberCore([1.0, 2.0, 3.0]);
    expect(nc.safeAt(0), 1.0);
    expect(nc.safeAt(1), 2.0);
    expect(nc.safeAt(2), 3.0);
    expect(nc.safeAt(-1), NumberNull);
    expect(nc.safeAt(3), NumberNull);

    nc[1] = 42.0;
    expect(nc.safeAt(1), 42.0);
  });

  test('Front', () {
    NumberCore nc = NumberCore([1.0, 2.0, 3.0]);
    expect(nc.front(), 1.0);

    nc[0] = 42.0;
    expect(nc.front(), 42.0);
  });

  test('Back', () {
    NumberCore nc = NumberCore([1.0, 2.0, 3.0]);
    expect(nc.back(), 3.0);

    nc[2] = 42.0;
    expect(nc.back(), 42.0);
  });

  test('FillBeginTest', () {
    NumberCore nc = NumberCore([1, 2, 3, 4, 5]);
    nc.fillBegin(2, 6);
    expect(nc[0], 6);
    expect(nc[1], 6);
    expect(nc[2], 3);
    expect(nc[3], 4);
    expect(nc[4], 5);
  });

  test('FillEndTest', () {
    NumberCore nc = NumberCore([1, 2, 3, 4, 5]);
    nc.fillEnd(2, 6);
    expect(nc[0], 1);
    expect(nc[1], 2);
    expect(nc[2], 3);
    expect(nc[3], 6);
    expect(nc[4], 6);
  });

  test('FillTest', () {
    NumberCore nc = NumberCore([1, 2, 3, 4, 5]);
    nc.fill(1, 3, 6);
    expect(nc[0], 1);
    expect(nc[1], 6);
    expect(nc[2], 6);
    expect(nc[3], 6);
    expect(nc[4], 5);
  });

  test('FillOutOfBoundsTest', () {
    NumberCore nc = NumberCore([1, 2, 3, 4, 5]);
    nc.fill(-1, 2, 6);
    nc.fill(4, 2, 6);
    expect(nc[0], 6);
    expect(nc[1], 2);
    expect(nc[2], 3);
    expect(nc[3], 4);
    expect(nc[4], 6);
  });

  test('ReplaceTest', () {
    NumberCore nc = NumberCore([1, 2, 3, 4, 5]);
    nc.replace(3, 8);
    expect(nc[2], 8);
    nc.replace(8, 8);
    expect(nc[2], 8);
  });

  test('ReplaceNotNumberTest', () {
    NumberCore nc = NumberCore([1.0, 2.0, double.nan, 4, double.infinity]);
    nc.replaceNotNumber(10);
    expect(nc[2], 10);
    expect(nc[4], 10);
    expect(nc[0], 1);
  });

  test('ReplaceEmptyValueTest', () {
    NumberCore nc = NumberCore([1, 2, NumberNull, 4, NumberNull]);
    nc.replaceEmptyValue(5);
    expect(nc[2], 5);
    expect(nc[4], 5);
    expect(nc[1], 2);
  });

  test('SwapTest', () {
    NumberCore nc1 = NumberCore([1, 2, 3]);
    NumberCore nc2 = NumberCore([4, 5, 6]);
    nc1.swap(nc2);
    expect(nc1[0], 4);
    expect(nc1[1], 5);
    expect(nc1[2], 6);
    expect(nc2[0], 1);
    expect(nc2[1], 2);
    expect(nc2[2], 3);
  });

  test('ReverseTest', () {
    NumberCore nc = NumberCore([1, 2, 3, 4, 5]);
    nc.reverse();
    expect(nc[0], 5);
    expect(nc[1], 4);
    expect(nc[2], 3);
    expect(nc[3], 2);
    expect(nc[4], 1);
  });

  test('GetMinMaxTest', () {
    // Test an empty NumberCore
    NumberCore nc1 = NumberCore();
    expect(nc1.getMinMax(0, 0).first, NumberNull);
    expect(nc1.getMinMax(0, 0).second, NumberNull);

    // Test with beginIndex and endIndex out of range
    NumberCore nc2 = NumberCore([1.0, 2.0, 3.0]);
    expect(nc2.getMinMax(-1, 4).first, NumberNull);
    expect(nc2.getMinMax(-1, 4).second, NumberNull);

    // Test with beginIndex == endIndex
    expect(nc2.getMinMax(1, 1).first, 2.0);
    expect(nc2.getMinMax(1, 1).second, 2.0);

    // Test with valid beginIndex and endIndex
    expect(nc2.getMinMax(1, 3).first, 2.0);
    expect(nc2.getMinMax(1, 3).second, 3.0);

    // Test with reverse order NumberCore
    NumberCore nc3 = NumberCore([3.0, 2.0, 1.0]);
    expect(nc3.getMinMax(0, 3).first, 1.0);
    expect(nc3.getMinMax(0, 3).second, 3.0);
  });

  test('MaxTest', () {
    expect(NumberCore.max(1.1, 2.2), 2.2);
    expect(NumberCore.max(2.2, 3.3), 3.3);
    expect(NumberCore.max(1.1, 3.3), 3.3);
    expect(NumberCore.max(NumberNull, 1.1), 1.1);
    expect(NumberCore.max(1.1, NumberNull), 1.1);
    expect(NumberCore.max(NumberNull, NumberNull), NumberNull);
  });

  test('MinTest', () {
    expect(NumberCore.min(1.1, 2.2), 1.1);
    expect(NumberCore.min(2.2, 3.3), 2.2);
    expect(NumberCore.min(1.1, 3.3), 1.1);
    expect(NumberCore.min(NumberNull, 1.1), 1.1);
    expect(NumberCore.min(1.1, NumberNull), 1.1);
    expect(NumberCore.min(NumberNull, NumberNull), NumberNull);
  });

  test('AbsTest', () {
    expect(NumberCore.abs(1.1), 1.1);
    expect(NumberCore.abs(-2.2), 2.2);
    expect(NumberCore.abs(3.3), 3.3);
    expect(NumberCore.abs(NumberNull), NumberNull);
  });

  test('MaxTest2', () {
    // Test with two NumberCore objects of equal size
    NumberCore nc1 = NumberCore([1, 2, 3, 4, 5]);
    NumberCore nc2 = NumberCore([6, 7, 8, 9, 10]);
    NumberCore result = NumberCore.getMax(nc1, nc2);
    expect(result.size(), 5);
    expect(result[0], 6);
    expect(result[1], 7);
    expect(result[2], 8);
    expect(result[3], 9);
    expect(result[4], 10);

    // Test with two NumberCore objects of different sizes
    NumberCore nc3 = NumberCore([1, 2, 3, 4, 5]);
    NumberCore nc4 = NumberCore([6, 7]);
    NumberCore result2 = NumberCore.getMax(nc3, nc4);
    expect(result2.size(), 5);
    expect(result2[0], 6);
    expect(result2[1], 7);
    expect(result2[2], NumberNull);
    expect(result2[3], NumberNull);
    expect(result2[4], NumberNull);

    // Test with one empty NumberCore object
    NumberCore nc5 = NumberCore([1, 2, 3, 4, 5]);
    NumberCore nc6 = NumberCore([]);
    NumberCore result3 = NumberCore.getMax(nc5, nc6);
    expect(result3.size(), 5);
    expect(result3[0], 1);
    expect(result3[1], 2);
    expect(result3[2], 3);
    expect(result3[3], 4);
    expect(result3[4], 5);

    // Test with both empty NumberCore objects
    NumberCore nc7 = NumberCore([]);
    NumberCore nc8 = NumberCore([]);
    NumberCore result4 = NumberCore.getMax(nc7, nc8);
    expect(result4.empty(), true);

    // Test with one NumberCore object with single value
    NumberCore nc9 = NumberCore([3]);
    NumberCore nc10 = NumberCore([1, 2, 3, 4, 5]);
    NumberCore result5 = NumberCore.getMax(nc9, nc10);
    expect(result5.size(), 5);
    expect(result5[0], 3);
    expect(result5[1], 3);
    expect(result5[2], 3);
    expect(result5[3], 4);
    expect(result5[4], 5);
  });

  test('MinTest2', () {
    // Test with two NumberCore objects of equal size
    NumberCore nc1 = NumberCore([1, 2, 3, 4, 5]);
    NumberCore nc2 = NumberCore([6, 7, 8, 9, 10]);
    NumberCore result = NumberCore.getMin(nc1, nc2);
    expect(result.size(), 5);
    expect(result[0], 1);
    expect(result[1], 2);
    expect(result[2], 3);
    expect(result[3], 4);
    expect(result[4], 5);

    // Test with two NumberCore objects of different sizes
    NumberCore nc3 = NumberCore([6, 7, 3, 4, 5]);
    NumberCore nc4 = NumberCore([1, 2]);
    NumberCore result2 = NumberCore.getMin(nc3, nc4);
    expect(result2.size(), 5);
    expect(result2[0], 1);
    expect(result2[1], 2);
    expect(result2[2], NumberNull);
    expect(result2[3], NumberNull);
    expect(result2[4], NumberNull);

    // Test with one empty NumberCore object
    NumberCore nc5 = NumberCore([1, 2, 3, 4, 5]);
    NumberCore nc6 = NumberCore([]);
    NumberCore result3 = NumberCore.getMin(nc5, nc6);
    expect(result3.size(), 5);
    expect(result3[0], 1);
    expect(result3[1], 2);
    expect(result3[2], 3);
    expect(result3[3], 4);
    expect(result3[4], 5);

    // Test with both empty NumberCore objects
    NumberCore nc7 = NumberCore([]);
    NumberCore nc8 = NumberCore([]);
    NumberCore result4 = NumberCore.getMin(nc7, nc8);
    expect(result4.empty(), true);

    // Test with one NumberCore object with single value
    NumberCore nc9 = NumberCore([3]);
    NumberCore nc10 = NumberCore([1, 2, 3, 4, 5]);
    NumberCore result5 = NumberCore.getMin(nc9, nc10);
    expect(result5.size(), 5);
    expect(result5[0], 1);
    expect(result5[1], 2);
    expect(result5[2], 3);
    expect(result5[3], 3);
    expect(result5[4], 3);
  });

  test('OperatorAddEqual', () {
    NumberCore v1 = NumberCore([1, 2, 3]);
    NumberCore v2 = NumberCore([4, 5, 6]);
    NumberCore v3 = NumberCore([5, 7, 9]);
    v1 += v2;
    expect(v1[0], v3[0]);
    expect(v1[1], v3[1]);
    expect(v1[2], v3[2]);
  });

  test('OperatorSubEqual', () {
    NumberCore v1 = NumberCore([4, 5, 6]);
    NumberCore v2 = NumberCore([1, 2, 3]);
    NumberCore v3 = NumberCore([3, 3, 3]);
    v1 -= v2;
    expect(v1[0], v3[0]);
    expect(v1[1], v3[1]);
    expect(v1[2], v3[2]);
  });

  test('OperatorMulEqual', () {
    NumberCore v1 = NumberCore([1, 2, 3]);
    NumberCore v2 = NumberCore([2, 3, 4]);
    NumberCore v3 = NumberCore([2, 6, 12]);
    v1 *= v2;
    expect(v1[0], v3[0]);
    expect(v1[1], v3[1]);
    expect(v1[2], v3[2]);
  });

  test('OperatorDivEqual', () {
    NumberCore v1 = NumberCore([4, 6, 8]);
    NumberCore v2 = NumberCore([2, 2, 2]);
    NumberCore v3 = NumberCore([2, 3, 4]);
    v1 /= v2;
    expect(v1[0], v3[0]);
    expect(v1[1], v3[1]);
    expect(v1[2], v3[2]);
  });

  test('OperatorModEqual', () {
    NumberCore v1 = NumberCore([5, 7, 9]);
    NumberCore v2 = NumberCore([2, 3, 4]);
    NumberCore v3 = NumberCore([1, 1, 1]);
    v1 %= v2;
    expect(v1[0], v3[0]);
    expect(v1[1], v3[1]);
    expect(v1[2], v3[2]);
  });

  test('OperatorNot', () {
    NumberCore v1 = NumberCore([1, 0, 1]);
    NumberCore v2 = NumberCore([0, 1, 0]);
    NumberCore v3 = NumberCore.operatorNot(v2);
    expect(v1[0], v3[0]);
    expect(v1[1], v3[1]);
    expect(v1[2], v3[2]);
  });

  test('Addition', () {
    NumberCore a = NumberCore([1.0, 2.0, 3.0]);
    NumberCore b = NumberCore([3.0, 2.0, 1.0]);
    NumberCore c = a + b;
    expect(c.size(), 3);
    expect(c[0], 4.0);
    expect(c[1], 4.0);
    expect(c[2], 4.0);
  });

  test('Subtraction', () {
    NumberCore a = NumberCore([1.0, 2.0, 3.0]);
    NumberCore b = NumberCore([3.0, 2.0, 1.0]);
    NumberCore c = a - b;
    expect(c.size(), 3);
    expect(c[0], -2.0);
    expect(c[1], 0.0);
    expect(c[2], 2.0);
  });

  test('Multiplication', () {
    NumberCore a = NumberCore([1.0, 2.0, 3.0]);
    NumberCore b = NumberCore([3.0, 2.0, 1.0]);
    NumberCore c = a * b;
    expect(c.size(), 3);
    expect(c[0], 3.0);
    expect(c[1], 4.0);
    expect(c[2], 3.0);
  });

  test('Division', () {
    NumberCore a = NumberCore([1.0, 2.0, 3.0]);
    NumberCore b = NumberCore([3.0, 2.0, 1.0]);
    NumberCore c = a / b;
    expect(c.size(), 3);
    expect(c[0], 1.0 / 3.0);
    expect(c[1], 1.0);
    expect(c[2], 3.0);
  });

  test('Modulo', () {
    NumberCore a = NumberCore([7.0, 8.0, 9.0]);
    NumberCore b = NumberCore([2.0, 3.0, 4.0]);
    NumberCore c = a % b;
    expect(c.size(), 3);
    expect(c[0], 1.0);
    expect(c[1], 2.0);
    expect(c[2], 1.0);
  });

  test('LogicalAnd', () {
    NumberCore a = NumberCore([1, 1, 0]);
    NumberCore b = NumberCore([0, 1, 1]);
    NumberCore c = NumberCore.operatorAnd(a, b);
    expect(c.size(), 3);
    expect(c[0], 0);
    expect(c[1], 1);
    expect(c[2], 0);
  });

  test('LogicalOr', () {
    NumberCore a = NumberCore([1, 1, 0]);
    NumberCore b = NumberCore([0, 1, 1]);
    NumberCore c = NumberCore.operatorOr(a, b);
    expect(c.size(), 3);
    expect(c[0], 1);
    expect(c[1], 1);
    expect(c[2], 1);
  });

  test('LessThan', () {
    NumberCore a = NumberCore([1, 2, 3]);
    NumberCore b = NumberCore([0, 2, 4]);
    NumberCore c = a < b;
    expect(c.size(), 3);
    expect(c[0], 0);
    expect(c[1], 0);
    expect(c[2], 1);
  });

  test('LessThanOrEqualTo', () {
    NumberCore a = NumberCore([1, 2, 3]);
    NumberCore b = NumberCore([0, 2, 4]);
    NumberCore c = a <= b;
    expect(c.size(), 3);
    expect(c[0], 0);
    expect(c[1], 1);
    expect(c[2], 1);
  });

  test('GreaterThan', () {
    NumberCore a = NumberCore([1, 2, 3]);
    NumberCore b = NumberCore([0, 2, 4]);
    NumberCore c = a > b;
    expect(c.size(), 3);
    expect(c[0], 1);
    expect(c[1], 0);
    expect(c[2], 0);
  });

  test('GreaterThanOrEqualTo', () {
    NumberCore a = NumberCore([1, 2, 3]);
    NumberCore b = NumberCore([0, 2, 4]);
    NumberCore c = a >= b;
    expect(c.size(), 3);
    expect(c[0], 1);
    expect(c[1], 1);
    expect(c[2], 0);
  });

  test('EqualTo', () {
    NumberCore a = NumberCore([1, 2, 3]);
    NumberCore b = NumberCore([0, 2, 4]);
    NumberCore c = NumberCore.operatorEqual(a, b);
    expect(c.size(), 3);
    expect(c[0], 0);
    expect(c[1], 1);
    expect(c[2], 0);
  });

  test('NotEqualTo', () {
    NumberCore a = NumberCore([1, 2, 3]);
    NumberCore b = NumberCore([0, 2, 4]);
    NumberCore c = NumberCore.operatorNotEqual(a, b);
    expect(c.size(), 3);
    expect(c[0], 1);
    expect(c[1], 0);
    expect(c[2], 1);
  });

  test('SetOtherAndGetOther', () {
    NumberCore nc = NumberCore([1.0, 2.0, 3.0]);
    expect(nc.getOther(0), "");
    expect(nc.getOther(1), "");
    expect(nc.getOther(2), "");

    String other1 = "a";
    String other2 = "b";
    String other3 = "c";
    nc.setOther(0, other1);
    nc.setOther(1, other2);
    nc.setOther(2, other3);
    expect(nc.getOther(0), other1);
    expect(nc.getOther(1), other2);
    expect(nc.getOther(2), other3);
  });
}
