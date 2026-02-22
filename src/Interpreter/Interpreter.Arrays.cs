/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Arrays.cs
 Array Operations

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
    // ========================================================================
    // Array Operations
    // ========================================================================

    // Create a new array variable
    private void ExecuteDim()
    {
        _pos++;
        
        while (_pos < _tokens.Count)
        {
            if (_tokens[_pos].Type == TokenType.TOK_NEWLINE || _tokens[_pos].Type == TokenType.TOK_EOF)
                break;
            
            if (_tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
                continue;
            }
            
            if (_tokens[_pos].Type == TokenType.TOK_VARIABLE)
            {
                string arrName = _tokens[_pos].StringValue ?? "";
                _variables.DeclareArray(arrName);
                _pos++;

                // Handle optional: DIM arr$ = expression
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_EQUALS)
                {
                    _pos++; // skip '='
                    Value val = EvaluateExpression();
                    string str = val.AsString();

                    // If value looks like key=value lines, populate as array
                    if (TryPopulateArrayFromKeyValue(arrName, str))
                        continue;

                    // Otherwise store as single element with key "0"
                    _variables.SetArrayElement(arrName, "0", val);
                }
            }
            else
            {
                _pos++;
            }
        }
    }

    // Parse "key=value\nkey=value\n..." string into array elements.
    // Returns true if content looked like key=value format.
    private bool TryPopulateArrayFromKeyValue(string arrName, string content)
    {
        var lines = content.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return false;

        // All lines must contain exactly one '=' to qualify
        foreach (var line in lines)
        {
            int eq = line.IndexOf('=');
            if (eq <= 0) return false;
        }

        foreach (var line in lines)
        {
            string trimmed = line.TrimEnd('\r');
            int eq = trimmed.IndexOf('=');
            string key = trimmed[..eq];
            string value = trimmed[(eq + 1)..];

            // Store as number if possible, otherwise as string
            if (double.TryParse(value, System.Globalization.NumberStyles.Any,
                System.Globalization.CultureInfo.InvariantCulture, out double num))
                _variables.SetArrayElement(arrName, key, Value.FromNumber(num));
            else
                _variables.SetArrayElement(arrName, key, Value.FromString(value));
        }
        return true;
    }

    // Delete a specific key from an array
    private void ExecuteDelKey()
    {
        _pos++;
        
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("Expected array name after DELKEY");
            return;
        }
        
        string arrName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        if (!Expect(TokenType.TOK_LPAREN))
        {
            Error("Expected ( after array name");
            return;
        }
        
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
        
        string key = string.Join(",", indices);
        _variables.DeleteKey(arrName, key);
    }

    // Delete an entire array variable
    private void ExecuteDelArray()
    {
        _pos++;
        
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("Expected array name after DELARRAY");
            return;
        }
        
        string arrName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        if (!_variables.ArrayExists(arrName))
        {
            Error($"Array not found: {arrName}");
            return;
        }
        
        _variables.DeleteArray(arrName);
    }

    // Check if a specific key exists in an array
    private Value EvaluateHaskeyFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
            return Value.Zero;
        
        string arrName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        Require(TokenType.TOK_LPAREN);
        string key = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        Require(TokenType.TOK_RPAREN);
        
        return Value.FromNumber(_variables.HasKey(arrName, key) ? 1 : 0);
    }
}
