/*
 * BazzBasic IDE - Main Form
 * MIT License - Copyright (c) 2025 Kristian Virtanen
 */

using ScintillaNET;
using System.Diagnostics;
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

    public MainForm()
    {
        InitializeComponent();
        
        // Load icon
        var iconPath = IOPath.Combine(Application.StartupPath, "icon.png");
        if (IOFile.Exists(iconPath))
        {
            using var bitmap = new Bitmap(iconPath);
            this.Icon = Icon.FromHandle(bitmap.GetHicon());
        }
        
        // Create initial empty tab
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

    private void SaveFile(bool saveAs = false)
    {
        if (tabControl.SelectedTab == null) return;
        
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
            
            if (result != DialogResult.OK) return;
            path = dialog.FileName;
        }
        
        IOFile.WriteAllText(path, tab.Editor.Text);
        tab.FilePath = path;
        tab.IsModified = false;
        tabControl.SelectedTab.Text = IOPath.GetFileName(path);
        tabControl.Invalidate(); // Redraw tabs
    }

    private void CloseTab()
    {
        if (tabControl.SelectedTab == null) return;
        
        var tab = _tabs[tabControl.SelectedTab];
        
        if (tab.IsModified)
        {
            var result = MessageBox.Show(
                $"Save changes to {tabControl.SelectedTab.Text.TrimEnd(' ', '*')}?",
                "BazzBasic IDE",
                MessageBoxButtons.YesNoCancel,
                MessageBoxIcon.Question);
            
            if (result == DialogResult.Cancel) return;
            if (result == DialogResult.Yes) SaveFile();
        }
        
        _tabs.Remove(tabControl.SelectedTab);
        tabControl.TabPages.Remove(tabControl.SelectedTab);
        
        if (tabControl.TabPages.Count == 0)
        {
            NewFile();
        }
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
        
        try
        {
            // Run in separate console window that stays open
            var startInfo = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/k \"\"{Application.ExecutablePath}\" \"{tab.FilePath}\"\"",
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

    #region Editor Creation

    private Scintilla CreateEditor()
    {
        var editor = new Scintilla();
        
        // Basic settings
        editor.Margins[0].Width = 40; // Line numbers
        editor.Margins[0].Type = MarginType.Number;
        
        // Configure lexer for BASIC-like syntax
        ConfigureBazzBasicSyntax(editor);
        
        // Events
        editor.TextChanged += (s, e) =>
        {
            if (tabControl.SelectedTab != null && _tabs.TryGetValue(tabControl.SelectedTab, out var tab))
            {
                if (!tab.IsModified)
                {
                    tab.IsModified = true;
                    tabControl.SelectedTab.Text = tabControl.SelectedTab.Text + " *";
                    tabControl.Invalidate(); // Redraw tabs
                }
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
        // Reset styles
        editor.StyleResetDefault();
        editor.Styles[Style.Default].Font = "Consolas";
        editor.Styles[Style.Default].Size = 11;
        editor.StyleClearAll();
        
        // Use VB lexer (closest to BASIC) - Scintilla 5 uses LexerName
        editor.LexerName = "vb";
        
        // VB style constants (from Scintilla documentation)
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
        
        // Colors
        editor.Styles[SCE_B_DEFAULT].ForeColor = Color.Black;
        editor.Styles[SCE_B_COMMENT].ForeColor = Color.FromArgb(0, 128, 0); // Green
        editor.Styles[SCE_B_NUMBER].ForeColor = Color.FromArgb(255, 128, 0); // Orange
        editor.Styles[SCE_B_KEYWORD].ForeColor = Color.Blue;
        editor.Styles[SCE_B_KEYWORD].Bold = true;
        editor.Styles[SCE_B_STRING].ForeColor = Color.FromArgb(163, 21, 21); // Dark red
        editor.Styles[SCE_B_OPERATOR].ForeColor = Color.Black;
        editor.Styles[SCE_B_IDENTIFIER].ForeColor = Color.Black;
        editor.Styles[SCE_B_KEYWORD2].ForeColor = Color.DarkCyan; // Functions
        editor.Styles[SCE_B_KEYWORD3].ForeColor = Color.DarkMagenta; // Built-ins
        editor.Styles[SCE_B_KEYWORD4].ForeColor = Color.Teal; // Graphics
        
        // BazzBasic keywords
        editor.SetKeywords(0, 
            "if then else elseif endif while wend for to step next " +
            "dim let goto gosub return end def fn " +
            "print input cls color locate screen " +
            "and or not mod rem");
        
        // Built-in functions
        editor.SetKeywords(1,
            "sin cos tan atn sqr abs int sgn log exp rnd " +
            "len left mid right instr chr asc val str " +
            "ucase lcase trim ltrim rtrim replace " +
            "timer sleep wait inkey");
        
        // I/O and arrays
        editor.SetKeywords(2,
            "open close read write append eof " +
            "ubound lbound haskey delkey");
        
        // Graphics and sound
        editor.SetKeywords(3,
            "line circle pset point paint box " +
            "loadimage drawimage freeimage " +
            "loadsound soundonce soundrepeat stopsound freesound " +
            "getmouse mousebutton keypressed flip");
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
