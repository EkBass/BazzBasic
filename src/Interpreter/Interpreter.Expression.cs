/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Expression.cs
 Expression parsing and evaluation

 Licence: MIT
*/

using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // Expression evaluation
    // ========================================================================
    
    private Value EvaluateExpression()
    {
        return EvaluateOr();
    }

    private Value EvaluateOr()
    {
        Value left = EvaluateAnd();
        
        while (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_OR)
        {
            _pos++;
            Value right = EvaluateAnd();
            left = Value.FromNumber((left.IsTrue() || right.IsTrue()) ? 1 : 0);
        }
        
        return left;
    }

    private Value EvaluateAnd()
    {
        Value left = EvaluateComparison();
        
        while (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_AND)
        {
            _pos++;
            Value right = EvaluateComparison();
            left = Value.FromNumber((left.IsTrue() && right.IsTrue()) ? 1 : 0);
        }
        
        return left;
    }

    private Value EvaluateComparison()
    {
        Value left = EvaluateAddSub();
        
        while (_pos < _tokens.Count)
        {
            Token op = _tokens[_pos];
            
            switch (op.Type)
            {
                case TokenType.TOK_EQUALS:
                    _pos++;
                    left = Value.FromNumber(CompareValues(left, EvaluateAddSub()) == 0 ? 1 : 0);
                    break;
                case TokenType.TOK_NOT_EQUALS:
                    _pos++;
                    left = Value.FromNumber(CompareValues(left, EvaluateAddSub()) != 0 ? 1 : 0);
                    break;
                case TokenType.TOK_LESS:
                    _pos++;
                    left = Value.FromNumber(CompareValues(left, EvaluateAddSub()) < 0 ? 1 : 0);
                    break;
                case TokenType.TOK_GREATER:
                    _pos++;
                    left = Value.FromNumber(CompareValues(left, EvaluateAddSub()) > 0 ? 1 : 0);
                    break;
                case TokenType.TOK_LESS_EQ:
                    _pos++;
                    left = Value.FromNumber(CompareValues(left, EvaluateAddSub()) <= 0 ? 1 : 0);
                    break;
                case TokenType.TOK_GREATER_EQ:
                    _pos++;
                    left = Value.FromNumber(CompareValues(left, EvaluateAddSub()) >= 0 ? 1 : 0);
                    break;
                default:
                    return left;
            }
        }
        
        return left;
    }

    private Value EvaluateAddSub()
    {
        Value left = EvaluateMulDiv();
        
        while (_pos < _tokens.Count)
        {
            Token op = _tokens[_pos];
            
            if (op.Type == TokenType.TOK_PLUS)
            {
                _pos++;
                Value right = EvaluateMulDiv();
                
                if (left.Type == BazzValueType.String || right.Type == BazzValueType.String)
                    left = Value.FromString(left.AsString() + right.AsString());
                else
                    left = Value.FromNumber(left.NumValue + right.NumValue);
            }
            else if (op.Type == TokenType.TOK_MINUS)
            {
                _pos++;
                left = Value.FromNumber(left.AsNumber() - EvaluateMulDiv().AsNumber());
            }
            else
            {
                break;
            }
        }
        
        return left;
    }

    private Value EvaluateMulDiv()
    {
        Value left = EvaluateUnary();
        
        while (_pos < _tokens.Count)
        {
            Token op = _tokens[_pos];
            
            if (op.Type == TokenType.TOK_MULTIPLY)
            {
                _pos++;
                left = Value.FromNumber(left.AsNumber() * EvaluateUnary().AsNumber());
            }
            else if (op.Type == TokenType.TOK_DIVIDE)
            {
                _pos++;
                double divisor = EvaluateUnary().AsNumber();
                left = divisor == 0 ? Value.Zero : Value.FromNumber(left.AsNumber() / divisor);
            }
            else if (op.Type == TokenType.TOK_MODULO)
            {
                _pos++;
                left = Value.FromNumber(left.AsNumber() % EvaluateUnary().AsNumber());
            }
            else
            {
                break;
            }
        }
        
        return left;
    }

    private Value EvaluateUnary()
    {
        if (_pos < _tokens.Count)
        {
            if (_tokens[_pos].Type == TokenType.TOK_MINUS)
            {
                _pos++;
                return Value.FromNumber(-EvaluateUnary().AsNumber());
            }
            if (_tokens[_pos].Type == TokenType.TOK_NOT)
            {
                _pos++;
                return Value.FromNumber(EvaluateUnary().IsTrue() ? 0 : 1);
            }
        }
        
        return EvaluatePrimary();
    }

    private Value EvaluatePrimary()
    {
        if (_pos >= _tokens.Count)
            return Value.Zero;

        Token token = _tokens[_pos];

        switch (token.Type)
        {
            case TokenType.TOK_NUMBER:
                _pos++;
                return Value.FromNumber(token.NumValue);
                
            case TokenType.TOK_STRING:
                _pos++;
                return Value.FromString(token.StringValue ?? "");
                
            case TokenType.TOK_VARIABLE:
            case TokenType.TOK_CONSTANT:
                return EvaluateVariableOrArray();
                
            case TokenType.TOK_TRUE:
                _pos++;
                return Value.FromNumber(1);
                
            case TokenType.TOK_FALSE:
                _pos++;
                return Value.FromNumber(0);
                
            case TokenType.TOK_LPAREN:
                _pos++;
                Value result = EvaluateExpression();
                Expect(TokenType.TOK_RPAREN);
                return result;

            // Math functions
            case TokenType.TOK_ABS:
                return EvaluateAbsFunc();
            case TokenType.TOK_ATAN:
                return EvaluateAtanFunc();
            case TokenType.TOK_CINT:
                return EvaluateCintFunc();
            case TokenType.TOK_COS:
                return EvaluateCosFunc();
            case TokenType.TOK_CEIL:
                return EvaluateCeilFunc();
            case TokenType.TOK_FLOOR:
                return EvaluateFloorFunc();
            case TokenType.TOK_EXP:
                return EvaluateExpFunc();
            case TokenType.TOK_INT:
                return EvaluateIntFunc();
            case TokenType.TOK_LOG:
                return EvaluateLogFunc();
            case TokenType.TOK_MAX:
                return EvaluateMaxFunc();
            case TokenType.TOK_MIN:
                return EvaluateMinFunc();
            case TokenType.TOK_MOD:
                return EvaluateModFunc();
            case TokenType.TOK_POW:
                return EvaluatePowFunc();
            case TokenType.TOK_RND:
                return EvaluateRnd();
            case TokenType.TOK_SIN:
                return EvaluateSinFunc();
            case TokenType.TOK_SQR:
                return EvaluateSqrFunc();
            case TokenType.TOK_ROUND:
                return EvaluateRoundFunc();
            case TokenType.TOK_SGN:
                return EvaluateSgnFunc();
            case TokenType.TOK_TAN:
                return EvaluateTanFunc();
            case TokenType.TOK_PI:
                return EvaluatePiFunc();
            case TokenType.TOK_HPI:
                return EvaluateHpiFunc();
            case TokenType.TOK_RAD:
                return EvaluateRadFunc();
            case TokenType.TOK_DEG:
                return EvaluateDegFunc();
            case TokenType.TOK_FASTSIN:
                return EvaluateFastSin();
            case TokenType.TOK_FASTCOS:
                return EvaluateFastCos();
            case TokenType.TOK_FASTRAD:
                return EvaluateFastRad();
            case TokenType.TOK_QPI:
                return EvaluateQpiFunc();
            case TokenType.TOK_TAU:
                return EvaluateTauFunc();

            // String functions
            case TokenType.TOK_ASC:
                return EvaluateAscFunc();
            case TokenType.TOK_CHR:
                return EvaluateChrFunc();
            case TokenType.TOK_INSTR:
                return EvaluateInstrFunc();
            case TokenType.TOK_INVERT:
                return EvaluateInvertFunc();
            case TokenType.TOK_LCASE:
                return EvaluateLcaseFunc();
            case TokenType.TOK_LEFT:
                return EvaluateLeftFunc();
            case TokenType.TOK_LEN:
                return EvaluateLenFunc();
            case TokenType.TOK_LTRIM:
                return EvaluateLtrimFunc();
            case TokenType.TOK_MID:
                return EvaluateMidFunc();
            case TokenType.TOK_REPEAT:
                return EvaluateRepeatFunc();
            case TokenType.TOK_REPLACE:
                return EvaluateReplaceFunc();
            case TokenType.TOK_RIGHT:
                return EvaluateRightFunc();
            case TokenType.TOK_RTRIM:
                return EvaluateRtrimFunc();
            case TokenType.TOK_SRAND:
                return EvaluateSrandFunc();
            case TokenType.TOK_SPLIT:
                return EvaluateSplitFunc();
            case TokenType.TOK_STR:
                return EvaluateStrFunc();
            case TokenType.TOK_TRIM:
                return EvaluateTrimFunc();
            case TokenType.TOK_UCASE:
                return EvaluateUcaseFunc();
            case TokenType.TOK_VAL:
                return EvaluateValFunc();
            case TokenType.TOK_BETWEEN:
                return EvaluateBetweenFunc();

            // Other functions
            case TokenType.TOK_INKEY:
                return EvaluateInkeyFunc();
            case TokenType.TOK_GETCONSOLE:
                return EvaluateGetConsoleFunc();
            case TokenType.TOK_RGB:
                return EvaluateRgbFunc();
            case TokenType.TOK_HASKEY:
                return EvaluateHaskeyFunc();
            case TokenType.TOK_LOADIMAGE:
                return EvaluateLoadimageFunc();
            case TokenType.TOK_LOADSHAPE:
                return EvaluateLoadshapeFunc();
            case TokenType.TOK_POINT:
                return EvaluatePoint();
            case TokenType.TOK_MOUSEX:
                return EvaluateMousexFunc();
            case TokenType.TOK_MOUSEY:
                return EvaluateMouseyFunc();
            case TokenType.TOK_MOUSEB:
                return EvaluateMousebFunc();
            case TokenType.TOK_LOADSOUND:
                return EvaluateLoadSound();
            case TokenType.TOK_FILEREAD:
                return EvaluateFileRead();
            case TokenType.TOK_FILEEXISTS:
                return EvaluateFileExists();
            case TokenType.TOK_FN:
                return EvaluateUserFunction();
            
            // Time functions
            case TokenType.TOK_TIME:
                return EvaluateTimeFunc();
            case TokenType.TOK_TICKS:
                return EvaluateTicksFunc();
                
            default:
                return Value.Zero;
        }
    }

    private Value EvaluateVariableOrArray()
    {
        string varName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        // Check for built-in constant
        if (_builtinConstants.TryGetValue(varName, out double constVal))
        {
            return Value.FromNumber(constVal);
        }
        
        // Check for array access
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++;
            
            var indices = new List<string>();
            while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_RPAREN)
            {
                if (_tokens[_pos].Type == TokenType.TOK_COMMA)
                {
                    _pos++;
                    continue;
                }
                Value idx = EvaluateExpression();
                indices.Add(idx.AsString());
                
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
                    _pos++;
            }
            Require(TokenType.TOK_RPAREN);
            
            // Special stuff: LEN(array$())
            if (indices.Count == 0)
            {
                return Value.FromNumber(_variables.GetArrayLength(varName));
            }
            
            string key = string.Join(",", indices);
            try
            {
                return _variables.GetArrayElement(varName, key);
            }
            catch (InvalidOperationException ex)
            {
                Error(ex.Message);
                return Value.Zero;
            }
        }
        
        // Get var
        try
        {
            return _variables.GetVariable(varName);
        }
        catch (UndefinedVariableException)
        {
            Error($"Undefined variable: {varName}");
            return Value.Zero;
        }
    }

    private int CompareValues(Value left, Value right)
    {
        // Both same type - direct comparison
        if (left.Type == right.Type)
        {
            if (left.Type == BazzValueType.Number)
                return left.NumValue.CompareTo(right.NumValue);
            return string.Compare(left.AsString(), right.AsString(), StringComparison.OrdinalIgnoreCase);
        }
        
        // Mixed types, we try numeric comparison first
        // Trying convert string to number
        double leftNum, rightNum;
        bool leftIsNum = left.Type == BazzValueType.Number || 
            double.TryParse(left.AsString(), System.Globalization.NumberStyles.Any,
                System.Globalization.CultureInfo.InvariantCulture, out _);
        bool rightIsNum = right.Type == BazzValueType.Number ||
            double.TryParse(right.AsString(), System.Globalization.NumberStyles.Any,
                System.Globalization.CultureInfo.InvariantCulture, out _);
        
        if (leftIsNum && rightIsNum)
        {
            // Both can be treated as numbers
            // a$ = 123, b$ = "456" -> compare as numbers
            leftNum = left.Type == BazzValueType.Number ? left.NumValue : 
                double.Parse(left.AsString(), System.Globalization.CultureInfo.InvariantCulture);
            rightNum = right.Type == BazzValueType.Number ? right.NumValue :
                double.Parse(right.AsString(), System.Globalization.CultureInfo.InvariantCulture);
            return leftNum.CompareTo(rightNum);
        }
        
        // string comparison as fallback
        return string.Compare(left.AsString(), right.AsString(), StringComparison.OrdinalIgnoreCase);
    }
}
