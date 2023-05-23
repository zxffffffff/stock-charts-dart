//***************************************************************************
// MIT License
//
// Author   : xiaofeng.zhu
// Support  : zxffffffff@outlook.com, 1337328542@qq.com
//
//**************************************************************************/
library stock_charts;

import 'package:stock_charts/model/Plugin/Indicator/Parser/color_parser.dart';
import 'package:stock_charts/model/Plugin/Indicator/Parser/drawing_parser.dart';
import 'package:stock_charts/model/Plugin/Indicator/Parser/function_parser.dart';
import 'package:stock_charts/model/Plugin/Indicator/Parser/keyword_parser.dart';

import '../../../core/number_core.dart';
import '../../../core/stock_core.dart';
import '../../../core/utils.dart';
import 'Core/exp_core.dart';
import 'Core/index_core.dart';

enum EnParseToken {
  ParseInit,
  String,
  Number,
  Rename, // :
  RenameAssign, // :=
  TokenLT, // <
  TokenLE, // <=
  TokenGT, // >
  TokenGE, // >=
  TokenEQ, // =, ==
  TokenNEQ, // !=
  TokenNOT, // !
  TokenPlus, // +
  TokenMinus, // -
  TokenMul, // *
  TokenDiv, // /
  TokenMod, // %
  TokenPow, // ^
  TokenAnd, // &&
  TokenOr, // ||
  TokenComma, // ,
  TokenLP, // (
  TokenRP, // )
  TokenFinal, // ;
}

class IndicatorParser {
  IndexFormula _formula = IndexFormula();

  FunctionParser _functionParser = FunctionParser();
  KeywordParser _keywordParser = KeywordParser();
  ColorParser _colorParser = ColorParser();
  DrawingParser _drawingParser = DrawingParser();

  IndexCore _result = IndexCore();
  Set<EnStockRely> _stockRely = {};
  bool _bParseError = false;
  String _errWord = "";

  String _expression = "";
  int _iteCurrent = -1;
  int _iteEnd = -1;
  EnParseToken _eToken = EnParseToken.ParseInit;
  Number _dValue = NumberNull;
  String _sValue = "";
  ExpInfo _expInfo = ExpInfo();
  ExpDrawingType _expDrawing = ExpDrawingType();

  // [0]
  void setFormula(IndexFormula formula) {
    _formula = formula;
  }

  // [1]
  void setStockCore(StockCore stockCore) {
    _functionParser.stockCore = stockCore;
    _keywordParser.stockCore = stockCore;
    _colorParser.stockCore = stockCore;
    _drawingParser.stockCore = stockCore;
  }

  void setStockExt(StockRelyData stockExt) {
    _functionParser.stockExt = stockExt;
    _keywordParser.stockExt = stockExt;
    _colorParser.stockExt = stockExt;
    _drawingParser.stockExt = stockExt;
  }

  // [2]
  bool run() {
    _result = IndexCore();
    _stockRely.clear();
    _bParseError = false;
    _errWord = "";

    List<String> expressions = _formula.expression.split(';');
    int i;
    for (i = 0; i < expressions.length; ++i) {
      _expression = Utils.to8bitStr(expressions[i]) + ";";
      if (Utils.checkEmpty(_expression)) continue;
      if (_expression.substring(_expression.length - 1) != '\x00')
        _expression += '\x00';

      _iteCurrent = 0;
      _iteEnd = _expression.length;
      _eToken = EnParseToken.ParseInit;
      _dValue = NumberNull;
      _sValue = "";
      _expInfo = ExpInfo();
      _expDrawing = ExpDrawingType();

      try {
        parseTokenValue();
        NumberCore core = parseFormula();
        if (_bParseError) throw Exception();

        ExpColorType expColor = parseColor();
        if (_bParseError) throw Exception();

        var exp = ExpCore();
        exp.core = core;
        exp.info = _expInfo;
        exp.colorType = expColor;
        exp.drawingType = _expDrawing;
        _result.exps.add(exp);
      } catch (e) {
        _result.err = true;
        _result.errExpression = expressions[i];
        _result.errWord = _errWord;
        return false;
      }
    }
    return true;
  }

  // [3]
  IndexCore getResult() {
    return _result;
  }

  IndexFormula getFormula() {
    return _formula;
  }

  Set<EnStockRely> getStockRely() {
    return _stockRely;
  }

  NumberCore parseFormula() {
    NumberCore coreLeft = parseRelationOperate();

    if (_bParseError) return coreLeft;

    for (;;) {
      switch (_eToken) {
        case EnParseToken.TokenAnd:
          parseTokenValue();
          coreLeft = NumberCore.operatorAnd(coreLeft, parseRelationOperate());
          break;
        case EnParseToken.TokenOr:
          parseTokenValue();
          coreLeft = NumberCore.operatorOr(coreLeft, parseRelationOperate());
          break;

        default:
          return coreLeft;
      }

      if (_bParseError) return coreLeft;
    }
  }

  ExpColorType parseColor() {
    var expColor = ExpColorType();
    expColor.type = EnExpLineType.LINE;
    expColor.thick = EnExpLineThick.LINETHICK1;
    expColor.color = "8080FF";

    if (_expression[_iteCurrent] == '\x00') return expColor;

    for (;;) {
      parseTokenValue();
      if (_eToken != EnParseToken.String) {
        _bParseError = true;
        return expColor;
      }

      String name = _sValue;
      if (_colorParser.check(name)) {
        var tuple2 = _colorParser.process(name);
        bool ok = tuple2.item1;
        ExpColorType expTemp = tuple2.item2;
        if (!ok) {
          _bParseError = true;
          _errWord = name;
          return expColor;
        }

        if (expTemp.type != EnExpLineType.None) expColor.type = expTemp.type;
        if (expTemp.thick != EnExpLineThick.None)
          expColor.thick = expTemp.thick;
        if (!expTemp.color.isEmpty) expColor.color = expTemp.color;
      } else {
        _bParseError = true;
        _errWord = name;
        return expColor;
      }

      parseTokenValue();
      if (_eToken == EnParseToken.TokenComma) continue;
      if (_eToken == EnParseToken.TokenFinal) return expColor;

      _bParseError = true;
      return expColor;
    }
  }

  NumberCore parseRelationOperate() {
    NumberCore coreLeft = parseArithLastOperate();

    if (_bParseError) return coreLeft;

    for (;;) {
      switch (_eToken) {
        case EnParseToken.TokenLT:
          {
            parseTokenValue();
            NumberCore coreRight = parseArithLastOperate();
            coreLeft = coreLeft < coreRight;
            break;
          }
        case EnParseToken.TokenLE:
          {
            parseTokenValue();
            NumberCore coreRight = parseArithLastOperate();
            coreLeft = coreLeft <= coreRight;
            break;
          }
        case EnParseToken.TokenGT:
          {
            parseTokenValue();
            NumberCore coreRight = parseArithLastOperate();
            coreLeft = coreLeft > coreRight;
            break;
          }
        case EnParseToken.TokenGE:
          {
            parseTokenValue();
            NumberCore coreRight = parseArithLastOperate();
            coreLeft = coreLeft >= coreRight;
            break;
          }
        case EnParseToken.TokenEQ:
          {
            parseTokenValue();
            NumberCore coreRight = parseArithLastOperate();
            coreLeft = NumberCore.operatorEqual(coreLeft, coreRight);
            break;
          }
        case EnParseToken.TokenNEQ:
          {
            parseTokenValue();
            NumberCore coreRight = parseArithLastOperate();
            coreLeft = NumberCore.operatorNotEqual(coreLeft, coreRight);
            break;
          }
        default:
          return coreLeft;
      }

      if (_bParseError) return coreLeft;
    }
  }

  NumberCore parseArithLastOperate() {
    NumberCore coreLeft = parseArithFirstOperate();

    if (_bParseError) return coreLeft;

    for (;;) {
      switch (_eToken) {
        case EnParseToken.TokenPlus:
          parseTokenValue();
          coreLeft = coreLeft + parseArithFirstOperate();
          break;
        case EnParseToken.TokenMinus:
          parseTokenValue();
          coreLeft = coreLeft - parseArithFirstOperate();
          break;
        default:
          return coreLeft;
      }

      if (_bParseError) return coreLeft;
    }
  }

  NumberCore parseArithFirstOperate() {
    NumberCore coreLeft = parsePrimTokenOperate();

    if (_bParseError) return coreLeft;

    NumberCore coreTemp;
    for (;;) {
      switch (_eToken) {
        case EnParseToken.TokenMul:
          parseTokenValue();
          coreTemp = parsePrimTokenOperate();
          coreLeft = coreLeft * coreTemp;
          break;

        case EnParseToken.TokenDiv:
          parseTokenValue();
          coreTemp = parsePrimTokenOperate();
          coreLeft = coreLeft / coreTemp;
          break;

        case EnParseToken.TokenMod:
          parseTokenValue();
          coreTemp = parsePrimTokenOperate();
          coreLeft = coreLeft % coreTemp;
          break;
        default:
          return coreLeft;
      }

      if (_bParseError) return coreLeft;
    }
  }

  NumberCore parsePrimTokenOperate() {
    var coreToken = NumberCore();
    String name = _sValue;

    switch (_eToken) {
      case EnParseToken.Number:
        parseTokenValue();
        coreToken = NumberCore.fromValue(_dValue);
        _dValue = NumberNull;
        return coreToken;

      case EnParseToken.String:
        parseTokenValue();

        if (_eToken == EnParseToken.Rename ||
            _eToken == EnParseToken.RenameAssign) {
          if (_eToken == EnParseToken.RenameAssign)
            _expInfo.renameAssign = true;
          _expInfo.rename = name;
          parseTokenValue();
          return parseFormula();
        } else if (checkAssign(name)) {
          return getAssign(name);
        } else if (checkInputParam(name)) {
          return getInputParam(name);
        } else if (_keywordParser.check(name)) {
          var rely = _keywordParser.stockRely(name);
          if (!rely.isEmpty) _stockRely.addAll(rely);

          var tuple2 = _keywordParser.process(name);
          bool ok = tuple2.item1;
          NumberCore coreResult = tuple2.item2;
          if (!ok) {
            _bParseError = true;
            _errWord = name;
            return coreResult;
          }
          return coreResult;
        } else if (_functionParser.check(name)) {
          var coreResult = NumberCore();
          if (_eToken == EnParseToken.TokenLP) {
            List<NumberCore> params = [];
            parseTokenValue();
            params.add(parseFormula());
            while (_eToken == EnParseToken.TokenComma)
              params.add(parseFormula());

            if (_eToken != EnParseToken.TokenRP) {
              _bParseError = true;
              _errWord = name;
              return coreResult;
            }

            var tuple2 = _functionParser.process(name, params);
            bool ok = tuple2.item1;
            coreResult = tuple2.item2;
            if (!ok) {
              _bParseError = true;
              _errWord = name;
              return coreResult;
            }

            if (_expression[_iteCurrent] != '\x00') {
              parseTokenValue();
            }
            return coreResult;
          } else {
            return coreResult;
          }
        } else if (_drawingParser.check(name)) {
          var coreResult = NumberCore();
          if (_eToken == EnParseToken.TokenLP) {
            List<NumberCore> params = [];
            parseTokenValue();
            params.add(parseFormula());
            while (_eToken == EnParseToken.TokenComma)
              params.add(parseFormula());

            if (_eToken != EnParseToken.TokenRP) {
              _bParseError = true;
              _errWord = name;
              return coreResult;
            }

            var tuple2 = _drawingParser.process(name, params);
            bool ok = tuple2.item1;
            ExpDrawingType drawingType = tuple2.item2;
            if (!ok) {
              _bParseError = true;
              _errWord = name;
              return coreResult;
            }
            _expDrawing = drawingType;

            if (_expression[_iteCurrent] != '\x00') {
              parseTokenValue();
            }
            return coreResult;
          } else {
            return coreResult;
          }
        } else {
          _bParseError = true;
          _errWord = name;
          return NumberCore();
        }

      case EnParseToken.TokenMinus:
        parseTokenValue();
        return parsePrimTokenOperate() * NumberCore.fromValue(-1.0);

      case EnParseToken.TokenPlus:
        parseTokenValue();
        return parsePrimTokenOperate();

      case EnParseToken.TokenNOT:
        parseTokenValue();
        return NumberCore.operatorNot(parsePrimTokenOperate());

      case EnParseToken.TokenAnd:
      case EnParseToken.TokenOr:
        return coreToken;

      case EnParseToken.TokenLP:
        {
          parseTokenValue();
          NumberCore coreResult = parseFormula();
          if (_eToken != EnParseToken.TokenRP) {
            return coreResult;
          }
          parseTokenValue();
          return coreResult;
        }

      case EnParseToken.TokenComma:
        parseTokenValue();
        return parsePrimTokenOperate();

      default:
        _bParseError = true;
        return coreToken;
    }
  }

  EnParseToken parseTokenValue() {
    switch (_expression[_iteCurrent]) {
      case ';':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenFinal;

      case ':':
        _iteCurrent++;
        if (_expression[_iteCurrent] == '=') {
          _iteCurrent++;
          return _eToken = EnParseToken.RenameAssign;
        }
        return _eToken = EnParseToken.Rename;

      case '\r':
      case '\n':
      case '\t':
      case '\v':
      case ' ':
        _iteCurrent++;
        return _eToken = parseTokenValue();

      case '*':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenMul;
      case '/':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenDiv;
      case '+':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenPlus;
      case '-':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenMinus;
      case '(':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenLP;
      case ')':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenRP;
      case '%':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenMod;
      case ',':
        _iteCurrent++;
        return _eToken = EnParseToken.TokenComma;

      case '<':
        _iteCurrent++;
        if (_expression[_iteCurrent] == '=') {
          _iteCurrent++;
          return _eToken = EnParseToken.TokenLE;
        }
        return _eToken = EnParseToken.TokenLT;
      case '>':
        _iteCurrent++;
        if (_expression[_iteCurrent] == '=') {
          _iteCurrent++;
          return _eToken = EnParseToken.TokenGE;
        }
        return _eToken = EnParseToken.TokenGT;
      case '=':
        _iteCurrent++;
        if (_expression[_iteCurrent] == '=') {
          _iteCurrent++;
          return _eToken = EnParseToken.TokenEQ;
        }
        return _eToken = EnParseToken.TokenEQ;

      case '&':
        _iteCurrent++;
        if (_expression[_iteCurrent] == '&') {
          _iteCurrent++;
          return _eToken = EnParseToken.TokenAnd;
        }
        return _eToken = EnParseToken.TokenAnd;
      case '|':
        _iteCurrent++;
        if (_expression[_iteCurrent] == '|') {
          _iteCurrent++;
          return _eToken = EnParseToken.TokenOr;
        }
        return _eToken = EnParseToken.TokenOr;
      case '!':
        _iteCurrent++;
        if (_expression[_iteCurrent] == '=') {
          _iteCurrent++;
          return _eToken = EnParseToken.TokenNEQ;
        }
        return _eToken = EnParseToken.TokenNOT;

      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        _dValue = parseNumberValue();
        return _eToken = EnParseToken.Number;

      default:
        if (Utils.isLetter(_expression[_iteCurrent]) ||
            _expression[_iteCurrent] == '_') {
          _sValue = "";
          while (Utils.isLetter(_expression[_iteCurrent]) ||
              Utils.isDigit(_expression[_iteCurrent]) ||
              _expression[_iteCurrent] == '_') {
            _sValue += _expression[_iteCurrent++];
          }

          if (_sValue == "AND") {
            _sValue = "";
            return _eToken = EnParseToken.TokenAnd;
          } else if (_sValue == "OR") {
            _sValue = "";
            return _eToken = EnParseToken.TokenOr;
          } else if (_sValue == "NOT") {
            _sValue = "";
            return _eToken = EnParseToken.TokenNOT;
          }

          return _eToken = EnParseToken.String;
        } else if (_expression[_iteCurrent] == '\x00') {
          return _eToken = EnParseToken.TokenFinal;
        }
        _bParseError = true;
        return _eToken;
    }
  }

  Number parseNumberValue() {
    String s = "";
    while (Utils.isDigit(_expression[_iteCurrent]) ||
        _expression[_iteCurrent] == '.') s += _expression[_iteCurrent++];
    Number dValue = double.parse(s);
    return dValue;
  }

  bool checkAssign(String name) {
    for (var result in _result.exps) {
      if (result.info.rename == name) return true;
    }
    return false;
  }

  NumberCore getAssign(String name) {
    for (var result in _result.exps) {
      if (result.info.rename == name) return result.core;
    }
    return NumberCore();
  }

  bool checkInputParam(String name) {
    return _formula.params.containsKey(name);
  }

  NumberCore getInputParam(String name) {
    if (_formula.params.containsKey(name))
      return NumberCore.fromValue(_formula.params[name]!.toDouble());
    return NumberCore();
  }
}
