/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Functions.cs
 User Functions

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
    // User-Defined Functions (DEF FN / END DEF)
    // ========================================================================
    
    private void ExecuteDefFn()
    {
        _pos++;
        
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_FN)
        {
            Error("Expected FN after DEF");
            return;
        }
        _pos++;
        
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("Expected function name after DEF FN");
            return;
        }
        
        string funcName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        var parameters = new List<string>();
        if (Expect(TokenType.TOK_LPAREN))
        {
            while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_RPAREN)
            {
                if (_tokens[_pos].Type == TokenType.TOK_COMMA)
                {
                    _pos++;
                    continue;
                }
                if (_tokens[_pos].Type == TokenType.TOK_VARIABLE)
                {
                    parameters.Add(_tokens[_pos].StringValue ?? "");
                    _pos++;
                }
                else
                {
                    _pos++;
                }
            }
            Require(TokenType.TOK_RPAREN);
        }
        
        int startPos = _pos;
        int endPos = FindEndDef(startPos);
        
        if (endPos < 0)
        {
            Error($"END DEF missing for function: {funcName}");
            return;
        }
        
        _functions[funcName] = new UserFunction
        {
            Name = funcName,
            Parameters = [.. parameters],
            StartPosition = startPos,
            EndPosition = endPos
        };
        
        _pos = endPos;
        SkipToNextLine();
    }

    private int FindEndDef(int startPos)
    {
        int depth = 1;
        int pos = startPos;
        
        while (pos < _tokens.Count && depth > 0)
        {
            if (_tokens[pos].Type == TokenType.TOK_DEF)
            {
                depth++;
            }
            else if (_tokens[pos].Type == TokenType.TOK_END)
            {
                if (pos + 1 < _tokens.Count && _tokens[pos + 1].Type == TokenType.TOK_DEF)
                {
                    depth--;
                    if (depth == 0)
                        return pos;
                }
            }
            pos++;
        }
        
        return -1;
    }

    private Value EvaluateUserFunction()
    {
        _pos++;
        
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("Expected function name after FN");
            return Value.Zero;
        }
        
        string funcName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        var args = new List<Value>();
        if (Expect(TokenType.TOK_LPAREN))
        {
            while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_RPAREN)
            {
                if (_tokens[_pos].Type == TokenType.TOK_COMMA)
                {
                    _pos++;
                    continue;
                }
                args.Add(EvaluateExpression());
                
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
                    _pos++;
            }
            Require(TokenType.TOK_RPAREN);
        }
        
        return CallUserFunction(funcName, args);
    }

    private Value CallUserFunction(string funcName, List<Value> args)
    {
        if (!_functions.TryGetValue(funcName, out UserFunction func))
        {
            Error($"Function not found: {funcName}");
            return Value.Zero;
        }
        
        int savedPos = _pos;
        bool savedRunning = _running;
        
        _variables.PushScope();
        
        for (int i = 0; i < func.Parameters.Length; i++)
        {
            Value argVal = i < args.Count ? args[i] : Value.Zero;
            _variables.SetLocal(func.Parameters[i], argVal);
        }
        
        _pos = func.StartPosition;
        _running = true;
        _inFunction = true;
        _functionStartPos = func.StartPosition;
        _functionEndPos = func.EndPosition;
        _returnValue = Value.Zero;
        
        while (_running && !_hasError && _pos < func.EndPosition)
        {
            ExecuteStatement();
        }
        
        _variables.PopScope();
        _pos = savedPos;
        _running = !_hasError && savedRunning;
        _inFunction = false;
        
        return _returnValue;
    }
}
