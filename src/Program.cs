/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Program.cs
 BazzBasic - BASIC Interpreter with integrated IDE

 Licence: MIT
*/

using System.Runtime.InteropServices;
using System.Text;
using BazzBasic.Lexer;
using BazzBasic.Interpreter;
using BazzBasic.Preprocessor;
using BazzBasic.IDE;

// Win32 API for console management
[DllImport("kernel32.dll")]
static extern bool FreeConsole();

// Marker for embedded BASIC code
const string EMBEDDED_MARKER = "---BAZZBASIC---";

// First, check if this exe has embedded BASIC code
string? embeddedCode = GetEmbeddedCode();
if (embeddedCode != null)
{
    // Run embedded code
    try
    {
        string exePath = Environment.ProcessPath ?? "";
        string basePath = Path.GetDirectoryName(exePath) ?? Directory.GetCurrentDirectory();
        RunProgram(embeddedCode, basePath, null);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error: {ex.Message}");
        return 1;
    }
    return 0;
}

// Check for -exe packaging command
if (args.Length >= 2 && args[0].ToLower() == "-exe")
{
    string sourceFile = args[1];
    return PackageExe(sourceFile);
}

// Normal operation: IDE or interpreter
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

// ============================================================================
// Helper functions
// ============================================================================

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

/// <summary>
/// Check if this exe has embedded BASIC code appended to it.
/// Returns the code if found, null otherwise.
/// </summary>
static string? GetEmbeddedCode()
{
    try
    {
        string? exePath = Environment.ProcessPath;
        if (string.IsNullOrEmpty(exePath) || !File.Exists(exePath))
            return null;
        
        byte[] exeBytes = File.ReadAllBytes(exePath);
        byte[] markerBytes = Encoding.UTF8.GetBytes(EMBEDDED_MARKER);
        
        // Search for marker from the end (more efficient)
        int markerPos = FindMarker(exeBytes, markerBytes);
        if (markerPos < 0)
            return null;
        
        // Extract code after marker
        int codeStart = markerPos + markerBytes.Length;
        if (codeStart >= exeBytes.Length)
            return null;
        
        byte[] codeBytes = new byte[exeBytes.Length - codeStart];
        Array.Copy(exeBytes, codeStart, codeBytes, 0, codeBytes.Length);
        
        return Encoding.UTF8.GetString(codeBytes);
    }
    catch
    {
        return null;
    }
}

/// <summary>
/// Find marker position in byte array (search from end for efficiency)
/// </summary>
static int FindMarker(byte[] data, byte[] marker)
{
    // Search last 1MB of file (code won't be bigger than that)
    int searchStart = Math.Max(0, data.Length - 1024 * 1024);
    
    for (int i = data.Length - marker.Length; i >= searchStart; i--)
    {
        bool found = true;
        for (int j = 0; j < marker.Length; j++)
        {
            if (data[i + j] != marker[j])
            {
                found = false;
                break;
            }
        }
        if (found)
            return i;
    }
    return -1;
}

/// <summary>
/// Package a BASIC file into a standalone exe
/// </summary>
static int PackageExe(string sourceFile)
{
    if (!File.Exists(sourceFile))
    {
        Console.WriteLine($"Error: File not found: {sourceFile}");
        return 1;
    }
    
    // Determine output filename
    string outputFile = Path.GetFileNameWithoutExtension(sourceFile) + ".exe";
    string outputPath = Path.Combine(
        Path.GetDirectoryName(Path.GetFullPath(sourceFile)) ?? Directory.GetCurrentDirectory(),
        outputFile
    );
    
    // Get path to this exe
    string? thisExe = Environment.ProcessPath;
    if (string.IsNullOrEmpty(thisExe) || !File.Exists(thisExe))
    {
        Console.WriteLine("Error: Cannot locate BazzBasic executable");
        return 1;
    }
    
    try
    {
        // Read source BASIC code
        string sourceCode = File.ReadAllText(sourceFile);
        
        // Read this exe (the "clean" bazzbasic.exe without embedded code)
        byte[] exeBytes = File.ReadAllBytes(thisExe);
        
        // Check if this exe already has embedded code (don't nest!)
        byte[] markerBytes = Encoding.UTF8.GetBytes(EMBEDDED_MARKER);
        int existingMarker = FindMarker(exeBytes, markerBytes);
        if (existingMarker >= 0)
        {
            // Truncate to original exe
            Array.Resize(ref exeBytes, existingMarker);
        }
        
        // Combine: exe + marker + code
        byte[] codeBytes = Encoding.UTF8.GetBytes(sourceCode);
        byte[] outputBytes = new byte[exeBytes.Length + markerBytes.Length + codeBytes.Length];
        
        Array.Copy(exeBytes, 0, outputBytes, 0, exeBytes.Length);
        Array.Copy(markerBytes, 0, outputBytes, exeBytes.Length, markerBytes.Length);
        Array.Copy(codeBytes, 0, outputBytes, exeBytes.Length + markerBytes.Length, codeBytes.Length);
        
        // Write output
        File.WriteAllBytes(outputPath, outputBytes);
        
        Console.WriteLine($"Created: {outputPath}");
        Console.WriteLine($"Size: {outputBytes.Length:N0} bytes");
        return 0;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error creating exe: {ex.Message}");
        return 1;
    }
}
