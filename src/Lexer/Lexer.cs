/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Lexer\Lexer.cs
 This turns code to INT tokens which is way faster than parsing on the from the string every time.
 Licence: MIT
*/

using System.Text;

namespace BazzBasic.Lexer;

public class Lexer
{
    // Keyword lookup table
    private static readonly Dictionary<string, TokenType> Keywords = new(StringComparer.OrdinalIgnoreCase)
    {
        // Control flow
        ["DEF"] = TokenType.TOK_DEF,
        ["DIM"] = TokenType.TOK_DIM,
        ["ELSE"] = TokenType.TOK_ELSE,
        ["ELSEIF"] = TokenType.TOK_ELSEIF,
        ["END"] = TokenType.TOK_END,
        ["ENDIF"] = TokenType.TOK_ENDIF,
        ["FN"] = TokenType.TOK_FN,
        ["FOR"] = TokenType.TOK_FOR,
        ["GOSUB"] = TokenType.TOK_GOSUB,
        ["GOTO"] = TokenType.TOK_GOTO,
        ["IF"] = TokenType.TOK_IF,
        ["INCLUDE"] = TokenType.TOK_INCLUDE,
        ["LET"] = TokenType.TOK_LET,
        ["NEXT"] = TokenType.TOK_NEXT,
        ["PRINT"] = TokenType.TOK_PRINT,
        ["REM"] = TokenType.TOK_REM,
        ["RETURN"] = TokenType.TOK_RETURN,
        ["STEP"] = TokenType.TOK_STEP,
        ["THEN"] = TokenType.TOK_THEN,
        ["TO"] = TokenType.TOK_TO,
        ["WEND"] = TokenType.TOK_WEND,
        ["WHILE"] = TokenType.TOK_WHILE,

        // I/O
        ["CLS"] = TokenType.TOK_CLS,
        ["COLOR"] = TokenType.TOK_COLOR,
        ["GETCONSOLE"] = TokenType.TOK_GETCONSOLE,
        ["INPUT"] = TokenType.TOK_INPUT,
        ["LOCATE"] = TokenType.TOK_LOCATE,
        ["SLEEP"] = TokenType.TOK_SLEEP,

        // Graphics
        ["B"] = TokenType.TOK_B,
        ["BF"] = TokenType.TOK_BF,
        ["CIRCLE"] = TokenType.TOK_CIRCLE,
        ["DRAWSHAPE"] = TokenType.TOK_DRAWSHAPE,
        ["HIDESHAPE"] = TokenType.TOK_HIDESHAPE,
        ["LINE"] = TokenType.TOK_LINE,
        ["LOADIMAGE"] = TokenType.TOK_LOADIMAGE,
        ["LOADSHAPE"] = TokenType.TOK_LOADSHAPE,
        ["MOVESHAPE"] = TokenType.TOK_MOVESHAPE,
        ["PAINT"] = TokenType.TOK_PAINT,
        ["PSET"] = TokenType.TOK_PSET,
        ["REMOVESHAPE"] = TokenType.TOK_REMOVESHAPE,
        ["ROTATESHAPE"] = TokenType.TOK_ROTATESHAPE,
        ["SCALESHAPE"] = TokenType.TOK_SCALESHAPE,
        ["SCREEN"] = TokenType.TOK_SCREEN,
        ["SCREENLOCK"] = TokenType.TOK_SCREENLOCK,
        ["SHOWSHAPE"] = TokenType.TOK_SHOWSHAPE,

        // Sound
        ["LOADSOUND"] = TokenType.TOK_LOADSOUND,
        ["SOUNDONCE"] = TokenType.TOK_SOUNDONCE,
        ["SOUNDONCEWAIT"] = TokenType.TOK_SOUNDONCEWAIT,
        ["SOUNDREPEAT"] = TokenType.TOK_SOUNDREPEAT,
        ["SOUNDSTOP"] = TokenType.TOK_SOUNDSTOP,
        ["SOUNDSTOPALL"] = TokenType.TOK_SOUNDSTOPALL,

        // File operations
        ["FILEREAD"] = TokenType.TOK_FILEREAD,
        ["FILEEXISTS"] = TokenType.TOK_FILEEXISTS,
        ["FILEWRITE"] = TokenType.TOK_FILEWRITE,
        ["FILEAPPEND"] = TokenType.TOK_FILEAPPEND,
        ["FILEDELETE"] = TokenType.TOK_FILEDELETE,

        // Math functions
        ["ABS"] = TokenType.TOK_ABS,
        ["ATAN"] = TokenType.TOK_ATAN,
        ["CEIL"] = TokenType.TOK_CEIL,
        ["CINT"] = TokenType.TOK_CINT,
        ["COS"] = TokenType.TOK_COS,
        ["EXP"] = TokenType.TOK_EXP,
        ["FLOOR"] = TokenType.TOK_FLOOR,
        ["INT"] = TokenType.TOK_INT,
        ["LOG"] = TokenType.TOK_LOG,
        ["MAX"] = TokenType.TOK_MAX,
        ["MIN"] = TokenType.TOK_MIN,
        ["MOD"] = TokenType.TOK_MOD,
        ["POW"] = TokenType.TOK_POW,
        ["RND"] = TokenType.TOK_RND,
        ["ROUND"] = TokenType.TOK_ROUND,
        ["SGN"] = TokenType.TOK_SGN,
        ["SIN"] = TokenType.TOK_SIN,
        ["SQR"] = TokenType.TOK_SQR,
        ["TAN"] = TokenType.TOK_TAN,

        // String functions
        ["ASC"] = TokenType.TOK_ASC,
        ["CHR"] = TokenType.TOK_CHR,
        ["INSTR"] = TokenType.TOK_INSTR,
        ["INVERT"] = TokenType.TOK_INVERT,
        ["LCASE"] = TokenType.TOK_LCASE,
        ["LEFT"] = TokenType.TOK_LEFT,
        ["LEN"] = TokenType.TOK_LEN,
        ["LTRIM"] = TokenType.TOK_LTRIM,
        ["MID"] = TokenType.TOK_MID,
        ["REPEAT"] = TokenType.TOK_REPEAT,
        ["REPLACE"] = TokenType.TOK_REPLACE,
        ["RIGHT"] = TokenType.TOK_RIGHT,
        ["RTRIM"] = TokenType.TOK_RTRIM,
        ["SRAND"] = TokenType.TOK_SRAND,
        ["SPLIT"] = TokenType.TOK_SPLIT,
        ["STR"] = TokenType.TOK_STR,
        ["TRIM"] = TokenType.TOK_TRIM,
        ["UCASE"] = TokenType.TOK_UCASE,
        ["VAL"] = TokenType.TOK_VAL,

        // Input/Mouse
        ["INKEY"] = TokenType.TOK_INKEY,
        ["RGB"] = TokenType.TOK_RGB,
        ["MOUSEX"] = TokenType.TOK_MOUSEX,
        ["MOUSEY"] = TokenType.TOK_MOUSEY,
        ["MOUSEB"] = TokenType.TOK_MOUSEB,
        
        // Array functions
        ["HASKEY"] = TokenType.TOK_HASKEY,
        ["DELKEY"] = TokenType.TOK_DELKEY,
        ["DELARRAY"] = TokenType.TOK_DELARRAY,
        
        // Logic
        ["AND"] = TokenType.TOK_AND,
        ["FALSE"] = TokenType.TOK_FALSE,
        ["NOT"] = TokenType.TOK_NOT,
        ["OFF"] = TokenType.TOK_OFF,
        ["ON"] = TokenType.TOK_ON,
        ["OR"] = TokenType.TOK_OR,
        ["TRUE"] = TokenType.TOK_TRUE,


        // Special
        ["BEEB"] = TokenType.TOK_BEEB,
    };

    private readonly string _source;
    private int _pos;
    private int _line;

    public Lexer(string source)
    {
        _source = source;
        _pos = 0;
        _line = 1;
    }


    // Tokenise entire source into token list

    public List<Token> Tokenize()
    {
        var tokens = new List<Token>();
        
        while (_pos < _source.Length)
        {
            var token = NextToken();
            if (token.HasValue)
            {
                tokens.Add(token.Value);
            }
        }
        
        // Add EOF
        tokens.Add(new Token(TokenType.TOK_EOF, _line));
        
        return tokens;
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

        while (_pos < _source.Length && _source[_pos] != '"')
        {
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
