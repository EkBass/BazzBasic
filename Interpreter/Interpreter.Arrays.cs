// ============================================================================
// BazzBasic - Interpreter (Array Operations)
// DIM, DELKEY, HASKEY
// ============================================================================

using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // Array Operations
    // ========================================================================
    
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
            }
            else
            {
                _pos++;
            }
        }
    }

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
