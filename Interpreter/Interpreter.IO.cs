// ============================================================================
// BazzBasic - Interpreter (I/O Commands)
// PRINT, INPUT, CLS, SLEEP, BEEB, INKEY
// ============================================================================

using BazzBasic.Lexer;
using BazzBasic.Parser;
using System.Text;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // I/O Commands
    // ========================================================================
    
    private void ExecutePrint()
    {
        _pos++;
        bool endsWithSemicolon = false;
        
        StringBuilder output = new StringBuilder();
        
        while (_pos < _tokens.Count)
        {
            Token token = _tokens[_pos];
            
            if (token.Type == TokenType.TOK_NEWLINE || token.Type == TokenType.TOK_EOF ||
                token.Type == TokenType.TOK_COLON)
                break;
            
            if (token.Type == TokenType.TOK_COMMA)
            {
                output.Append("\t");
                _pos++;
                endsWithSemicolon = false;
                continue;
            }
            
            if (token.Type == TokenType.TOK_SEMICOLON)
            {
                _pos++;
                endsWithSemicolon = true;
                continue;
            }
            
            Value value = EvaluateExpression();
            output.Append(value.AsString());
            endsWithSemicolon = false;
        }
        
        if (Graphics.Graphics.IsInitialized)
        {
            Graphics.Graphics.Print(output.ToString(), !endsWithSemicolon);
        }
        else
        {
            Console.Write(output.ToString());
            if (!endsWithSemicolon)
                Console.WriteLine();
        }
    }

    private void ExecuteInput()
    {
        _pos++;
        
        string prompt = "? ";
        
        // Check for optional prompt string
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_STRING)
        {
            prompt = _tokens[_pos].StringValue ?? "";
            _pos++;
            Require(TokenType.TOK_COMMA);
        }
        
        // Collect all variable names
        var varNames = new List<string>();
        
        while (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_VARIABLE)
        {
            varNames.Add(_tokens[_pos].StringValue ?? "");
            _pos++;
            
            // Check for comma (more variables follow)
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
            }
            else
            {
                break;
            }
        }
        
        if (varNames.Count == 0)
        {
            Error("Expected variable after INPUT");
            return;
        }
        
        Console.Write(prompt);
        string? input = Console.ReadLine() ?? "";
        
        // Split input by comma or whitespace
        // First try comma, if no commas found, use whitespace
        string[] values;
        if (input.Contains(','))
        {
            values = input.Split(',', StringSplitOptions.TrimEntries);
        }
        else
        {
            values = input.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
        }
        
        // Assign values to variables
        for (int i = 0; i < varNames.Count; i++)
        {
            string varName = varNames[i];
            string value = i < values.Length ? values[i] : "";
            
            // Check if variable is string type (ends with $)
            if (varName.EndsWith('$'))
            {
                _variables.SetVariable(varName, Value.FromString(value));
            }
            else
            {
                // Try to parse as number
                if (double.TryParse(value, System.Globalization.NumberStyles.Any, 
                    System.Globalization.CultureInfo.InvariantCulture, out double numVal))
                {
                    _variables.SetVariable(varName, Value.FromNumber(numVal));
                }
                else
                {
                    _variables.SetVariable(varName, Value.FromString(value));
                }
            }
        }
    }

    private void ExecuteCls()
    {
        _pos++;
        
        if (Graphics.Graphics.IsInitialized)
        {
            Graphics.Graphics.Clear();
            Graphics.Graphics.SetCursorPosition(0, 0);
        }
        else
        {
            Console.Clear();
        }
    }

    private void ExecuteSleep()
    {
        _pos++;
        
        int ms = 0;
        if (!IsEndOfStatement())
        {
            ms = (int)EvaluateExpression().AsNumber();
        }
        
        if (ms > 0)
        {
            Thread.Sleep(ms);
        }
        else
        {
            Console.ReadKey(true);
        }
    }

    private void ExecuteBeeb()
    {
        _pos++;
        Console.Beep();
    }

    private Value EvaluateInkeyFunc()
    {
        _pos++;
        
        // If graphics mode is active, read from SDL2
        if (Graphics.Graphics.IsInitialized)
        {
            return Value.FromNumber(Graphics.Graphics.GetLastKey());
        }
        
        // Otherwise read from console
        if (Console.KeyAvailable)
        {
            ConsoleKeyInfo key = Console.ReadKey(true);
            
            switch (key.Key)
            {
                case ConsoleKey.Escape:
                    return Value.FromNumber(27);
                case ConsoleKey.Enter:
                    return Value.FromNumber(13);
                case ConsoleKey.Tab:
                    return Value.FromNumber(9);
                case ConsoleKey.Backspace:
                    return Value.FromNumber(8);
                case ConsoleKey.Spacebar:
                    return Value.FromNumber(32);
                case ConsoleKey.UpArrow:
                    return Value.FromNumber(328);
                case ConsoleKey.DownArrow:
                    return Value.FromNumber(336);
                case ConsoleKey.LeftArrow:
                    return Value.FromNumber(331);
                case ConsoleKey.RightArrow:
                    return Value.FromNumber(333);
                case ConsoleKey.Insert:
                    return Value.FromNumber(338);
                case ConsoleKey.Delete:
                    return Value.FromNumber(339);
                case ConsoleKey.Home:
                    return Value.FromNumber(327);
                case ConsoleKey.End:
                    return Value.FromNumber(335);
                case ConsoleKey.PageUp:
                    return Value.FromNumber(329);
                case ConsoleKey.PageDown:
                    return Value.FromNumber(337);
                case ConsoleKey.F1:
                    return Value.FromNumber(315);
                case ConsoleKey.F2:
                    return Value.FromNumber(316);
                case ConsoleKey.F3:
                    return Value.FromNumber(317);
                case ConsoleKey.F4:
                    return Value.FromNumber(318);
                case ConsoleKey.F5:
                    return Value.FromNumber(319);
                case ConsoleKey.F6:
                    return Value.FromNumber(320);
                case ConsoleKey.F7:
                    return Value.FromNumber(321);
                case ConsoleKey.F8:
                    return Value.FromNumber(322);
                case ConsoleKey.F9:
                    return Value.FromNumber(323);
                case ConsoleKey.F10:
                    return Value.FromNumber(324);
                case ConsoleKey.F11:
                    return Value.FromNumber(389);
                case ConsoleKey.F12:
                    return Value.FromNumber(390);
                default:
                    return Value.FromNumber(key.KeyChar);
            }
        }
        return Value.FromNumber(0);
    }

    private Value EvaluateRgbFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        int r = (int)EvaluateExpression().AsNumber() & 255;
        Require(TokenType.TOK_COMMA);
        int g = (int)EvaluateExpression().AsNumber() & 255;
        Require(TokenType.TOK_COMMA);
        int b = (int)EvaluateExpression().AsNumber() & 255;
        Require(TokenType.TOK_RPAREN);
        
        return Value.FromNumber((r << 16) | (g << 8) | b);
    }

    // ========================================================================
    // Mouse Functions
    // ========================================================================
    
    private Value EvaluateMousexFunc()
    {
        _pos++;
        
        if (!Graphics.Graphics.IsInitialized)
        {
            return Value.FromNumber(0);
        }
        
        Graphics.Graphics.UpdateMouse();
        return Value.FromNumber(Graphics.Graphics.MouseX);
    }

    private Value EvaluateMouseyFunc()
    {
        _pos++;
        
        if (!Graphics.Graphics.IsInitialized)
        {
            return Value.FromNumber(0);
        }
        
        Graphics.Graphics.UpdateMouse();
        return Value.FromNumber(Graphics.Graphics.MouseY);
    }

    private Value EvaluateMousebFunc()
    {
        _pos++;
        
        if (!Graphics.Graphics.IsInitialized)
        {
            return Value.FromNumber(0);
        }
        
        Graphics.Graphics.UpdateMouse();
        return Value.FromNumber(Graphics.Graphics.MouseButtons);
    }
}
