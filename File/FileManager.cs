// ============================================================================
// BazzBasic - File Manager
// Handles file operations
// ============================================================================

namespace BazzBasic.File;

public class FileManager
{
    private readonly string _rootPath;

    public FileManager(string rootPath)
    {
        _rootPath = rootPath;
    }

    public string RootPath => _rootPath;

    /// <summary>
    /// Read entire file contents as string
    /// </summary>
    public string ReadFile(string path)
    {
        try
        {
            string fullPath = ResolvePath(path);
            return System.IO.File.ReadAllText(fullPath);
        }
        catch
        {
            return string.Empty; // Return empty string on error
        }
    }

    /// <summary>
    /// Check if file exists
    /// </summary>
    public bool FileExists(string path)
    {
        try
        {
            string fullPath = ResolvePath(path);
            return System.IO.File.Exists(fullPath);
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Write content to file (overwrites existing file)
    /// </summary>
    public bool WriteFile(string path, string content)
    {
        try
        {
            string fullPath = ResolvePath(path);
            
            // Ensure directory exists
            string? directory = Path.GetDirectoryName(fullPath);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }
            
            System.IO.File.WriteAllText(fullPath, content);
            return true;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Append content to end of file
    /// </summary>
    public bool AppendFile(string path, string content)
    {
        try
        {
            string fullPath = ResolvePath(path);
            
            // Ensure directory exists
            string? directory = Path.GetDirectoryName(fullPath);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }
            
            System.IO.File.AppendAllText(fullPath, content);
            return true;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Delete file
    /// </summary>
    public bool DeleteFile(string path)
    {
        try
        {
            string fullPath = ResolvePath(path);
            if (System.IO.File.Exists(fullPath))
            {
                System.IO.File.Delete(fullPath);
                return true;
            }
            return false;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Resolve path relative to root or as absolute
    /// </summary>
    private string ResolvePath(string path)
    {
        // If already absolute, use as-is
        if (Path.IsPathRooted(path))
        {
            return path;
        }
        
        // Otherwise, combine with root path
        return Path.Combine(_rootPath, path);
    }
}
