/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.File.cs
 File Operations

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

    // FILELIST(arr$, path$) or FILELIST(arr$, path$, pattern$)
    // Fills arr$ with file names (no directories, no paths) in path$,
    // sorted alphabetically, keys 0..n-1. Any previous contents of arr$ are cleared.
    // pattern$ uses * and ? wildcards, default all files. Not recursive.
    // Returns the number of files; 0 if the folder doesn't exist.

    private Value EvaluateFileList()
    {
        _pos++; // Skip TOK_FILELIST
        Require(TokenType.TOK_LPAREN, "Expected '(' after FILELIST");

        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("FILELIST requires array variable as first parameter");
            return Value.Zero;
        }

        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        // Allow arr$() as well as arr$
        if (_pos + 1 < _tokens.Count
            && _tokens[_pos].Type == TokenType.TOK_LPAREN
            && _tokens[_pos + 1].Type == TokenType.TOK_RPAREN)
            _pos += 2;

        Require(TokenType.TOK_COMMA, "Expected ',' after FILELIST array");
        string path = EvaluateExpression().AsString();

        string pattern = "*";
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++; // Skip comma
            pattern = EvaluateExpression().AsString();
        }

        Require(TokenType.TOK_RPAREN, "Expected ')' after FILELIST arguments");

        _variables.DeclareArray(arrayName);
        _variables.GetAllArrayElements(arrayName)?.Clear();

        var files = _fileManager.ListFiles(path, pattern);
        for (int i = 0; i < files.Count; i++)
            _variables.SetArrayElement(arrayName, i.ToString(), Value.FromString(files[i]));

        return Value.FromNumber(files.Count);
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

        // Check if next token is a plain array name (variable without index, or with empty parens)
        string content;
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_VARIABLE)
        {
            string varName = _tokens[_pos].StringValue ?? "";
            bool isEmptyParens = _pos + 2 < _tokens.Count
                && _tokens[_pos + 1].Type == TokenType.TOK_LPAREN
                && _tokens[_pos + 2].Type == TokenType.TOK_RPAREN;
            bool isNoParens = _pos + 1 >= _tokens.Count || _tokens[_pos + 1].Type != TokenType.TOK_LPAREN;

            if (!string.IsNullOrEmpty(varName) && (isNoParens || isEmptyParens))
            {
                var elements = _variables.GetAllArrayElements(varName);
                if (elements != null && elements.Count > 0)
                {
                    _pos++; // consume variable token
                    if (isEmptyParens) _pos += 2; // consume '(' and ')'
                    var sb = new System.Text.StringBuilder();
                    foreach (var kv in elements)
                        sb.AppendLine($"{kv.Key}={kv.Value.AsString()}");
                    content = sb.ToString();
                    _fileManager.WriteFile(path, content);
                    return;
                }
            }
        }

        content = EvaluateExpression().AsString();
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

    // SHELL(command$) or SHELL(command$, timeout)
    // Returns output as string. Timeout 0 or omitted = 5000ms default.
    private Value EvaluateShell()
    {
        _pos++; // Skip TOK_SHELL
        Require(TokenType.TOK_LPAREN, "Expected '(' after SHELL");

        string command = EvaluateExpression().AsString();
        int timeout = 5000;

        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++; // Skip comma
            timeout = (int)EvaluateExpression().AsNumber();
        }

        Require(TokenType.TOK_RPAREN, "Expected ')' after SHELL arguments");

        string result = _fileManager.ExecuteShellCommand(command, timeout);
        return Value.FromString(result);
    }
}
