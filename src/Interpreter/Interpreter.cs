/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Interpreter.cs
 Main execution loop and state management

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using System.Diagnostics;
using BazzBasic.Lexer;
using BazzBasic.Parser;
using BazzBasic.Sound;
using BazzBasic.File;

namespace BazzBasic.Interpreter;

// FOR state
public struct ForState
{
    public string VarName;
    public double EndValue;
    public double StepValue;
    public int LoopPosition;
}

// User-defined functions
public struct UserFunction
{
    public string Name;
    public string[] Parameters;
    public int StartPosition;
    public int EndPosition;
}

public partial class Interpreter
{
    private readonly List<Token> _tokens;
    private readonly Variables _variables;
    private readonly Dictionary<string, int> _labels;
    
    private int _pos;
    private bool _running;
    private bool _hasError;
    
    // Stackss
    private readonly Stack<int> _gosubStack = new();
    private readonly Stack<ForState> _forStack = new();
    private readonly Stack<int> _whileStack = new();
    private readonly Stack<bool> _ifStack = new();
    
    // User-defined functions
    private readonly Dictionary<string, UserFunction> _functions = new(StringComparer.OrdinalIgnoreCase);
    private bool _inFunction = false;
    private int _functionStartPos = -1;
    private int _functionEndPos = -1;
    private Value _returnValue = Value.Zero;
    
    // Builtin constants
    private readonly Dictionary<string, double> _builtinConstants;
    
    // RND
    private readonly Random _random = new();
    
    // FastTrig lookup tables
    private double[]? _fastSinTable = null;
    private double[]? _fastCosTable = null;
    private bool _fastTrigEnabled = false;
    
    // Sound (lazy - initialized only when first sound command is used)
    private Sound.SoundManager? _soundManager = null;
    private Sound.SoundManager GetSoundManager() => _soundManager ??= new Sound.SoundManager();
    
    // File
    private readonly FileManager _fileManager;
    
    // Time
    private readonly Stopwatch _programTimer = Stopwatch.StartNew();

    public Interpreter(List<Token> tokens, string basePath = "")
    {
        _tokens = tokens;
        _variables = new Variables();
        _labels = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        _builtinConstants = InitBuiltinConstants();
        _pos = 0;
        _running = false;
        
        // Init the file manager with base path
        if (string.IsNullOrEmpty(basePath))
        {
            basePath = Directory.GetCurrentDirectory();
        }
        _fileManager = new FileManager(basePath);
        
        // ROOT# constant
        _variables.SetConstant("ROOT#", Value.FromString(basePath));
        
        ScanLabels();
    }

    private static Dictionary<string, double> InitBuiltinConstants()
    {
        return new Dictionary<string, double>(StringComparer.OrdinalIgnoreCase)
        {
            // Key constants -> KEY_ESC# or KEY_TAB#
            ["KEY_BACKSPACE#"] = 8,
            ["KEY_TAB#"] = 9,
            ["KEY_ENTER#"] = 13,
            ["KEY_ESC#"] = 27,
            ["KEY_SPACE#"] = 32,
            ["KEY_UP#"] = 328,
            ["KEY_DOWN#"] = 336,
            ["KEY_LEFT#"] = 331,
            ["KEY_RIGHT#"] = 333,
            ["KEY_INSERT#"] = 338,
            ["KEY_DELETE#"] = 339,
            ["KEY_HOME#"] = 327,
            ["KEY_END#"] = 335,
            ["KEY_PGUP#"] = 329,
            ["KEY_PGDN#"] = 337,
            ["KEY_F1#"] = 315,
            ["KEY_F2#"] = 316,
            ["KEY_F3#"] = 317,
            ["KEY_F4#"] = 318,
            ["KEY_F5#"] = 319,
            ["KEY_F6#"] = 320,
            ["KEY_F7#"] = 321,
            ["KEY_F8#"] = 322,
            ["KEY_F9#"] = 323,
            ["KEY_F10#"] = 324,
            ["KEY_F11#"] = 389,
            ["KEY_F12#"] = 390,
            // Numpad keys
            ["KEY_NUMPAD0#"] = 256,
            ["KEY_NUMPAD1#"] = 257,
            ["KEY_NUMPAD2#"] = 258,
            ["KEY_NUMPAD3#"] = 259,
            ["KEY_NUMPAD4#"] = 260,
            ["KEY_NUMPAD5#"] = 261,
            ["KEY_NUMPAD6#"] = 262,
            ["KEY_NUMPAD7#"] = 263,
            ["KEY_NUMPAD8#"] = 264,
            ["KEY_NUMPAD9#"] = 265,
            // SHIFT, CTRL, ALT
            ["KEY_LSHIFT#"] = 340,
            ["KEY_RSHIFT#"] = 344,
            ["KEY_LCTRL#"] = 341,
            ["KEY_RCTRL#"] = 345,
            ["KEY_LALT#"] = 342,
            ["KEY_RALT#"] = 346,
            // Win keys
            ["KEY_LWIN#"] = 343,
            ["KEY_RWIN#"] = 347,
            // Alphabets and numbers
            ["KEY_0#"] = 48,
            ["KEY_1#"] = 49,
            ["KEY_2#"] = 50,
            ["KEY_3#"] = 51,
            ["KEY_4#"] = 52,
            ["KEY_5#"] = 53,
            ["KEY_6#"] = 54,
            ["KEY_7#"] = 55,
            ["KEY_8#"] = 56,
            ["KEY_9#"] = 57,
            ["KEY_A#"] = 65,
            ["KEY_B#"] = 66,
            ["KEY_C#"] = 67,
            ["KEY_D#"] = 68,
            ["KEY_E#"] = 69,
            ["KEY_F#"] = 70,
            ["KEY_G#"] = 71,
            ["KEY_H#"] = 72,
            ["KEY_I#"] = 73,
            ["KEY_J#"] = 74,
            ["KEY_K#"] = 75,
            ["KEY_L#"] = 76,
            ["KEY_M#"] = 77,
            ["KEY_N#"] = 78,
            ["KEY_O#"] = 79,
            ["KEY_P#"] = 80,
            ["KEY_Q#"] = 81,
            ["KEY_R#"] = 82,
            ["KEY_S#"] = 83,
            ["KEY_T#"] = 84,
            ["KEY_U#"] = 85,
            ["KEY_V#"] = 86,
            ["KEY_W#"] = 87,
            ["KEY_X#"] = 88,
            ["KEY_Y#"] = 89,
            ["KEY_Z#"] = 90,
            // Punctuations
            ["KEY_SEP#"] = 59, // ;:
            ["KEY_EQUALS#"] = 61, // =
            ["KEY_COMMA#"] = 44, // ,
            ["KEY_MINUS#"] = 45, // -
            ["KEY_DOT#"] = 46, // .
            ["KEY_SLASH#"] = 47, // /
            ["KEY_GRAVE#"] = 96, // `
            // KEY_LBRACKET#, KEY_RBRACKET#,  KEY_BACKSLASH# 
            ["KEY_LBRACKET#"] = 91, // [
            ["KEY_RBRACKET#"] = 93, // ]
            ["KEY_BACKSLASH#"] = 92, // \

            // Mouse
            ["MOUSE_LEFT#"] = 1,
            ["MOUSE_RIGHT#"] = 2,
            ["MOUSE_MIDDLE#"] = 4, // Wont detect rolling, just pressing
        };
    }

    private void ScanLabels()
    {
        for (int i = 0; i < _tokens.Count; i++)
        {
            if (_tokens[i].Type == TokenType.TOK_LABEL)
            {
                bool isLineStart = (i == 0) || (_tokens[i - 1].Type == TokenType.TOK_NEWLINE);
                
                if (isLineStart)
                {
                    string labelName = _tokens[i].StringValue ?? "";
                    _labels[labelName] = i;
                }
            }
        }
    }

    public void Run()
    {
        _pos = 0;
        _running = true;
        _hasError = false;
        
        while (_running && !_hasError && _pos < _tokens.Count)
        {
            ExecuteStatement();
        }
    }

    private void ExecuteStatement()
    {
        SkipNewlines();
        
        if (_pos >= _tokens.Count)
        {
            _running = false;
            return;
        }

        Token token = _tokens[_pos];

        switch (token.Type)
        {
            case TokenType.TOK_LABEL:
                _pos++;
                break;
            case TokenType.TOK_LET:
                ExecuteLet();
                break;
            case TokenType.TOK_PRINT:
                ExecutePrint();
                break;
            case TokenType.TOK_GOTO:
                ExecuteGoto();
                break;
            case TokenType.TOK_GOSUB:
                ExecuteGosub();
                break;
            case TokenType.TOK_RETURN:
                ExecuteReturn();
                break;
            case TokenType.TOK_IF:
                ExecuteIf();
                break;
            case TokenType.TOK_ELSE:
                ExecuteElse();
                break;
            case TokenType.TOK_ELSEIF:
                ExecuteElseIf();
                break;
            case TokenType.TOK_ENDIF:
                _pos++;
                ExecuteEndIf();
                break;
            case TokenType.TOK_FOR:
                ExecuteFor();
                break;
            case TokenType.TOK_NEXT:
                ExecuteNext();
                break;
            case TokenType.TOK_WHILE:
                ExecuteWhile();
                break;
            case TokenType.TOK_WEND:
                ExecuteWend();
                break;
            case TokenType.TOK_DIM:
                ExecuteDim();
                break;
            case TokenType.TOK_DELKEY:
                ExecuteDelKey();
                break;
            case TokenType.TOK_DELARRAY:
                ExecuteDelArray();
                break;
            case TokenType.TOK_DEF:
                ExecuteDefFn();
                break;
            case TokenType.TOK_INPUT:
                ExecuteInput();
                break;
            case TokenType.TOK_CLS:
                ExecuteCls();
                break;
            case TokenType.TOK_LOCATE:
                ExecuteLocate();
                break;
            case TokenType.TOK_COLOR:
                ExecuteColor();
                break;
            case TokenType.TOK_BEEB:
                ExecuteBeeb();
                break;
            case TokenType.TOK_SLEEP:
                ExecuteSleep();
                break;
            case TokenType.TOK_FASTTRIG:
                ExecuteFastTrig();
                break;
            case TokenType.TOK_SCREEN:
                ExecuteScreen();
                break;
            case TokenType.TOK_SCREENLOCK:
                ExecuteScreenlock();
                break;
            case TokenType.TOK_VSYNC:
                ExecuteVSync();
                break;
            case TokenType.TOK_PSET:
                ExecutePset();
                break;
            case TokenType.TOK_LINE:
                // Check for LINE INPUT
                if (_pos + 1 < _tokens.Count && _tokens[_pos + 1].Type == TokenType.TOK_INPUT)
                {
                    ExecuteLineInput();
                }
                else
                {
                    ExecuteLine();
                }
                break;
            case TokenType.TOK_CIRCLE:
                ExecuteCircle();
                break;
            case TokenType.TOK_PAINT:
                ExecutePaint();
                break;
            case TokenType.TOK_MOVESHAPE:
                ExecuteMoveshape();
                break;
            case TokenType.TOK_ROTATESHAPE:
                ExecuteRotateshape();
                break;
            case TokenType.TOK_SCALESHAPE:
                ExecuteScaleshape();
                break;
            case TokenType.TOK_DRAWSHAPE:
                ExecuteDrawshape();
                break;
            case TokenType.TOK_SHOWSHAPE:
                ExecuteShowshape();
                break;
            case TokenType.TOK_HIDESHAPE:
                ExecuteHideshape();
                break;
            case TokenType.TOK_REMOVESHAPE:
                ExecuteRemoveshape();
                break;
            case TokenType.TOK_SOUNDONCE:
                ExecuteSoundOnce();
                break;
            case TokenType.TOK_SOUNDREPEAT:
                ExecuteSoundRepeat();
                break;
            case TokenType.TOK_SOUNDSTOP:
                ExecuteSoundStop();
                break;
            case TokenType.TOK_SOUNDSTOPALL:
                ExecuteSoundStopAll();
                break;
            case TokenType.TOK_SOUNDONCEWAIT:
                ExecuteSoundOnceWait();
                break;
            case TokenType.TOK_FILEWRITE:
                ExecuteFileWrite();
                break;
            case TokenType.TOK_FILEAPPEND:
                ExecuteFileAppend();
                break;
            case TokenType.TOK_FILEDELETE:
                ExecuteFileDelete();
                break;
            case TokenType.TOK_END:
                _pos++;
                if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_IF)
                {
                    _pos++;
                    ExecuteEndIf();
                }
                else
                {
                    _running = false;
                }
                break;
            case TokenType.TOK_EOF:
                _running = false;
                break;
            case TokenType.TOK_REM:
                SkipToNextLine();
                break;
            case TokenType.TOK_NEWLINE:
                _pos++;
                break;
            case TokenType.TOK_VARIABLE:
                ExecuteAssignment();
                break;
            default:
                _pos++;
                break;
        }
    }

    // ========================================================================
    // LET / Assignment
    // ========================================================================
    
    private void ExecuteLet()
    {
        _pos++;
        ExecuteAssignment(isNewDeclaration: true);
    }

    private void ExecuteAssignment(bool isNewDeclaration = false)
    {
        if (_pos >= _tokens.Count) return;

        // LET with multiple inits: LET a$, b$, c# = 3.14
        // Variables before = get default values, last one (or all if no =) gets value or default
        var pendingVars = new List<string>();
        
        while (_pos < _tokens.Count)
        {
            Token varToken = _tokens[_pos];
            if (varToken.Type != TokenType.TOK_VARIABLE && varToken.Type != TokenType.TOK_CONSTANT)
                break;
            
            string varName = varToken.StringValue ?? "";
            _pos++;
            
            // Check array assignment, only for single variable case
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
            {
                // Init pending variables first
                foreach (var pending in pendingVars)
                {
                    InitializeVariable(pending, isNewDeclaration);
                }
                ExecuteArrayAssignment(varName);
                return;
            }
            
            // Check if there's = after this variable
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_EQUALS)
            {
                // Init all pending variables with defaults first
                foreach (var pending in pendingVars)
                {
                    InitializeVariable(pending, isNewDeclaration);
                }
                
                _pos++; // 
                Value value = EvaluateExpression();
                
                // Sen value to the variable
                AssignValueToVariable(varName, value, isNewDeclaration);
                
                // See for more comma separated assingments after the value
                while (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
                {
                    _pos++; // Skip comma
                    if (_pos >= _tokens.Count) break;
                    
                    varToken = _tokens[_pos];
                    if (varToken.Type != TokenType.TOK_VARIABLE && varToken.Type != TokenType.TOK_CONSTANT)
                        break;
                    
                    varName = varToken.StringValue ?? "";
                    _pos++;
                    
                    if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_EQUALS)
                    {
                        _pos++; // Skip =
                        value = EvaluateExpression();
                        AssignValueToVariable(varName, value, isNewDeclaration);
                    }
                    else
                    {
                        InitializeVariable(varName, isNewDeclaration);
                    }
                }
                return;
            }
            
            // Check comma if more variables follows
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                pendingVars.Add(varName);
                _pos++; // Skip comma
                continue;
            }
            
            // No comma, no equals - this is the last variable, check if it needs existing check
            if (!isNewDeclaration && !varName.EndsWith('#') && !_variables.VariableExists(varName))
            {
                Error($"Undefined variable: {varName} (use LET for first assignment)");
                return;
            }
            
            // Init variables
            foreach (var pending in pendingVars)
            {
                InitializeVariable(pending, isNewDeclaration);
            }
            
            // Initialize last variable
            InitializeVariable(varName, isNewDeclaration);
            return;
        }
        
        // Initialize if remaining variables
        foreach (var pending in pendingVars)
        {
            InitializeVariable(pending, isNewDeclaration);
        }
    }
    
    private void InitializeVariable(string varName, bool isNewDeclaration)
    {
        if (isNewDeclaration)
        {
            if (varName.EndsWith('$'))
            {
                _variables.SetVariable(varName, Value.Empty);
            }
            else if (varName.EndsWith('#'))
            {
                Error($"Constants must be initialized with a value: {varName}");
            }
            else
            {
                _variables.SetVariable(varName, Value.Zero);
            }
        }
    }
    
    private void AssignValueToVariable(string varName, Value value, bool isNewDeclaration)
    {
        if (!isNewDeclaration && !varName.EndsWith('#') && !_variables.VariableExists(varName))
        {
            Error($"Undefined variable: {varName} (use LET for first assignment)");
            return;
        }
        
        if (varName.EndsWith('#'))
        {
            if (!_variables.SetConstant(varName, value))
            {
                Error($"Cannot redefine constant '{varName}'");
            }
        }
        else
        {
            _variables.SetVariable(varName, value);
        }
    }

    private void ExecuteArrayAssignment(string arrayName)
    {
        _pos++;
        
        var indices = new List<string>();
        while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_RPAREN)
        {
            if (_tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
                continue;
            }
            Value idx = EvaluateExpression();
            indices.Add(idx.AsString());
            
            if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_COMMA)
            {
                _pos++;
            }
        }
        Require(TokenType.TOK_RPAREN);
        
        if (!Expect(TokenType.TOK_EQUALS)) return;
        
        Value value = EvaluateExpression();
        string key = string.Join(",", indices);
        
        try
        {
            _variables.SetArrayElement(arrayName, key, value);
        }
        catch (InvalidOperationException ex)
        {
            Error(ex.Message);
        }
    }

    // ========================================================================
    // Helpers
    // ========================================================================
    
    private void SkipNewlines()
    {
        while (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_NEWLINE)
            _pos++;
    }

    private void SkipToNextLine()
    {
        while (_pos < _tokens.Count && _tokens[_pos].Type != TokenType.TOK_NEWLINE)
            _pos++;
        if (_pos < _tokens.Count)
            _pos++;
    }

    private bool IsEndOfStatement()
    {
        return _pos >= _tokens.Count || 
               _tokens[_pos].Type == TokenType.TOK_NEWLINE || 
               _tokens[_pos].Type == TokenType.TOK_EOF ||
               _tokens[_pos].Type == TokenType.TOK_COLON;
    }

    private bool Expect(TokenType type)
    {
        if (_pos < _tokens.Count && _tokens[_pos].Type == type)
        {
            _pos++;
            return true;
        }
        return false;
    }

    private void Require(TokenType type, string errorMsg = "")
    {
        if (_pos < _tokens.Count && _tokens[_pos].Type == type)
        {
            _pos++;
            return;
        }
        
        if (string.IsNullOrEmpty(errorMsg))
        {
            errorMsg = $"Expected {type}";
        }
        Error(errorMsg);
    }

    private void Error(string message)
    {
        int line = _pos < _tokens.Count ? _tokens[_pos].Line : 0;
        Console.WriteLine($"Error at line {line}: {message}");
        _running = false;
        _hasError = true;
    }
}
