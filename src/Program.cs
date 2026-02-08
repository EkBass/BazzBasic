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

// Check for -lib library compilation command
if (args.Length >= 2 && args[0].ToLower() == "-lib")
{
    string sourceFile = args[1];
    return CompileLibrary(sourceFile);
}

// Check for -v version info
if (args.Length == 1 && (args[0].ToLower() == "-v" || args[0].ToLower() == "--version"))
{
    Console.WriteLine($"Version: {BazzBasic.AppInfo.Version}");
    Console.WriteLine($"Url: {BazzBasic.AppInfo.Url}");
    return 0;
}

// Normal operation: IDE or interpreter
if (args.Length == 0)
{
    // No arguments - launch IDE on STA thread
    FreeConsole();
    
    var thread = new Thread(() =>
    {
        try
        {
            ApplicationConfiguration.Initialize();
            Application.Run(new MainForm());
        }
        catch (Exception ex)
        {
            MessageBox.Show($"IDE Error: {ex.Message}\n\n{ex.StackTrace}", "BazzBasic Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
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
        // Preprocess - handle INCLUDE directives for .bas files
        var preprocessor = new Preprocessor(basePath);
        string processedSource = preprocessor.Process(source, filename);
        
        // Tokenize
        var lexer = new Lexer(processedSource);
        var tokens = lexer.Tokenize();

        // Load .bb libraries (if any INCLUDE "*.bb" statements)
        // .bb are tokenized libraries, so this step adds their tokens into the main token list
        var libraryLoader = new LibraryLoader(basePath);
        tokens = libraryLoader.ProcessLibraries(tokens);
        
        // Run
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


// Check if this exe has embedded BASIC code appended to it.
// Returns the code if found, null otherwise.
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

// Find marker position in byte array (search from end for efficiency)
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


// Package a BASIC file into a standalone exe
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


// Compile a BASIC library file to tokenized .bb format
static int CompileLibrary(string sourceFile)
{
    if (!File.Exists(sourceFile))
    {
        Console.WriteLine($"Error: File not found: {sourceFile}");
        return 1;
    }
    
    // Determine output filename and library name
    string baseName = Path.GetFileNameWithoutExtension(sourceFile);
    string libraryName = baseName.ToUpperInvariant();
    string outputFile = baseName + ".bb";
    string outputPath = Path.Combine(
        Path.GetDirectoryName(Path.GetFullPath(sourceFile)) ?? Directory.GetCurrentDirectory(),
        outputFile
    );
    
    try
    {
        // Read and tokenize source
        string source = File.ReadAllText(sourceFile);
        var lexer = new Lexer(source);
        var tokens = lexer.Tokenize();
        
        // Validate: only DEF FN allowed
        var errors = TokenSerializer.ValidateLibraryContent(tokens);
        if (errors.Count > 0)
        {
            Console.WriteLine("Library validation failed:");
            foreach (var error in errors)
            {
                Console.WriteLine($"  {error}");
            }
            return 1;
        }
        
        // Add library prefix to function names
        TokenSerializer.AddFunctionPrefix(tokens, libraryName);
        
        // Serialize to binary
        byte[] data = TokenSerializer.Serialize(tokens, libraryName);
        
        // Write output
        File.WriteAllBytes(outputPath, data);
        
        Console.WriteLine($"Created library: {outputPath}");
        Console.WriteLine($"Library name: {libraryName}");
        Console.WriteLine($"Size: {data.Length:N0} bytes");
        return 0;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error compiling library: {ex.Message}");
        return 1;
    }
}
