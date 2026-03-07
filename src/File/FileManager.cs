/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: File\FileManager.cs
 Handles file operations 

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

namespace BazzBasic.File;

public class FileManager(string rootPath)
{
    private readonly string _rootPath = rootPath;

    public string RootPath => _rootPath;

    // Read entire file contents as string
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

    // Check if file exists
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

    // Write content to file (overwrites existing file)
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

    // Append content to end of file
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

    // Delete file
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
    // Execute SHELL command and return output
    // timeout: milliseconds to wait. 0 or omitted = 5000ms default
    public string ExecuteShellCommand(string command, int timeout = 5000)
    {
        if (string.IsNullOrWhiteSpace(command))
            return string.Empty;

        if (timeout <= 0)
            timeout = 5000;

        try
        {
            var processInfo = new System.Diagnostics.ProcessStartInfo("cmd.exe", $"/c {command}")
            {
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };
            using var process = System.Diagnostics.Process.Start(processInfo);
            if (process == null) return string.Empty;
            process.WaitForExit(timeout);
            return process.StandardOutput.ReadToEnd();
        }
        catch
        {
            return string.Empty;
        }
    }
    // Resolve path relative to root or as absolute
    public string ResolvePath(string path)
    {
        // If already absolute, use as-is
        if (Path.IsPathRooted(path))
        {
            return path;
        }

        // Or combine with root path
        return Path.Combine(_rootPath, path);
    }
}
