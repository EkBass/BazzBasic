/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Preprocessor\Preprocessor.cs
 Handles INCLUDE directives before tokenization

 Licence: MIT
*/

namespace BazzBasic.Preprocessor;

public class Preprocessor
{
    private readonly HashSet<string> _includedFiles = new(StringComparer.OrdinalIgnoreCase);
    private readonly string _basePath;

    public Preprocessor(string basePath = "")
    {
        _basePath = string.IsNullOrEmpty(basePath) ? Directory.GetCurrentDirectory() : basePath;
    }


    // Handle source code to  expand all INCLUDE directives

    public string Process(string source, string? currentFile = null)
    {
        // Track current file to prevent circulariti
        if (currentFile != null)
        {
            string fullPath = Path.GetFullPath(Path.Combine(_basePath, currentFile));
            if (_includedFiles.Contains(fullPath))
            {
                throw new Exception($"Circular INCLUDE detected: {currentFile}");
            }
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
                string includeLine = trimmedLine.Substring(7).Trim();
                
                // Extract filename
                string? filename = ExtractQuotedString(includeLine);
                
                if (filename == null)
                {
                    throw new Exception($"Invalid INCLUDE syntax at line {i + 1}: expected \"filename\"");
                }

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

                // Read and recursively process included file
                string includedSource = System.IO.File.ReadAllText(filePath);
                string processedInclude = Process(includedSource, filePath);

                // Add comment showing where include came from
                // Why I did this? No one can see the source after tokenization anyway
                // "but it helps debugging preprocessed source"
                // That is my excuse and I am sticking to it dang
                result.Add($"' --- BEGIN INCLUDE: {filename} ---");
                result.Add(processedInclude.TrimEnd());
                result.Add($"' --- END INCLUDE: {filename} ---");
            }
            else
            {
                result.Add(line);
            }
        }

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
