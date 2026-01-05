/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Lexer\TokenType.cs
 Token Types

 Licence: MIT
*/

namespace BazzBasic.Lexer;

public enum TokenType
{
    // ========================================================================
    // Control Flow Keywords
    // ========================================================================
    TOK_DEF = 1,
    TOK_DIM,
    TOK_END,
    TOK_ENDIF,
    TOK_ELSE,
    TOK_ELSEIF,
    TOK_FN,
    TOK_FOR,
    TOK_GOSUB,
    TOK_GOTO,
    TOK_IF,
    TOK_INCLUDE,
    TOK_LET,
    TOK_NEXT,
    TOK_PRINT,
    TOK_REM,
    TOK_RETURN,
    TOK_STEP,
    TOK_THEN,
    TOK_TO,
    TOK_WEND,
    TOK_WHILE,

    // ========================================================================
    // I/O Keywords
    // ========================================================================
    TOK_CLS,
    TOK_COLOR,
    TOK_INPUT,
    TOK_LOCATE,
    TOK_SLEEP,

    // ========================================================================
    // Graphics Keywords
    // ========================================================================
    TOK_B,          // Box flag for LINE
    TOK_BF,         // Box Filled flag for LINE
    TOK_CIRCLE,
    TOK_DRAWSHAPE,
    TOK_HIDESHAPE,
    TOK_LINE,
    TOK_LOADIMAGE,
    TOK_LOADSHAPE,
    TOK_MOVESHAPE,
    TOK_PAINT,
    TOK_PSET,
    TOK_REMOVESHAPE,
    TOK_ROTATESHAPE,
    TOK_SCALESHAPE,
    TOK_SCREEN,
    TOK_SCREENLOCK,
    TOK_SHOWSHAPE,

    // ========================================================================
    // Sound Keywords
    // ========================================================================
    TOK_LOADSOUND,
    TOK_SOUNDONCE,
    TOK_SOUNDONCEWAIT,
    TOK_SOUNDREPEAT,
    TOK_SOUNDSTOP,
    TOK_SOUNDSTOPALL,

    // ========================================================================
    // File Keywords
    // ========================================================================
    TOK_FILEREAD,
    TOK_FILEEXISTS,
    TOK_FILEWRITE,
    TOK_FILEAPPEND,
    TOK_FILEDELETE,

    // ========================================================================
    // Built-in Functions
    // ========================================================================
    // Math
    TOK_ABS,
    TOK_ATAN,
    TOK_CINT,
    TOK_COS,
    TOK_CEIL,
    TOK_EXP,
    TOK_FLOOR,
    TOK_INT,
    TOK_LOG,
    TOK_MAX,
    TOK_MIN,
    TOK_MOD,
    TOK_POW,
    TOK_RND,
    TOK_ROUND,
    TOK_SGN,
    TOK_SIN,
    TOK_SQR,
    TOK_TAN,

    // String
    TOK_ASC,
    TOK_CHR,
    TOK_INSTR,
    TOK_INVERT,
    TOK_LCASE,
    TOK_LEFT,
    TOK_LEN,
    TOK_LTRIM,
    TOK_MID,
    TOK_REPEAT,
    TOK_REPLACE,
    TOK_RIGHT,
    TOK_RTRIM,
    TOK_SRAND,
    TOK_SPLIT,
    TOK_STR,
    TOK_TRIM,
    TOK_UCASE,
    TOK_VAL,

    // Input/Mouse
    TOK_INKEY,
    TOK_MOUSEB,
    TOK_MOUSEX,
    TOK_MOUSEY,
    TOK_RGB,

    // Array functions
    TOK_DELARRAY,
    TOK_DELKEY,
    TOK_HASKEY,

    // ========================================================================
    // Logic Keywords
    // ========================================================================
    TOK_AND,
    TOK_FALSE,
    TOK_NOT,
    TOK_OFF,
    TOK_ON,
    TOK_OR,
    TOK_TRUE,


    // ========================================================================
    // Operators
    // ========================================================================
    TOK_COLON,              // :
    TOK_COMMA,              // ,
    TOK_DIVIDE,             // /
    TOK_EQUALS,             // =
    TOK_GREATER,            // >
    TOK_GREATER_EQ,         // >=
    TOK_LESS,               // <
    TOK_LESS_EQ,            // <=
    TOK_LPAREN,             // (
    TOK_MINUS,              // -
    TOK_MODULO,             // % (MOD)
    TOK_MULTIPLY,           // *
    TOK_NOT_EQUALS,         // <>
    TOK_PLUS,               // +
    TOK_RPAREN,             // )
    TOK_SEMICOLON,          // ;

    // ========================================================================
    // Literals
    // ========================================================================
    TOK_CONSTANT,     // StringValue = constant name (ends with #)
    TOK_LABEL,        // StringValue = label name
    TOK_NUMBER,       // NumValue contains the number
    TOK_STRING,       // StringValue contains the string
    TOK_VARIABLE,     // StringValue = variable name (ends with $)

    // ========================================================================
    // Special
    // ========================================================================
    TOK_BEEB,
    TOK_EOF,
    TOK_NEWLINE,
}
