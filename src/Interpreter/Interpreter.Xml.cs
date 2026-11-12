/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: Interpreter\Interpreter.Xml.cs
 "Light model" XML support: ASXML, LOADXML, SAVEXML and the XML half of ASARRAY.
 Meant mainly for reading RSS/Atom feeds. JSON stays the recommended format.

 XML <-> array mapping (6.11.2026):
   - Every element below the root gets an index, even a single one, so a
     loop over items never silently finds nothing:
       <rss><channel><item><title>A</title></item></channel></rss>
       -> rss,channel,0,item,0,title,0 = "A"
   - Attributes:            <guid isPermaLink="false">  -> ...,guid,0,@isPermaLink
   - Text next to attributes or child elements           -> ...,#text
   - Prefixes are kept as written: <dc:creator>          -> ...,dc:creator,0
   - CDATA is plain text. Comments, processing instructions and DTDs are ignored.
   - Not supported: the order of mixed text and elements (<p>a <b>b</b> c</p>).
   - All values are strings (XML has no number type).

 Only System.Xml / System.Xml.Linq / System.Text.Json.Nodes: no NuGet packages,
 no reflection, safe for PublishTrimmed.

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using System.Globalization;
using System.Text;
using System.Text.Json.Nodes;
using System.Xml;
using System.Xml.Linq;
using BazzBasic.Lexer;
using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

public partial class Interpreter
{
    private enum DataFormat { Unknown, Json, Xml }

    // ASARRAY decides the format from the first real character:
    // '{' or '[' = JSON, '<' = XML. A BOM and leading whitespace are skipped.
    private static DataFormat SniffDataFormat(string data)
    {
        foreach (char c in data)
        {
            if (c == '﻿' || char.IsWhiteSpace(c)) continue;
            if (c == '{' || c == '[') return DataFormat.Json;
            if (c == '<') return DataFormat.Xml;
            return DataFormat.Unknown;
        }
        return DataFormat.Unknown;
    }

    // DTDs are ignored: no external entities (XXE), no entity expansion bombs.
    private static XDocument ParseXmlDocument(string xml)
    {
        var settings = new XmlReaderSettings
        {
            DtdProcessing = DtdProcessing.Ignore,
            XmlResolver = null,
            IgnoreComments = true,
            IgnoreProcessingInstructions = true,
            IgnoreWhitespace = true,
        };
        using var sr = new StringReader(xml.TrimStart('﻿'));
        using var reader = XmlReader.Create(sr, settings);
        return XDocument.Load(reader);
    }

    // XML text -> array, returns element count (same count rule as JSON: one per stored value)
    private int FlattenXml(string xml, string arrayName)
    {
        var root = ParseXmlDocument(xml).Root
            ?? throw new XmlException("document has no root element");
        return FlattenXmlElement(root, XmlElementName(root), arrayName);
    }

    private int FlattenXmlElement(XElement el, string key, string arrayName)
    {
        int count = 0;

        foreach (var a in el.Attributes())
        {
            _variables.SetArrayElement(arrayName, $"{key},@{XmlAttributeName(a)}", Value.FromString(a.Value));
            count++;
        }

        // XText also covers XCData, so CDATA arrives as plain text
        string text = string.Concat(el.Nodes().OfType<XText>().Select(t => t.Value)).Trim();
        bool hasChildren = el.HasElements;

        if (!hasChildren && !el.HasAttributes)
        {
            _variables.SetArrayElement(arrayName, key, Value.FromString(text));
            return count + 1;
        }

        if (text.Length > 0)
        {
            _variables.SetArrayElement(arrayName, $"{key},#text", Value.FromString(text));
            count++;
        }

        if (!hasChildren) return count;

        var seen = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        foreach (var child in el.Elements())
        {
            string name = XmlElementName(child);
            seen.TryGetValue(name, out int i);
            seen[name] = i + 1;
            count += FlattenXmlElement(child, $"{key},{name},{i}", arrayName);
        }
        return count;
    }

    // Keep the prefix the document uses: <dc:creator> -> "dc:creator". Default namespace -> local name.
    private static string XmlElementName(XElement el)
    {
        string? prefix = el.GetPrefixOfNamespace(el.Name.Namespace);
        return string.IsNullOrEmpty(prefix) ? el.Name.LocalName : $"{prefix}:{el.Name.LocalName}";
    }

    private static string XmlAttributeName(XAttribute a)
    {
        // xmlns declarations are kept so ASXML can write them back
        if (a.IsNamespaceDeclaration)
            return a.Name.Namespace == XNamespace.None ? "xmlns" : $"xmlns:{a.Name.LocalName}";
        if (a.Name.Namespace == XNamespace.None) return a.Name.LocalName;
        if (a.Name.Namespace == XNamespace.Xml) return $"xml:{a.Name.LocalName}";
        string? prefix = a.Parent?.GetPrefixOfNamespace(a.Name.Namespace);
        return string.IsNullOrEmpty(prefix) ? a.Name.LocalName : $"{prefix}:{a.Name.LocalName}";
    }

    // ------------------------------------------------------------------------
    // Array -> XML text. Goes through BuildJsonTree, so arrays and nested keys
    // behave exactly as in ASJSON.
    // ------------------------------------------------------------------------
    private static string BuildXmlText(IDictionary<string, Value> elements, bool indent)
    {
        JsonNode tree = BuildJsonTree(elements);
        string rootName = "root";
        JsonNode? body = tree;

        // One top-level key that is a single element becomes the root, so
        // ASARRAY(feed$, rss$) followed by ASXML(feed$) gives back <rss>...</rss>.
        // An indexed root ("rss,0,...") works too.
        if (tree is JsonObject obj && obj.Count == 1)
        {
            var only = obj.First();
            JsonNode? value = only.Value;
            if (value is JsonArray one && one.Count == 1) value = one[0];
            if (!only.Key.StartsWith('@') && !only.Key.StartsWith('#') && value is not JsonArray)
            {
                rootName = only.Key;
                body = value;
            }
        }

        var sb = new StringBuilder();
        if (indent) sb.Append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        WriteXmlElement(sb, rootName, body, indent, 0);
        return sb.ToString();
    }

    private static void WriteXmlElement(StringBuilder sb, string name, JsonNode? node, bool indent, int depth)
    {
        CheckXmlName(name);
        string pad = indent ? new string(' ', depth * 2) : "";
        string nl = indent ? "\n" : "";

        if (node is JsonArray arr)   // array directly inside an array: one <item> per entry
        {
            sb.Append(pad).Append('<').Append(name).Append('>').Append(nl);
            foreach (var item in arr) WriteXmlElement(sb, "item", item, indent, depth + 1);
            sb.Append(pad).Append("</").Append(name).Append('>').Append(nl);
            return;
        }

        if (node is not JsonObject o)   // leaf value
        {
            string v = XmlLeafText(node);
            sb.Append(pad).Append('<').Append(name);
            if (v.Length == 0) { sb.Append("/>").Append(nl); return; }
            sb.Append('>').Append(EscapeXmlText(v)).Append("</").Append(name).Append('>').Append(nl);
            return;
        }

        sb.Append(pad).Append('<').Append(name);
        foreach (var kv in o)
        {
            if (!kv.Key.StartsWith('@')) continue;
            string attr = kv.Key[1..];
            CheckXmlName(attr);
            sb.Append(' ').Append(attr).Append("=\"").Append(EscapeXmlAttr(XmlLeafText(kv.Value))).Append('"');
        }

        string text = o.TryGetPropertyValue("#text", out var t) ? XmlLeafText(t) : "";
        var children = o.Where(kv => !kv.Key.StartsWith('@') && kv.Key != "#text").ToList();

        if (children.Count == 0)
        {
            if (text.Length == 0) { sb.Append("/>").Append(nl); return; }
            sb.Append('>').Append(EscapeXmlText(text)).Append("</").Append(name).Append('>').Append(nl);
            return;
        }

        sb.Append('>').Append(nl);
        if (text.Length > 0)
            sb.Append(indent ? new string(' ', (depth + 1) * 2) : "").Append(EscapeXmlText(text)).Append(nl);
        foreach (var kv in children)
        {
            if (kv.Value is JsonArray list)   // indexed element: <item>..</item><item>..</item>
                foreach (var item in list) WriteXmlElement(sb, kv.Key, item, indent, depth + 1);
            else
                WriteXmlElement(sb, kv.Key, kv.Value, indent, depth + 1);
        }
        sb.Append(pad).Append("</").Append(name).Append('>').Append(nl);
    }

    private static string XmlLeafText(JsonNode? n)
    {
        if (n is null) return "";
        if (n is JsonValue v)
        {
            if (v.TryGetValue<string>(out var s)) return s;
            if (v.TryGetValue<double>(out var d)) return d.ToString("R", CultureInfo.InvariantCulture);
        }
        return n.ToJsonString();
    }

    private static void CheckXmlName(string name)
    {
        try { XmlConvert.VerifyName(name); }
        catch (XmlException) { throw new FormatException($"key '{name}' is not a valid XML name"); }
    }

    private static string EscapeXmlText(string s) =>
        s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;");

    private static string EscapeXmlAttr(string s) =>
        EscapeXmlText(s).Replace("\"", "&quot;");

    // ========================================================================
    // Commands
    // ========================================================================

    // ASXML(array$) — converts BazzBasic array to XML string (6.11.2026)
    private Value EvaluateAsXml()
    {
        _pos++;
        Require(TokenType.TOK_LPAREN, "Expected '(' after ASXML");

        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_RPAREN, "Expected ')' after ASXML argument");

        var elements = _variables.GetAllArrayElements(arrayName);
        if (elements == null)
        {
            Error($"Array not declared: {arrayName}");
            return Value.FromString("");
        }

        try
        {
            return Value.FromString(BuildXmlText(elements, indent: false));
        }
        catch (Exception ex)
        {
            Error($"ASXML: {ex.Message}");
            return Value.FromString("");
        }
    }

    // LOADXML arr$, path$ — load XML file directly into array (6.11.2026)
    private void ExecuteLoadXml()
    {
        _pos++;
        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_COMMA, "Expected ',' in LOADXML arr$, path$");
        string path = EvaluateExpression().AsString();

        try
        {
            string xml = System.IO.File.ReadAllText(_fileManager.ResolvePath(path));
            if (!_variables.ArrayExists(arrayName))
                _variables.DeclareArray(arrayName);
            FlattenXml(xml, arrayName);
        }
        catch (Exception ex)
        {
            Error($"LOADXML failed: {ex.Message}");
        }
    }

    // SAVEXML arr$, path$ — save array as XML file (6.11.2026)
    private void ExecuteSaveXml()
    {
        _pos++;
        string arrayName = _tokens[_pos].StringValue ?? "";
        _pos++;
        Require(TokenType.TOK_COMMA, "Expected ',' in SAVEXML arr$, path$");
        string path = EvaluateExpression().AsString();

        var elements = _variables.GetAllArrayElements(arrayName);
        if (elements == null)
        {
            Error($"Array not declared: {arrayName}");
            return;
        }

        try
        {
            System.IO.File.WriteAllText(_fileManager.ResolvePath(path), BuildXmlText(elements, indent: true));
        }
        catch (Exception ex)
        {
            Error($"SAVEXML failed: {ex.Message}");
        }
    }
}
