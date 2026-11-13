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
    // Error retrieving the last HTTP error message (empty if last call succeeded)
    private string _lastHttpError = "";

    // Shared HttpClient to reuse connections and avoid socket exhaustion.
    // Per-request timeouts are driven by a CancellationTokenSource, so the
    // client-level timeout is disabled here (otherwise it would fire first).
    private static readonly HttpClient _httpClient = new()
    {
        Timeout = System.Threading.Timeout.InfiniteTimeSpan
    };

    // Default request timeout in seconds, used when a call omits the argument.
    private const double DefaultHttpTimeoutSeconds = 30.0;

    // Send a prepared request with a per-call timeout (seconds). 0 or less = no timeout.
    private static string SendWithTimeout(HttpRequestMessage request, double timeoutSeconds)
    {
        using var cts = timeoutSeconds > 0
            ? new CancellationTokenSource(TimeSpan.FromSeconds(timeoutSeconds))
            : new CancellationTokenSource();
        try
        {
            var response = _httpClient.SendAsync(request, cts.Token).GetAwaiter().GetResult();
            return response.Content.ReadAsStringAsync(cts.Token).GetAwaiter().GetResult();
        }
        catch (OperationCanceledException) when (cts.IsCancellationRequested)
        {
            throw new Exception($"timed out after {timeoutSeconds:0.##} s");
        }
    }

    // HTTP get error message (empty if last call succeeded)
    private Value EvaluateHttpError()
    {
        _pos++;                                  // consume HTTPERROR
        if (Expect(TokenType.TOK_LPAREN))        // HTTPERROR tai HTTPERROR()
            Require(TokenType.TOK_RPAREN);
        return Value.FromString(_lastHttpError);
    }

    // HTTPGET(url$) / HTTPGET(url$, headers$) -> returns response body as string
    private Value EvaluateHttpGet()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after HTTPGET");
        string url = EvaluateExpression().AsString();

        string? headersArrayName = null;
        double timeoutSeconds = DefaultHttpTimeoutSeconds;
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++; // consume comma
            headersArrayName = _tokens[_pos].StringValue ?? "";
            _pos++;

            // Optional trailing argument: timeout in seconds
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++; // consume comma
                timeoutSeconds = EvaluateExpression().AsNumber();
            }
        }

        Require(TokenType.TOK_RPAREN, "Expected ')' after HTTPGET arguments");

        // Check that the URL is valid and uses HTTP or HTTPS scheme
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
        {
            Error($"HTTPGET: invalid URL '{url}'");
            return Value.Empty;
        }

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, url);
            ApplyHeaders(request, headersArrayName);
            _lastHttpError = "";
            return Value.FromString(SendWithTimeout(request, timeoutSeconds));
        }
        catch (Exception ex)
        {
            _lastHttpError = ex.Message;
            return Value.FromString("");
        }
    }

    // HTTPPOST(url$, body$) / HTTPPOST(url$, body$, headers$) -> returns response body as string
    private Value EvaluateHttpPost()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after HTTPPOST");
        string url = EvaluateExpression().AsString();
        Require(TokenType.TOK_COMMA, "Expected ',' after HTTPPOST url");
        string body = EvaluateExpression().AsString();

        string? headersArrayName = null;
        double timeoutSeconds = DefaultHttpTimeoutSeconds;
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++; // consume comma
            headersArrayName = _tokens[_pos].StringValue ?? "";
            _pos++;

            // Optional trailing argument: timeout in seconds
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++; // consume comma
                timeoutSeconds = EvaluateExpression().AsNumber();
            }
        }

        Require(TokenType.TOK_RPAREN, "Expected ')' after HTTPPOST arguments");

        // Check that the URL is valid and uses HTTP or HTTPS scheme
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
        {
            Error($"HTTPPOST: invalid URL '{url}'");
            return Value.Empty;
        }

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Content = new StringContent(body, System.Text.Encoding.UTF8, "application/json");
            ApplyHeaders(request, headersArrayName);
            _lastHttpError = "";
            return Value.FromString(SendWithTimeout(request, timeoutSeconds));
        }
        catch (Exception ex)
        {
            _lastHttpError = ex.Message;
            return Value.FromString("");
        }
    }

    // Apply BazzBasic array elements as HTTP headers to a request
    private void ApplyHeaders(HttpRequestMessage request, string? arrayName)
    {
        if (arrayName == null) return;
        var elements = _variables.GetAllArrayElements(arrayName);
        if (elements == null) return;

        foreach (var kv in elements)
        {
            string headerValue = kv.Value.AsString();
            // Request headers first; fall back to content headers (e.g. Content-Type)
            if (!request.Headers.TryAddWithoutValidation(kv.Key, headerValue))
                request.Content?.Headers.TryAddWithoutValidation(kv.Key, headerValue);
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

        try
        {
            var root = BuildJsonTree(elements);
            return Value.FromString(root.ToJsonString());
        }
        catch (Exception ex)
        {
            Error($"ASJSON failed: {ex.Message}");
            return Value.FromString("{}");
        }
    }

    // Build nested object/array tree from flat comma-key dictionary
    // (IDictionary so it accepts both the OrderedDictionary array backing store
    // and the plain Dictionary used internally for recursive sub-objects)
    // Builds a JsonNode tree (not Dictionary/List) so serialization needs no
    // reflection and works with PublishTrimmed.
    private static System.Text.Json.Nodes.JsonNode BuildJsonTree(IDictionary<string, Value> elements)
    {
        if (elements.Count == 0)
            return new System.Text.Json.Nodes.JsonObject();

        // Collect all top-level keys
        var top = new Dictionary<string, List<(string rest, Value val)>>(StringComparer.Ordinal);   // D100/D12: array keys are case-sensitive

        foreach (var kv in elements)
        {
            int comma = kv.Key.IndexOf(',');
            string first = comma < 0 ? kv.Key : kv.Key[..comma];
            string rest  = comma < 0 ? ""     : kv.Key[(comma + 1)..];
            if (!top.ContainsKey(first)) top[first] = [];
            top[first].Add((rest, kv.Value));
        }

        // D95: JSON array only when every top-level key is the CANONICAL string of a
        // non-negative int AND the index range is bounded (max <= 1e6, or dense:
        // max < 4*count+64, so the loop stays O(element count)). Anything else becomes a
        // JSON object with the original key strings. Before, any numeric key made the
        // loop run max+1 times - arr$("2147483647") froze then OOMed with no error and no
        // line number - and "-5" / "007" / " 5" keys were silently dropped.
        const int MaxSparseArrayIndex = 1_000_000;
        bool isArray = true;
        int max = -1;
        foreach (var k in top.Keys)
        {
            if (!int.TryParse(k, out int n) || n < 0 || n.ToString() != k)
            {
                isArray = false;
                break;
            }
            if (n > max) max = n;
        }

        if (isArray && (max <= MaxSparseArrayIndex || max < 4 * top.Count + 64))
        {
            var list = new System.Text.Json.Nodes.JsonArray();
            for (int i = 0; i <= max; i++)
            {
                string idx = i.ToString();
                System.Text.Json.Nodes.JsonNode? node = top.ContainsKey(idx) ? ResolveNode(top[idx]) : null;
                list.Add(node);
            }
            return list;
        }
        else
        {
            var dict = new System.Text.Json.Nodes.JsonObject();
            foreach (var kv in top)
                dict[kv.Key] = ResolveNode(kv.Value);
            return dict;
        }
    }

    private static System.Text.Json.Nodes.JsonNode? ResolveNode(List<(string rest, Value val)> entries)
    {
        // Leaf node — single entry with no further path
        if (entries.Count == 1 && entries[0].rest == "")
        {
            Value v = entries[0].val;
            if (v.Type == BazzBasic.Parser.BazzValueType.Number)
                return System.Text.Json.Nodes.JsonValue.Create(v.NumValue);
            return System.Text.Json.Nodes.JsonValue.Create(v.AsString());
        }

        // Recurse: rebuild sub-dictionary
        var sub = new Dictionary<string, Value>(StringComparer.Ordinal);   // D100/D12: array keys are case-sensitive
        foreach (var (rest, val) in entries)
            sub[rest] = val;
        return BuildJsonTree(sub);
    }

    // ASARRAY(arr$, data$) — fills arr$ from a JSON or XML string, returns element count.
    // The format is picked from the first character (6.11.2026): '{' / '[' = JSON, '<' = XML.
    private Value EvaluateAsArray()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after ASARRAY");

        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_COMMA, "Expected ',' in ASARRAY(arr$, data$)");

        string data = EvaluateExpression().AsString();
        Require(TokenType.TOK_RPAREN, "Expected ')' after ASARRAY arguments");

        // HTTPGET / HTTPPOST return "" on failure, so an empty string is the common case
        if (data.Trim('﻿', ' ', '\t', '\r', '\n').Length == 0)
        {
            Error("ASARRAY: data is empty (if it came from HTTPGET or HTTPPOST, check HTTPERROR)");
            return Value.Zero;
        }

        var format = SniffDataFormat(data);
        if (format == DataFormat.Unknown)
        {
            Error("ASARRAY: data is not JSON or XML (must start with {, [ or <)");
            return Value.Zero;
        }

        if (!_variables.ArrayExists(arrayName))
            _variables.DeclareArray(arrayName);

        if (format == DataFormat.Xml)
        {
            try
            {
                return Value.FromNumber(FlattenXml(data, arrayName));
            }
            catch (Exception ex)
            {
                Error($"ASARRAY failed to parse XML: {ex.Message}");
                return Value.Zero;
            }
        }

        try
        {
            var doc = System.Text.Json.JsonDocument.Parse(data.TrimStart('﻿'));
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
            string json = root.ToJsonString(
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
