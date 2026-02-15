/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Control.cs
 Control Flow

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
    // IF / ELSEIF / ELSE / ENDIF
    // ========================================================================
    
    private void ExecuteIf()
    {
        _pos++;
        
        Value condition = EvaluateExpression();
        
        if (!Expect(TokenType.TOK_THEN))
        {
            Error("Expected THEN after IF condition");
            return;
        }
        
        bool isBlockIf = IsEndOfStatement();
        
        if (isBlockIf)
        {
            _ifStack.Push(condition.IsTrue());
            
            if (!condition.IsTrue())
            {
                SkipToElseOrEndIf();
            }
        }
        else
        {
            if (condition.IsTrue())
            {
                ExecuteOneLineIfThen();
                SkipPastElseClause();
            }
            else
            {
                SkipToElseOnLine();
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_ELSE)
                {
                    _pos++;
                    ExecuteOneLineIfThen();
                }
            }
        }
    }

    private void ExecuteOneLineIfThen()
    {
        while (_pos < _tokens.Count)
        {
            Token token = _tokens[_pos];
            
            if (token.Type == TokenType.TOK_NEWLINE || token.Type == TokenType.TOK_EOF ||
                token.Type == TokenType.TOK_ELSE)
                break;
            
            if (token.Type == TokenType.TOK_GOTO)
            {
                ExecuteGoto();
                return;
            }
            else if (token.Type == TokenType.TOK_GOSUB)
            {
                ExecuteGosub();
                return;
            }
            else if (token.Type == TokenType.TOK_END)
            {
                _pos++;
                _running = false;
                return;
            }
            else if (token.Type == TokenType.TOK_LABEL)
            {
                string labelName = token.StringValue ?? "";
                if (_labels.TryGetValue(labelName, out int targetPos))
                {
                    _pos = targetPos;
                    return;
                }
                _pos++;
            }
            else
            {
                ExecuteStatement();
            }
        }
    }

    private void SkipToElseOnLine()
    {
        while (_pos < _tokens.Count)
        {
            Token token = _tokens[_pos];
            if (token.Type == TokenType.TOK_NEWLINE || token.Type == TokenType.TOK_EOF ||
                token.Type == TokenType.TOK_ELSE)
                return;
            _pos++;
        }
    }

    private void SkipPastElseClause()
    {
        while (_pos < _tokens.Count)
        {
            Token token = _tokens[_pos];
            if (token.Type == TokenType.TOK_NEWLINE || token.Type == TokenType.TOK_EOF)
                return;
            _pos++;
        }
    }

    private void ExecuteElse()
    {
        _pos++;
        
        if (_ifStack.Count > 0 && _ifStack.Peek())
        {
            SkipToEndIf();
        }
    }

    private void ExecuteElseIf()
    {
        _pos++;
        
        if (_ifStack.Count > 0 && _ifStack.Peek())
        {
            SkipToEndIf();
            return;
        }
        
        Value condition = EvaluateExpression();
        Require(TokenType.TOK_THEN);
        
        if (_ifStack.Count > 0)
        {
            _ifStack.Pop();
            _ifStack.Push(condition.IsTrue());
        }
        
        if (!condition.IsTrue())
        {
            SkipToElseOrEndIf();
        }
    }

    private void ExecuteEndIf()
    {
        if (_ifStack.Count > 0)
            _ifStack.Pop();
    }

    private void SkipToElseOrEndIf()
    {
        int depth = 1;
        
        while (_pos < _tokens.Count && depth > 0)
        {
            SkipNewlines();
            if (_pos >= _tokens.Count) break;
            
            Token token = _tokens[_pos];
            
            if (token.Type == TokenType.TOK_IF)
            {
                int savedPos = _pos;
                _pos++;
                while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_THEN && 
                       _tokens[_pos].Type != TokenType.TOK_NEWLINE)
                    _pos++;
                
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_THEN)
                {
                    _pos++;
                    if (IsEndOfStatement())
                        depth++;
                }
                _pos = savedPos;
            }
            else if (token.Type == TokenType.TOK_ENDIF)
            {
                depth--;
                if (depth == 0) return;
            }
            else if (token.Type == TokenType.TOK_END)
            {
                _pos++;
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_IF)
                {
                    depth--;
                    if (depth == 0)
                    {
                        _pos--;
                        return;
                    }
                }
                _pos--;
            }
            else if (token.Type == TokenType.TOK_ELSE || token.Type == TokenType.TOK_ELSEIF)
            {
                if (depth == 1) return;
            }
            
            _pos++;
        }
    }

    private void SkipToEndIf()
    {
        int depth = 1;
        
        while (_pos < _tokens.Count && depth > 0)
        {
            Token token = _tokens[_pos];
            
            if (token.Type == TokenType.TOK_IF)
            {
                int savedPos = _pos;
                _pos++;
                while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_THEN && 
                       _tokens[_pos].Type != TokenType.TOK_NEWLINE)
                    _pos++;
                
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_THEN)
                {
                    _pos++;
                    if (IsEndOfStatement())
                        depth++;
                }
                _pos = savedPos;
            }
            else if (token.Type == TokenType.TOK_ENDIF)
            {
                depth--;
                if (depth == 0) return;
            }
            else if (token.Type == TokenType.TOK_END)
            {
                _pos++;
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_IF)
                {
                    depth--;
                    if (depth == 0)
                    {
                        _pos--;
                        return;
                    }
                }
                _pos--;
            }
            
            _pos++;
        }
    }

    // ========================================================================
    // FOR / NEXT
    // ========================================================================
    
    private void ExecuteFor()
    {
        _pos++;
        
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("Expected variable after FOR");
            return;
        }
        
        string varName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        Require(TokenType.TOK_EQUALS);
        double startVal = EvaluateExpression().AsNumber();
        
        if (!Expect(TokenType.TOK_TO))
        {
            Error("Expected TO in FOR statement");
            return;
        }
        
        double endVal = EvaluateExpression().AsNumber();
        
        double stepVal = 1;
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_STEP)
        {
            _pos++;
            stepVal = EvaluateExpression().AsNumber();
        }
        
        _variables.SetVariable(varName, Value.FromNumber(startVal));
        
        bool shouldExecute = (stepVal > 0 && startVal <= endVal) || (stepVal < 0 && startVal >= endVal);
        
        if (shouldExecute)
        {
            _forStack.Push(new ForState
            {
                VarName = varName,
                EndValue = endVal,
                StepValue = stepVal,
                LoopPosition = _pos
            });
        }
        else
        {
            SkipToNext();
        }
    }

    private void ExecuteNext()
    {
        _pos++;
        
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_VARIABLE)
            _pos++;
        
        if (_forStack.Count == 0)
        {
            Error("NEXT without FOR");
            return;
        }
        
        ForState state = _forStack.Pop();
        double currentVal = _variables.GetVariable(state.VarName).AsNumber();
        currentVal += state.StepValue;
        
        bool done = (state.StepValue > 0 && currentVal > state.EndValue) ||
                    (state.StepValue < 0 && currentVal < state.EndValue);
        
        if (done)
        {
            // Loop complete
        }
        else
        {
            _variables.SetVariable(state.VarName, Value.FromNumber(currentVal));
            _forStack.Push(state);
            _pos = state.LoopPosition;
        }
    }

    private void SkipToNext()
    {
        int depth = 1;
        while (_pos < _tokens.Count && depth > 0)
        {
            if (_tokens[_pos].Type == TokenType.TOK_FOR)
                depth++;
            else if (_tokens[_pos].Type == TokenType.TOK_NEXT)
            {
                depth--;
                if (depth == 0)
                {
                    _pos++;
                    if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_VARIABLE)
                        _pos++;
                    return;
                }
            }
            _pos++;
        }
    }

    // ========================================================================
    // WHILE / WEND
    // ========================================================================
    
    private void ExecuteWhile()
    {
        int whilePos = _pos;
        _pos++;
        
        Value condition = EvaluateExpression();
        
        if (condition.IsTrue())
        {
            _whileStack.Push(whilePos);
        }
        else
        {
            SkipToWend();
        }
    }

    private void ExecuteWend()
    {
        _pos++;
        
        if (_whileStack.Count == 0)
        {
            Error("WEND without WHILE");
            return;
        }
        
        int whilePos = _whileStack.Pop();
        _pos = whilePos;
    }

    private void SkipToWend()
    {
        int depth = 1;
        while (_pos < _tokens.Count && depth > 0)
        {
            if (_tokens[_pos].Type == TokenType.TOK_WHILE)
                depth++;
            else if (_tokens[_pos].Type == TokenType.TOK_WEND)
            {
                depth--;
                if (depth == 0)
                {
                    _pos++;
                    return;
                }
            }
            _pos++;
        }
    }
}
