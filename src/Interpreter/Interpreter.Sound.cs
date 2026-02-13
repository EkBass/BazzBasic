/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Sound.cs
 Sound shit

 Licence: MIT
*/


using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // Sound Commands
    // ========================================================================


    // Im pretty sure this is not needed anymore, but I check later
    /*
    private void ExecuteLoadSound()
    {
        _pos++; // Skip LOADSOUND token
        
        // This is handled in EvaluateExpression as a function
        throw new Exception("LOADSOUND should be used as a function, not a command");
    }
    */
    private void ExecuteSoundOnce()
    {
        _pos++; // Skip SOUNDONCE token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after SOUNDONCE");
        string soundId = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after sound ID");
        
        _soundManager.PlayOnce(soundId);
    }

    private void ExecuteSoundRepeat()
    {
        _pos++; // Skip SOUNDREPEAT token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after SOUNDREPEAT");
        string soundId = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after sound ID");
        
        _soundManager.PlayRepeat(soundId);
    }

    private void ExecuteSoundStop()
    {
        _pos++; // Skip SOUNDSTOP token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after SOUNDSTOP");
        string soundId = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after sound ID");
        
        _soundManager.StopSound(soundId);
    }

    private void ExecuteSoundStopAll()
    {
        _pos++; // Skip SOUNDSTOPALL token
        
        // Opt parentheses
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++; // Skip '('
            Require(TokenType.TOK_RPAREN, "Expected ')' after SOUNDSTOPALL");
        }
        
        _soundManager.StopAllSounds();
    }

    private void ExecuteSoundOnceWait()
    {
        _pos++; // Skip SOUNDONCEWAIT token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after SOUNDONCEWAIT");
        string soundId = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after sound ID");
        
        _soundManager.PlayOnceWait(soundId);
    }

    // ========================================================================
    // LoadSound Function
    // ========================================================================
    private Value EvaluateLoadSound()
    {
        _pos++; // Skip LOADSOUND token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after LOADSOUND");
        string filePath = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after file path");
        
        string soundId = _soundManager.LoadSound(filePath);
        return Value.FromString(soundId);
    }
}
