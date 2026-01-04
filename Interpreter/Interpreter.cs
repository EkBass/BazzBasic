// ============================================================================
// BazzBasic - Interpreter (Main)
// Core execution loop and state management
// ============================================================================

using BazzBasic.Lexer;
using BazzBasic.Parser;
using BazzBasic.Sound;
using BazzBasic.File;

namespace BazzBasic.Interpreter;

// FOR loop state
public struct ForState
{
    public string VarName;
    public double EndValue;
    public double StepValue;
    public int LoopPosition;
}

// User-defined function
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
    
    // Stacks
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
    
    // Built-in constants
    private readonly Dictionary<string, double> _builtinConstants;
    
    // Random number generator
    private readonly Random _random = new();
    
    // Sound manager
    private readonly SoundManager _soundManager = new();
    
    // File manager
    private readonly FileManager _fileManager;

    public Interpreter(List<Token> tokens, string basePath = "")
    {
        _tokens = tokens;
        _variables = new Variables();
        _labels = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        _builtinConstants = InitBuiltinConstants();
        _pos = 0;
        _running = false;
        
        // Initialize file manager with base path
        if (string.IsNullOrEmpty(basePath))
        {
            basePath = Directory.GetCurrentDirectory();
        }
        _fileManager = new FileManager(basePath);
        
        // Set ROOT# constant
        _variables.SetConstant("ROOT#", Value.FromString(basePath));
        
        ScanLabels();
    }

    private static Dictionary<string, double> InitBuiltinConstants()
    {
        return new Dictionary<string, double>(StringComparer.OrdinalIgnoreCase)
        {
            // Keyboard
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
            // Mouse
            ["MOUSE_LEFT#"] = 1,
            ["MOUSE_RIGHT#"] = 2,
            ["MOUSE_MIDDLE#"] = 4,
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
            case TokenType.TOK_SCREEN:
                ExecuteScreen();
                break;
            case TokenType.TOK_SCREENLOCK:
                ExecuteScreenlock();
                break;
            case TokenType.TOK_PSET:
                ExecutePset();
                break;
            case TokenType.TOK_LINE:
                ExecuteLine();
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

        Token varToken = _tokens[_pos];
        if (varToken.Type != TokenType.TOK_VARIABLE && varToken.Type != TokenType.TOK_CONSTANT)
            return;
        
        string varName = varToken.StringValue ?? "";
        _pos++;
        
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_LPAREN)
        {
            ExecuteArrayAssignment(varName);
            return;
        }
        
        if (!isNewDeclaration && !varName.EndsWith('#') && !_variables.VariableExists(varName))
        {
            Error($"Undefined variable: {varName} (use LET for first assignment)");
            return;
        }
        
        // Check if there's an assignment (=)
        if (_pos < _tokens.Count && _tokens[_pos].Type == TokenType.TOK_EQUALS)
        {
            _pos++; // Skip =
            Value value = EvaluateExpression();
            
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
        else if (isNewDeclaration)
        {
            // LET var without assignment - create empty/zero variable
            if (varName.EndsWith('$'))
            {
                _variables.SetVariable(varName, Value.Empty);
            }
            else if (varName.EndsWith('#'))
            {
                Error($"Constants must be initialized with a value");
            }
            else
            {
                _variables.SetVariable(varName, Value.Zero);
            }
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
    // Helper methods
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
