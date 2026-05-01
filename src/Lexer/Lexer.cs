/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Lexer\Lexer.cs
 This turns code to INT tokens which is way faster than parsing on the from the string every time.
 
    Copyright (c):
	    - 2025 - 2026
	    - Kristian Virtanen
	    - krisu.virtanen@gmail.com

    	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using System.Text;

namespace BazzBasic.Lexer;

public class Lexer(string source)
{
    // Keyword lookup table
    private static readonly Dictionary<string, TokenType> Keywords = new(StringComparer.OrdinalIgnoreCase)
    {
        // Control flow
        // Before 1.0, adjust these alphabetically
        ["DEF"]         = TokenType.TOK_DEF,
        ["DIM"]         = TokenType.TOK_DIM,
        ["ELSE"]        = TokenType.TOK_ELSE,
        ["ELSEIF"]      = TokenType.TOK_ELSEIF,
        ["END"]         = TokenType.TOK_END,
        ["ENDIF"]       = TokenType.TOK_ENDIF,
        ["FN"]          = TokenType.TOK_FN,
        ["FOR"]         = TokenType.TOK_FOR,
        ["GOSUB"]       = TokenType.TOK_GOSUB,
        ["GOTO"]        = TokenType.TOK_GOTO,
        ["IF"]          = TokenType.TOK_IF,
        ["INCLUDE"]     = TokenType.TOK_INCLUDE,
        ["LET"]         = TokenType.TOK_LET,
        ["NEXT"]        = TokenType.TOK_NEXT,
        ["PRINT"]       = TokenType.TOK_PRINT,
        ["REM"]         = TokenType.TOK_REM,
        ["RETURN"]      = TokenType.TOK_RETURN,
        ["STEP"]        = TokenType.TOK_STEP,
        ["THEN"]        = TokenType.TOK_THEN,
        ["TO"]          = TokenType.TOK_TO,
        ["WEND"]        = TokenType.TOK_WEND,
        ["WHILE"]       = TokenType.TOK_WHILE,

        // I/O
        ["CLS"]         = TokenType.TOK_CLS,
        ["COLOR"]       = TokenType.TOK_COLOR,
        ["GETCONSOLE"]  = TokenType.TOK_GETCONSOLE,
        ["CURPOS"]      = TokenType.TOK_CURPOS,
        ["INPUT"]       = TokenType.TOK_INPUT,
        ["LOCATE"]      = TokenType.TOK_LOCATE,
        ["SLEEP"]       = TokenType.TOK_SLEEP,

        // Graphics
        ["B"]           = TokenType.TOK_B,
        ["BF"]          = TokenType.TOK_BF,
        ["CIRCLE"]      = TokenType.TOK_CIRCLE,
        ["DRAWSHAPE"]   = TokenType.TOK_DRAWSHAPE,
        ["HIDESHAPE"]   = TokenType.TOK_HIDESHAPE,
        ["LINE"]        = TokenType.TOK_LINE,
        ["LOADIMAGE"]   = TokenType.TOK_LOADIMAGE,
        ["LOADSHAPE"]   = TokenType.TOK_LOADSHAPE,
        ["MOVESHAPE"]   = TokenType.TOK_MOVESHAPE,
        ["PAINT"]       = TokenType.TOK_PAINT,
        ["POINT"]       = TokenType.TOK_POINT,
        ["PSET"]        = TokenType.TOK_PSET,
        ["REMOVESHAPE"] = TokenType.TOK_REMOVESHAPE,
        ["ROTATESHAPE"] = TokenType.TOK_ROTATESHAPE,
        ["SCALESHAPE"]  = TokenType.TOK_SCALESHAPE,
        ["SCREEN"]      = TokenType.TOK_SCREEN,
        ["SCREENLOCK"]  = TokenType.TOK_SCREENLOCK,
        ["SHOWSHAPE"]   = TokenType.TOK_SHOWSHAPE,
        ["VSYNC"]       = TokenType.TOK_VSYNC,
        ["FULLSCREEN"]  = TokenType.TOK_FULLSCREEN,
        ["LOADSHEET"]   = TokenType.TOK_LOADSHEET,
        ["LOADFONT"]    = TokenType.TOK_LOADFONT,
        ["DRAWSTRING"]  = TokenType.TOK_DRAWSTRING,
        ["HTTPGET"]     = TokenType.TOK_HTTPGET,
        ["HTTPPOST"]    = TokenType.TOK_HTTPPOST,
        ["ASJSON"]      = TokenType.TOK_ASJSON,
        ["ASARRAY"]     = TokenType.TOK_ASARRAY,
        ["LOADJSON"]    = TokenType.TOK_LOADJSON,
        ["SAVEJSON"]    = TokenType.TOK_SAVEJSON,
        ["STARTLISTEN"]  = TokenType.TOK_STARTLISTEN,
        ["GETREQUEST"]   = TokenType.TOK_GETREQUEST,
        ["SENDRESPONSE"] = TokenType.TOK_SENDRESPONSE,
        ["STOPLISTEN"]   = TokenType.TOK_STOPLISTEN,

        // Sound
        ["LOADSOUND"]       = TokenType.TOK_LOADSOUND,
        ["SOUNDONCE"]       = TokenType.TOK_SOUNDONCE,
        ["SOUNDONCEWAIT"]   = TokenType.TOK_SOUNDONCEWAIT,
        ["SOUNDREPEAT"]     = TokenType.TOK_SOUNDREPEAT,
        ["SOUNDSTOP"]       = TokenType.TOK_SOUNDSTOP,
        ["SOUNDSTOPALL"]    = TokenType.TOK_SOUNDSTOPALL,

        // File operations
        ["FILEREAD"]        = TokenType.TOK_FILEREAD,
        ["FILEEXISTS"]      = TokenType.TOK_FILEEXISTS,
        ["FILEWRITE"]       = TokenType.TOK_FILEWRITE,
        ["FILEAPPEND"]      = TokenType.TOK_FILEAPPEND,
        ["FILEDELETE"]      = TokenType.TOK_FILEDELETE,
        ["SHELL"]           = TokenType.TOK_SHELL,

        // Math functions
        ["ABS"]             = TokenType.TOK_ABS,
        ["ATAN"]            = TokenType.TOK_ATAN,
        ["ATAN2"]           = TokenType.TOK_ATAN2,
        ["ISSET"]           = TokenType.TOK_ISSET,
        ["CEIL"]            = TokenType.TOK_CEIL,
        ["CINT"]            = TokenType.TOK_CINT,
        ["COS"]             = TokenType.TOK_COS,
        ["EXP"]             = TokenType.TOK_EXP,
        ["FLOOR"]           = TokenType.TOK_FLOOR,
        ["INT"]             = TokenType.TOK_INT,
        ["LOG"]             = TokenType.TOK_LOG,
        ["MAX"]             = TokenType.TOK_MAX,
        ["MIN"]             = TokenType.TOK_MIN,
        ["MOD"]             = TokenType.TOK_MOD,
        ["POW"]             = TokenType.TOK_POW,
        ["RND"]             = TokenType.TOK_RND,
        ["ROUND"]           = TokenType.TOK_ROUND,
        ["SGN"]             = TokenType.TOK_SGN,
        ["SIN"]             = TokenType.TOK_SIN,
        ["SQR"]             = TokenType.TOK_SQR,
        ["TAN"]             = TokenType.TOK_TAN,
        ["PI"]              = TokenType.TOK_PI,
        ["RAD"]             = TokenType.TOK_RAD,
        ["DEG"]             = TokenType.TOK_DEG,
        ["HPI"]             = TokenType.TOK_HPI,
        ["FASTTRIG"]        = TokenType.TOK_FASTTRIG,
        ["FASTSIN"]         = TokenType.TOK_FASTSIN,
        ["FASTCOS"]         = TokenType.TOK_FASTCOS,
        ["FASTRAD"]         = TokenType.TOK_FASTRAD,
        ["QPI"]             = TokenType.TOK_QPI,
        ["TAU"]             = TokenType.TOK_TAU,
        ["BETWEEN"]         = TokenType.TOK_BETWEEN,
        ["EULER"]           = TokenType.TOK_EULER,
        ["DISTANCE"]        = TokenType.TOK_DISTANCE,
        ["CLAMP"]           = TokenType.TOK_CLAMP,
        ["LERP"]            = TokenType.TOK_LERP,
        ["INBETWEEN"]        = TokenType.TOK_INBETWEEN,

        // String functions
        ["ASC"]         = TokenType.TOK_ASC,
        ["CHR"]         = TokenType.TOK_CHR,
        ["INSTR"]       = TokenType.TOK_INSTR,
        ["INVERT"]      = TokenType.TOK_INVERT,
        ["LCASE"]       = TokenType.TOK_LCASE,
        ["LEFT"]        = TokenType.TOK_LEFT,
        ["LEN"]         = TokenType.TOK_LEN,
        ["LTRIM"]       = TokenType.TOK_LTRIM,
        ["MID"]         = TokenType.TOK_MID,
        ["REPEAT"]      = TokenType.TOK_REPEAT,
        ["REPLACE"]     = TokenType.TOK_REPLACE,
        ["RIGHT"]       = TokenType.TOK_RIGHT,
        ["RTRIM"]       = TokenType.TOK_RTRIM,
        ["SRAND"]       = TokenType.TOK_SRAND,
        ["SPLIT"]       = TokenType.TOK_SPLIT,
        ["STR"]         = TokenType.TOK_STR,
        ["TRIM"]        = TokenType.TOK_TRIM,
        ["UCASE"]       = TokenType.TOK_UCASE,
        ["VAL"]         = TokenType.TOK_VAL,
        ["FSTRING"]     = TokenType.TOK_FSTRING,

        // Input/Mouse
        ["INKEY"]       = TokenType.TOK_INKEY,
        ["RGB"]         = TokenType.TOK_RGB,
        ["MOUSEX"]      = TokenType.TOK_MOUSEX,
        ["MOUSEY"]      = TokenType.TOK_MOUSEY,
        ["MOUSELEFT"]   = TokenType.TOK_MOUSELEFT,
        ["MOUSEMIDDLE"] = TokenType.TOK_MOUSEMIDDLE,
        ["MOUSERIGHT"]  = TokenType.TOK_MOUSERIGHT,
        ["KEYDOWN"]     = TokenType.TOK_KEYDOWN,
        ["WAITKEY"]     = TokenType.TOK_WAITKEY,
        ["BASE64ENCODE"] = TokenType.TOK_BASE64ENCODE,
        ["BASE64DECODE"] = TokenType.TOK_BASE64DECODE,
        ["SHA256"]       = TokenType.TOK_SHA256,
        ["MOUSEHIDE"]    = TokenType.TOK_MOUSEHIDE,
        ["MOUSESHOW"]    = TokenType.TOK_MOUSESHOW,

        // Array functions
        ["HASKEY"]      = TokenType.TOK_HASKEY,
        ["DELKEY"]      = TokenType.TOK_DELKEY,
        ["DELARRAY"]    = TokenType.TOK_DELARRAY,
        ["JOIN"]        = TokenType.TOK_JOIN,
        ["ROWCOUNT"]    = TokenType.TOK_ROWCOUNT,
        ["ARGS"]        = TokenType.TOK_ARGS,
        ["ARGCOUNT"]    = TokenType.TOK_ARGCOUNT,

        // Time functions
        ["TICKS"]       = TokenType.TOK_TICKS,
        ["TIME"]        = TokenType.TOK_TIME,
        
        // Logic
        ["AND"]         = TokenType.TOK_AND,
        ["FALSE"]       = TokenType.TOK_FALSE,
        ["NOT"]         = TokenType.TOK_NOT,
        ["OFF"]         = TokenType.TOK_OFF,
        ["ON"]          = TokenType.TOK_ON,
        ["OR"]          = TokenType.TOK_OR,
        ["TRUE"]        = TokenType.TOK_TRUE,


        // Special
        ["BEEB"] = TokenType.TOK_BEEB,
    };

    private readonly string _source = source;
    private int _pos = 0;
    private int _line = 1;


    // Tokenise entire source into token list

    public List<Token> Tokenize()
    {
        var tokens = new List<Token>();
        int parenDepth = 0;

        while (_pos < _source.Length)
        {
            var token = NextToken();
            if (token.HasValue)
            {
                // Implicit line continuation: suppress NEWLINE if either
                //   (a) the previous token cannot legally end an expression
                //       (binary operator, comma, compound-assign, etc.), or
                //   (b) we are currently inside an open '(' ... ')' pair.
                // Comments after the token are already stripped before the
                // NEWLINE is emitted, and empty lines stay suppressed since
                // the last *added* token still belongs to the open expression.
                if (token.Value.Type == TokenType.TOK_NEWLINE
                    && tokens.Count > 0
                    && (IsLineContinuationToken(tokens[tokens.Count - 1].Type)
                        || parenDepth > 0))
                {
                    continue;
                }

                // Track parenthesis nesting. Clamp at zero so a stray ')'
                // does not produce a negative depth that would affect later
                // newline handling â€” the parser will report the imbalance.
                if (token.Value.Type == TokenType.TOK_LPAREN)
                    parenDepth++;
                else if (token.Value.Type == TokenType.TOK_RPAREN && parenDepth > 0)
                    parenDepth--;

                tokens.Add(token.Value);
            }
        }
        
        // Add EOF
        tokens.Add(new Token(TokenType.TOK_EOF, _line));
        
        return tokens;
    }

    // Tokens that imply "the expression is incomplete, please continue on the
    // next line". Keep this list strictly to tokens that *cannot* validly end
    // a statement; otherwise innocent typos (a stray operator) would silently
    // swallow the next line of code instead of raising a clear parse error.
    // TOK_LPAREN is also covered structurally by the paren-depth counter.
    private static bool IsLineContinuationToken(TokenType t)
    {
        return t switch
        {
            // Arithmetic operators
            TokenType.TOK_PLUS              => true,
            TokenType.TOK_MINUS             => true,
            TokenType.TOK_MULTIPLY          => true,
            TokenType.TOK_DIVIDE            => true,
            TokenType.TOK_MODULO            => true,    // %
            // NOTE: TOK_MOD is the MOD() function, not a binary operator.
            // Comparison operators
            TokenType.TOK_EQUALS            => true,    // = (also assignment)
            TokenType.TOK_NOT_EQUALS        => true,
            TokenType.TOK_LESS              => true,
            TokenType.TOK_LESS_EQ           => true,
            TokenType.TOK_GREATER           => true,
            TokenType.TOK_GREATER_EQ        => true,
            // Logical operators
            TokenType.TOK_AND               => true,
            TokenType.TOK_OR                => true,
            // Compound assignment
            TokenType.TOK_PLUS_ASSIGN       => true,
            TokenType.TOK_MINUS_ASSIGN      => true,
            TokenType.TOK_MULTIPLY_ASSIGN   => true,
            TokenType.TOK_DIVIDE_ASSIGN     => true,
            // Structural
            TokenType.TOK_COMMA             => true,
            TokenType.TOK_LPAREN            => true,
            _                               => false,
        };
    }

    private Token? NextToken()
    {
        SkipWhitespace();
        
        if (_pos >= _source.Length)
            return null;

        char c = _source[_pos];

        // NL
        if (c == '\n')
        {
            _pos++;
            return new Token(TokenType.TOK_NEWLINE, _line++);
        }

        // Skip carriace return
        if (c == '\r')
        {
            _pos++;
            return NextToken();
        }

        // REM or '
        if (c == '\'')
        {
            SkipToEndOfLine();
            return NextToken();
        }

        // Label [name]
        if (c == '[')
        {
            return ReadLabel();
        }

        // Number
        if (char.IsDigit(c) || (c == '.' && _pos + 1 < _source.Length && char.IsDigit(_source[_pos + 1])))
        {
            return ReadNumber();
        }

        // String "..."
        if (c == '"')
        {
            return ReadString();
        }

        // Keyword, function, or variable
        if (char.IsLetter(c) || c == '_')
        {
            return ReadWord();
        }

        // Two character operators
        if (_pos + 1 < _source.Length)
        {
            string twoChar = _source.Substring(_pos, 2);
            TokenType? opType = twoChar switch
            {
                "<=" => TokenType.TOK_LESS_EQ,
                ">=" => TokenType.TOK_GREATER_EQ,
                "<>" => TokenType.TOK_NOT_EQUALS,
                "!=" => TokenType.TOK_NOT_EQUALS,
                "==" => TokenType.TOK_EQUALS,
                "+=" => TokenType.TOK_PLUS_ASSIGN,
                "-=" => TokenType.TOK_MINUS_ASSIGN,
                "*=" => TokenType.TOK_MULTIPLY_ASSIGN,
                "/=" => TokenType.TOK_DIVIDE_ASSIGN,
                _ => null
            };
            
            if (opType.HasValue)
            {
                _pos += 2;
                return new Token(opType.Value, _line);
            }
        }

        // Single character operators
        TokenType? singleOp = c switch
        {
            '+' => TokenType.TOK_PLUS,
            '-' => TokenType.TOK_MINUS,
            '*' => TokenType.TOK_MULTIPLY,
            '/' => TokenType.TOK_DIVIDE,
            '%' => TokenType.TOK_MODULO,
            '=' => TokenType.TOK_EQUALS,
            '<' => TokenType.TOK_LESS,
            '>' => TokenType.TOK_GREATER,
            '(' => TokenType.TOK_LPAREN,
            ')' => TokenType.TOK_RPAREN,
            ',' => TokenType.TOK_COMMA,
            ';' => TokenType.TOK_SEMICOLON,
            ':' => TokenType.TOK_COLON,
            _ => null
        };

        if (singleOp.HasValue)
        {
            _pos++;
            return new Token(singleOp.Value, _line);
        }

        // Unknown character - fuck it
        _pos++;
        return NextToken();
    }

    private void SkipWhitespace()
    {
        while (_pos < _source.Length)
        {
            char c = _source[_pos];
            if (c == ' ' || c == '\t')
                _pos++;
            else
                break;
        }
    }

    private void SkipToEndOfLine()
    {
        while (_pos < _source.Length && _source[_pos] != '\n')
        {
            _pos++;
        }
    }

    private Token ReadLabel()
    {
        _pos++; // Skip '['
        int start = _pos;
        
        while (_pos < _source.Length && _source[_pos] != ']')
        {
            _pos++;
        }
        
        string labelName = _source[start.._pos].Trim();
        
        if (_pos < _source.Length)
            _pos++; // Skip ']'
        
        return new Token(TokenType.TOK_LABEL, labelName.ToUpperInvariant(), _line);
    }

    private Token ReadNumber()
    {
        int start = _pos;
        bool hasDecimal = false;
        
        while (_pos < _source.Length)
        {
            char c = _source[_pos];
            if (char.IsDigit(c))
            {
                _pos++;
            }
            else if (c == '.' && !hasDecimal)
            {
                hasDecimal = true;
                _pos++;
            }
            else
            {
                break;
            }
        }
        
        string numStr = _source[start.._pos];
        double value = double.Parse(numStr, System.Globalization.CultureInfo.InvariantCulture);
        
        return new Token(TokenType.TOK_NUMBER, value, _line);
    }

    private Token ReadString()
    {
        _pos++; // Skip opening "
        var sb = new StringBuilder();

        while (_pos < _source.Length)
        {
            // End of string
            if (_source[_pos] == '"')
            {
                // "" inside string = escaped quote (BASIC style)
                if (_pos + 1 < _source.Length && _source[_pos + 1] == '"')
                {
                    sb.Append('"');
                    _pos += 2;
                    continue;
                }
                break; // closing quote
            }

            if (_source[_pos] == '\\' && _pos + 1 < _source.Length)
            {
                // Escape sequence
                _pos++; // Skip backslash
                switch (_source[_pos])
                {
                    case '"':
                        sb.Append('"');
                        break;
                    case '\\':
                        sb.Append('\\');
                        break;
                    case 'n':
                        sb.Append('\n');
                        break;
                    case 't':
                        sb.Append('\t');
                        break;
                    case 'r':
                        sb.Append('\r');
                        break;
                    default:
                        // Unknown escape, which we just add literally
                        sb.Append('\\');
                        sb.Append(_source[_pos]);
                        break;
                }
                _pos++;
            }
            else
            {
                sb.Append(_source[_pos]);
                _pos++;
            }
        }

        if (_pos < _source.Length)
            _pos++; // Skip closing "

        return new Token(TokenType.TOK_STRING, sb.ToString(), _line);
    }

    private Token ReadWord()
    {
        int start = _pos;
        
        // Read alpanumeric characters
        while (_pos < _source.Length)
        {
            char c = _source[_pos];
            if (char.IsLetterOrDigit(c) || c == '_')
            {
                _pos++;
            }
            else
            {
                break;
            }
        }
        
        // Check suffix $ or # 
        if (_pos < _source.Length)
        {
            char c = _source[_pos];
            if (c == '$' || c == '#')
            {
                _pos++;
            }
        }
        
        string word = _source[start.._pos];
        string upperWord = word.ToUpperInvariant();
        
        // Check if its a keyword
        if (Keywords.TryGetValue(upperWord, out TokenType keywordType))
        {
            // Special case: REM is a comment
            // I dont like REM, but its in BASIC so...
            if (keywordType == TokenType.TOK_REM)
            {
                SkipToEndOfLine();
                return NextToken() ?? new Token(TokenType.TOK_EOF, _line);
            }
            
            return new Token(keywordType, _line);
        }
        
        // Variable if ends with $ or constant ends with #
        if (upperWord.EndsWith('$'))
        {
            return new Token(TokenType.TOK_VARIABLE, upperWord, _line);
        }
        else if (upperWord.EndsWith('#'))
        {
            return new Token(TokenType.TOK_CONSTANT, upperWord, _line);
        }
        else
        {
            // ERROR: Not a keyword and missing $ or # suffix
            throw new Exception($"Line {_line}: '{word}' is not a valid variable name (must end with $ or #) or keyword");
        }
    }

    // ========================================================================
    // Static helper methods
    // ========================================================================
    
    public static bool IsKeyword(string word)
    {
        return Keywords.ContainsKey(word);
    }

    public static bool IsValidVariableName(string name)
    {
        return name.Length >= 2 && name.EndsWith('$');
    }

    public static bool IsValidConstantName(string name)
    {
        return name.Length >= 2 && name.EndsWith('#');
    }
}
