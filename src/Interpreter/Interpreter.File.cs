/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.File.cs
 File Operations

 Licence: MIT
*/
using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // File Functions
    // ========================================================================


    // FileRead(path$) - Read entire file contents as string
    // Returns empty string if file doesnt exist or shit happens

    private Value EvaluateFileRead()
    {
        _pos++; // Skip TOK_FILEREAD
        Require(TokenType.TOK_LPAREN, "Expected '(' after FILEREAD");
        
        string path = EvaluateExpression().AsString();
        
        Require(TokenType.TOK_RPAREN, "Expected ')' after FILEREAD path");
        
        string content = _fileManager.ReadFile(path);
        return Value.FromString(content);
    }


    // FileExists(path$) - Check if file exists
    // Returns 1 if exists, 0 if not

    private Value EvaluateFileExists()
    {
        _pos++; // Skip TOK_FILEEXISTS
        Require(TokenType.TOK_LPAREN, "Expected '(' after FILEEXISTS");
        
        string path = EvaluateExpression().AsString();
        
        Require(TokenType.TOK_RPAREN, "Expected ')' after FILEEXISTS path");
        
        bool exists = _fileManager.FileExists(path);
        return Value.FromNumber(exists ? 1 : 0);
    }

    // ========================================================================
    // File Commands
    // ========================================================================


    // FileWrite path$, contents$
    // Makes directory if needs to

    private void ExecuteFileWrite()
    {
        _pos++; // Skip TOK_FILEWRITE
        
        string path = EvaluateExpression().AsString();
        
        Require(TokenType.TOK_COMMA, "Expected ',' after FILEWRITE path");
        
        string content = EvaluateExpression().AsString();
        
        // Write file (returns false on error)
        _fileManager.WriteFile(path, content);
    }


    // FileAppend path$, contents$
    // Creates file/directory if needes to

    private void ExecuteFileAppend()
    {
        _pos++; // Skip TOK_FILEAPPEND
        
        string path = EvaluateExpression().AsString();
        
        Require(TokenType.TOK_COMMA, "Expected ',' after FILEAPPEND path");
        
        string content = EvaluateExpression().AsString();
        
        // Append file - silent false on error
        _fileManager.AppendFile(path, content);
    }


    // FileDelete path$
    private void ExecuteFileDelete()
    {
        _pos++; // Skip TOK_FILEDELETE
        
        string path = EvaluateExpression().AsString();
        
        _fileManager.DeleteFile(path);
    }
}
