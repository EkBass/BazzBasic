/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: Interpreter\Interpreter.Gamepad.cs
 Gamepad functions: GAMEPADS, PADBUTTON, PADAXIS, PADNAME, PADRUMBLE

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using BazzBasic.Gamepad;
using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // Works in console and graphics mode. A pad that isn't connected reads as
    // "nothing pressed" (FALSE / 0 / "") - no error, so games don't need guard code.

    // GAMEPADS() or GAMEPADS -> number of connected pads
    private Value EvaluateGamepadsFunc()
    {
        _pos++;
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++;
            Require(TokenType.TOK_RPAREN, "GAMEPADS: expected ')'");
        }
        return Value.FromNumber(GamepadManager.Count());
    }

    // PADBUTTON(pad, button) -> TRUE/FALSE
    private Value EvaluatePadButtonFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "PADBUTTON: expected '('");
        int pad = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA, "PADBUTTON: expected ','");
        int button = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN, "PADBUTTON: expected ')'");

        if (button < 0 || button >= GamepadManager.ButtonCount)
        {
            Error($"PADBUTTON: button must be 0-{GamepadManager.ButtonCount - 1}, got {button}");
            return Value.Zero;
        }
        return Value.FromNumber(GamepadManager.Button(pad, button) ? 1 : 0);
    }

    // PADAXIS(pad, axis) -> sticks -1..1, triggers 0..1
    private Value EvaluatePadAxisFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "PADAXIS: expected '('");
        int pad = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA, "PADAXIS: expected ','");
        int axis = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN, "PADAXIS: expected ')'");

        if (axis < 0 || axis >= GamepadManager.AxisCount)
        {
            Error($"PADAXIS: axis must be 0-{GamepadManager.AxisCount - 1}, got {axis}");
            return Value.Zero;
        }
        return Value.FromNumber(GamepadManager.Axis(pad, axis));
    }

    // PADNAME(pad) -> controller name or ""
    private Value EvaluatePadNameFunc()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "PADNAME: expected '('");
        int pad = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_RPAREN, "PADNAME: expected ')'");
        return Value.FromString(GamepadManager.Name(pad));
    }

    // PADRUMBLE pad, strength, ms      (parentheses optional)
    private void ExecutePadRumble()
    {
        _pos++;
        bool paren = false;
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            _pos++;
            paren = true;
        }
        int pad = (int)EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA, "PADRUMBLE: expected ','");
        double strength = EvaluateExpression().AsNumber();
        Require(TokenType.TOK_COMMA, "PADRUMBLE: expected ','");
        int ms = (int)EvaluateExpression().AsNumber();
        if (paren) Require(TokenType.TOK_RPAREN, "PADRUMBLE: expected ')'");
        if (!_running) return;

        GamepadManager.Rumble(pad, strength, ms);
    }
}
