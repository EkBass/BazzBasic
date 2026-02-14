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
    /*
     * After ver. 0.7 DO NOT change the numeric values of existing tokens!
     * Find next free from the proper category and use that.
     */
    // Before 1.0, adjust these alphabetically
    // I did change the numeric values, sorry, but I did it in a way that allows for future expansion and keeps related tokens together.
    // ========================================================================
    // Control Flow Keywords 1 - 50
    // ========================================================================
    TOK_DEF = 1,
    TOK_DIM                 = 2,
    TOK_END                 = 3,
    TOK_ENDIF               = 4,
    TOK_ELSE                = 5,
    TOK_ELSEIF              = 6,
    TOK_FN                  = 7,
    TOK_FOR                 = 8,
    TOK_GOSUB               = 9,
    TOK_GOTO                = 10,
    TOK_IF                  = 11,
    TOK_INCLUDE             = 12,
    TOK_LET                 = 13,
    TOK_NEXT                = 14,
    TOK_PRINT               = 15,
    TOK_REM                 = 16,
    TOK_RETURN              = 17,
    TOK_STEP                = 18,
    TOK_THEN                = 19,
    TOK_TO                  = 20,
    TOK_WEND                = 21,
    TOK_WHILE               = 22,

    // ========================================================================
    // I/O Keywords 51 - 100
    // ========================================================================
    TOK_CLS                 = 51,
    TOK_COLOR               = 52,
    TOK_GETCONSOLE          = 53,
    TOK_INPUT               = 54,
    TOK_LOCATE              = 55,
    TOK_SLEEP               = 56,

    // ========================================================================
    // Graphics Keywords 101 - 150
    // ========================================================================
    TOK_B                   = 101,          // Box flag for LINE
    TOK_BF                  = 102,         // Box Filled flag for LINE
    TOK_CIRCLE              = 103,
    TOK_DRAWSHAPE           = 104,
    TOK_HIDESHAPE           = 105,
    TOK_LINE                = 106,
    TOK_LOADIMAGE           = 107,
    TOK_LOADSHAPE           = 108,
    TOK_MOVESHAPE           = 109,
    TOK_PAINT               = 110,
    TOK_POINT               = 111,      // Read pixel color at x,y
    TOK_PSET                = 112,
    TOK_REMOVESHAPE         = 113,
    TOK_ROTATESHAPE         = 114,
    TOK_SCALESHAPE          = 115,
    TOK_SCREEN              = 116,
    TOK_SCREENLOCK          = 117,
    TOK_SHOWSHAPE           = 118,
    TOK_VSYNC               = 119,

    // ========================================================================
    // Sound Keywords 151 - 200
    // ========================================================================
    TOK_LOADSOUND           = 151,
    TOK_SOUNDONCE           = 152,
    TOK_SOUNDONCEWAIT       = 153,
    TOK_SOUNDREPEAT         = 154,
    TOK_SOUNDSTOP           = 155,
    TOK_SOUNDSTOPALL        = 156,

    // ========================================================================
    // File Keywords 201 - 250
    // ========================================================================
    TOK_FILEREAD            = 201,
    TOK_FILEEXISTS          = 202,
    TOK_FILEWRITE           = 203,
    TOK_FILEAPPEND          = 204,
    TOK_FILEDELETE          = 205,

    // ========================================================================
    // Built-in Functions 251 - 400
    // ========================================================================
    // Math
    TOK_ABS                 = 251,
    TOK_ATAN                = 252,
    TOK_CINT                = 253,
    TOK_COS                 = 254,
    TOK_CEIL                = 255,
    TOK_EXP                 = 256,
    TOK_FLOOR               = 257,
    TOK_INT                 = 258,
    TOK_LOG                 = 259,
    TOK_MAX                 = 260,
    TOK_MIN                 = 261,
    TOK_MOD                 = 262,
    TOK_POW                 = 263,
    TOK_RND                 = 264,
    TOK_ROUND               = 265,
    TOK_SGN                 = 266,
    TOK_SIN                 = 267,
    TOK_SQR                 = 268,
    TOK_TAN                 = 269,
    TOK_PI                  = 270,
    TOK_RAD                 = 271,
    TOK_DEG                 = 272,
    TOK_HPI                 = 273,
    TOK_FASTTRIG            = 274,
    TOK_FASTSIN             = 275,
    TOK_FASTCOS             = 276,
    TOK_FASTRAD             = 277,
    TOK_QPI                 = 278,
    TOK_TAU                 = 279,
    TOK_BETWEEN             = 280,
    TOK_EULER               = 281,
    TOK_DISTANCE            = 282,
    TOK_CLAMP               = 283,
    TOK_LERP                = 284,

    // String
    TOK_ASC                 = 300,
    TOK_CHR                 = 301,
    TOK_INSTR               = 302,
    TOK_INVERT              = 303,
    TOK_LCASE               = 304,
    TOK_LEFT                = 305,
    TOK_LEN                 = 306,
    TOK_LTRIM               = 307,
    TOK_MID                 = 308,
    TOK_REPEAT              = 309,
    TOK_REPLACE             = 310,
    TOK_RIGHT               = 311,
    TOK_RTRIM               = 312,
    TOK_SRAND               = 313,
    TOK_SPLIT               = 314,
    TOK_STR                 = 315,
    TOK_TRIM                = 316,
    TOK_UCASE               = 317,
    TOK_VAL                 = 318,

    // Input/Mouse
    TOK_INKEY               = 350,
    TOK_MOUSEB              = 351,
    TOK_MOUSEX              = 352,
    TOK_MOUSEY              = 353,
    TOK_RGB                 = 354,
    TOK_KEYDOWN             = 355,

    // Array functions
    TOK_DELARRAY            = 360,
    TOK_DELKEY              = 361,
    TOK_HASKEY              = 362,

    // Time functions
    TOK_TICKS               = 370,
    TOK_TIME                = 371,

    // ========================================================================
    // Logic Keywords 400 - 450
    // ========================================================================
    TOK_AND                 = 400,
    TOK_FALSE               = 410,
    TOK_NOT                 = 402,
    TOK_OFF                 = 403,
    TOK_ON                  = 404,
    TOK_OR                  = 405,
    TOK_TRUE                = 406,


    // ========================================================================
    // Operators 450 - 500
    // ========================================================================
    TOK_COLON               = 450,              // :
    TOK_COMMA               = 451,              // ,
    TOK_DIVIDE              = 452,              // /
    TOK_EQUALS              = 453,              // =
    TOK_GREATER             = 454,              // >
    TOK_GREATER_EQ          = 455,              // >=
    TOK_LESS                = 456,              // <
    TOK_LESS_EQ             = 457,              // <=
    TOK_LPAREN              = 458,              // (
    TOK_MINUS               = 459,              // -
    TOK_MODULO              = 460,              // % (MOD)
    TOK_MULTIPLY            = 461,              // *
    TOK_NOT_EQUALS          = 462,              // <>
    TOK_PLUS                = 463,              // +
    TOK_RPAREN              = 464,              // )
    TOK_SEMICOLON           = 465,              // ;

    // ========================================================================
    // Literals 501 - 550
    // ========================================================================
    TOK_CONSTANT            = 501,          // StringValue = constant name (ends with #)
    TOK_LABEL               = 502,          // StringValue = label name
    TOK_NUMBER              = 503,          // NumValue contains the number
    TOK_STRING              = 504,          // StringValue contains the string
    TOK_VARIABLE            = 505,          // StringValue = variable name (ends with $)

    // ========================================================================
    // Special 551+
    // ========================================================================
    TOK_BEEB                = 551,
    TOK_EOF                 = 552,
    TOK_NEWLINE             = 553,
}
