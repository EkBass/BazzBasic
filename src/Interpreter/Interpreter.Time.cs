/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Time.cs
 Time functions: TIME and TICKS

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    /* ========================================================================
     Time Functions
     TIME(format$) - Returns formatted date/time string using .NET format
     TICKS - Returns milliseconds since program start
     ========================================================================
     TIME(format$) - Returns current date/time formatted using .NET DateTime format strings.
     Examples:
       TIME("HH:mm:ss")      -> "15:21:22"
       TIME("dd.MM.yyyy")    -> "09.01.2026"
       TIME("dddd")          -> "Friday"
       TIME("MMMM")          -> "January"
       TIME()                -> Default format "HH:mm:ss" */
    private Value EvaluateTimeFunc()
    {
        _pos++; // Skip TIME token
        
        string format = "HH:mm:ss"; // Default format in european style (24-hour)

        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++; // Skip (
            
            // Check if empty parentheses TIME()
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_RPAREN)
            {
                _pos++; // Skip )
            }
            else
            {
                // Get format string
                format = EvaluateExpression().AsString();
                Require(TokenType.TOK_RPAREN);
            }
        }
        
        try
        {
            string result = DateTime.Now.ToString(format);
            return Value.FromString(result);
        }
        catch (FormatException)
        {
            Error($"Invalid TIME format: {format}");
            return Value.Empty;
        }
    }


    // TICKS - Returns milliseconds elapsed since program started.
    // Useful for timing, animations, and game loops.
    private Value EvaluateTicksFunc()
    {
        _pos++; // Skip TICKS token
        
        // Allow optional empty parentheses: TICKS or TICKS()
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++; // Skip (
            Require(TokenType.TOK_RPAREN);
        }
        
        return Value.FromNumber(_programTimer.ElapsedMilliseconds);
    }
}
