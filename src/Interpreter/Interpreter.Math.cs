/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Math.cs
 
 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
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
    // Before 1.0, adjust these alphabetically
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
    // HPI
    // QPI
    // TAU
    // BETWEEN
    // EULER
    // CLAMP
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

    // CLAMP function
    private Value EvaluateClampFunc()
    {
        _pos++; // Skip 'CLAMP'

        if (_tokens[_pos].Type != TokenType.TOK_LPAREN)
            Error("Expected '(' after CLAMP");
        _pos++;

        double value = EvaluateExpression().AsNumber();

        if (_tokens[_pos].Type != TokenType.TOK_COMMA)
            Error("Expected ',' in CLAMP");
        _pos++;

        double min = EvaluateExpression().AsNumber();

        if (_tokens[_pos].Type != TokenType.TOK_COMMA)
            Error("Expected ',' in CLAMP");
        _pos++;

        double max = EvaluateExpression().AsNumber();

        if (_tokens[_pos].Type != TokenType.TOK_RPAREN)
            Error("Expected ')' after CLAMP");
        _pos++;

        // Clamp logic
        if (value < min) return Value.FromNumber(min);
        if (value > max) return Value.FromNumber(max);
        return Value.FromNumber(value);
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

    // LERP function - Linear interpolation between two values
    private Value EvaluateLerpFunc()
    {
        _pos++; // Skip 'LERP'

        if (_tokens[_pos].Type != TokenType.TOK_LPAREN)
            Error("Expected '(' after LERP");
        _pos++;

        double start = EvaluateExpression().AsNumber();

        if (_tokens[_pos].Type != TokenType.TOK_COMMA)
            Error("Expected ',' in LERP");
        _pos++;

        double end = EvaluateExpression().AsNumber();

        if (_tokens[_pos].Type != TokenType.TOK_COMMA)
            Error("Expected ',' in LERP");
        _pos++;

        double t = EvaluateExpression().AsNumber();

        if (_tokens[_pos].Type != TokenType.TOK_RPAREN)
            Error("Expected ')' after LERP");
        _pos++;

        // LERP formula: start + (end - start) * t
        double result = start + (end - start) * t;

        return Value.FromNumber(result);
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

    // QPI function - (PI/4)
    private Value EvaluateQpiFunc()
    {
        _pos++;
        return Value.FromNumber(0.7853981633974475);
    }

    // TAU function - (PI*2)
    private Value EvaluateTauFunc()
    {
        _pos++;
        return Value.FromNumber(6.28318530717958);
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

    // BETWEEN function - Check if a value is between two others (inclusive)
    private Value EvaluateBetweenFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double value = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double lower = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double upper = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        return Value.FromNumber((value >= lower && value <= upper) ? 1 : 0);
    }

    // EULER function - Euler's number (e)
    private Value EvaluateEulerFunc()
    {
        _pos++;
        return Value.FromNumber(2.718281828459045);
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

    // DISTANCE function - Euclidean distance (2D or 3D)
    // DISTANCE(x1, y1, x2, y2)          → 2D distance
    // DISTANCE(x1, y1, z1, x2, y2, z2)  → 3D distance
    private Value EvaluateDistanceFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after DISTANCE");

        double p1 = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA, "Expected ',' in DISTANCE parameters");
        double p2 = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA, "Expected ',' in DISTANCE parameters");
        double p3 = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA, "Expected ',' in DISTANCE parameters");
        double p4 = EvaluateExpression().AsNumber();

        // Check for 5th and 6th parameters (3D mode)
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++; // Skip comma
            double p5 = EvaluateExpression().AsNumber();
            Require(TokenType.TOK_COMMA, "Expected 6th parameter for 3D DISTANCE");
            double p6 = EvaluateExpression().AsNumber();
            Require(TokenType.TOK_RPAREN, "Expected ')' after DISTANCE parameters");

            // 3D: DISTANCE(x1, y1, z1, x2, y2, z2)
            double dx = p4 - p1;
            double dy = p5 - p2;
            double dz = p6 - p3;
            return Value.FromNumber(Math.Sqrt(dx * dx + dy * dy + dz * dz));
        }

        Require(TokenType.TOK_RPAREN, "Expected ')' after DISTANCE parameters");

        // 2D: DISTANCE(x1, y1, x2, y2)
        double dx2 = p3 - p1;
        double dy2 = p4 - p2;
        return Value.FromNumber(Math.Sqrt(dx2 * dx2 + dy2 * dy2));
    }
}
