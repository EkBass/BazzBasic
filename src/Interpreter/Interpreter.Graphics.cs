/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Graphics.cs
 Graphics Commands

 Licence: MIT
*/
using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // ========================================================================
    // Graphics Commands
    // ========================================================================
    
    private void ExecuteScreen()
    {
        _pos++;
        
        int mode = 0;
        int width = 640;
        int height = 480;
        string title = "BazzBasic Graphics";
        bool customDimensions = false;
        
        if (!IsEndOfStatement())
        {
            mode = (int)EvaluateExpression().AsNumber();
            
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
                width = (int)EvaluateExpression().AsNumber();
                customDimensions = true;
                
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
                {
                    _pos++;
                    height = (int)EvaluateExpression().AsNumber();
                    
                    if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
                    {
                        _pos++;
                        title = EvaluateExpression().AsString();
                    }
                }
            }
        }

        // Classic 80s modes - only apply if no custom dimensions were provided
        // When custom dimensions are given (e.g., SCREEN 0, 800, 600), use those instead
        if (!customDimensions)
        {
            switch (mode)
            {
                case 0:
                    width = 640;
                    height = 400;
                    break;
                case 1:
                    width = 320;
                    height = 200;
                    break;
                case 2:
                    width = 640;
                    height = 350;
                    break;
                case 7:
                    width = 320;
                    height = 200;
                    break;
                case 9:
                    width = 640;
                    height = 350;
                    break;
                case 12:
                    width = 640;
                    height = 480;
                    break;
                case 13:
                    width = 320;
                    height = 200;
                    break;
            }
        }
        
        try
        {
            Graphics.Graphics.Initialize(width, height, title);
        }
        catch (Exception ex)
        {
            Error($"Failed to initialize graphics: {ex.Message}");
        }
    }

    private void ExecuteScreenlock()
    {
        _pos++;
        
        // Check for ON or OFF
        bool locked = true; // Default to ON
        
        if (_pos < _tokens.Count)
        {
            if (_tokens[_pos].Type == TokenType.TOK_ON)
            {
                locked = true;
                _pos++;
            }
            else if (_tokens[_pos].Type == TokenType.TOK_OFF)
            {
                locked = false;
                _pos++;
            }
        }
        
        Graphics.Graphics.SetScreenLock(locked);
    }

    private void ExecutePset()
    {
        _pos++;
        
        Require(TokenType.TOK_LPAREN);
        int x = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int y = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++;
            int color = (int)EvaluateExpression().AsNumber();
            
            if (color > 255)
            {
                int r = (color >> 16) & 0xFF;
                int g = (color >> 8) & 0xFF;
                int b = color & 0xFF;
                Graphics.Graphics.SetColor(r, g, b);
            }
            else
            {
                Graphics.Graphics.SetColorFromIndex(color);
            }
        }
        
        Graphics.Graphics.SetPixel(x, y);
        Graphics.Graphics.Present();
    }

    private void ExecuteLine()
    {
        _pos++;
        
        Require(TokenType.TOK_LPAREN);
        int x1 = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int y1 = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        Require(TokenType.TOK_MINUS);
        
        Require(TokenType.TOK_LPAREN);
        int x2 = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int y2 = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++;
            int color = (int)EvaluateExpression().AsNumber();
            
            if (color > 255)
            {
                int r = (color >> 16) & 0xFF;
                int g = (color >> 8) & 0xFF;
                int b = color & 0xFF;
                Graphics.Graphics.SetColor(r, g, b);
            }
            else
            {
                Graphics.Graphics.SetColorFromIndex(color);
            }
            
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
                if (_pos < _tokens.Count)
                {
                    if (_tokens[_pos].Type == TokenType.TOK_BF)
                    {
                        _pos++;
                        Graphics.Graphics.DrawRect(x1, y1, x2 - x1, y2 - y1, true);
                        Graphics.Graphics.Present();
                        return;
                    }
                    else if (_tokens[_pos].Type == TokenType.TOK_B)
                    {
                        _pos++;
                        Graphics.Graphics.DrawRect(x1, y1, x2 - x1, y2 - y1, false);
                        Graphics.Graphics.Present();
                        return;
                    }
                }
            }
        }
        
        Graphics.Graphics.DrawLine(x1, y1, x2, y2);
        Graphics.Graphics.Present();
    }

    private void ExecuteCircle()
    {
        _pos++;
        
        Require(TokenType.TOK_LPAREN);
        int centerX = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int centerY = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        Require(TokenType.TOK_COMMA);
        int radius = (int)EvaluateExpression().AsNumber();
        
        bool filled = false;
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++;
            int color = (int)EvaluateExpression().AsNumber();
            
            if (color > 255)
            {
                int r = (color >> 16) & 0xFF;
                int g = (color >> 8) & 0xFF;
                int b = color & 0xFF;
                Graphics.Graphics.SetColor(r, g, b);
            }
            else
            {
                Graphics.Graphics.SetColorFromIndex(color);
            }
            
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
                while (_pos < _tokens.Count && !IsEndOfStatement())
                {
                    if (_tokens[_pos].Type == TokenType.TOK_NUMBER)
                    {
                        double fillFlag = EvaluateExpression().AsNumber();
                        filled = fillFlag != 0;
                        break;
                    }
                    _pos++;
                }
            }
        }
        
        Graphics.Graphics.DrawCircle(centerX, centerY, radius, filled);
        Graphics.Graphics.Present();
    }

    private void ExecutePaint()
    {
        _pos++;
        
        Require(TokenType.TOK_LPAREN);
        int x = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int y = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        Require(TokenType.TOK_COMMA);
        int color = (int)EvaluateExpression().AsNumber();
        
        if (color > 255)
        {
            int r = (color >> 16) & 0xFF;
            int g = (color >> 8) & 0xFF;
            int b = color & 0xFF;
            Graphics.Graphics.SetColor(r, g, b);
        }
        else
        {
            Graphics.Graphics.SetColorFromIndex(color);
        }
        
        Graphics.Graphics.SetPixel(x, y);
        Graphics.Graphics.Present();
    }

    private void ExecuteLocate()
    {
        _pos++;
        
        int row = (int)EvaluateExpression().AsNumber();
        int col = 1;
        
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++;
            col = (int)EvaluateExpression().AsNumber();
        }
        
        if (Graphics.Graphics.IsInitialized)
        {
            Graphics.Graphics.SetCursorPosition(row - 1, col - 1);
        }
        else
        {
            try
            {
                Console.SetCursorPosition(col - 1, row - 1);
            }
            catch
            {
                // Ignore out of screen
            }
        }
    }

    private void ExecuteColor()
    {
        _pos++;
        
        int fg = (int)EvaluateExpression().AsNumber();
        int bg = 0;
        
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++;
            bg = (int)EvaluateExpression().AsNumber();
        }
        
        if (Graphics.Graphics.IsInitialized)
        {
            Graphics.Graphics.SetColorFromIndex(fg);
            Graphics.Graphics.SetBackgroundColor(
                (MapColorToRGB(bg) >> 16) & 0xFF,
                (MapColorToRGB(bg) >> 8) & 0xFF,
                MapColorToRGB(bg) & 0xFF
            );
        }
        else
        {
            try
            {
                Console.ForegroundColor = MapColor(fg);
                Console.BackgroundColor = MapColor(bg);
            }
            catch
            {
                // Ignore invalid colors
            }
        }
    }

    private static ConsoleColor MapColor(int basicColor)
    {
        return (basicColor & 15) switch
        {
            0 => ConsoleColor.Black,
            1 => ConsoleColor.DarkBlue,
            2 => ConsoleColor.DarkGreen,
            3 => ConsoleColor.DarkCyan,
            4 => ConsoleColor.DarkRed,
            5 => ConsoleColor.DarkMagenta,
            6 => ConsoleColor.DarkYellow,
            7 => ConsoleColor.Gray,
            8 => ConsoleColor.DarkGray,
            9 => ConsoleColor.Blue,
            10 => ConsoleColor.Green,
            11 => ConsoleColor.Cyan,
            12 => ConsoleColor.Red,
            13 => ConsoleColor.Magenta,
            14 => ConsoleColor.Yellow,
            15 => ConsoleColor.White,
            _ => ConsoleColor.Gray
        };
    }

    private static int MapColorToRGB(int basicColor)
    {
        var (r, g, b) = (basicColor & 15) switch
        {
            0 => (0, 0, 0),
            1 => (0, 0, 170),
            2 => (0, 170, 0),
            3 => (0, 170, 170),
            4 => (170, 0, 0),
            5 => (170, 0, 170),
            6 => (170, 85, 0),
            7 => (170, 170, 170),
            8 => (85, 85, 85),
            9 => (85, 85, 255),
            10 => (85, 255, 85),
            11 => (85, 255, 255),
            12 => (255, 85, 85),
            13 => (255, 85, 255),
            14 => (255, 255, 85),
            15 => (255, 255, 255),
            _ => (255, 255, 255)
        };
        
        return (r << 16) | (g << 8) | b;
    }
    
    // ========================================================================
    // Shape/Sprite stuff
    // ========================================================================
    
    private Value EvaluateLoadshapeFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        
        string shapeType = EvaluateExpression().AsString().ToUpperInvariant();
        Require(TokenType.TOK_COMMA);
        double width = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double height = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        int color = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN);
        
        if (!Graphics.Graphics.IsInitialized)
        {
            Error("Graphics mode not initialized. Use SCREEN first.");
            return Value.FromString("");
        }
        
        Graphics.ShapeType type = shapeType switch
        {
            "RECTANGLE" => Graphics.ShapeType.Rectangle,
            "CIRCLE" => Graphics.ShapeType.Circle,
            "TRIANGLE" => Graphics.ShapeType.Triangle,
            _ => Graphics.ShapeType.Rectangle
        };
        
        string id = Graphics.ShapeManager.CreateShape(type, width, height, color);
        return Value.FromString(id);
    }
    
    private Value EvaluateLoadimageFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN);
        
        string filepath = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN);
        
        if (!Graphics.Graphics.IsInitialized)
        {
            Error("Graphics mode not initialized. Use SCREEN first.");
            return Value.FromString("");
        }
        
        try
        {
            string id = Graphics.ShapeManager.LoadImageShape(filepath, Graphics.Graphics.Renderer);
            return Value.FromString(id);
        }
        catch (Exception ex)
        {
            Error($"Failed to load image: {ex.Message}");
            return Value.FromString("");
        }
    }
    
    private void ExecuteMoveshape()
    {
        _pos++;
        
        string id = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        double x = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA);
        double y = EvaluateExpression().AsNumber();
        
        Graphics.ShapeManager.MoveShape(id, x, y);
    }
    
    private void ExecuteRotateshape()
    {
        _pos++;
        
        string id = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        double angle = EvaluateExpression().AsNumber();
        
        Graphics.ShapeManager.RotateShape(id, angle);
    }
    
    private void ExecuteScaleshape()
    {
        _pos++;
        
        string id = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA);
        double scale = EvaluateExpression().AsNumber();
        
        Graphics.ShapeManager.ScaleShape(id, scale);
    }
    
    private void ExecuteDrawshape()
    {
        _pos++;
        
        string id = EvaluateExpression().AsString();
        
        if (!Graphics.Graphics.IsInitialized)
        {
            Error("Graphics mode not initialized. Use SCREEN first.");
            return;
        }
        
        Graphics.ShapeManager.DrawShape(id, Graphics.Graphics.Renderer);
    }
    
    private void ExecuteShowshape()
    {
        _pos++;
        string id = EvaluateExpression().AsString();
        Graphics.ShapeManager.ShowShape(id);
    }
    
    private void ExecuteHideshape()
    {
        _pos++;
        string id = EvaluateExpression().AsString();
        Graphics.ShapeManager.HideShape(id);
    }
    
    private void ExecuteRemoveshape()
    {
        _pos++;
        string id = EvaluateExpression().AsString();
        Graphics.ShapeManager.RemoveShape(id);
    }
}
