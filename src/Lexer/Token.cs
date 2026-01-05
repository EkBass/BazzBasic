/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Lexer\Token.cs
 Token Structure

 Licence: MIT
*/






namespace BazzBasic.Lexer;

public readonly struct Token
{
    public readonly TokenType Type;
    public readonly double NumValue;
    public readonly string? StringValue;
    public readonly int Line;

    public Token(TokenType type, int line)
    {
        Type = type;
        NumValue = 0;
        StringValue = null;
        Line = line;
    }

    public Token(TokenType type, double numValue, int line)
    {
        Type = type;
        NumValue = numValue;
        StringValue = null;
        Line = line;
    }

    public Token(TokenType type, string stringValue, int line)
    {
        Type = type;
        NumValue = 0;
        StringValue = stringValue;
        Line = line;
    }

    // ========================================================================
    // Fast category checks
    // ========================================================================

    // Categories are generated automatically based on TokenType enum values so this is not needed
    // anymore, but I dont dare to remve it yet

    // See TokenType.cs 

    // Keywords have values 1-109
    public bool IsKeyword => (int)Type >= 1 && (int)Type < 120;
    
    // Operators have values 120-139
    public bool IsOperator => (int)Type >= 120 && (int)Type < 200;
    
    // Literals have values 200-209
    public bool IsLiteral => (int)Type >= 200 && (int)Type < 250;

    // ========================================================================
    // Debug output
    // ========================================================================
    
    public override string ToString()
    {
        return Type switch
        {
            TokenType.TOK_NUMBER => $"NUM:{NumValue}",
            TokenType.TOK_STRING => $"STR:\"{StringValue}\"",
            TokenType.TOK_VARIABLE => $"VAR:{StringValue}",
            TokenType.TOK_CONSTANT => $"CONST:{StringValue}",
            TokenType.TOK_LABEL => $"LBL:[{StringValue}]",
            TokenType.TOK_NEWLINE => "NEWLINE",
            TokenType.TOK_EOF => "EOF",
            _ when IsOperator => $"OP:{Type}",
            _ when IsKeyword => $"KEY:{Type}",
            _ => $"?:{Type}"
        };
    }
}
