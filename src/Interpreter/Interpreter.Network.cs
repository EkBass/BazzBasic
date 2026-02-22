/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.Network.cs
 Network related commands
 Basicly we just "ape" the C# here

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
    // Shared HttpClient to reuse connections and avoid socket exhaustion
    private static readonly HttpClient _httpClient = new()
    {
        Timeout = TimeSpan.FromSeconds(30)
    };

    // HTTPGET(url$) -> returns response body as string
    private Value EvaluateHttpGet()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after HTTPGET");
        string url = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after HTTPGET url");

        try
        {
            string result = _httpClient.GetStringAsync(url).GetAwaiter().GetResult();
            return Value.FromString(result);
        }
        catch (Exception ex)
        {
            throw new Exception($"HTTPGET failed: {ex.Message}");
        }
    }

    // HTTPPOST(url$, body$) -> returns response body as string
    private Value EvaluateHttpPost()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after HTTPPOST");
        string url = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA, "Expected ',' after HTTPPOST url");
        string body = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after HTTPPOST body");

        try
        {
            var content = new StringContent(body, System.Text.Encoding.UTF8, "application/json");
            var response = _httpClient.PostAsync(url, content).GetAwaiter().GetResult();
            string result = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            return Value.FromString(result);
        }
        catch (Exception ex)
        {
            throw new Exception($"HTTPPOST failed: {ex.Message}");
        }
    }
}
