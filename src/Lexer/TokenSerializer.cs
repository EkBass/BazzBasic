/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Lexer\TokenSerializer.cs
 Binary serialization for .bb library files

 Licence: MIT
*/

using System.Text;

namespace BazzBasic.Lexer;

public static class TokenSerializer
{
    // File format magic bytes
    private static readonly byte[] MAGIC = "BAZZ"u8.ToArray();
    private const byte VERSION = 1;

    // Serialize tokens to binary .bb format
    public static byte[] Serialize(List<Token> tokens, string libraryName)
    {
        using var ms = new MemoryStream();
        using var writer = new BinaryWriter(ms, Encoding.UTF8);

        // Header
        writer.Write(MAGIC);
        writer.Write(VERSION);
        writer.Write(libraryName.ToUpperInvariant());
        writer.Write(tokens.Count);

        // Tokens
        foreach (var token in tokens)
        {
            writer.Write((ushort)token.Type);
            writer.Write((ushort)token.Line);

            // Data type: 0=none, 1=number, 2=string
            if (token.NumValue != 0)
            {
                writer.Write((byte)1);
                writer.Write(token.NumValue);
            }
            else if (!string.IsNullOrEmpty(token.StringValue))
            {
                writer.Write((byte)2);
                writer.Write(token.StringValue);
            }
            else
            {
                writer.Write((byte)0);
            }
        }

        return ms.ToArray();
    }

    // Deserialize binary .bb format to tokens
    public static (string LibraryName, List<Token> Tokens) Deserialize(byte[] data)
    {
        using var ms = new MemoryStream(data);
        using var reader = new BinaryReader(ms, Encoding.UTF8);

        // Verify magic
        var magic = reader.ReadBytes(4);
        if (!magic.SequenceEqual(MAGIC))
        {
            throw new Exception("Invalid library file format");
        }

        // Version check
        var version = reader.ReadByte();
        if (version > VERSION)
        {
            throw new Exception($"Library file version {version} not supported (max: {VERSION})");
        }

        // Header
        var libraryName = reader.ReadString();
        var tokenCount = reader.ReadInt32();

        // Tokens
        var tokens = new List<Token>(tokenCount);
        for (int i = 0; i < tokenCount; i++)
        {
            var type = (TokenType)reader.ReadUInt16();
            var line = reader.ReadUInt16();
            var dataType = reader.ReadByte();

            double numValue = 0;
            string? stringValue = null;

            if (dataType == 1)
            {
                numValue = reader.ReadDouble();
            }
            else if (dataType == 2)
            {
                stringValue = reader.ReadString();
            }

            // Use appropriate constructor based on data type
            Token token;
            if (stringValue != null)
                token = new Token(type, stringValue, line);
            else if (numValue != 0)
                token = new Token(type, numValue, line);
            else
                token = new Token(type, line);
            
            tokens.Add(token);
        }

        return (libraryName, tokens);
    }

    // Validate that source contains only DEF FN functions
    public static List<string> ValidateLibraryContent(List<Token> tokens)
    {
        var errors = new List<string>();
        int i = 0;

        while (i < tokens.Count)
        {
            var token = tokens[i];

            // Skip allowed tokens
            if (token.Type == TokenType.TOK_NEWLINE ||
                token.Type == TokenType.TOK_EOF ||
                token.Type == TokenType.TOK_REM)
            {
                i++;
                continue;
            }

            // Must be DEF FN
            if (token.Type != TokenType.TOK_DEF)
            {
                errors.Add($"Line {token.Line}: Libraries can only contain DEF FN functions. Found: {token.Type}");
                // Skip to next line
                while (i < tokens.Count && tokens[i].Type != TokenType.TOK_NEWLINE)
                    i++;
                i++;
                continue;
            }

            // Skip entire DEF FN block until END DEF
            int depth = 1;
            i++; // Skip DEF
            while (i < tokens.Count && depth > 0)
            {
                if (tokens[i].Type == TokenType.TOK_DEF)
                    depth++;
                else if (tokens[i].Type == TokenType.TOK_END &&
                         i + 1 < tokens.Count &&
                         tokens[i + 1].Type == TokenType.TOK_DEF)
                {
                    depth--;
                    i++; // Skip DEF after END
                }
                i++;
            }
        }

        return errors;
    }

    // Add library prefix to all function names in tokens
    public static void AddFunctionPrefix(List<Token> tokens, string prefix)
    {
        for (int i = 0; i < tokens.Count - 1; i++)
        {
            // Find DEF FN <name>
            if (tokens[i].Type == TokenType.TOK_DEF &&
                tokens[i + 1].Type == TokenType.TOK_FN &&
                i + 2 < tokens.Count &&
                tokens[i + 2].Type == TokenType.TOK_VARIABLE)
            {
                var funcName = tokens[i + 2].StringValue;
                var newName = $"{prefix}_{funcName}";
                tokens[i + 2] = new Token(
                    TokenType.TOK_VARIABLE,
                    newName,
                    tokens[i + 2].Line
                );
            }
        }
    }
}
