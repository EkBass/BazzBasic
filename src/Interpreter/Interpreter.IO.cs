/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.IO.cs
 I/O stuff.

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using BazzBasic.Lexer;
using BazzBasic.Parser;
using System.Runtime.InteropServices;
using System.Text;
using SDL2;

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
        
        StringBuilder output = new();
        
        while (_pos < _tokens.Count)
        {
            Token token = _tokens[_pos];
            
            if (token.Type == TokenType.TOK_NEWLINE || token.Type == TokenType.TOK_EOF ||
                token.Type == TokenType.TOK_COLON)
                break;
            
            if (token.Type == TokenType.TOK_COMMA)
            {
                output.Append('\t');
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
        
        // Check for optional print string
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_STRING)
        {
            prompt = _tokens[_pos].StringValue ?? "";
            _pos++;
            Require(TokenType.TOK_COMMA);
        }
        
        // collect variable names. Can be 1 or many many more
        var varNames = new List<string>();
        
        while (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_VARIABLE)
        {
            varNames.Add(_tokens[_pos].StringValue ?? "");
            _pos++;
            
            // Check comma if more variables follow
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
        
        string input;
        if (Graphics.Graphics.IsInitialized)
        {
            input = Graphics.Graphics.ReadLine(prompt);
        }
        else
        {
            Console.Write(prompt);
            input = Console.ReadLine() ?? "";
        }
        
        // Split input by comma and whitespace
        // First comma, if no comma's found, use whitespace
        string[] values;
        if (input.Contains(','))
        {
            values = input.Split(',', StringSplitOptions.TrimEntries);
        }
        else
        {
            values = input.Split([' ', '\t'], StringSplitOptions.RemoveEmptyEntries);
        }
        
        // Set values to variables
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
                // This should not be needed anymore since non-typed variables
                // Ill check later
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

    private void ExecuteLineInput()
    {
        _pos++; // Skip LINE
        _pos++; // Skip INPUT
        
        string prompt = "";
        
        // Check for optional prompt string
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_STRING)
        {
            prompt = _tokens[_pos].StringValue ?? "";
            _pos++;
            
            // Comma after prompt is optional
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
            }
        }
        
        // Get variable name
        if (_pos >= _tokens.Count || _tokens[_pos].Type != TokenType.TOK_VARIABLE)
        {
            Error("Expected variable after LINE INPUT");
            return;
        }
        
        string varName = _tokens[_pos].StringValue ?? "";
        _pos++;
        
        // Print prompt and read entire line
        string input;
        if (Graphics.Graphics.IsInitialized)
        {
            input = Graphics.Graphics.ReadLine(prompt);
        }
        else
        {
            if (!string.IsNullOrEmpty(prompt))
            {
                Console.Write(prompt);
            }
            input = Console.ReadLine() ?? "";
        }
        
        // Store entire line to variable (no splitting)
        _variables.SetVariable(varName, Value.FromString(input));
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
        
        if (Graphics.Graphics.IsInitialized)
            return Value.FromNumber(Graphics.Graphics.GetLastKey());

        if (Console.KeyAvailable)
            return Value.FromNumber(ReadConsoleKey());

        return Value.FromNumber(0);
    }

    // Shared console key reader used by INKEY and WAITKEY
    private static double ReadConsoleKey()
    {
        ConsoleKeyInfo key = Console.ReadKey(true);
        return key.Key switch
        {
            ConsoleKey.Escape    => 27,
            ConsoleKey.Enter     => 13,
            ConsoleKey.Tab       => 9,
            ConsoleKey.Backspace => 8,
            ConsoleKey.Spacebar  => 32,
            ConsoleKey.UpArrow   => 328,
            ConsoleKey.DownArrow => 336,
            ConsoleKey.LeftArrow => 331,
            ConsoleKey.RightArrow => 333,
            ConsoleKey.Insert    => 338,
            ConsoleKey.Delete    => 339,
            ConsoleKey.Home      => 327,
            ConsoleKey.End       => 335,
            ConsoleKey.PageUp    => 329,
            ConsoleKey.PageDown  => 337,
            ConsoleKey.F1        => 315,
            ConsoleKey.F2        => 316,
            ConsoleKey.F3        => 317,
            ConsoleKey.F4        => 318,
            ConsoleKey.F5        => 319,
            ConsoleKey.F6        => 320,
            ConsoleKey.F7        => 321,
            ConsoleKey.F8        => 322,
            ConsoleKey.F9        => 323,
            ConsoleKey.F10       => 324,
            ConsoleKey.F11       => 389,
            ConsoleKey.F12       => 390,
            _                    => (double)key.KeyChar
        };
    }

    // WAITKEY() or WAITKEY(key1$) or WAITKEY(key1$, key2$, ...)
    // Blocks until a matching key is pressed and returns its value.
    // Without parameters: waits for any key and returns it.
    private Value EvaluateWaitKeyFunc()
    {
        _pos++; // Skip TOK_WAITKEY

        var acceptedKeys = new List<double>();

        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++; // Skip (

            // Empty parens WAITKEY() = accept any key
            if (_tokens[_pos].Type != TokenType.TOK_RPAREN)
            {
                while (true)
                {
                    acceptedKeys.Add(EvaluateExpression().AsNumber());
                    if (_tokens[_pos].Type == TokenType.TOK_COMMA)
                        _pos++; // Skip comma, read next key
                    else
                        break;
                }
            }
            Require(TokenType.TOK_RPAREN, "Expected ')'");
        }

        // Loop until a matching key (or any key if no params)
        while (true)
        {
            double key = 0;

            if (Graphics.Graphics.IsInitialized)
            {
                key = Graphics.Graphics.GetLastKey();
            }
            else if (Console.KeyAvailable)
            {
                // Use ConsoleKey enum value (always uppercase/neutral) so
                // KEY_A# matches both 'a' and 'A' — shift state is irrelevant
                ConsoleKeyInfo info = Console.ReadKey(true);
                key = (double)info.Key;
            }

            if (key != 0)
            {
                if (acceptedKeys.Count == 0 || acceptedKeys.Contains(key))
                    return Value.FromNumber(key);
            }

            System.Threading.Thread.Sleep(16);
        }
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

    private Value EvaluateMouseleftFunc()
    {
        _pos++;
        if (!Graphics.Graphics.IsInitialized) return Value.FromNumber(0);
        Graphics.Graphics.UpdateMouse();
        return Value.FromNumber((Graphics.Graphics.MouseButtons & 1) != 0 ? 1 : 0);
    }

    private Value EvaluateMousemiddleFunc()
    {
        _pos++;
        if (!Graphics.Graphics.IsInitialized) return Value.FromNumber(0);
        Graphics.Graphics.UpdateMouse();
        return Value.FromNumber((Graphics.Graphics.MouseButtons & 2) != 0 ? 1 : 0);
    }

    private Value EvaluateMouserightFunc()
    {
        _pos++;
        if (!Graphics.Graphics.IsInitialized) return Value.FromNumber(0);
        Graphics.Graphics.UpdateMouse();
        return Value.FromNumber((Graphics.Graphics.MouseButtons & 4) != 0 ? 1 : 0);
    }

    private void ExecuteMouseHide()
    {
        _pos++;
        if (!Graphics.Graphics.IsInitialized) return;
        _ = SDL.SDL_ShowCursor(SDL.SDL_DISABLE);
    }

    private void ExecuteMouseShow()
    {
        _pos++;
        if (!Graphics.Graphics.IsInitialized) return;
        SDL.SDL_ShowCursor(SDL.SDL_ENABLE);
    }

    // ========================================================================
    // Console Reading Functions
    // ========================================================================

    // Windows API imports for reading console
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetStdHandle(int nStdHandle);
    
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    private static extern bool ReadConsoleOutputCharacter(
        IntPtr hConsoleOutput,
        [Out] char[] lpCharacter,
        int nLength,
        COORD dwReadCoord,
        out int lpNumberOfCharsRead);
    
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool ReadConsoleOutputAttribute(
        IntPtr hConsoleOutput,
        [Out] ushort[] lpAttribute,
        int nLength,
        COORD dwReadCoord,
        out int lpNumberOfAttrsRead);
    
    [StructLayout(LayoutKind.Sequential)]
    private struct COORD
    {
        public short X;
        public short Y;
        public COORD(short x,
                     short y) { X = x; Y = y; }
    }
    
    private const int STD_OUTPUT_HANDLE = -11;
    
    // GETCONSOLE(row, column, mode)
    // Uses same (row, column) order as LOCATE for consistency
    // mode 0 = character at position
    // 1 = foreground color
    // 2 = background color

    private Value EvaluateGetConsoleFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        int row = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int column = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int mode = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        // Graphics mode - not supported yet
        if (Graphics.Graphics.IsInitialized)
        {
            return Value.FromNumber(0);
        }
        
        // Convert from 1-based (BASIC) to 0-based (Windows API)
        // COORD is (X, Y) = (column, row) in Windows API
        IntPtr handle = GetStdHandle(STD_OUTPUT_HANDLE);
        COORD coord = new((short)(column - 1), (short)(row - 1));
        
        switch (mode)
        {
            case 0: // Character
                char[] chars = new char[1];
                if (ReadConsoleOutputCharacter(handle, chars, 1, coord, out _))
                {
                    return Value.FromNumber(chars[0]);
                }
                return Value.FromNumber(0);
                
            case 1: // Foreground color
                ushort[] attrs1 = new ushort[1];
                if (ReadConsoleOutputAttribute(handle, attrs1, 1, coord, out _))
                {
                    return Value.FromNumber(attrs1[0] & 0x0F);
                }
                return Value.FromNumber(0);
                
            case 2: // Background color
                ushort[] attrs2 = new ushort[1];
                if (ReadConsoleOutputAttribute(handle, attrs2, 1, coord, out _))
                {
                    return Value.FromNumber((attrs2[0] >> 4) & 0x0F);
                }
                return Value.FromNumber(0);
                
            default:
                return Value.FromNumber(0);
        }
    }

    // CURPOS("row") → 1-based row of current console cursor
    // CURPOS("col") → 1-based column of current console cursor
    // CURPOS()      → "row,col" as string
    private Value EvaluateCurPosFunc()
    {
        _pos++; // skip CURPOS

        string mode = "";
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++; // skip (
            if (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_RPAREN)
                mode = EvaluateExpression().AsString().ToLowerInvariant();
            Require(TokenType.TOK_RPAREN);
        }

        var (left, top) = Console.GetCursorPosition();
        int row = top + 1;   // 1-based, matches LOCATE
        int col = left + 1;

        return mode switch
        {
            "row" => Value.FromNumber(row),
            "col" => Value.FromNumber(col),
            _     => Value.FromString($"{row},{col}")
        };
    }
}
