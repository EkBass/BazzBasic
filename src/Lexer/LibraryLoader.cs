/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Lexer\LibraryLoader.cs
 Loads and merges .bb library files into token stream

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

namespace BazzBasic.Lexer;

public class LibraryLoader
{
    private readonly HashSet<string> _loadedLibraries = new(StringComparer.OrdinalIgnoreCase);
    private readonly string _basePath;
    private readonly SourceMap? _sourceMap;   // T27: INCLUDEd-file locations + library token ranges

    public LibraryLoader(string basePath = "", SourceMap? sourceMap = null)
    {
        _basePath = string.IsNullOrEmpty(basePath) ? Directory.GetCurrentDirectory() : basePath;
        _sourceMap = sourceMap;
    }

    // "Line N" in the main program, "<file> line N" when the INCLUDE "x.bb" sits in an INCLUDEd .bas
    private string Where(int line) => _sourceMap?.Describe(line) ?? $"Line {line}";


    // Process tokens: find .bb INCLUDE statements, load libraries, merge toke
    public List<Token> ProcessLibraries(List<Token> tokens)
    {
        var libraryTokens = new List<Token>();
        var programTokens = new List<Token>();
        int i = 0;

        while (i < tokens.Count)
        {
            // Look for INCLUDE "something.bb"
            if (tokens[i].Type == TokenType.TOK_INCLUDE &&
                i + 1 < tokens.Count &&
                tokens[i + 1].Type == TokenType.TOK_STRING)
            {
                string filename = tokens[i + 1].StringValue ?? "";
                
                if (filename.EndsWith(".bb", StringComparison.OrdinalIgnoreCase))
                {
                    // Load library
                    var libTokens = LoadLibrary(filename, tokens[i].Line);
                    // T27 part B: libraries go first (merge below), so these indices are final
                    if (libTokens.Count > 0)
                        _sourceMap?.AddLibrary(libraryTokens.Count, libraryTokens.Count + libTokens.Count, filename);
                    libraryTokens.AddRange(libTokens);
                    
                    // Skip INCLUDE + filename + possible NEWLINE
                    i += 2;
                    if (i < tokens.Count && tokens[i].Type == TokenType.TOK_NEWLINE)
                        i++;
                    continue;
                }
            }

            programTokens.Add(tokens[i]);
            i++;
        }

        // Merge: libraries first, then program or it gets ugly
        if (libraryTokens.Count > 0)
        {
            // Add newline separator
            libraryTokens.Add(new Token(TokenType.TOK_NEWLINE, 0));
            libraryTokens.AddRange(programTokens);
            return libraryTokens;
        }

        return programTokens;
    }

    // Load a single .bb library file */
    private List<Token> LoadLibrary(string filename, int includeLine)
    {
        // Resolve path
        string filePath = ResolveLibraryPath(filename);
        
        if (!System.IO.File.Exists(filePath))
        {
            throw new Exception($"{Where(includeLine)}: Library not found: {filename}");
        }

        // Check for circular/duplicate loading
        string fullPath = Path.GetFullPath(filePath);
        if (_loadedLibraries.Contains(fullPath))
        {
            // Already loaded - skip silently tho I would like to remind the user about it... a little
            // Ok, lets be nice and throw a warning while skipping
            Console.Error.WriteLine($"Warning: {Where(includeLine)}: Library '{filename}' already loaded, skipping.");
            return new List<Token>();
        }
        _loadedLibraries.Add(fullPath);

        // Load and deserialize
        try
        {
            byte[] data = System.IO.File.ReadAllBytes(filePath);
            var (libraryName, tokens) = TokenSerializer.Deserialize(data);
            
            // Remove EOF token from library (will be at end of program)
            tokens.RemoveAll(t => t.Type == TokenType.TOK_EOF);
            
            return tokens;
        }
        catch (Exception ex)
        {
            throw new Exception($"{Where(includeLine)}: Error loading library {filename}: {ex.Message}");
        }
    }

    // Figure out library file path
    private string ResolveLibraryPath(string filename)
    {
        // Try relative to base path first
        string basePath = Path.Combine(_basePath, filename);
        if (System.IO.File.Exists(basePath))
        {
            return Path.GetFullPath(basePath);
        }

        // Try as absolute path
        if (System.IO.File.Exists(filename))
        {
            return Path.GetFullPath(filename);
        }

        // Return as-is (will fail with not found)
        return filename;
    }
}
