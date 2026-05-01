/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.HttpListen.cs
 Built-in HTTP server commands for receiving form posts / data
 from local HTML pages.
 
 STARTLISTEN port [, timeout_ms]
 LET body$ = GETREQUEST()
 SENDRESPONSE str$
 STOPLISTEN
 
 - Bound to 127.0.0.1 only — no admin rights needed on Windows.
 - GETREQUEST blocks until a real request arrives or the timeout
   expires (returns empty string on timeout).
 - OPTIONS preflight requests are answered automatically with
   200 OK + CORS headers and never reach user code.
 - SENDRESPONSE always sends 200 OK, text/plain, with
   Access-Control-Allow-Origin: * so cross-origin browser pages
   work without extra setup.
 
 Copyright (c):
    - 2025 - 2026
    - Kristian Virtanen
    - krisu.virtanen@gmail.com

    - Licensed under the MIT License. See LICENSE file in the project root.
*/

using System.Net;
using System.Text;
using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    // Single shared listener — only one active server at a time
    private HttpListener? _httpListener;
    private int _httpListenerTimeoutMs;          // 0 = wait forever
    private HttpListenerContext? _pendingContext; // request awaiting SENDRESPONSE

    // STARTLISTEN port [, timeout_ms]
    private void ExecuteStartListen()
    {
        _pos++; // consume STARTLISTEN

        int port = (int)EvaluateExpression().AsNumber();
        int timeout = 0;

        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
        {
            _pos++;
            timeout = (int)EvaluateExpression().AsNumber();
            if (timeout < 0) timeout = 0;
        }

        if (port < 1 || port > 65535)
        {
            Error($"STARTLISTEN: invalid port {port}.");
            return;
        }

        if (_httpListener != null)
        {
            Error("STARTLISTEN: a listener is already active. Call STOPLISTEN first.");
            return;
        }

        try
        {
            var listener = new HttpListener();
            // 127.0.0.1 only -> no admin rights needed on Windows
            listener.Prefixes.Add($"http://127.0.0.1:{port}/");
            listener.Start();
            _httpListener = listener;
            _httpListenerTimeoutMs = timeout;
            _pendingContext = null;
        }
        catch (HttpListenerException ex)
        {
            Error($"STARTLISTEN: failed to bind port {port}: {ex.Message}");
        }
        catch (Exception ex)
        {
            Error($"STARTLISTEN: {ex.Message}");
        }
    }

    // GETREQUEST() -> body of POST, or query string of GET (without '?'), or "" on timeout
    private Value EvaluateGetRequest()
    {
        _pos++; // consume GETREQUEST
        Require(TokenType.TOK_LPAREN, "Expected '(' after GETREQUEST");
        Require(TokenType.TOK_RPAREN, "Expected ')' after GETREQUEST");

        if (_httpListener == null)
        {
            Error("GETREQUEST: no listener active. Call STARTLISTEN first.");
            return Value.Empty;
        }

        // If a previous request is still pending without a SENDRESPONSE,
        // close it with an empty 200 so the browser doesn't hang. This
        // keeps the API simple for users who forget SENDRESPONSE.
        if (_pendingContext != null)
        {
            try { WriteResponse(_pendingContext, ""); } catch { /* ignore */ }
            _pendingContext = null;
        }

        int remainingMs = _httpListenerTimeoutMs;
        var swatch = System.Diagnostics.Stopwatch.StartNew();

        while (true)
        {
            HttpListenerContext ctx;
            try
            {
                var task = _httpListener.GetContextAsync();

                if (_httpListenerTimeoutMs <= 0)
                {
                    // Wait forever
                    task.Wait();
                    ctx = task.Result;
                }
                else
                {
                    int waitMs = remainingMs - (int)swatch.ElapsedMilliseconds;
                    if (waitMs <= 0) return Value.Empty;
                    if (!task.Wait(waitMs))
                        return Value.Empty;
                    ctx = task.Result;
                }
            }
            catch (Exception ex)
            {
                Error($"GETREQUEST: {ex.Message}");
                return Value.Empty;
            }

            // Auto-handle CORS preflight: respond and keep waiting
            string method = ctx.Request.HttpMethod.ToUpperInvariant();
            if (method == "OPTIONS")
            {
                try { WritePreflight(ctx); } catch { /* ignore */ }
                continue;
            }

            _pendingContext = ctx;

            // Hand back something sensible:
            //  - POST/PUT/PATCH -> request body (UTF-8 string)
            //  - GET/DELETE/etc -> query string without leading '?'
            if (method == "POST" || method == "PUT" || method == "PATCH")
            {
                using var reader = new System.IO.StreamReader(
                    ctx.Request.InputStream,
                    ctx.Request.ContentEncoding ?? Encoding.UTF8);
                return Value.FromString(reader.ReadToEnd());
            }
            else
            {
                string? query = ctx.Request.Url?.Query ?? "";
                if (query.StartsWith('?')) query = query.Substring(1);
                return Value.FromString(query);
            }
        }
    }

    // SENDRESPONSE str$
    private void ExecuteSendResponse()
    {
        _pos++; // consume SENDRESPONSE
        string body = EvaluateExpression().AsString();

        if (_httpListener == null)
        {
            Error("SENDRESPONSE: no listener active. Call STARTLISTEN first.");
            return;
        }

        if (_pendingContext == null)
        {
            Error("SENDRESPONSE: no pending request. Call GETREQUEST() first.");
            return;
        }

        try
        {
            WriteResponse(_pendingContext, body);
        }
        catch (Exception ex)
        {
            Error($"SENDRESPONSE: {ex.Message}");
        }
        finally
        {
            _pendingContext = null;
        }
    }

    // STOPLISTEN — silent no-op if no listener active
    private void ExecuteStopListen()
    {
        _pos++; // consume STOPLISTEN

        if (_pendingContext != null)
        {
            try { WriteResponse(_pendingContext, ""); } catch { /* ignore */ }
            _pendingContext = null;
        }

        if (_httpListener != null)
        {
            try { _httpListener.Stop(); } catch { /* ignore */ }
            try { _httpListener.Close(); } catch { /* ignore */ }
            _httpListener = null;
        }
    }

    // ----- helpers -----

    private static void WriteResponse(HttpListenerContext ctx, string body)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(body);
        ctx.Response.StatusCode = 200;
        ctx.Response.ContentType = "text/plain; charset=utf-8";
        ctx.Response.ContentLength64 = bytes.Length;
        ctx.Response.AddHeader("Access-Control-Allow-Origin", "*");
        ctx.Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
        ctx.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");
        ctx.Response.OutputStream.Write(bytes, 0, bytes.Length);
        ctx.Response.OutputStream.Close();
    }

    private static void WritePreflight(HttpListenerContext ctx)
    {
        ctx.Response.StatusCode = 200;
        ctx.Response.ContentLength64 = 0;
        ctx.Response.AddHeader("Access-Control-Allow-Origin", "*");
        ctx.Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
        ctx.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");
        ctx.Response.AddHeader("Access-Control-Max-Age", "86400");
        ctx.Response.OutputStream.Close();
    }
}
