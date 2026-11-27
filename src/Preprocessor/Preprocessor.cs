/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Preprocessor\Preprocessor.cs
 Handles INCLUDE directives before tokenization

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using BazzBasic.Lexer;

namespace BazzBasic.Preprocessor;

public class Preprocessor
{
    // Every .bas file expanded so far (full path)
    private readonly HashSet<string> _includedFiles = new(StringComparer.OrdinalIgnoreCase);
    // Files on the current INCLUDE path, main -> ... -> the file being expanded (T27 / O14).
    // Only a file on this path is a real cycle; a file expanded earlier on another path is skipped.
    private readonly HashSet<string> _includeChain = new(StringComparer.OrdinalIgnoreCase);
    private readonly string _basePath;

    public Preprocessor(string basePath = "")
    {
        _basePath = string.IsNullOrEmpty(basePath) ? Directory.GetCurrentDirectory() : basePath;
    }


    // Handle source code to  expand all INCLUDE directives

    public string Process(string source, string? currentFile = null) => ProcessFile(source, currentFile, null);

    // label = the file name as written in its INCLUDE line (null = main program), for messages
    private string ProcessFile(string source, string? currentFile, string? label)
    {
        // Track current file to prevent circulariti
        // (main file: path as given on the command line, relative to the current directory;
        // INCLUDEd file: already a full path from ResolveFilePath)
        string? fullPath = null;
        if (currentFile != null)
        {
            fullPath = Path.GetFullPath(currentFile);
            if (_includeChain.Contains(fullPath))
            {
                throw new Exception($"Circular INCLUDE detected: {currentFile}");
            }
            _includeChain.Add(fullPath);
            _includedFiles.Add(fullPath);
        }

        var lines = source.Split('\n');
        var result = new List<string>();

        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i].TrimEnd('\r');
            string trimmedLine = line.TrimStart();

            // See for INCLUDE directive
            if (trimmedLine.StartsWith("INCLUDE", StringComparison.OrdinalIgnoreCase))
            {
                string includeLine = trimmedLine[7..].Trim();
                
                // Extract filename
                // (inside an INCLUDEd file the message names that file, T27 / P4)
                string? filename = ExtractQuotedString(includeLine) ?? throw new Exception(label == null
                    ? $"Invalid INCLUDE syntax at line {i + 1}: expected \"filename\""
                    : $"{SourceMap.Where(label, i + 1)}: Invalid INCLUDE syntax: expected \"filename\"");

                // Skip .bb library files - they are handled after tokenization
                if (filename.EndsWith(".bb", StringComparison.OrdinalIgnoreCase))
                {
                    result.Add(line); // Keep the INCLUDE line for LibraryLoader
                    continue;
                }

                // solve file path
                string filePath = ResolveFilePath(filename, currentFile);

                if (!System.IO.File.Exists(filePath))
                {
                    throw new Exception($"INCLUDE file not found: {filename} (resolved to: {filePath})");
                }

                // Already expanded on another path (not a cycle): skip it with a warning, like a
                // duplicate .bb library (LibraryLoader). One comment line keeps the line count.
                // A file on the current path is not skipped: ProcessFile reports it as circular.
                string includePath = Path.GetFullPath(filePath);
                if (_includedFiles.Contains(includePath) && !_includeChain.Contains(includePath))
                {
                    Console.Error.WriteLine($"Warning: {SourceMap.Where(label, i + 1)}: Include '{filename}' already included, skipping.");
                    result.Add($"' already included, skipped: {filename}");
                    continue;
                }

                // Read and recursively process included file
                string includedSource = System.IO.File.ReadAllText(filePath);
                string processedInclude = ProcessFile(includedSource, filePath, filename);

                // Add comment showing where include came from
                // Why I did this? No one can see the source after tokenization anyway
                // "but it helps debugging preprocessed source"
                // That is my excuse and I am sticking to it dang
                // T27: the line map (SourceMap.Build) reads these markers back for error locations
                result.Add(SourceMap.BeginMarker(filename));
                result.Add(processedInclude.TrimEnd());
                result.Add(SourceMap.EndMarker(filename));
            }
            else
            {
                result.Add(line);
            }
        }

        // Leaving this file: it is no longer on the INCLUDE path (it stays in _includedFiles)
        if (fullPath != null)
            _includeChain.Remove(fullPath);

        return string.Join("\n", result);
    }


    // Get string content from quotes

    private static string? ExtractQuotedString(string input)
    {
        int start = input.IndexOf('"');
        if (start < 0) return null;

        int end = input.IndexOf('"', start + 1);
        if (end < 0) return null;

        return input.Substring(start + 1, end - start - 1);
    }


    // Solve include file path relative to current file or base path

    private string ResolveFilePath(string filename, string? currentFile)
    {
        // If current file exists, try relative to it first
        if (currentFile != null)
        {
            string? dir = Path.GetDirectoryName(currentFile);
            if (!string.IsNullOrEmpty(dir))
            {
                string relativePath = Path.Combine(dir, filename);
                if (System.IO.File.Exists(relativePath))
                {
                    return Path.GetFullPath(relativePath);
                }
            }
        }

        // Try relative to base path
        string basePath = Path.Combine(_basePath, filename);
        if (System.IO.File.Exists(basePath))
        {
            return Path.GetFullPath(basePath);
        }

        // Return as-is  which will fail with file not found
        return filename;
    }
}
