/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Math.cs
 Lets do some math!
 Licence: MIT
*/


using BazzBasic.Lexer;
using BazzBasic.Parser;
//using System.Reflection.Metadata.Ecma335;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // # Helpers
    // HelperGetDouble
    //
    // # Math Functions in alphabetical order and so outdated list anyway
    // ABS
    // ATAN
    // CINT
    // CEIL
    // COS
    // EXP
    // INT
    // LOG
    // RND
    // ROUND
    // SGN
    // SIN
    // SQR
    // TAN
    // PI
    // ========================================================================

    private double HelperGetDouble() {
        Require(TokenType.TOK_LPAREN);
        double n = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        return n;
    }

    // ABS function
    private Value EvaluateAbsFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Abs(HelperGetDouble()));
    }

    // ATAN function
    private Value EvaluateAtanFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Atan(HelperGetDouble()));
    }

    // CINT function
    private Value EvaluateCintFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Round(HelperGetDouble(), MidpointRounding.AwayFromZero));
    }

    // CEIL function
    private Value EvaluateCeilFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Ceiling(HelperGetDouble()));
    }

    // COS function
    private Value EvaluateCosFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Cos(HelperGetDouble()));
    }

    // EXP function
    private Value EvaluateExpFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Exp(HelperGetDouble()));
    }

    // FLOOR function
    private Value EvaluateFloorFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Floor(HelperGetDouble()));
    }

    // INT function
    private Value EvaluateIntFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Truncate(HelperGetDouble()));
    }

    // LOG function
    private Value EvaluateLogFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Log(HelperGetDouble()));
    }

    // MAX function
    private Value EvaluateMaxFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double a = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double b = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        return Value.FromNumber(Math.Max(a, b));
    }

    // MIN function
    private Value EvaluateMinFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double a = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double b = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        return Value.FromNumber(Math.Min(a, b));
    }

    // MOD function
    private Value EvaluateModFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double a = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double b = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        return Value.FromNumber(a % b);
    }

    // PI function
    private Value EvaluatePiFunc()
    {
        _pos++;
        return Value.FromNumber(3.14159265358979);
    }

    // HPI function - Half PI (PI/2)
    private Value EvaluateHpiFunc()
    {
        _pos++;
        return Value.FromNumber(1.5707963267948966);
    }

    // RAD function - Convert degrees to radians
    private Value EvaluateRadFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double degrees = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        double radians = degrees * (Math.PI / 180.0);
        return Value.FromNumber(radians);
    }

    // DEG function - Convert radians to degrees
    private Value EvaluateDegFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double radians = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        double degrees = radians * (180.0 / Math.PI);
        return Value.FromNumber(degrees);
    }

    // POW function
    private Value EvaluatePowFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double a = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double b = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        return Value.FromNumber(Math.Pow(a, b));
    }

    // RND function
    private Value EvaluateRnd()
    {
        _pos++;
        double n = HelperGetDouble();

        if (n <= 0) return Value.FromNumber(_random.NextDouble());
        return Value.FromNumber(_random.Next((int)n));
    }

    // ROUND function
    private Value EvaluateRoundFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Round(HelperGetDouble()));
    }

    // SGN function
    private Value EvaluateSgnFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Sign(HelperGetDouble()));
    }

    // SIN function
    private Value EvaluateSinFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Sin(HelperGetDouble()));
    }

    // SQR function
    private Value EvaluateSqrFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Sqrt(HelperGetDouble()));
    }

    // TAN function
    private Value EvaluateTanFunc()
    {
        _pos++;
        return Value.FromNumber(Math.Tan(HelperGetDouble()));
    }
}
