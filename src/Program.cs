/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Program.cs
 BazzBasic - BASIC Interpreter

 Licence: MIT
*/

using BazzBasic.Lexer;
using BazzBasic.Interpreter;
using BazzBasic.Preprocessor;
using BazzBasic.Graphics;

// Check command line arguments
if (args.Length == 0)
{
    LoadInfo();
}
else
{
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
        // Always shutdown graphics on edit
        if (Graphics.IsInitialized)
        {
            Graphics.Shutdown();
        }
    }
}

static void LoadInfo()
{
    // This originally run code written here, but now just shows usage info
    // Not finest solution but works for now
    Console.WriteLine("BazzBasic Version 0.5");
    Console.WriteLine("Release date 9th Jan 2026");
    Console.WriteLine("https://github.com/EkBass/BazzBasic");
    Console.WriteLine("Usage: bazzbasic <filename.bas>");
}
