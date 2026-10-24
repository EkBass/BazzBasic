/*
 * BazzBasic IDE - Main Form
 * MIT License - Copyright (c) 2025 Kristian Virtanen
 */

using ScintillaNET;
using System.Diagnostics;
using System.Text.RegularExpressions;
using IOFile = System.IO.File;
using IOPath = System.IO.Path;

namespace BazzBasic.IDE;

public partial class MainForm : Form
{
    private readonly Dictionary<TabPage, EditorTab> _tabs = new();
    private int _untitledCount = 0;
    
    // Find/Replace state
    private string _lastSearchText = "";
    private FindReplaceDialog? _findReplaceDialog;

    // Theme
    private readonly IdeSettings _settings = IdeSettings.Load();
    private EditorTheme _theme = EditorTheme.Light;

    public MainForm()
    {
        BuildUi();

        _theme = EditorTheme.FromName(_settings.Theme);
        ApplyChromeTheme();
        RestoreWindowPlacement();
        
        // Window icon: the ApplicationIcon (icon.ico) embedded in BazzBasic-IDE.exe
        try { this.Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath); } catch { }
        
        // Session restore option
        restoreSessionMenuItem.Checked = _settings.RestoreSession;
        restoreSessionMenuItem.CheckedChanged += (s, e) =>
        {
            _settings.RestoreSession = restoreSessionMenuItem.Checked;
            _settings.Save();
        };

        // Tree View on/off, remembered between sessions
        // Width is clamped so a broken or extreme ide.json value cannot hide the panel or the editor
        codeTree.Width = Math.Clamp(_settings.TreeViewWidth, 80, 800);
        treeViewMenuItem.Checked = _settings.ShowTreeView;
        SetTreeViewVisible(_settings.ShowTreeView);
        treeViewMenuItem.CheckedChanged += (s, e) =>
        {
            _settings.ShowTreeView = treeViewMenuItem.Checked;
            _settings.Save();
            SetTreeViewVisible(treeViewMenuItem.Checked);
        };

        // Syntax coloring on/off, remembered between sessions.
        // Read before any editor is created: ApplyEditorColors checks the menu item,
        // so editors opened later (New/Open) pick up the same state.
        syntaxColoringMenuItem.Checked = _settings.SyntaxColoring;
        syntaxColoringMenuItem.CheckedChanged += (s, e) =>
        {
            _settings.SyntaxColoring = syntaxColoringMenuItem.Checked;
            _settings.Save();

            foreach (var tab in _tabs.Values)
                ApplyEditorColors(tab.Editor);
        };

        // Reopen last session's files, or start with an empty tab
        if (!(_settings.RestoreSession && RestoreSession()))
            NewFile();
        
        // Setup keyboard shortcuts
        KeyPreview = true;
    }

    #region File Operations

    public void NewFile()
    {
        _untitledCount++;
        var tabPage = new TabPage($"Untitled {_untitledCount}");
        var editor = CreateEditor();
        
        tabPage.Controls.Add(editor);
        editor.Dock = DockStyle.Fill;
        
        // Insert default template before the tab is registered,
        // so an untouched new file does not count as modified
        string template = $"' BazzBasic version {BazzBasic.AppInfo.Version}\n' https://ekbass.github.io/BazzBasic/\n";
        editor.Text = template;
        editor.SelectionStart = editor.TextLength;
        
        var editorTab = new EditorTab(tabPage, editor, null);
        _tabs[tabPage] = editorTab;
        
        tabControl.TabPages.Add(tabPage);
        tabControl.SelectedTab = tabPage;
        
        editor.Focus();
    }

    public void OpenFile(string? path = null)
    {
        if (path == null)
        {
            using var dialog = new OpenFileDialog
            {
                Filter = "BazzBasic files (*.bas)|*.bas|All files (*.*)|*.*",
                DefaultExt = "bas",
                InitialDirectory = Application.StartupPath,
                RestoreDirectory = true
            };
            
            this.TopMost = true;
            var result = dialog.ShowDialog(this);
            this.TopMost = false;
            
            if (result != DialogResult.OK) return;
            path = dialog.FileName;
        }
        
        // Check if already open
        foreach (var (tabPage, tab) in _tabs)
        {
            if (tab.FilePath == path)
            {
                tabControl.SelectedTab = tabPage;
                return;
            }
        }
        
        var content = IOFile.ReadAllText(path);
        var newTabPage = new TabPage(IOPath.GetFileName(path));
        var editor = CreateEditor();
        editor.Text = content;
        
        newTabPage.Controls.Add(editor);
        editor.Dock = DockStyle.Fill;
        
        var editorTab = new EditorTab(newTabPage, editor, path);
        _tabs[newTabPage] = editorTab;
        
        tabControl.TabPages.Add(newTabPage);
        tabControl.SelectedTab = newTabPage;
        
        editor.Focus();
    }

    private bool SaveFile(bool saveAs = false)
    {
        if (tabControl.SelectedTab == null) return false;
        
        var tab = _tabs[tabControl.SelectedTab];
        var path = tab.FilePath;

        if (path == null || saveAs)
        {
            using var dialog = new SaveFileDialog
            {
                Filter = "BazzBasic files (*.bas)|*.bas|All files (*.*)|*.*",
                DefaultExt = "bas",
                InitialDirectory = Application.StartupPath,
                RestoreDirectory = true
            };
            
            if (!string.IsNullOrEmpty(path))
            {
                dialog.FileName = IOPath.GetFileName(path);
                dialog.InitialDirectory = IOPath.GetDirectoryName(path);
            }
            
            this.TopMost = true;
            var result = dialog.ShowDialog(this);
            this.TopMost = false;
            
            if (result != DialogResult.OK) return false;
            path = dialog.FileName;
        }
        
        IOFile.WriteAllText(path, tab.Editor.Text);
        tab.FilePath = path;
        tab.IsModified = false;
        tabControl.SelectedTab.Text = IOPath.GetFileName(path);
        tabControl.Invalidate(); // Redraw tabs
        return true;
    }

    private bool CloseTab()
    {
        if (tabControl.SelectedTab == null) return false;
        
        var tab = _tabs[tabControl.SelectedTab];

        if (tab.IsModified)
        {
            var result = MessageBox.Show(
                $"Save changes to {tabControl.SelectedTab.Text.TrimEnd(' ', '*')}?",
                "BazzBasic IDE",
                MessageBoxButtons.YesNoCancel,
                MessageBoxIcon.Question);
            
            if (result == DialogResult.Cancel) return false;
            if (result == DialogResult.Yes && !SaveFile()) return false;
        }
        
        _tabs.Remove(tabControl.SelectedTab);
        tabControl.TabPages.Remove(tabControl.SelectedTab);

        if (tabControl.TabPages.Count == 0)
        {
            NewFile();
        }

        // Closing a tab does not always change SelectedIndex, so refresh explicitly
        RefreshCodeTree();
        return true;
    }

    [System.Runtime.InteropServices.DllImport("user32.dll", EntryPoint = "SendMessage")]
    private static extern IntPtr SendMessage(IntPtr hWnd, int msg, IntPtr wParam, IntPtr lParam);

    private const int SCI_FORMATRANGE = 2151;

    [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    private struct RECT
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    private struct CHARACTERRANGE
    {
        public int cpMin;
        public int cpMax;
    }

    [System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
    private struct RANGEFORMAT
    {
        public IntPtr hdc;
        public IntPtr hdcTarget;
        public RECT rc;
        public RECT rcPage;
        public CHARACTERRANGE chrg;
    }

    private const int SCI_GETLENGTH = 2006;           // document length in BYTES (UTF-8)
    private const int SCI_SETPRINTCOLOURMODE = 2148;
    private const int SC_PRINT_COLOURONWHITE = 3;     // keep syntax colours, force white background
    private const int SC_PRINT_BLACKONWHITE = 2;      // plain black text on white paper

    private void PrintTab()
    {
        if (tabControl.SelectedTab == null) return;
        var tab = _tabs[tabControl.SelectedTab];
        var editor = tab.Editor;

        using var printDialog = new PrintDialog();
        using var printDocument = new System.Drawing.Printing.PrintDocument();
        printDocument.DocumentName = tab.FilePath != null ? IOPath.GetFileName(tab.FilePath) : "Untitled";

        int position = 0;      // byte position, Scintilla positions are bytes, not chars
        int length = 0;
        Exception? printError = null;

        printDocument.BeginPrint += (s, e) =>
        {
            position = 0;
            length = SendMessage(editor.Handle, SCI_GETLENGTH, IntPtr.Zero, IntPtr.Zero).ToInt32();
            // Syntax colours on white paper, also in dark mode.
            // With Syntax Coloring off, print plain black text to match the screen.
            int printMode = syntaxColoringMenuItem.Checked ? SC_PRINT_COLOURONWHITE : SC_PRINT_BLACKONWHITE;
            SendMessage(editor.Handle, SCI_SETPRINTCOLOURMODE, (IntPtr)printMode, IntPtr.Zero);
        };

        printDocument.PrintPage += (s, e) =>
        {
            var g = e.Graphics!;

            // MarginBounds/PageBounds are in 1/100 inch. The HDC from GetHdc() is in
            // printer pixels, with its origin at the printable area, not the paper edge.
            float dpiX = g.DpiX, dpiY = g.DpiY;
            float hardX = e.PageSettings.HardMarginX, hardY = e.PageSettings.HardMarginY;
            int ToDevX(float v) => (int)((v - hardX) * dpiX / 100f);
            int ToDevY(float v) => (int)((v - hardY) * dpiY / 100f);

            var rf = new RANGEFORMAT
            {
                rc = new RECT
                {
                    Left = ToDevX(e.MarginBounds.Left),
                    Top = ToDevY(e.MarginBounds.Top),
                    Right = ToDevX(e.MarginBounds.Right),
                    Bottom = ToDevY(e.MarginBounds.Bottom)
                },
                rcPage = new RECT
                {
                    Left = 0,
                    Top = 0,
                    Right = ToDevX(e.PageBounds.Right),
                    Bottom = ToDevY(e.PageBounds.Bottom)
                },
                chrg = new CHARACTERRANGE { cpMin = position, cpMax = length }
            };

            IntPtr hdc = g.GetHdc();
            IntPtr lParam = System.Runtime.InteropServices.Marshal.AllocHGlobal(System.Runtime.InteropServices.Marshal.SizeOf<RANGEFORMAT>());
            try
            {
                rf.hdc = hdc;
                rf.hdcTarget = hdc;
                System.Runtime.InteropServices.Marshal.StructureToPtr(rf, lParam, false);
                int next = SendMessage(editor.Handle, SCI_FORMATRANGE, (IntPtr)1, lParam).ToInt32();

                // Guard against an endless page loop if nothing fits on the page
                if (next <= position)
                {
                    e.HasMorePages = false;
                    return;
                }
                position = next;
                e.HasMorePages = position < length;
            }
            catch (Exception ex)
            {
                printError = ex;
                e.Cancel = true;          // abort the job cleanly instead of leaving a broken file
                e.HasMorePages = false;
            }
            finally
            {
                System.Runtime.InteropServices.Marshal.FreeHGlobal(lParam);
                g.ReleaseHdc(hdc);
            }
        };

        // Note: no "FORMATRANGE with null HDC" cleanup in EndPrint.
        // That is a RichEdit convention; Scintilla does not need it.

        printDialog.Document = printDocument;
        printDialog.UseEXDialog = true;
        if (printDialog.ShowDialog(this) != DialogResult.OK) return;

        try
        {
            printDocument.Print();
        }
        catch (Exception ex)
        {
            printError ??= ex;
        }

        if (printError != null)
        {
            MessageBox.Show(this, $"Printing failed:\n\n{printError.Message}",
                "BazzBasic IDE", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    #endregion

    #region Session

    // Session files that could not be reopened; reported once the window is visible
    private readonly List<string> _missingSessionFiles = new();

    // Reopen files from the last session. Returns false if nothing was opened.
    private bool RestoreSession()
    {
        foreach (var path in _settings.SessionFiles)
        {
            try
            {
                if (IOFile.Exists(path)) OpenFile(path);
                else _missingSessionFiles.Add(path);
            }
            catch
            {
                _missingSessionFiles.Add(path); // Locked, no permission etc.
            }
        }

        if (tabControl.TabPages.Count == 0) return false;

        int i = _settings.SessionActiveIndex;
        if (i >= 0 && i < tabControl.TabPages.Count)
            tabControl.SelectedIndex = i;
        return true;
    }

    protected override void OnShown(EventArgs e)
    {
        base.OnShown(e);
        if (_missingSessionFiles.Count > 0)
        {
            MessageBox.Show(this,
                "These files from the last session no longer exist and were removed from the session:\n\n" +
                string.Join("\n", _missingSessionFiles),
                "BazzBasic IDE", MessageBoxButtons.OK, MessageBoxIcon.Information);
            _missingSessionFiles.Clear();
        }
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        // Ask about unsaved changes, in tab order
        foreach (TabPage page in tabControl.TabPages)
        {
            var tab = _tabs[page];
            if (!tab.IsModified) continue;

            tabControl.SelectedTab = page;
            var result = MessageBox.Show(this,
                $"Save changes to {page.Text.TrimEnd(' ', '*')}?",
                "BazzBasic IDE", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question);

            if (result == DialogResult.Cancel) { e.Cancel = true; return; }
            if (result == DialogResult.Yes)
            {
                SaveFile();
                if (tab.IsModified) { e.Cancel = true; return; } // Save As was cancelled
            }
        }

        // Remember open files (saved ones only) and the active tab.
        // Stored even when restore is off, so turning it on later restores the last session.
        var files = new List<string>();
        int active = 0;
        foreach (TabPage page in tabControl.TabPages)
        {
            var path = _tabs[page].FilePath;
            if (path == null) continue;
            if (page == tabControl.SelectedTab) active = files.Count;
            files.Add(path);
        }
        _settings.SessionFiles = files;
        _settings.SessionActiveIndex = active;
        _settings.TreeViewWidth = codeTree.Width;
        SaveWindowPlacement();
        _settings.Save();

        base.OnFormClosing(e);
    }

    // Window size, position and maximized state from ide.json
    private void RestoreWindowPlacement()
    {
        if (_settings.WindowX is int x && _settings.WindowY is int y &&
            _settings.WindowWidth is int w && _settings.WindowHeight is int h)
        {
            var bounds = new Rectangle(x, y,
                Math.Max(w, MinimumSize.Width),
                Math.Max(h, MinimumSize.Height));

            // Only use the saved position if the title bar is on a screen that exists now.
            // Protects against a disconnected second monitor leaving the window off-screen.
            var titleBar = new Rectangle(bounds.X, bounds.Y, bounds.Width, 30);
            if (Screen.AllScreens.Any(s => s.WorkingArea.IntersectsWith(titleBar)))
            {
                StartPosition = FormStartPosition.Manual;
                Bounds = bounds;
            }
        }

        // Maximizes on the screen the saved bounds are on
        if (_settings.WindowMaximized)
            WindowState = FormWindowState.Maximized;
    }

    private void SaveWindowPlacement()
    {
        // When maximized or minimized, RestoreBounds holds the normal-size window,
        // so un-maximizing after the next start goes back to the right size.
        var normal = WindowState == FormWindowState.Normal ? Bounds : RestoreBounds;

        _settings.WindowX = normal.X;
        _settings.WindowY = normal.Y;
        _settings.WindowWidth = normal.Width;
        _settings.WindowHeight = normal.Height;
        _settings.WindowMaximized = WindowState == FormWindowState.Maximized;
    }

    #endregion

    #region Find/Replace

    private void ShowFindDialog()
    {
        ShowFindReplaceDialog(false);
    }

    private void ShowReplaceDialog()
    {
        ShowFindReplaceDialog(true);
    }

    private void ShowFindReplaceDialog(bool showReplace)
    {
        if (tabControl.SelectedTab == null || !_tabs.TryGetValue(tabControl.SelectedTab, out var tab))
            return;

        // Get selected text as initial search term
        var selectedText = tab.Editor.SelectedText;
        if (!string.IsNullOrEmpty(selectedText))
            _lastSearchText = selectedText;

        if (_findReplaceDialog == null || _findReplaceDialog.IsDisposed)
        {
            _findReplaceDialog = new FindReplaceDialog();
            _findReplaceDialog.FindNext += FindReplaceDialog_FindNext;
            _findReplaceDialog.Replace += FindReplaceDialog_Replace;
            _findReplaceDialog.ReplaceAll += FindReplaceDialog_ReplaceAll;
        }

        _findReplaceDialog.SearchText = _lastSearchText;
        _findReplaceDialog.ShowReplace = showReplace;
        _findReplaceDialog.Show(this);
        _findReplaceDialog.Focus();
    }

    private void FindReplaceDialog_FindNext(object? sender, FindEventArgs e)
    {
        if (tabControl.SelectedTab == null || !_tabs.TryGetValue(tabControl.SelectedTab, out var tab))
            return;

        _lastSearchText = e.SearchText;
        var editor = tab.Editor;
        
        int startPos = editor.CurrentPosition;
        int foundPos = editor.Text.IndexOf(e.SearchText, startPos, 
            e.MatchCase ? StringComparison.Ordinal : StringComparison.OrdinalIgnoreCase);
        
        // Wrap around
        if (foundPos < 0)
        {
            foundPos = editor.Text.IndexOf(e.SearchText, 0,
                e.MatchCase ? StringComparison.Ordinal : StringComparison.OrdinalIgnoreCase);
        }
        
        if (foundPos >= 0)
        {
            editor.SetSelection(foundPos, foundPos + e.SearchText.Length);
            editor.ScrollCaret();
            statusLabel.Text = $"Found at position {foundPos}";
        }
        else
        {
            statusLabel.Text = "Text not found";
            MessageBox.Show($"Cannot find \"{e.SearchText}\"", "Find", 
                MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }

    private void FindReplaceDialog_Replace(object? sender, ReplaceEventArgs e)
    {
        if (tabControl.SelectedTab == null || !_tabs.TryGetValue(tabControl.SelectedTab, out var tab))
            return;

        var editor = tab.Editor;
        
        // If current selection matches search text, replace it
        if (string.Equals(editor.SelectedText, e.SearchText, 
            e.MatchCase ? StringComparison.Ordinal : StringComparison.OrdinalIgnoreCase))
        {
            editor.ReplaceSelection(e.ReplaceText);
        }
        
        // Find next
        FindReplaceDialog_FindNext(sender, new FindEventArgs(e.SearchText, e.MatchCase));
    }

    private void FindReplaceDialog_ReplaceAll(object? sender, ReplaceEventArgs e)
    {
        if (tabControl.SelectedTab == null || !_tabs.TryGetValue(tabControl.SelectedTab, out var tab))
            return;

        var editor = tab.Editor;
        var comparison = e.MatchCase ? StringComparison.Ordinal : StringComparison.OrdinalIgnoreCase;
        
        int count = 0;
        int pos = 0;
        
        editor.BeginUndoAction();
        try
        {
            while ((pos = editor.Text.IndexOf(e.SearchText, pos, comparison)) >= 0)
            {
                editor.SetSelection(pos, pos + e.SearchText.Length);
                editor.ReplaceSelection(e.ReplaceText);
                pos += e.ReplaceText.Length;
                count++;
            }
        }
        finally
        {
            editor.EndUndoAction();
        }
        
        statusLabel.Text = $"Replaced {count} occurrence(s)";
        MessageBox.Show($"Replaced {count} occurrence(s)", "Replace All",
            MessageBoxButtons.OK, MessageBoxIcon.Information);
    }

    #endregion

    #region Run Operations

    // File name of the interpreter (BazzBasic.csproj AssemblyName). The IDE itself is BazzBasic-IDE.exe.
    private const string InterpreterExeName = "BazzBasic.exe";

    /// <summary>
    /// Finds the interpreter: 1) path set by the user, 2) IDE folder, 3) PATH.
    /// A set path that no longer exists is reported, not silently replaced,
    /// so the user never runs a different interpreter than the one they chose.
    /// </summary>
    private (string? Path, string Source) ResolveInterpreterPath(string? setting)
    {
        if (!string.IsNullOrWhiteSpace(setting))
        {
            return IOFile.Exists(setting)
                ? (setting, "set by you")
                : (null, "the path set by you does not exist");
        }

        var local = IOPath.Combine(Application.StartupPath, InterpreterExeName);
        if (IOFile.Exists(local))
            return (local, "IDE folder");

        var pathVar = Environment.GetEnvironmentVariable("PATH") ?? "";
        foreach (var dir in pathVar.Split(IOPath.PathSeparator, StringSplitOptions.RemoveEmptyEntries))
        {
            try
            {
                var candidate = IOPath.Combine(dir.Trim().Trim('"'), InterpreterExeName);
                if (IOFile.Exists(candidate))
                    return (candidate, "PATH");
            }
            catch (ArgumentException)
            {
                // Broken PATH entry with invalid characters: skip it
            }
        }

        return (null, "not in the IDE folder or in PATH");
    }

    // Returns the interpreter to run, or null after telling the user (and offering to set it)
    private string? GetInterpreterPathOrAsk()
    {
        var (path, _) = ResolveInterpreterPath(_settings.InterpreterPath);
        if (path != null) return path;

        string message = string.IsNullOrWhiteSpace(_settings.InterpreterPath)
            ? $"{InterpreterExeName} was not found in the IDE folder or in PATH."
            : $"The {InterpreterExeName} set in Run → Path to BazzBasic.exe was not found:\n{_settings.InterpreterPath}";

        var answer = MessageBox.Show(this, message + "\n\nSet its location now?", "BazzBasic IDE",
            MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

        if (answer == DialogResult.Yes && ShowInterpreterPathDialog())
            return ResolveInterpreterPath(_settings.InterpreterPath).Path;

        return null;
    }

    // Run → Path to BazzBasic.exe... Returns true if the user pressed OK.
    private bool ShowInterpreterPathDialog()
    {
        using var dialog = new InterpreterPathDialog(_settings.InterpreterPath, ResolveInterpreterPath);
        if (dialog.ShowDialog(this) != DialogResult.OK)
            return false;

        _settings.InterpreterPath = dialog.SelectedPath;
        _settings.Save();
        return true;
    }

    private void CompileAs(string flag)
    {
        if (tabControl.SelectedTab == null) return;

        var tab = _tabs[tabControl.SelectedTab];

        if (tab.FilePath == null || tab.IsModified)
        {
            SaveFile();
            if (tab.FilePath == null) return;
        }

        var exe = GetInterpreterPathOrAsk();
        if (exe == null) return;

        try
        {
            var startInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c \"\"{exe}\" {flag} \"{tab.FilePath}\" && echo Done. & pause\"",
                WorkingDirectory = IOPath.GetDirectoryName(tab.FilePath),
                UseShellExecute = true
            };

            Process.Start(startInfo);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Compile failed: {ex.Message}", "Error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void RunProgram()
    {
        if (tabControl.SelectedTab == null) return;
        
        var tab = _tabs[tabControl.SelectedTab];
        
        // Must save first
        if (tab.FilePath == null || tab.IsModified)
        {
            SaveFile();
            if (tab.FilePath == null) return;
        }

        var exe = GetInterpreterPathOrAsk();
        if (exe == null) return;
        
        try
        {
            // Run in separate console window
            // Window closes on success, stays open on error (|| pause)
            var startInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c \"\"{exe}\" \"{tab.FilePath}\" || pause\"",
                WorkingDirectory = IOPath.GetDirectoryName(tab.FilePath),
                UseShellExecute = true
            };
            
            Process.Start(startInfo);
            statusLabel.Text = "Program started";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to run: {ex.Message}", "Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    #endregion

    #region Tree View

    // DEF FN Name$(params)  -> "Name$(params)"
    private static readonly Regex FnLineRegex = new(
        @"^\s*DEF\s+FN\s+(\w+[$#]?)\s*(\([^)]*\))?",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);

    // [label] alone on its line, optionally followed by a comment.
    // Same rule as the Lexer: anything between [ and ] is the label name, e.g. [sub:box]
    private static readonly Regex LabelLineRegex = new(
        @"^\s*\[([^\]\r\n]+)\]\s*('.*)?$",
        RegexOptions.Compiled);

    private record CodeTreeEntry(bool IsFunction, string Text, int Line);

    // Tag of the empty node between Functions and Labels; it can't be selected
    private const string SpacerTag = "spacer";

    private void CodeTree_BeforeSelect(object? sender, TreeViewCancelEventArgs e)
    {
        if (e.Node?.Tag is SpacerTag) e.Cancel = true;
    }

    private void SetTreeViewVisible(bool visible)
    {
        codeTree.Visible = visible;
        codeTreeSplitter.Visible = visible;
        if (visible)
            RefreshCodeTree();
    }

    // Use the menu state, not codeTree.Visible: Visible reads false until the form
    // itself is shown, which made the startup (session restore) refresh do nothing.
    private bool IsCodeTreeEnabled => treeViewMenuItem.Checked;

    private void ScheduleCodeTreeRefresh()
    {
        if (!IsCodeTreeEnabled) return;
        treeRefreshTimer.Stop();   // restart the countdown on every edit
        treeRefreshTimer.Start();
    }

    private void RefreshCodeTree()
    {
        if (!IsCodeTreeEnabled) return;
        treeRefreshTimer.Stop();

        // Scan the active editor. Scintilla line i == index i after splitting on '\n'.
        var entries = new List<CodeTreeEntry>();
        var editor = ActiveEditor;
        if (editor != null)
        {
            string[] lines = editor.Text.Split('\n');
            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i].TrimEnd('\r');

                var fn = FnLineRegex.Match(line);
                if (fn.Success)
                {
                    entries.Add(new CodeTreeEntry(true, fn.Groups[1].Value + fn.Groups[2].Value, i));
                    continue;
                }

                var label = LabelLineRegex.Match(line);
                if (label.Success)
                    entries.Add(new CodeTreeEntry(false, "[" + label.Groups[1].Value.Trim() + "]", i));
            }
        }

        var fnEntries = entries.Where(x => x.IsFunction).ToList();
        var labelEntries = entries.Where(x => !x.IsFunction).ToList();

        // Same names as before (typical while typing): only update line numbers.
        // Keeps scroll position and selection instead of rebuilding the tree.
        // Root layout: [0] Functions, [1] empty spacer, [2] Labels
        if (codeTree.Nodes.Count == 3 &&
            NodesMatch(codeTree.Nodes[0], fnEntries) &&
            NodesMatch(codeTree.Nodes[2], labelEntries))
        {
            for (int i = 0; i < fnEntries.Count; i++) codeTree.Nodes[0].Nodes[i].Tag = fnEntries[i].Line;
            for (int i = 0; i < labelEntries.Count; i++) codeTree.Nodes[2].Nodes[i].Tag = labelEntries[i].Line;
            return;
        }

        // Remember the top visible node as (root index, child text): root texts contain counts that change
        var oldTop = codeTree.TopNode;
        int topRoot = oldTop == null ? -1 : (oldTop.Parent?.Index ?? oldTop.Index);
        string? topChild = oldTop?.Parent != null ? oldTop.Text : null;

        codeTree.BeginUpdate();
        try
        {
            codeTree.Nodes.Clear();
            var fnRoot = codeTree.Nodes.Add($"Functions ({fnEntries.Count})");
            codeTree.Nodes.Add(new TreeNode("") { Tag = SpacerTag });   // visual gap between the groups
            var labelRoot = codeTree.Nodes.Add($"Labels ({labelEntries.Count})");

            foreach (var e in fnEntries) fnRoot.Nodes.Add(new TreeNode(e.Text) { Tag = e.Line });
            foreach (var e in labelEntries) labelRoot.Nodes.Add(new TreeNode(e.Text) { Tag = e.Line });

            codeTree.ExpandAll();

            // Try to keep the same part of the list visible
            if (topRoot >= 0 && topRoot < codeTree.Nodes.Count)
            {
                var root = codeTree.Nodes[topRoot];
                var top = topChild == null
                    ? root
                    : root.Nodes.Cast<TreeNode>().FirstOrDefault(n => n.Text == topChild) ?? root;
                codeTree.TopNode = top;
            }
        }
        finally
        {
            codeTree.EndUpdate();
        }
    }

    private static bool NodesMatch(TreeNode root, List<CodeTreeEntry> entries)
    {
        if (root.Nodes.Count != entries.Count) return false;
        for (int i = 0; i < entries.Count; i++)
            if (root.Nodes[i].Text != entries[i].Text) return false;
        return true;
    }

    private void CodeTree_NodeMouseClick(object? sender, TreeNodeMouseClickEventArgs e)
    {
        if (e.Node?.Tag is not int line) return;   // root node clicked
        var editor = ActiveEditor;
        if (editor == null || line >= editor.Lines.Count) return;

        editor.Lines[line].Goto();
        editor.FirstVisibleLine = Math.Max(0, line - 2);   // target near the top, not the bottom edge

        // Give focus back to the editor after the TreeView has finished handling the click
        BeginInvoke(() => editor.Focus());
    }

    #endregion

    #region Editor Creation

    // Editor of the currently selected tab, or null if none
    private Scintilla? ActiveEditor =>
        tabControl.SelectedTab != null && _tabs.TryGetValue(tabControl.SelectedTab, out var tab)
            ? tab.Editor
            : null;

    private Scintilla CreateEditor()
    {
        var editor = new Scintilla();
        editor.TextChanged += (s, e) => ScheduleCodeTreeRefresh();
        
        // Line number margin (margin 0)
        editor.Margins[0].Width = 45;
        editor.Margins[0].Type = MarginType.Number;
        
        // Small separator margin (margin 1) - creates gap between line numbers and code
        editor.Margins[1].Width = 8;
        editor.Margins[1].Type = MarginType.Symbol;
        
        // Configure lexer for BASIC-like syntax (also applies theme colors)
        ConfigureBazzBasicSyntax(editor);
        
        // Events
        // Mark the tab that owns THIS editor as modified (not the selected tab:
        // OpenFile sets the text before its tab is selected). Text set before
        // the tab is registered in _tabs (OpenFile, NewFile template) is ignored.
        editor.TextChanged += (s, e) =>
        {
            foreach (var tab in _tabs.Values)
            {
                if (tab.Editor != editor) continue;
                if (!tab.IsModified)
                {
                    tab.IsModified = true;
                    tab.TabPage.Text += " *";
                    tabControl.Invalidate(); // Redraw tabs
                }
                break;
            }
        };
        
        editor.UpdateUI += (s, e) =>
        {
            if (e.Change.HasFlag(UpdateChange.Selection))
            {
                UpdatePositionLabel();
            }
        };
        
        return editor;
    }

    private void UpdatePositionLabel()
    {
        if (tabControl.SelectedTab != null && _tabs.TryGetValue(tabControl.SelectedTab, out var tab))
        {
            var editor = tab.Editor;
            int line = editor.CurrentLine + 1;
            int col = editor.GetColumn(editor.CurrentPosition) + 1;
            positionLabel.Text = $"Ln {line}, Col {col}";
        }
    }

    private void ConfigureBazzBasicSyntax(Scintilla editor)
    {
        // Use VB lexer (closest to BASIC) - Scintilla 5 uses LexerName
        editor.LexerName = "vb";

        // Keyword lists must match the keyword dictionary in src/Lexer/Lexer.cs.
        // When adding a keyword there, add it here too (and to the syntax files in extras/).

        // Control flow, declarations, logic
        editor.SetKeywords(0,
            "if then else elseif endif end while wend for to step next exit " +
            "dim let goto gosub return def fn include rem sleep " +
            "and or not true false on off");

        // Math & string functions, constants
        editor.SetKeywords(1,
            "abs atan atan2 between inbetween ceil cint clamp cos deg distance exp floor int lerp log max min mod pow rad rnd round sgn sin sqr tan " +
            "pi hpi qpi tau euler fasttrig fastsin fastcos fastrad " +
            "asc chr instr invert lcase left len ltrim mid repeat replace right rtrim srand split str trim ucase val fstring " +
            "ticks time rgb");

        // I/O, files, network, arrays, program arguments
        editor.SetKeywords(2,
            "print input cls color locate curpos getconsole inkey keydown waitkey " +
            "fileread filewrite fileappend fileexists filedelete filelist shell " +
            "httpget httppost startlisten getrequest sendresponse stoplisten " +
            "asjson asarray loadjson savejson base64encode base64decode sha256 " +
            "isset haskey delkey delarray join rowcount arrkey args argcount");

        // Graphics, mouse & sound
        editor.SetKeywords(3,
            "screen screenlock fullscreen vsync line circle pset point paint b bf " +
            "loadimage loadshape loadsheet loadfont drawstring " +
            "moveshape drawshape rotateshape scaleshape showshape hideshape removeshape " +
            "mousex mousey mouseleft mouseright mousemiddle mousehide mouseshow " +
            "gamepads padbutton padaxis padname padrumble " +
            "loadsound soundonce soundoncewait soundrepeat soundstop soundstopall");

        ApplyEditorColors(editor);
    }

    // Applies the current theme to one editor. Safe to call again on theme change.
    private void ApplyEditorColors(Scintilla editor)
    {
        var t = _theme;

        // Default style is copied to all styles by StyleClearAll
        editor.StyleResetDefault();
        editor.Styles[Style.Default].Font = "Consolas";
        editor.Styles[Style.Default].Size = 11;
        editor.Styles[Style.Default].BackColor = t.Back;
        editor.Styles[Style.Default].ForeColor = t.Fore;
        editor.StyleClearAll();

        // VB lexer style constants (from Scintilla documentation)
        const int SCE_B_DEFAULT = 0;
        const int SCE_B_COMMENT = 1;
        const int SCE_B_NUMBER = 2;
        const int SCE_B_KEYWORD = 3;
        const int SCE_B_STRING = 4;
        const int SCE_B_OPERATOR = 6;
        const int SCE_B_IDENTIFIER = 7;
        const int SCE_B_KEYWORD2 = 8;
        const int SCE_B_KEYWORD3 = 9;
        const int SCE_B_KEYWORD4 = 10;

        if (syntaxColoringMenuItem.Checked)
        {
            editor.Styles[SCE_B_DEFAULT].ForeColor = t.Fore;
            editor.Styles[SCE_B_COMMENT].ForeColor = t.Comment;
            editor.Styles[SCE_B_NUMBER].ForeColor = t.Number;
            editor.Styles[SCE_B_KEYWORD].ForeColor = t.Keyword;
            editor.Styles[SCE_B_KEYWORD].Bold = true;
            editor.Styles[SCE_B_STRING].ForeColor = t.String;
            editor.Styles[SCE_B_OPERATOR].ForeColor = t.Operator;
            editor.Styles[SCE_B_IDENTIFIER].ForeColor = t.Fore;
            editor.Styles[SCE_B_KEYWORD2].ForeColor = t.Keyword2; // Functions
            editor.Styles[SCE_B_KEYWORD3].ForeColor = t.Keyword3; // I/O, files, arrays
            editor.Styles[SCE_B_KEYWORD4].ForeColor = t.Keyword4; // Graphics & sound
        }
        else
        {
            // Syntax coloring off: the lexer keeps running, but every lexer style
            // renders as plain text in the theme's foreground colour.
            // Gutter, caret and selection keep their colours (they are editor chrome).
            foreach (int style in new[] { SCE_B_DEFAULT, SCE_B_COMMENT, SCE_B_NUMBER,
                                          SCE_B_KEYWORD, SCE_B_STRING, SCE_B_OPERATOR,
                                          SCE_B_IDENTIFIER, SCE_B_KEYWORD2, SCE_B_KEYWORD3, SCE_B_KEYWORD4 })
            {
                editor.Styles[style].ForeColor = t.Fore;
                editor.Styles[style].Bold = false;
            }
        }

        // Line numbers: a Number margin takes its background from Style.LineNumber,
        // Margins[n].BackColor only affects Symbol margins (that is why setting it on margin 0 did nothing).
        editor.Styles[Style.LineNumber].BackColor = t.Gutter;
        editor.Styles[Style.LineNumber].ForeColor = t.GutterFore;
        editor.Margins[1].BackColor = t.Gutter;

        editor.CaretForeColor = t.Caret;
        editor.SelectionBackColor = t.Selection;
    }

    // Switch theme for the whole IDE and remember the choice
    private void SetTheme(EditorTheme theme)
    {
        _theme = theme;
        _settings.Theme = theme.Name;
        _settings.Save();

        foreach (var tab in _tabs.Values)
            ApplyEditorColors(tab.Editor);

        ApplyChromeTheme();
    }

    // Menus, status bar, tabs and title bar
    private void ApplyChromeTheme()
    {
        var t = _theme;

        if (t.IsDark)
        {
            var renderer = new ThemeRenderer(t);
            menuStrip.Renderer = renderer;
            statusStrip.Renderer = renderer;
        }
        else
        {
            menuStrip.RenderMode = ToolStripRenderMode.ManagerRenderMode;
            statusStrip.RenderMode = ToolStripRenderMode.ManagerRenderMode;
        }

        menuStrip.BackColor = t.ChromeBack;
        menuStrip.ForeColor = t.ChromeFore;
        statusStrip.BackColor = t.ChromeBack;
        statusStrip.ForeColor = t.ChromeFore;
        statusLabel.ForeColor = t.ChromeFore;
        positionLabel.ForeColor = t.ChromeFore;
        this.BackColor = t.ChromeBack;

        lightModeMenuItem.Checked = !t.IsDark;
        darkModeMenuItem.Checked = t.IsDark;

        tabControl.Invalidate();

        // Tree View uses the editor colours so it looks like part of the editor area
        codeTree.BackColor = t.Back;
        codeTree.ForeColor = t.Fore;
        codeTree.LineColor = t.GutterFore;
        codeTreeSplitter.BackColor = t.ChromeBack;

        if (IsHandleCreated)
            TitleBar.SetDark(Handle, t.IsDark);
    }

    protected override void OnHandleCreated(EventArgs e)
    {
        base.OnHandleCreated(e);
        TitleBar.SetDark(Handle, _theme.IsDark);
    }

    #endregion

    #region Event Handlers

    protected override void OnKeyDown(KeyEventArgs e)
    {
        base.OnKeyDown(e);
        
        if (e.Control)
        {
            switch (e.KeyCode)
            {
                case Keys.N:
                    NewFile();
                    e.Handled = true;
                    break;
                case Keys.O:
                    OpenFile();
                    e.Handled = true;
                    break;
                case Keys.S:
                    SaveFile(e.Shift);
                    e.Handled = true;
                    break;
                case Keys.W:
                    CloseTab();
                    e.Handled = true;
                    break;
                case Keys.F:
                    ShowFindDialog();
                    e.Handled = true;
                    break;
                case Keys.H:
                    ShowReplaceDialog();
                    e.Handled = true;
                    break;
            }
        }
        else if (e.KeyCode == Keys.F5)
        {
            RunProgram();
            e.Handled = true;
        }
        else if (e.KeyCode == Keys.F3)
        {
            // Find next with last search term
            if (!string.IsNullOrEmpty(_lastSearchText))
            {
                FindReplaceDialog_FindNext(this, new FindEventArgs(_lastSearchText, false));
            }
            e.Handled = true;
        }
    }

    #endregion
}

// Helper class to track tab state
public class EditorTab
{
    public TabPage TabPage { get; }
    public Scintilla Editor { get; }
    public string? FilePath { get; set; }
    public bool IsModified { get; set; }

    public EditorTab(TabPage tabPage, Scintilla editor, string? filePath)
    {
        TabPage = tabPage;
        Editor = editor;
        FilePath = filePath;
        IsModified = false;
    }
}

// Find/Replace event args
public class FindEventArgs : EventArgs
{
    public string SearchText { get; }
    public bool MatchCase { get; }

    public FindEventArgs(string searchText, bool matchCase)
    {
        SearchText = searchText;
        MatchCase = matchCase;
    }
}

public class ReplaceEventArgs : FindEventArgs
{
    public string ReplaceText { get; }

    public ReplaceEventArgs(string searchText, string replaceText, bool matchCase)
        : base(searchText, matchCase)
    {
        ReplaceText = replaceText;
    }
}
