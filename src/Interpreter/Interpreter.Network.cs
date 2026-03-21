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

    // ========================================================================
    // JSON functions
    // ========================================================================

    // ASJSON(array$) — converts BazzBasic array to JSON string
    private Value EvaluateAsJson()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after ASJSON");

        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_RPAREN, "Expected ')' after ASJSON argument");

        var elements = _variables.GetAllArrayElements(arrayName);
        if (elements == null)
        {
            Error($"Array not declared: {arrayName}");
            return Value.FromString("{}");
        }

        var root = BuildJsonTree(elements);
        return Value.FromString(System.Text.Json.JsonSerializer.Serialize(root,
            new System.Text.Json.JsonSerializerOptions { WriteIndented = false }));
    }

    // Build nested object/array tree from flat comma-key dictionary
    private static object BuildJsonTree(Dictionary<string, Value> elements)
    {
        // Collect all top-level keys
        var top = new Dictionary<string, List<(string rest, Value val)>>(StringComparer.OrdinalIgnoreCase);

        foreach (var kv in elements)
        {
            int comma = kv.Key.IndexOf(',');
            string first = comma < 0 ? kv.Key : kv.Key[..comma];
            string rest  = comma < 0 ? ""     : kv.Key[(comma + 1)..];
            if (!top.ContainsKey(first)) top[first] = [];
            top[first].Add((rest, kv.Value));
        }

        // If all keys are numeric indices → array
        bool isArray = top.Keys.All(k => int.TryParse(k, out _));

        if (isArray)
        {
            var list = new List<object?>();
            int max = top.Keys.Select(k => int.Parse(k)).Max();
            for (int i = 0; i <= max; i++)
            {
                string idx = i.ToString();
                if (!top.ContainsKey(idx)) { list.Add(null); continue; }
                list.Add(ResolveNode(top[idx]));
            }
            return list;
        }
        else
        {
            var dict = new Dictionary<string, object?>();
            foreach (var kv in top)
                dict[kv.Key] = ResolveNode(kv.Value);
            return dict;
        }
    }

    private static object? ResolveNode(List<(string rest, Value val)> entries)
    {
        // Leaf node — single entry with no further path
        if (entries.Count == 1 && entries[0].rest == "")
        {
            Value v = entries[0].val;
            if (v.Type == BazzBasic.Parser.BazzValueType.Number) return v.NumValue;
            return v.AsString();
        }

        // Recurse: rebuild sub-dictionary
        var sub = new Dictionary<string, Value>(StringComparer.OrdinalIgnoreCase);
        foreach (var (rest, val) in entries)
            sub[rest] = val;
        return BuildJsonTree(sub);
    }

    // ASARRAY(arr$, json$) — fills arr$ from JSON string, returns element count
    private Value EvaluateAsArray()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after ASARRAY");

        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_COMMA, "Expected ',' in ASARRAY(arr$, json$)");

        string json = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after ASARRAY arguments");

        if (!_variables.ArrayExists(arrayName))
            _variables.DeclareArray(arrayName);

        try
        {
            var doc = System.Text.Json.JsonDocument.Parse(json);
            int count = FlattenJsonElement(doc.RootElement, arrayName, "");
            return Value.FromNumber(count);
        }
        catch (Exception ex)
        {
            Error($"ASARRAY failed to parse JSON: {ex.Message}");
            return Value.Zero;
        }
    }

    // Recursively flatten JsonElement into array using comma-separated key paths
    private int FlattenJsonElement(System.Text.Json.JsonElement el, string arrayName, string prefix)
    {
        int count = 0;
        switch (el.ValueKind)
        {
            case System.Text.Json.JsonValueKind.Object:
                foreach (var prop in el.EnumerateObject())
                {
                    string key = prefix == "" ? prop.Name : $"{prefix},{prop.Name}";
                    count += FlattenJsonElement(prop.Value, arrayName, key);
                }
                break;

            case System.Text.Json.JsonValueKind.Array:
                int i = 0;
                foreach (var item in el.EnumerateArray())
                {
                    string key = prefix == "" ? i.ToString() : $"{prefix},{i}";
                    count += FlattenJsonElement(item, arrayName, key);
                    i++;
                }
                break;

            case System.Text.Json.JsonValueKind.String:
                _variables.SetArrayElement(arrayName, prefix, Value.FromString(el.GetString() ?? ""));
                count++;
                break;

            case System.Text.Json.JsonValueKind.Number:
                _variables.SetArrayElement(arrayName, prefix, Value.FromNumber(el.GetDouble()));
                count++;
                break;

            case System.Text.Json.JsonValueKind.True:
                _variables.SetArrayElement(arrayName, prefix, Value.FromNumber(1));
                count++;
                break;

            case System.Text.Json.JsonValueKind.False:
                _variables.SetArrayElement(arrayName, prefix, Value.FromNumber(0));
                count++;
                break;
        }
        return count;
    }

    // LOADJSON arr$, path$ — load JSON file directly into array
    private void ExecuteLoadJson()
    {
        _pos++;
        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_COMMA, "Expected ',' in LOADJSON arr$, path$");
        string path = EvaluateExpression().AsString();

        try
        {
            string json = System.IO.File.ReadAllText(_fileManager.ResolvePath(path));
            if (!_variables.ArrayExists(arrayName))
                _variables.DeclareArray(arrayName);
            var doc = System.Text.Json.JsonDocument.Parse(json);
            FlattenJsonElement(doc.RootElement, arrayName, "");
        }
        catch (Exception ex)
        {
            Error($"LOADJSON failed: {ex.Message}");
        }
    }

    // SAVEJSON arr$, path$ — save array as JSON file
    private void ExecuteSaveJson()
    {
        _pos++;
        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_COMMA, "Expected ',' in SAVEJSON arr$, path$");
        string path = EvaluateExpression().AsString();

        var elements = _variables.GetAllArrayElements(arrayName);
        if (elements == null)
        {
            Error($"Array not declared: {arrayName}");
            return;
        }

        try
        {
            var root = BuildJsonTree(elements);
            string json = System.Text.Json.JsonSerializer.Serialize(root,
                new System.Text.Json.JsonSerializerOptions { WriteIndented = true });
            System.IO.File.WriteAllText(_fileManager.ResolvePath(path), json);
        }
        catch (Exception ex)
        {
            Error($"SAVEJSON failed: {ex.Message}");
        }
    }

    // BASE64ENCODE(s$) — encode string to Base64
    private Value EvaluateBase64Encode()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after BASE64ENCODE");
        string input = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')'");
        return Value.FromString(Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(input)));
    }

    // BASE64DECODE(s$) — decode Base64 string
    private Value EvaluateBase64Decode()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after BASE64DECODE");
        string input = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')'");
        try
        {
            return Value.FromString(System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(input)));
        }
        catch
        {
            Error("BASE64DECODE: invalid Base64 string");
            return Value.Empty;
        }
    }

    // SHA256(s$) — returns lowercase hex SHA256 hash
    private Value EvaluateSha256()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after SHA256");
        string input = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')'");
        byte[] hash = System.Security.Cryptography.SHA256.HashData(
            System.Text.Encoding.UTF8.GetBytes(input));
        return Value.FromString(Convert.ToHexString(hash).ToLowerInvariant());
    }
}
