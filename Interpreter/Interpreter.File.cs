// ============================================================================
// BazzBasic Interpreter - File Operations
// Handles file I/O operations
// ============================================================================

using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // File Functions (return Value)
    // ========================================================================

    /// <summary>
    /// FileRead(path$) - Read entire file contents as string
    /// Returns empty string if file doesn't exist or error occurs
    /// </summary>
    private Value EvaluateFileRead()
    {
        _pos++; // Skip TOK_FILEREAD
        Require(TokenType.TOK_LPAREN, "Expected '(' after FILEREAD");
        
        string path = EvaluateExpression().AsString();
        
        Require(TokenType.TOK_RPAREN, "Expected ')' after FILEREAD path");
        
        string content = _fileManager.ReadFile(path);
        return Value.FromString(content);
    }

    /// <summary>
    /// FileExists(path$) - Check if file exists
    /// Returns 1 if exists, 0 if not
    /// </summary>
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
    // File Commands (statements, no return value)
    // ========================================================================

    /// <summary>
    /// FileWrite path$, contents$ - Write/overwrite file
    /// Creates directory if needed
    /// </summary>
    private void ExecuteFileWrite()
    {
        _pos++; // Skip TOK_FILEWRITE
        
        string path = EvaluateExpression().AsString();
        
        Require(TokenType.TOK_COMMA, "Expected ',' after FILEWRITE path");
        
        string content = EvaluateExpression().AsString();
        
        // Write file - silent failure (returns false on error)
        _fileManager.WriteFile(path, content);
    }

    /// <summary>
    /// FileAppend path$, contents$ - Append to file
    /// Creates file/directory if needed
    /// </summary>
    private void ExecuteFileAppend()
    {
        _pos++; // Skip TOK_FILEAPPEND
        
        string path = EvaluateExpression().AsString();
        
        Require(TokenType.TOK_COMMA, "Expected ',' after FILEAPPEND path");
        
        string content = EvaluateExpression().AsString();
        
        // Append file - silent failure (returns false on error)
        _fileManager.AppendFile(path, content);
    }

    /// <summary>
    /// FileDelete path$ - Delete file
    /// Throws error if file doesn't exist
    /// </summary>
    private void ExecuteFileDelete()
    {
        _pos++; // Skip TOK_FILEDELETE
        
        string path = EvaluateExpression().AsString();
        
        // Delete file - silent failure (returns false if file doesn't exist)
        _fileManager.DeleteFile(path);
    }
}
