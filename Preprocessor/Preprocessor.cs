// ============================================================================
// BazzBasic - Preprocessor
// Handles INCLUDE directives before tokenization
// ============================================================================

namespace BazzBasic.Preprocessor;

public class Preprocessor
{
    private readonly HashSet<string> _includedFiles = new(StringComparer.OrdinalIgnoreCase);
    private readonly string _basePath;

    public Preprocessor(string basePath = "")
    {
        _basePath = string.IsNullOrEmpty(basePath) ? Directory.GetCurrentDirectory() : basePath;
    }

    /// <summary>
    /// Process source code and expand all INCLUDE directives
    /// </summary>
    public string Process(string source, string? currentFile = null)
    {
        // Track current file to prevent circular includes
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

            // Check for INCLUDE directive
            if (trimmedLine.StartsWith("INCLUDE", StringComparison.OrdinalIgnoreCase))
            {
                string includeLine = trimmedLine.Substring(7).Trim();
                
                // Extract filename from quotes
                string? filename = ExtractQuotedString(includeLine);
                
                if (filename == null)
                {
                    throw new Exception($"Invalid INCLUDE syntax at line {i + 1}: expected \"filename\"");
                }

                // Resolve file path
                string filePath = ResolveFilePath(filename, currentFile);

                if (!File.Exists(filePath))
                {
                    throw new Exception($"INCLUDE file not found: {filename} (resolved to: {filePath})");
                }

                // Read and recursively process included file
                string includedSource = File.ReadAllText(filePath);
                string processedInclude = Process(includedSource, filePath);

                // Add comment showing where include came from
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

    /// <summary>
    /// Extract string content from quotes
    /// </summary>
    private static string? ExtractQuotedString(string input)
    {
        int start = input.IndexOf('"');
        if (start < 0) return null;

        int end = input.IndexOf('"', start + 1);
        if (end < 0) return null;

        return input.Substring(start + 1, end - start - 1);
    }

    /// <summary>
    /// Resolve include file path relative to current file or base path
    /// </summary>
    private string ResolveFilePath(string filename, string? currentFile)
    {
        // If current file exists, try relative to it first
        if (currentFile != null)
        {
            string? dir = Path.GetDirectoryName(currentFile);
            if (!string.IsNullOrEmpty(dir))
            {
                string relativePath = Path.Combine(dir, filename);
                if (File.Exists(relativePath))
                {
                    return Path.GetFullPath(relativePath);
                }
            }
        }

        // Try relative to base path
        string basePath = Path.Combine(_basePath, filename);
        if (File.Exists(basePath))
        {
            return Path.GetFullPath(basePath);
        }

        // Return as-is (will fail with file not found)
        return filename;
    }
}
