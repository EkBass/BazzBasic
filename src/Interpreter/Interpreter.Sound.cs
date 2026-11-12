/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Sound.cs
 Sound shit

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
        if (_hasError) return;
        
        try { GetSoundManager().PlayOnce(soundId); }
        catch (Exception ex) { Error($"SOUNDONCE: {ex.Message}"); }
    }

    private void ExecuteSoundRepeat()
    {
        _pos++; // Skip SOUNDREPEAT token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after SOUNDREPEAT");
        string soundId = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after sound ID");
        if (_hasError) return;
        
        try { GetSoundManager().PlayRepeat(soundId); }
        catch (Exception ex) { Error($"SOUNDREPEAT: {ex.Message}"); }
    }

    private void ExecuteSoundStop()
    {
        _pos++; // Skip SOUNDSTOP token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after SOUNDSTOP");
        string soundId = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after sound ID");
        
        GetSoundManager().StopSound(soundId);
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
        
        GetSoundManager().StopAllSounds();
    }

    private void ExecuteSoundOnceWait()
    {
        _pos++; // Skip SOUNDONCEWAIT token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after SOUNDONCEWAIT");
        string soundId = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after sound ID");
        if (_hasError) return;
        
        try { GetSoundManager().PlayOnceWait(soundId); }
        catch (Exception ex) { Error($"SOUNDONCEWAIT: {ex.Message}"); }
    }

    // ========================================================================
    // LoadSound Function
    // ========================================================================
    private Value EvaluateLoadSound()
    {
        _pos++; // Skip LOADSOUND token
        
        Require(TokenType.TOK_LPAREN, "Expected '(' after LOADSOUND");
        string filePath = EvaluateExpression().AsString();
        if (!Path.IsPathRooted(filePath))
            filePath = Path.Combine(_fileManager.RootPath, filePath);
        Require(TokenType.TOK_RPAREN, "Expected ')' after file path");
        if (_hasError) return Value.Empty;
        
        try
        {
            string soundId = GetSoundManager().LoadSound(filePath);
            return Value.FromString(soundId);
        }
        catch (Exception ex)
        {
            Error($"LOADSOUND: {ex.Message}");
            return Value.Empty;
        }
    }
}
