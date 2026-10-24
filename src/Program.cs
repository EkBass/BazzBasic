/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Program.cs
 BazzBasic - BASIC Interpreter (console). The IDE is a separate exe: BazzBasic-IDE.exe

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using System.Runtime.InteropServices;
using System.Text;
using BazzBasic.Lexer;
using BazzBasic.Interpreter;
using BazzBasic.Preprocessor;

// Win32 API: number of processes attached to this console.
// 1 = only us, i.e. started by double-click and the window closes when we exit.
[DllImport("kernel32.dll")]
static extern uint GetConsoleProcessList(uint[] processList, uint processCount);

// IDE exe that "BazzBasic.exe" without arguments starts (must match IDE AssemblyName)
const string IDE_EXE_NAME = "BazzBasic-IDE.exe";

// Nahimic audio middleware on this system breaks WASAPI device enumeration.
// DirectSound bypasses it reliably.
Environment.SetEnvironmentVariable("SDL_AUDIODRIVER", "directsound");

// Unicode console I/O. Wrapped: there may be no console (e.g. output redirected oddly).
try { Console.OutputEncoding = Encoding.UTF8; } catch { }
try { Console.InputEncoding  = Encoding.UTF8; } catch { }

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
        if (!RunProgram(embeddedCode, basePath, null))
            return 1;
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
if (args.Length == 1 && (args[0].ToLower() == "-v" || args[0].ToLower() == "-version"))
{
    Console.WriteLine($"Version: {BazzBasic.AppInfo.Version}");
    Console.WriteLine($"Url: {BazzBasic.AppInfo.Url}");
    return 0;
}

// Check for -guide for beginner's guide link
if (args.Length == 1 && (args[0].ToLower() == "-guide" || args[0].ToLower() == "-help"))
{
    Console.WriteLine("BazzBasic - Beginner's Guide");
    Console.WriteLine("Url: https://github.com/EkBass/BazzBasic-Beginners-Guide/releases");
    return 0;
}

// Check for -checkupdate
// (-checkupdates accepted too: older manual pages used that spelling)
if (args.Length == 1 && (args[0].ToLower() == "-checkupdate" || args[0].ToLower() == "-checkupdates"))
{
    string result = await BazzBasic.UpdateChecker.CheckAsync();
    Console.WriteLine(result);
    return 0;
}

// Normal operation: no arguments -> start the IDE next to us, otherwise run a file
if (args.Length == 0)
{
    // Backward compatibility: double-clicking BazzBasic.exe used to open the IDE
    string exeDir = Path.GetDirectoryName(Environment.ProcessPath ?? "") ?? "";
    string idePath = Path.Combine(exeDir, IDE_EXE_NAME);
    if (File.Exists(idePath))
    {
        try
        {
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = idePath,
                WorkingDirectory = exeDir,
                UseShellExecute = true
            });
            return 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: could not start {IDE_EXE_NAME}: {ex.Message}");
        }
    }

    PrintUsage();

    // Started by double-click: keep the window open so the text can be read
    bool ownConsole = false;
    try { ownConsole = GetConsoleProcessList(new uint[2], 2) == 1; } catch { }
    if (ownConsole)
    {
        Console.WriteLine();
        Console.Write("Press any key to close...");
        try { Console.ReadKey(true); } catch { }
    }
    return 0;
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
    
    string[] userArgs = args.Length > 1 ? args[1..] : [];
    
    try
    {
        string source = File.ReadAllText(filename);
        string basePath = Path.GetDirectoryName(Path.GetFullPath(filename)) ?? Directory.GetCurrentDirectory();
        if (!RunProgram(source, basePath, filename, userArgs))
            return 1;
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

static void PrintUsage()
{
    Console.WriteLine($"{BazzBasic.AppInfo.Name} {BazzBasic.AppInfo.Version} - {BazzBasic.AppInfo.Url}");
    Console.WriteLine();
    Console.WriteLine("Usage:");
    Console.WriteLine("  BazzBasic.exe program.bas [args...]   Run a program");
    Console.WriteLine("  BazzBasic.exe -exe program.bas        Compile to a standalone .exe");
    Console.WriteLine("  BazzBasic.exe -lib library.bas        Compile a library to .bb");
    Console.WriteLine("  BazzBasic.exe -v | -version           Show version");
    Console.WriteLine("  BazzBasic.exe -checkupdate            Check for a newer version");
    Console.WriteLine("  BazzBasic.exe -guide | -help          Beginner's guide link");
    Console.WriteLine();
    Console.WriteLine($"The editor is {IDE_EXE_NAME} (not found next to BazzBasic.exe).");
}

// Runs the program on its own thread with a large stack.
// DEF FN calls recurse on the C# call stack (~13 frames per BASIC call), so the default
// 1 MB main-thread stack crashed the whole process with "Stack overflow" at only
// ~500-700 levels of BASIC recursion. 256 MB is reserved virtually and committed only
// as it is used. CallUserFunction also checks the remaining stack and reports a clean
// BASIC error before it runs out.
static bool RunProgram(string source, string basePath = "", string? filename = null, string[]? userArgs = null)
{
    const int INTERPRETER_STACK_SIZE = 256 * 1024 * 1024;
    bool ok = false;
    Exception? failure = null;

    var thread = new System.Threading.Thread(() =>
    {
        try { ok = RunProgramCore(source, basePath, filename, userArgs); }
        catch (Exception ex) { failure = ex; }
    }, INTERPRETER_STACK_SIZE);

    thread.Start();
    thread.Join();

    // Re-throw on the caller's thread so the existing "Error: ..." handlers still apply
    if (failure != null)
        System.Runtime.ExceptionServices.ExceptionDispatchInfo.Capture(failure).Throw();

    return ok;
}

static bool RunProgramCore(string source, string basePath, string? filename, string[]? userArgs)
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
        var interpreter = new Interpreter(tokens, basePath, userArgs);
        interpreter.Run();
        return !interpreter.HasError;
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
        // Read source BASIC code and process INCLUDE directives
        // so the standalone exe contains the fully merged source
        string rawSource = File.ReadAllText(sourceFile);
        string basePath = Path.GetDirectoryName(Path.GetFullPath(sourceFile)) ?? Directory.GetCurrentDirectory();
        var preprocessor = new Preprocessor(basePath);
        string sourceCode = preprocessor.Process(rawSource, sourceFile);
        
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
