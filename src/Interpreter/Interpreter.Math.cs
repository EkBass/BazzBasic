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

    // ========================================================================
    // FastTrig - Lookup table based trigonometry for graphics/games
    // ========================================================================

    // FASTTRIG statement - Enable/disable fast trig lookup tables
    private void ExecuteFastTrig()
    {
        _pos++; // Skip TOK_FASTTRIG
        Require(TokenType.TOK_LPAREN, "Expected '(' after FASTTRIG");
        bool enable = EvaluateExpression().AsNumber() != 0; // TRUE = non-zero
        Require(TokenType.TOK_RPAREN, "Expected ')' after FASTTRIG parameter");
        
        if (enable && !_fastTrigEnabled)
        {
            // Create and populate lookup tables
            _fastSinTable = new double[360];
            _fastCosTable = new double[360];
            
            for (int i = 0; i < 360; i++)
            {
                double radians = i * (Math.PI / 180.0);
                _fastSinTable[i] = Math.Sin(radians);
                _fastCosTable[i] = Math.Cos(radians);
            }
            
            _fastTrigEnabled = true;
        }
        else if (!enable && _fastTrigEnabled)
        {
            // Destroy lookup tables and free memory
            _fastSinTable = null;
            _fastCosTable = null;
            _fastTrigEnabled = false;
        }
    }

    // FastSin function - Fast sine lookup (1 degree precision)
    private Value EvaluateFastSin()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after FASTSIN");
        double angle = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN, "Expected ')' after FASTSIN parameter");
        
        if (!_fastTrigEnabled || _fastSinTable == null)
        {
            int line = _pos < _tokens.Count ? _tokens[_pos].Line : 0;
            throw new Exception($"Line {line}: FastTrig not enabled. Call FASTTRIG(TRUE) first.");
        }
        
        // Normalize angle to 0-359 range
        int index = ((int)Math.Round(angle) % 360 + 360) % 360;
        return Value.FromNumber(_fastSinTable[index]);
    }

    // FastCos function - Fast cosine lookup (1 degree precision)
    private Value EvaluateFastCos()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after FASTCOS");
        double angle = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN, "Expected ')' after FASTCOS parameter");
        
        if (!_fastTrigEnabled || _fastCosTable == null)
        {
            int line = _pos < _tokens.Count ? _tokens[_pos].Line : 0;
            throw new Exception($"Line {line}: FastTrig not enabled. Call FASTTRIG(TRUE) first.");
        }
        
        int index = ((int)Math.Round(angle) % 360 + 360) % 360;
        return Value.FromNumber(_fastCosTable[index]);
    }

    // FastRad function - Fast degree to radian conversion (1 degree precision)
    private Value EvaluateFastRad()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after FASTRAD");
        double angle = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN, "Expected ')' after FASTRAD parameter");
        
        // Normalize and convert using pre-calculated constant
        int index = ((int)Math.Round(angle) % 360 + 360) % 360;
        return Value.FromNumber(index * 0.017453292519943295); // PI/180
    }
}
