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
using System.Linq;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // Array Operations
    // ========================================================================

    // Create new array variables: DIM name$ [(size)] [= value] {, name$ ...}
    // The statement ends at end of line, ':' or ELSE (one-line IF), like PRINT.
    // The size in parentheses is accepted and ignored (arrays grow as needed);
    // nothing inside it is declared or evaluated: DIM b$(n$) declares only B$.
    private void ExecuteDim()
    {
        _pos++;

        while (!_hasError)
        {
            if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
            {
                string found = _pos < _tokens.Count ? DescribeToken(_tokens[_pos]) : "end of file";
                Error($"DIM: expected an array name ending in $, got {found}");
                return;
            }

            string arrName = _tokens[_pos].StringValue ?? "";
            _variables.DimArray(arrName);
            _pos++;

            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
            {
                // Optional size: DIM a$(10), DIM m$(10, 10), DIM b$(n$ + 1)
                SkipDimSize();
                if (_hasError) return;
            }
            else if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_EQUALS)
            {
                // Optional value: DIM arr$ = expression
                _pos++; // skip '='
                Value val = EvaluateExpression();
                if (_hasError) return;

                // key=value lines fill named keys, anything else goes to key "0"
                if (!TryPopulateArrayFromKeyValue(arrName, val.AsString()))
                    _variables.SetArrayElement(arrName, "0", val);
            }

            if (IsEndOfStatement() || _tokens[_pos].Type == TokenType.TOK_ELSE)
                return;

            if (_tokens[_pos].Type != TokenType.TOK_COMMA)
            {
                Error($"DIM: expected ',' or end of statement after {arrName}, got {DescribeToken(_tokens[_pos])}");
                return;
            }
            _pos++; // skip ','
        }
    }

    // Skip a balanced "( ... )" after a DIM name without evaluating it.
    // A missing ')' is reported on the line of the '('.
    private void SkipDimSize()
    {
        int open = _pos;
        int depth = 0;
        while (_pos < _tokens.Count)
        {
            TokenType t = _tokens[_pos].Type;
            if (t == TokenType.TOK_NEWLINE || t == TokenType.TOK_EOF || t == TokenType.TOK_COLON)
                break;
            _pos++;
            if (t == TokenType.TOK_LPAREN)
                depth++;
            else if (t == TokenType.TOK_RPAREN && --depth == 0)
                return;
        }
        _pos = open;
        Error("DIM: missing ')' after the array size");
    }

    // Parse "key=value\nkey=value\n..." string into array elements.
    // Returns true if content looked like key=value format.
    private bool TryPopulateArrayFromKeyValue(string arrName, string content)
    {
        var rawLines = content.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (rawLines.Length == 0) return false;

        // Blank lines already dropped above. Also skip full-line comments ('#').
        // Inline comments (KEY=value # note) are NOT handled yet.
        var lines = rawLines
            .Where(l => !l.TrimEnd('\r').TrimStart().StartsWith('#'))
            .ToArray();
        if (lines.Length == 0) return false;

        // All remaining lines must contain exactly one '=' to qualify
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
        while (_pos < _tokens.Count && !_hasError && _tokens[_pos].Type != TokenType.TOK_RPAREN)
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

    // Merge two arrays into a destination array.
    // Keys from src2 overwrite matching keys from src1.
    // JOIN dest$, src1$, src2$
    private void ExecuteJoin()
    {
        _pos++;

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("JOIN: expected destination array name");
            return;
        }
        string destName = _tokens[_pos].StringValue ?? "";
        _pos++;

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_COMMA)
        {
            Error("JOIN: expected comma after destination array");
            return;
        }
        _pos++;

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("JOIN: expected first source array name");
            return;
        }
        string src1Name = _tokens[_pos].StringValue ?? "";
        _pos++;

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_COMMA)
        {
            Error("JOIN: expected comma after first source array");
            return;
        }
        _pos++;

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("JOIN: expected second source array name");
            return;
        }
        string src2Name = _tokens[_pos].StringValue ?? "";
        _pos++;

        var src1 = _variables.GetAllArrayElements(src1Name);
        var src2 = _variables.GetAllArrayElements(src2Name);

        if (src1 == null) { Error($"JOIN: array not found: {src1Name}"); return; }
        if (src2 == null) { Error($"JOIN: array not found: {src2Name}"); return; }

        if (!_variables.ArrayExists(destName))
            _variables.DeclareArray(destName);

        foreach (var kvp in src1)
            _variables.SetArrayElement(destName, kvp.Key, kvp.Value);

        foreach (var kvp in src2)
            _variables.SetArrayElement(destName, kvp.Key, kvp.Value);
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

    // Return number of unique first-dimension rows in a 2D array
    // Syntax: ROWCOUNT(arr$())
    private Value EvaluateRowCount()
    {
        _pos++; // consume TOK_ROWCOUNT
        Require(TokenType.TOK_LPAREN);

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("ROWCOUNT: expected array name");
            return Value.Zero;
        }
        string arrName = _tokens[_pos].StringValue ?? "";
        _pos++;

        Require(TokenType.TOK_LPAREN);  // inner (
        Require(TokenType.TOK_RPAREN);  // inner )
        Require(TokenType.TOK_RPAREN);  // outer )

        return Value.FromNumber(_variables.GetArrayRowCount(arrName));
    }

    // Return the key at a given 0-based index in insertion order.
    // Pairs with LEN(arr$()) to loop over associative arrays with FOR/NEXT or WHILE/WEND.
    // Syntax: ARRKEY(arr$(), i)
    private Value EvaluateArrKeyFunc()
    {
        _pos++; // consume TOK_ARRKEY
        Require(TokenType.TOK_LPAREN);

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("ARRKEY: expected array name");
            return Value.Empty;
        }
        string arrName = _tokens[_pos].StringValue ?? "";
        _pos++;

        Require(TokenType.TOK_LPAREN);  // inner (
        Require(TokenType.TOK_RPAREN);  // inner )  -- empty parens: whole array, not one element

        Require(TokenType.TOK_COMMA);
        int index = (int)EvaluateExpression().AsNumber();

        Require(TokenType.TOK_RPAREN);  // outer )

        string? key = _variables.GetArrayKeyAt(arrName, index);
        if (key == null)
        {
            Error($"ARRKEY: index {index} out of range for array {arrName}");
            return Value.Empty;
        }
        return Value.FromString(key);
    }
}
