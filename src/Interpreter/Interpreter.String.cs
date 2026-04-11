/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.String.cs
 String stuff

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
    // String Functions in most likely outdated list order
    // ========================================================================
    // 
    // Before 1.0, adjust these alphabetically
    // TOK_ASC,
    // TOK_CHR,
    // TOK_INSTR,
    // TOK_INVERT,
    // TOK_LCASE,
    // TOK_LEFT,
    // TOK_LEN,
    // TOK_LTRIM,
    // TOK_MID,
    // TOK_REPEAT,
    // TOK_RIGHT,
    // TOK_RTRIM,
    // TOK_SRAND
    // TOK_STR,
    // TOK_TRIM,
    // TOK_UCASE,
    // TOK_VAL,

    private Value EvaluateAscFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string s = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        return Value.FromNumber(s.Length > 0 ? s[0] : 0);
    }

    private Value EvaluateChrFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        int code = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        return Value.FromString(((char)code).ToString());
    }

    private Value EvaluateInstrFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);

        // Collect all parameters into a list first
        var parms = new List<Value>();
        while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_RPAREN)
        {
            if (_tokens[_pos].Type == TokenType.TOK_COMMA) { _pos++; continue; }
            parms.Add(EvaluateExpression());
        }
        Require(TokenType.TOK_RPAREN);

        if (parms.Count < 2)
        {
            Error("INSTR: expected at least 2 arguments");
            return Value.Zero;
        }

        string haystack, needle;
        int startPos = 0;
        bool ignoreCase = false;

        if (parms.Count == 2)
        {
            // INSTR(haystack, needle) — case-sensitive
            haystack = parms[0].AsString();
            needle   = parms[1].AsString();
        }
        else if (parms.Count == 3)
        {
            // Distinguish by type of 3rd param:
            //   Number → INSTR(haystack, needle, flag)   0=case-insensitive, 1=case-sensitive
            //   String → INSTR(start, haystack, needle)  1-based start
            if (parms[2].Type == BazzValueType.Number)
            {
                haystack   = parms[0].AsString();
                needle     = parms[1].AsString();
                ignoreCase = parms[2].AsNumber() == 0;
            }
            else
            {
                startPos = (int)parms[0].AsNumber() - 1; // convert to 0-based
                haystack = parms[1].AsString();
                needle   = parms[2].AsString();
            }
        }
        else // 4+ params: INSTR(start, haystack, needle, flag)
        {
            startPos   = (int)parms[0].AsNumber() - 1;
            haystack   = parms[1].AsString();
            needle     = parms[2].AsString();
            ignoreCase = parms[3].AsNumber() == 0;
        }

        if (startPos < 0 || startPos >= haystack.Length)
            return Value.Zero;

        var comparison = ignoreCase ? StringComparison.OrdinalIgnoreCase : StringComparison.Ordinal;
        int idx = haystack.IndexOf(needle, startPos, comparison);
        return Value.FromNumber(idx == -1 ? 0 : idx + 1);
    }

    private Value EvaluateInvertFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string toInvert = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);

        if (toInvert.Length < 2)
        {
            return Value.FromString(toInvert);
        }

        return Value.FromString(new string([.. toInvert.Reverse()]));
    }

    private Value EvaluateLcaseFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string s = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        return Value.FromString(s.ToLowerInvariant());
    }

    private Value EvaluateLeftFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string s = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        int n = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);

        if (n <= 0) return Value.FromString("");
        if (n >= s.Length) return Value.FromString(s);
        return Value.FromString(s[..n]);
    }

    private Value EvaluateLenFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);

        // Special case: LEN(array$()) for array length
        if (_pos < _tokens.Count &&
            (_tokens[_pos].Type == TokenType.TOK_VARIABLE || _tokens[_pos].Type == TokenType.TOK_CONSTANT))
        {
            string varName = _tokens[_pos].StringValue ?? "";
            int savedPos = _pos;
            _pos++;

            // Check for empty parentheses: arr$()
            if (_pos + 1 < _tokens.Count &&
                _tokens[_pos].Type == TokenType.TOK_LPAREN &&
                _tokens[_pos + 1].Type == TokenType.TOK_RPAREN)
            {
                _pos += 2; // Skip ()
                Require(TokenType.TOK_RPAREN); // Skip outer )
                return Value.FromNumber(_variables.GetArrayLength(varName));
            }

            // Not array length, restore and evaluate normally
            _pos = savedPos;
        }

        Value v = EvaluateExpression();
        Require(TokenType.TOK_RPAREN);
        return Value.FromNumber(v.AsString().Length);
    }

    private Value EvaluateLtrimFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string toTrim = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        return Value.FromString(toTrim.TrimStart());
    }

    private Value EvaluateMidFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string s = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        int start = (int)EvaluateExpression().AsNumber() - 1; // 1-based
        int len = s.Length - start;

        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++;
            len = (int)EvaluateExpression().AsNumber();
        }
        Require(TokenType.TOK_RPAREN);

        if (start < 0 || start >= s.Length) return Value.FromString("");
        if (start + len > s.Length) len = s.Length - start;
        return Value.FromString(s.Substring(start, len));
    }

    private Value EvaluateRepeatFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string toRepeat = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        int timesTo = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);

        string repTemp = "";
        for (int i = 0; i < timesTo; i++)
        {
            repTemp += toRepeat;
        }
        return Value.FromString(repTemp);
    }

    private Value EvaluateReplaceFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string source = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        string oldValue = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        string newValue = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        
        return Value.FromString(source.Replace(oldValue, newValue));
    }

    private Value EvaluateRightFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string s = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        int n = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);

        if (n <= 0) return Value.FromString("");
        if (n >= s.Length) return Value.FromString(s);
        return Value.FromString(s[^n..]);
    }

    private Value EvaluateRtrimFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string toTrim = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        return Value.FromString(toTrim.TrimEnd());
    }

    // SRAND returns a random string of length r
    private Value EvaluateSrandFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        int length = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);

        // adjusted as raw string generation
        const string chars = """ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890!@#£$%&/{([)]=}?+-_""";
        var random = new Random();
        var result = new char[length];
        for (int i = 0; i < length; i++)
        {
            result[i] = chars[random.Next(chars.Length)];
        }
        return Value.FromString(new string(result));
    }

    private Value EvaluateSplitFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        
        // Get the array variable name
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("SPLIT requires array variable as first parameter");
            return Value.Zero;
        }
        
        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_COMMA);
        
        // Get string to split
        string text = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        
        // Get delimiter
        string delimiter = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        
        // Ensure array exists
        if (!_variables.ArrayExists(arrayName))
        {
            _variables.DeclareArray(arrayName);
        }
        
        // Split and populate array
        string[] parts = text.Split(delimiter);
        for (int i = 0; i < parts.Length; i++)
        {
            _variables.SetArrayElement(arrayName, i.ToString(), Value.FromString(parts[i]));
        }
        
        // Return number of parts
        return Value.FromNumber(parts.Length);
    }
    private Value EvaluateStrFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        double n = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        return Value.FromString(n.ToString(System.Globalization.CultureInfo.InvariantCulture));
    }

    private Value EvaluateTrimFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string toTrim = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        return Value.FromString(toTrim.Trim());
    }

    private Value EvaluateUcaseFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string s = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        return Value.FromString(s.ToUpperInvariant());
    }

    private Value EvaluateValFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        string s = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);

        if (double.TryParse(s, System.Globalization.NumberStyles.Any,
            System.Globalization.CultureInfo.InvariantCulture, out double result))
            return Value.FromNumber(result);
        return Value.Zero;
    }
}
