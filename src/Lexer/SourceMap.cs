/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Lexer\SourceMap.cs
 Maps a line of the preprocessed (merged) source back to the file it came from

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

namespace BazzBasic.Lexer;

// Error locations for INCLUDEd files (T27 / O13).
// The Preprocessor replaces every INCLUDE "x.bas" line with a BEGIN marker line, the processed
// text of x.bas and an END marker line. Build() reads those markers back, so the same code works
// for a normal run and for an -exe (which embeds the merged text, markers included).
// Token.Line stays the line in the MERGED text; this map is used only when a message is printed.
public sealed class SourceMap
{
    // Marker lines. A line is a marker only when it is EXACTLY prefix + name + suffix.
    // The Preprocessor writes them with BeginMarker()/EndMarker(), so both sides share this text.
    // Changing it needs no compatibility work: every -exe carries its own interpreter.
    public const string BeginPrefix  = "'@@BAZZBASIC-INCLUDE-BEGIN@@ ";
    public const string EndPrefix    = "'@@BAZZBASIC-INCLUDE-END@@ ";
    public const string MarkerSuffix = " @@";

    public static string BeginMarker(string name) => BeginPrefix + name + MarkerSuffix;
    public static string EndMarker(string name) => EndPrefix + name + MarkerSuffix;

    private readonly string?[] _file;   // [merged line - 1]: file label, null = main program
    private readonly int[] _line;       // [merged line - 1]: line number inside that file
    private readonly List<(int Start, int End, string Name)> _libraries = new();

    private SourceMap(int count)
    {
        _file = new string?[count];
        _line = new int[count];
    }

    public static SourceMap Build(string mergedSource)
    {
        // Same line count the Lexer sees: it counts only '\n'
        string[] lines = mergedSource.Split('\n');
        var map = new SourceMap(lines.Length);
        var parents = new Stack<(string? File, int Line)>();
        string? file = null;   // current file, null = main program
        int line = 0;          // last line number used in the current file

        for (int i = 0; i < lines.Length; i++)
        {
            string text = lines[i].TrimEnd('\r');

            if (TryReadMarker(text, BeginPrefix, out string beginName))
            {
                line++;                          // the BEGIN marker stands on the parent's INCLUDE line
                map._file[i] = file;
                map._line[i] = line;
                parents.Push((file, line));
                file = beginName;
                line = 0;
            }
            else if (parents.Count > 0 && TryReadMarker(text, EndPrefix, out string endName) && endName == file)
            {
                (file, line) = parents.Pop();    // back in the parent, still on its INCLUDE line
                map._file[i] = file;
                map._line[i] = line;
            }
            else
            {
                line++;
                map._file[i] = file;
                map._line[i] = line;
            }
        }
        return map;
    }

    private static bool TryReadMarker(string text, string prefix, out string name)
    {
        name = "";
        if (text.Length <= prefix.Length + MarkerSuffix.Length
            || !text.StartsWith(prefix, StringComparison.Ordinal)
            || !text.EndsWith(MarkerSuffix, StringComparison.Ordinal))
            return false;
        name = text.Substring(prefix.Length, text.Length - prefix.Length - MarkerSuffix.Length);
        return true;
    }

    // .bb library tokens sit at token indices [start, end) of the final token list
    // (LibraryLoader puts every library first; the list is not changed after that).
    public void AddLibrary(int start, int end, string name) => _libraries.Add((start, end, name));

    // Merged line -> (file, line in that file); File == null means the main program.
    // Out-of-range lines (0 = no token, e.g. the separator LibraryLoader adds) come back unchanged.
    public (string? File, int Line) Locate(int mergedLine)
    {
        if (mergedLine < 1 || mergedLine > _file.Length)
            return (null, mergedLine);
        return (_file[mergedLine - 1], _line[mergedLine - 1]);
    }

    // Runtime variant: a token inside a .bb library reports the library and its own source line
    public (string? File, int Line) Locate(int tokenIndex, int tokenLine)
    {
        foreach (var lib in _libraries)
        {
            if (tokenIndex >= lib.Start && tokenIndex < lib.End)
                return (lib.Name, tokenLine);
        }
        return Locate(tokenLine);
    }

    // Location text for load-time messages and warnings:
    // "Line N" in the main program (the old text), "<file> line N" inside an INCLUDEd file
    public static string Where(string? file, int line) => file == null ? $"Line {line}" : $"{file} line {line}";

    public string Describe(int mergedLine)
    {
        var (file, line) = Locate(mergedLine);
        return Where(file, line);
    }
}
