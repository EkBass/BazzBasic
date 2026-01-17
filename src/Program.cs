/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Program.cs
 BazzBasic - BASIC Interpreter with integrated IDE

 Licence: MIT
*/

using System.Runtime.InteropServices;
using BazzBasic.Lexer;
using BazzBasic.Interpreter;
using BazzBasic.Preprocessor;
using BazzBasic.IDE;

// Win32 API for console management
[DllImport("kernel32.dll")]
static extern bool FreeConsole();

// Check command line arguments
if (args.Length == 0)
{
    // No arguments - launch IDE on STA thread
    FreeConsole();
    
    var thread = new Thread(() =>
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
    });
    thread.SetApartmentState(ApartmentState.STA);
    thread.Start();
    thread.Join();
}
else
{
    // File argument - run interpreter (console stays attached)
    string filename = args[0];
    if (!File.Exists(filename))
    {
        Console.WriteLine($"Error: File not found: {filename}");
        return 1;
    }
    
    try
    {
        string source = File.ReadAllText(filename);
        string basePath = Path.GetDirectoryName(Path.GetFullPath(filename)) ?? Directory.GetCurrentDirectory();
        RunProgram(source, basePath, filename);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error: {ex.Message}");
        return 1;
    }
}

return 0;

static void RunProgram(string source, string basePath = "", string? filename = null)
{
    try
    {
        // Preprocess - handle INCLUDE directives
        var preprocessor = new Preprocessor(basePath);
        string processedSource = preprocessor.Process(source, filename);
        
        var lexer = new Lexer(processedSource);
        var tokens = lexer.Tokenize();
        var interpreter = new Interpreter(tokens, basePath);
        interpreter.Run();
    }
    finally
    {
        // Always shutdown graphics on exit
        if (BazzBasic.Graphics.Graphics.IsInitialized)
        {
            BazzBasic.Graphics.Graphics.Shutdown();
        }
    }
}
