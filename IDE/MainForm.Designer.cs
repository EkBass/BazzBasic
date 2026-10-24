/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\MainForm.Designer.cs
 IDE design code for main form

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

#nullable enable

using System.Drawing.Text;

namespace BazzBasic.IDE;

partial class MainForm
{
    private System.ComponentModel.IContainer? components = null;
    
    private MenuStrip           menuStrip = null!;
    private ToolStripMenuItem   fileMenu = null!;
    private ToolStripMenuItem   newMenuItem = null!;
    private ToolStripMenuItem   openMenuItem = null!;
    private ToolStripMenuItem   saveMenuItem = null!;
    private ToolStripMenuItem   saveAsMenuItem = null!;
    private ToolStripMenuItem   saveAllMenuItem = null!;
    private ToolStripMenuItem   closeMenuItem = null!;
    private ToolStripMenuItem   closeAllMenuItem = null!;
    private ToolStripMenuItem   restoreSessionMenuItem = null!;
    private ToolStripMenuItem   printTabItem = null!;
    private ToolStripMenuItem   exitMenuItem = null!;

    // Tree View
    private ToolStripMenuItem   treeViewMenuItem = null!;
    private TreeView            codeTree = null!;
    private Splitter            codeTreeSplitter = null!;
    private System.Windows.Forms.Timer treeRefreshTimer = null!;

    // Edit
    private ToolStripMenuItem   editMenu = null!;
    private ToolStripMenuItem   undoMenuItem = null!;
    private ToolStripMenuItem   redoMenuItem = null!;
    private ToolStripMenuItem   cutMenuItem = null!;
    private ToolStripMenuItem   copyMenuItem = null!;
    private ToolStripMenuItem   pasteMenuItem = null!;
    private ToolStripMenuItem   selectAllMenuItem = null!;
    private ToolStripMenuItem   addCommentMenuItem = null!;
    private ToolStripMenuItem   removeCommentMenuItem = null!;

    private ToolStripMenuItem   searchMenu = null!;
    private ToolStripMenuItem   searchMenuItem = null!;
    private ToolStripMenuItem   replaceMenuItem = null!;

    // View
    private ToolStripMenuItem   viewMenu = null!;
    private ToolStripMenuItem   lightModeMenuItem = null!;
    private ToolStripMenuItem   darkModeMenuItem = null!;
    private ToolStripMenuItem   syntaxColoringMenuItem = null!;
    private ToolStripMenuItem   takeScreenshotItem = null!;
    private ToolStripMenuItem   openCmdItem = null!;
    private ToolStripMenuItem   openFileBrowser = null!;
    private ToolStripMenuItem   zoomIn = null!;
    private ToolStripMenuItem   zoomOut = null!;

    // Run
    private ToolStripMenuItem   runMenu = null!;
    private ToolStripMenuItem   runMenuItem = null!;
    // Create executable
    private ToolStripMenuItem   createExeMenuItem = null!;
    // Create lib
    private ToolStripMenuItem   CreateLibMenuItem = null!;
    // Path to BazzBasic.exe used by Run and Compile
    private ToolStripMenuItem   interpreterPathMenuItem = null!;

    private ToolStripMenuItem   homeMenuItem = null!;
    private ToolStripMenuItem   helpMenu = null!;
    private ToolStripMenuItem   aboutMenuItem = null!;
    private ToolStripMenuItem   manualMenuItem = null!;
    private ToolStripMenuItem   guideMenuItem = null!;
    private ToolStripMenuItem   rosettaMenuItem = null!;

    private TabControl          tabControl = null!;
    
    private StatusStrip statusStrip             = null!;
    private ToolStripStatusLabel statusLabel    = null!;
    private ToolStripStatusLabel positionLabel  = null!;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    private void BuildUi()
    {
        this.components = new System.ComponentModel.Container();
        
        // Main Form
        this.Text = $"{BazzBasic.AppInfo.Name} IDE v{BazzBasic.AppInfo.Version}";
        this.Size = new Size(1200, 800);
        this.StartPosition = FormStartPosition.CenterScreen;
        this.MinimumSize = new Size(800, 600);
        
        // Menu Strip
        menuStrip = new MenuStrip();
        
        // File Menu
        fileMenu = new ToolStripMenuItem("&File");
        newMenuItem = new ToolStripMenuItem("&New", null, (s, e) => NewFile(), Keys.Control | Keys.N);
        openMenuItem = new ToolStripMenuItem("&Open...", null, (s, e) => OpenFile(), Keys.Control | Keys.O);
        saveMenuItem = new ToolStripMenuItem("&Save", null, (s, e) => SaveFile(), Keys.Control | Keys.S);
        saveAsMenuItem = new ToolStripMenuItem("Save &As...", null, (s, e) => SaveFile(true), Keys.Control | Keys.Shift | Keys.S);
        saveAllMenuItem = new ToolStripMenuItem("Save A&ll", null, (s, e) => SaveAll());
        closeMenuItem = new ToolStripMenuItem("&Close Tab", null, (s, e) => CloseTab(), Keys.Control | Keys.W);
        closeAllMenuItem = new ToolStripMenuItem("Clos&e All", null, (s, e) => CloseAll());
        restoreSessionMenuItem = new ToolStripMenuItem("&Restore Session on Startup") { CheckOnClick = true };
        printTabItem = new ToolStripMenuItem("&Print", null, (s, e) => PrintTab(), Keys.Control | Keys.P);
        exitMenuItem = new ToolStripMenuItem("E&xit", null, (s, e) => Close(), Keys.Alt | Keys.F4);
        
        fileMenu.DropDownItems.AddRange(new ToolStripItem[] {
            newMenuItem, openMenuItem, new ToolStripSeparator(),
            saveMenuItem, saveAsMenuItem, saveAllMenuItem, new ToolStripSeparator(),
            closeMenuItem, closeAllMenuItem, new ToolStripSeparator(),
            restoreSessionMenuItem, new ToolStripSeparator(),
            printTabItem, new ToolStripSeparator(),
            exitMenuItem
        });
        
        // Edit Menu
        editMenu = new ToolStripMenuItem("&Edit");
        undoMenuItem  = new ToolStripMenuItem("&Undo",  null, (s, e) => ActiveEditor?.Undo(),  Keys.Control | Keys.Z);
        redoMenuItem  = new ToolStripMenuItem("&Redo",  null, (s, e) => ActiveEditor?.Redo(),  Keys.Control | Keys.Y);
        cutMenuItem   = new ToolStripMenuItem("Cu&t",   null, (s, e) => ActiveEditor?.Cut(),   Keys.Control | Keys.X);
        copyMenuItem  = new ToolStripMenuItem("&Copy",  null, (s, e) => ActiveEditor?.Copy(),  Keys.Control | Keys.C);
        pasteMenuItem = new ToolStripMenuItem("&Paste", null, (s, e) => ActiveEditor?.Paste(), Keys.Control | Keys.V);

        // 
        selectAllMenuItem = new ToolStripMenuItem("Select &All", null, (s, e) => ActiveEditor?.SelectAll(), Keys.Control | Keys.A);
        addCommentMenuItem = new ToolStripMenuItem("&Comment Selection", null, (s, e) => AddComment(), Keys.Control | Keys.Q);
        removeCommentMenuItem = new ToolStripMenuItem("&Uncomment Selection", null, (s, e) => RemoveComment(), Keys.Control | Keys.Shift | Keys.Q);

        editMenu.DropDownItems.AddRange(new ToolStripItem[] {
            undoMenuItem, redoMenuItem, new ToolStripSeparator(),
            cutMenuItem, copyMenuItem, pasteMenuItem, new ToolStripSeparator(),
            selectAllMenuItem, new ToolStripSeparator(), addCommentMenuItem, removeCommentMenuItem
        });

        // Grey out items that can't be used right now (only while the menu is open)
        editMenu.DropDownOpening += (s, e) =>
        {
            var ed = ActiveEditor;
            bool hasSel = ed != null && ed.SelectionStart != ed.SelectionEnd;
            undoMenuItem.Enabled  = ed?.CanUndo ?? false;
            redoMenuItem.Enabled  = ed?.CanRedo ?? false;
            cutMenuItem.Enabled   = hasSel;
            copyMenuItem.Enabled  = hasSel;
            pasteMenuItem.Enabled = ed?.CanPaste ?? false;
            selectAllMenuItem.Enabled = ed != null;
        };

        // Re-enable on close so keyboard shortcuts keep working
        editMenu.DropDownClosed += (s, e) =>
        {
            foreach (ToolStripItem item in editMenu.DropDownItems)
                item.Enabled = true;
        };

        // Search Menu
        searchMenu = new ToolStripMenuItem("&Search");
        searchMenuItem = new ToolStripMenuItem("&Find...", null, (s, e) => ShowFindDialog(), Keys.Control | Keys.F);
        replaceMenuItem = new ToolStripMenuItem("&Replace...", null, (s, e) => ShowReplaceDialog(), Keys.Control | Keys.H);
        
        searchMenu.DropDownItems.AddRange(new ToolStripItem[] {
            searchMenuItem, replaceMenuItem
        });

        // View Menu
        viewMenu = new ToolStripMenuItem("&View");
        treeViewMenuItem = new ToolStripMenuItem("T&ree View") { CheckOnClick = true };
        openCmdItem = new ToolStripMenuItem("Open &Console", null, (s, e) => OpenCommandPrompt());
        openFileBrowser = new ToolStripMenuItem("Open File &Browser", null, (s, e) => OpenFileBrowser());
        lightModeMenuItem = new ToolStripMenuItem("&Light Mode", null, (s, e) => SetTheme(EditorTheme.Light));
        darkModeMenuItem = new ToolStripMenuItem("&Dark Mode (experimental)", null, (s, e) => SetTheme(EditorTheme.Dark));
        // On/off for editor syntax colors, remembered in ide.json (handler wired in the MainForm constructor)
        syntaxColoringMenuItem = new ToolStripMenuItem("Synta&x Coloring") { CheckOnClick = true };
        takeScreenshotItem = new ToolStripMenuItem("&Take Screenshot to Clipboard", null, (s, e) => TakeScreenshot());
        zoomIn = new ToolStripMenuItem("Zoom &In", null, (s, e) => ActiveEditor?.ZoomIn(), Keys.Control | Keys.Add);

        // Tested only with normal desktop keyboard. On laptops, the + and - keys may not work as expected, so this is a workaround.

        zoomIn.ShortcutKeyDisplayString = "Ctrl++";
        zoomOut = new ToolStripMenuItem("Zoom &Out", null, (s, e) => ActiveEditor?.ZoomOut(), Keys.Control | Keys.Subtract);
        zoomOut.ShortcutKeyDisplayString = "Ctrl+-";
        

        viewMenu.DropDownItems.AddRange(new ToolStripItem[] {
            treeViewMenuItem,
            new ToolStripSeparator(),
            openCmdItem, openFileBrowser,
            new ToolStripSeparator(),
            lightModeMenuItem, darkModeMenuItem, syntaxColoringMenuItem,
            new ToolStripSeparator(),
            takeScreenshotItem,
            new ToolStripSeparator(),
            zoomIn, zoomOut 
        });

        // Run Menu
        runMenu = new ToolStripMenuItem("&Run");
        runMenuItem = new ToolStripMenuItem("&Run Program", null, (s, e) => RunProgram(), Keys.F5);
        createExeMenuItem = new ToolStripMenuItem("Compile as &Exe", null, (s, e) => CompileAs("-exe"));
        CreateLibMenuItem = new ToolStripMenuItem("Compile as &Library (.bb)", null, (s, e) => CompileAs("-lib"));
        interpreterPathMenuItem = new ToolStripMenuItem("&Path to BazzBasic.exe...", null, (s, e) => ShowInterpreterPathDialog());
        runMenu.DropDownItems.AddRange(new ToolStripItem[] {
            runMenuItem, new ToolStripSeparator(),
            createExeMenuItem, CreateLibMenuItem, new ToolStripSeparator(),
            interpreterPathMenuItem
        });

        // Help Menu
        helpMenu = new ToolStripMenuItem("&Help");
        aboutMenuItem = new ToolStripMenuItem("&About", null, (s, e) => ShowAbout());
        helpMenu.DropDownItems.Add(aboutMenuItem);

        // Link to BazzBasic homepage
        // cmd: start https://ekbass.github.io/BazzBasic/
        homeMenuItem = new ToolStripMenuItem("&Homepage", null, (s, e) => System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
        {
            FileName = "https://ekbass.github.io/BazzBasic/",
            UseShellExecute = true
        }));
        helpMenu.DropDownItems.Add(homeMenuItem);

        // Link to online manual
        // cmd: start https://ekbass.github.io/BazzBasic/manual/#/
        manualMenuItem = new ToolStripMenuItem("&Online Manual", null, (s, e) => System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
        {
            FileName = "https://ekbass.github.io/BazzBasic/manual/#/",
            UseShellExecute = true
        }));
        helpMenu.DropDownItems.Add(manualMenuItem);

        // Link to beginner's guide
        // cmd: start https://github.com/EkBass/BazzBasic-Beginners-Guide/releases
        guideMenuItem = new ToolStripMenuItem("&Beginner's Guide", null, (s, e) => System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
        {
            FileName = "https://github.com/EkBass/BazzBasic-Beginners-Guide/releases",
            UseShellExecute = true
        }));
        helpMenu.DropDownItems.Add(guideMenuItem);

        // Link to Rosetta Code
        // cmd: start https://rosettacode.org/wiki/Category:BazzBasic
        rosettaMenuItem = new ToolStripMenuItem("&Rosetta Code", null, (s, e) => System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
        {
            FileName = "https://rosettacode.org/wiki/Category:BazzBasic",
            UseShellExecute = true
        }));
        helpMenu.DropDownItems.Add(rosettaMenuItem);

        // Check for updates
        var checkUpdateMenuItem = new ToolStripMenuItem("&Check for Updates...", null, async (s, e) =>
        {
            string result = await BazzBasic.UpdateChecker.CheckAsync();
            MessageBox.Show(result, "BazzBasic Update Check", MessageBoxButtons.OK, MessageBoxIcon.Information);
        });
        helpMenu.DropDownItems.Add(checkUpdateMenuItem);


        menuStrip.Items.AddRange(new ToolStripItem[] { fileMenu, editMenu, searchMenu, viewMenu, runMenu, helpMenu });
        
        // Tab Control for editor tabs - with close button support
        tabControl = new TabControl
        {
            Dock = DockStyle.Fill,
            DrawMode = TabDrawMode.OwnerDrawFixed,
            Padding = new Point(12, 4)  // Extra space for close button
        };
        
        tabControl.DrawItem += TabControl_DrawItem;
        tabControl.MouseClick += TabControl_MouseClick;
        tabControl.SelectedIndexChanged += (s, e) =>
        {
            if (tabControl.SelectedTab != null && _tabs.TryGetValue(tabControl.SelectedTab, out var tab))
            {
                tab.Editor.Focus();
                UpdatePositionLabel();
            }
            RefreshCodeTree();
        };

        // Tree View: DEF FN functions and [labels] of the active tab
        codeTree = new TreeView
        {
            Dock = DockStyle.Left,
            Width = 200,
            Visible = false,
            HideSelection = false,
            FullRowSelect = true,
            BorderStyle = BorderStyle.None
        };
        // NodeMouseClick (not AfterSelect) so clicking the already selected node jumps again
        codeTree.NodeMouseClick += CodeTree_NodeMouseClick;
        codeTree.BeforeSelect += CodeTree_BeforeSelect;

        // MinSize: tree can't be dragged narrower than 80 px. MinExtra: editor keeps at least 200 px.
        codeTreeSplitter = new Splitter { Dock = DockStyle.Left, Width = 4, Visible = false, MinSize = 80, MinExtra = 200 };

        // Debounce: re-parse 500 ms after the last edit, not on every key press
        treeRefreshTimer = new System.Windows.Forms.Timer { Interval = 500 };
        treeRefreshTimer.Tick += (s, e) =>
        {
            treeRefreshTimer.Stop();
            RefreshCodeTree();
        };
        
        // Status Strip
        statusStrip = new StatusStrip();
        statusLabel = new ToolStripStatusLabel("Ready") { Spring = true, TextAlign = ContentAlignment.MiddleLeft };
        positionLabel = new ToolStripStatusLabel("Ln 1, Col 1");
        statusStrip.Items.AddRange(new ToolStripItem[] { statusLabel, positionLabel });
        
        // Layout
        this.MainMenuStrip = menuStrip;
        // Order matters: the last added control is docked first.
        // Result: tree at the far left, splitter next to it, tabs fill the rest.
        this.Controls.Add(tabControl);
        this.Controls.Add(codeTreeSplitter);
        this.Controls.Add(codeTree);
        this.Controls.Add(menuStrip);
        this.Controls.Add(statusStrip);
    }

    private void TabControl_DrawItem(object? sender, DrawItemEventArgs e)
    {
        var tabPage = tabControl.TabPages[e.Index];
        var tabRect = tabControl.GetTabRect(e.Index);
        
        // Draw background
        bool isSelected = tabControl.SelectedIndex == e.Index;
        using var bgBrush = new SolidBrush(isSelected ? _theme.TabActive : _theme.TabInactive);
        e.Graphics.FillRectangle(bgBrush, tabRect);
        
        // Draw tab text
        var textRect = new Rectangle(tabRect.X + 4, tabRect.Y + 4, tabRect.Width - 24, tabRect.Height - 4);
        TextRenderer.DrawText(e.Graphics, tabPage.Text, tabControl.Font, textRect, 
            _theme.ChromeFore, TextFormatFlags.Left | TextFormatFlags.VerticalCenter);
        
        // Draw close button (X)
        var closeRect = GetCloseButtonRect(tabRect);
        using var closeFont = new Font("Arial", 8, FontStyle.Bold);
        TextRenderer.DrawText(e.Graphics, "×", closeFont, closeRect, 
            _theme.TabClose, TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter);
    }

    private Rectangle GetCloseButtonRect(Rectangle tabRect)
    {
        return new Rectangle(tabRect.Right - 18, tabRect.Top + 4, 14, tabRect.Height - 8);
    }

    private void TabControl_MouseClick(object? sender, MouseEventArgs e)
    {
        for (int i = 0; i < tabControl.TabPages.Count; i++)
        {
            var tabRect = tabControl.GetTabRect(i);
            var closeRect = GetCloseButtonRect(tabRect);
            
            if (closeRect.Contains(e.Location))
            {
                var tabToClose = tabControl.TabPages[i];
                tabControl.SelectedTab = tabToClose;
                CloseTab();
                return;
            }
        }
    }

    private void ShowAbout()
    {
        MessageBox.Show(
            "BazzBasic IDE\n\n" +
            "Development environment for BazzBasic.\n\n" +
            "Copyright © 2026 krisu.virtanen@gmail.com\n" +
            "https://ekbass.github.io/BazzBasic\n" +
            "MIT License",
            "About BazzBasic IDE",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information);
    }

    // now work damn you piece of shit
    private void TakeScreenshot()
    {
        var bounds = this.Bounds;
        using var bmp = new Bitmap(bounds.Width, bounds.Height);
        using (var g = System.Drawing.Graphics.FromImage(bmp))
        {
            g.CopyFromScreen(bounds.Location, Point.Empty, bounds.Size);
        }
        Clipboard.SetImage(bmp);
    }

    // Folder of the file in the active tab. For an unsaved (Untitled) tab,
    // or if that folder no longer exists, the folder of the IDE executable.
    private string GetWorkingFolder()
    {
        if (tabControl.SelectedTab != null &&
            _tabs.TryGetValue(tabControl.SelectedTab, out var tab) &&
            tab.FilePath != null)
        {
            var dir = System.IO.Path.GetDirectoryName(tab.FilePath);
            if (!string.IsNullOrEmpty(dir) && System.IO.Directory.Exists(dir))
                return dir;
        }
        return Application.StartupPath;
    }

    private void OpenCommandPrompt()
    {
        System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
        {
            FileName = "cmd.exe",
            WorkingDirectory = GetWorkingFolder(),
            UseShellExecute = true
        });
    }

    private void OpenFileBrowser()
    {
        System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
        {
            FileName = GetWorkingFolder(),
            UseShellExecute = true
        });
    }

    private void AddComment()
    {
        var editor = ActiveEditor;
        if (editor == null) return;

        int selectionStart = editor.SelectionStart;
        int selectionEnd = editor.SelectionEnd;

        // Determine first and last selected lines
        int firstLine = editor.LineFromPosition(selectionStart);
        int lastLine = editor.LineFromPosition(selectionEnd);

        // If selection ends at the beginning of a line, ignore that line, because it means the selection does not include any text on that line.
        if (selectionEnd > selectionStart &&
            editor.GetColumn(selectionEnd) == 0)
        {
            lastLine--;
        }

        // No text selection: comment the current line.
        if (lastLine < firstLine)
            lastLine = firstLine;

        // Keep the entire operation as one Undo action
        editor.BeginUndoAction();

        try
        {
            // Work backwards so inserting text does not
            // change the positions of the remaining lines
            for (int i = lastLine; i >= firstLine; i--)
            {
                int position = editor.Lines[i].Position;
                editor.InsertText(position, "' ");
            }
        }
        finally
        {
            editor.EndUndoAction();
        }
    }

    private void RemoveComment()
    {
        var editor = ActiveEditor;
        if (editor == null) return;

        int selectionStart = editor.SelectionStart;
        int selectionEnd = editor.SelectionEnd;

        int firstLine = editor.LineFromPosition(selectionStart);
        int lastLine = editor.LineFromPosition(selectionEnd);

        // Same rule as AddComment: a selection ending at column 0 does not include that line
        if (selectionEnd > selectionStart && editor.GetColumn(selectionEnd) == 0)
            lastLine--;

        if (lastLine < firstLine)
            lastLine = firstLine;

        editor.BeginUndoAction();
        try
        {
            for (int i = lastLine; i >= firstLine; i--)
            {
                var line = editor.Lines[i];
                string text = line.Text;

                // Skip indentation
                int indent = 0;
                while (indent < text.Length && (text[indent] == ' ' || text[indent] == '\t'))
                    indent++;

                if (indent >= text.Length || text[indent] != '\'')
                    continue; // not a comment line

                // "' " -> remove both, "'X" -> remove only the mark
                int length = (indent + 1 < text.Length && text[indent + 1] == ' ') ? 2 : 1;

                editor.DeleteRange(line.Position + indent, length);
            }
        }
        finally
        {
            editor.EndUndoAction();
        }
    }

    // Keys.Add and Keys.Subtract respond only to the +/- keys on the numeric keypad.This causes issues with laptops.
    // This override should address that issue.
    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        switch (keyData)
        {
            case Keys.Control | Keys.Oemplus:
                zoomIn.PerformClick();
                return true;
            case Keys.Control | Keys.OemMinus:
                zoomOut.PerformClick();
                return true;
        }
        return base.ProcessCmdKey(ref msg, keyData);
    }

    private void SaveAll()
    {
        var current = tabControl.SelectedTab;

        foreach (var page in tabControl.TabPages.Cast<TabPage>().ToList())
        {
            if (!_tabs[page].IsModified) continue;
            tabControl.SelectedTab = page;   // user sees which file a Save As dialog is for
            SaveFile();                      // cancelling one dialog skips that file only
        }

        if (current != null && tabControl.TabPages.Contains(current))
            tabControl.SelectedTab = current;
    }

    private void CloseAll()
    {
        // Snapshot: CloseTab() creates a new Untitled tab when the last one closes,
        // so looping until Count == 0 would never end.
        foreach (var page in tabControl.TabPages.Cast<TabPage>().ToList())
        {
            tabControl.SelectedTab = page;
            if (!CloseTab()) return;   // Cancel stops the whole operation
        }
    }
}
