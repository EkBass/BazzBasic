/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Jump.cs
 GOTO, GOSUB, RETURN

 Licence: MIT
*/





using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // GOTO / GOSUB / RETURN
    // ========================================================================
    
    private void ExecuteGoto()
    {
        _pos++;
        
        if (_pos >= _tokens.Count)
        {
            Error("Expected label after GOTO");
            return;
        }
        
        string labelName;
        
        if (_tokens[_pos].Type == TokenType.TOK_LABEL)
        {
            labelName = _tokens[_pos].StringValue ?? "";
            _pos++;
        }

        // Allowing GOTO to accept variables that contain label names makes me uber nerd (read lazy) but thats basic 
        else if (_tokens[_pos].Type == TokenType.TOK_VARIABLE || _tokens[_pos].Type == TokenType.TOK_CONSTANT)
        {
            string varName = _tokens[_pos].StringValue ?? "";
            _pos++;
            try
            {
                Value val = _variables.GetVariable(varName);
                labelName = val.AsString().Trim('[', ']').ToUpperInvariant();
            }
            catch (UndefinedVariableException)
            {
                Error($"Undefined variable: {varName}");
                return;
            }
        }
        else
        {
            Error("Expected label or variable after GOTO");
            return;
        }
        
        if (!_labels.TryGetValue(labelName, out int targetPos))
        {
            Error($"Label '{labelName}' not found");
            return;
        }
        
        if (_inFunction)
        {
            if (targetPos < _functionStartPos || targetPos > _functionEndPos)
            {
                Error($"GOTO cannot jump outside function: {labelName}");
                return;
            }
        }
        
        _pos = targetPos;
    }

    private void ExecuteGosub()
    {
        _pos++;
        
        if (_pos >= _tokens.Count)
        {
            Error("Expected label after GOSUB");
            return;
        }
        
        string labelName;
        
        if (_tokens[_pos].Type == TokenType.TOK_LABEL)
        {
            labelName = _tokens[_pos].StringValue ?? "";
            _pos++;
        }
        else if (_tokens[_pos].Type == TokenType.TOK_VARIABLE || _tokens[_pos].Type == TokenType.TOK_CONSTANT)
        {
            string varName = _tokens[_pos].StringValue ?? "";
            _pos++;
            try
            {
                Value val = _variables.GetVariable(varName);
                labelName = val.AsString().Trim('[', ']').ToUpperInvariant();
            }
            catch (UndefinedVariableException)
            {
                Error($"Undefined variable: {varName}");
                return;
            }
        }
        else
        {
            Error("Expected label or variable after GOSUB");
            return;
        }
        
        if (!_labels.TryGetValue(labelName, out int targetPos))
        {
            Error($"Label '{labelName}' not found");
            return;
        }
        
        if (_inFunction)
        {
            if (targetPos < _functionStartPos || targetPos > _functionEndPos)
            {
                Error($"GOSUB cannot jump outside function: {labelName}");
                return;
            }
        }
        
        _gosubStack.Push(_pos);
        _pos = targetPos;
    }

    private void ExecuteReturn()
    {
        _pos++;
        
        if (_inFunction)
        {
            if (!IsEndOfStatement())
            {
                _returnValue = EvaluateExpression();
            }
            _running = false;
            return;
        }
        
        if (_gosubStack.Count == 0)
        {
            Error("RETURN without GOSUB");
            return;
        }
        
        _pos = _gosubStack.Pop();
    }
}
