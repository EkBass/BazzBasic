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

namespace BazzBasic.IDE;

partial class MainForm
{
    private System.ComponentModel.IContainer? components = null;
    
    private MenuStrip menuStrip = null!;
    private ToolStripMenuItem fileMenu = null!;
    private ToolStripMenuItem newMenuItem = null!;
    private ToolStripMenuItem openMenuItem = null!;
    private ToolStripMenuItem saveMenuItem = null!;
    private ToolStripMenuItem saveAsMenuItem = null!;
    private ToolStripMenuItem closeMenuItem = null!;
    private ToolStripMenuItem exitMenuItem = null!;

    // Edit
    private ToolStripMenuItem editMenu = null!;
    private ToolStripMenuItem undoMenuItem = null!;
    private ToolStripMenuItem redoMenuItem = null!;
    private ToolStripMenuItem cutMenuItem = null!;
    private ToolStripMenuItem copyMenuItem = null!;
    private ToolStripMenuItem pasteMenuItem = null!;
    private ToolStripMenuItem selectAllMenuItem = null!;
    
    private ToolStripMenuItem searchMenu = null!;
    private ToolStripMenuItem searchMenuItem = null!;
    private ToolStripMenuItem replaceMenuItem = null!;

    // View
    private ToolStripMenuItem viewMenu = null!;
    private ToolStripMenuItem lightModeMenuItem = null!;
    private ToolStripMenuItem darkModeMenuItem = null!;
    private ToolStripMenuItem takeScreenshotItem = null;

    // Run
    private ToolStripMenuItem runMenu = null!;
    private ToolStripMenuItem runMenuItem = null!;
    // Create executable
    private ToolStripMenuItem createExeMenuItem = null!;
    // Create lib
    private ToolStripMenuItem CreateLibMenuItem = null!;

    private ToolStripMenuItem helpMenu = null!;
    private ToolStripMenuItem aboutMenuItem = null!;
    private ToolStripMenuItem manualMenuItem = null!;
    private ToolStripMenuItem guideMenuItem = null!;
    private ToolStripMenuItem rosettaMenuItem = null!;

    private TabControl tabControl = null!;
    
    private StatusStrip statusStrip = null!;
    private ToolStripStatusLabel statusLabel = null!;
    private ToolStripStatusLabel positionLabel = null!;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    private void InitializeComponent()
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
        closeMenuItem = new ToolStripMenuItem("&Close Tab", null, (s, e) => CloseTab(), Keys.Control | Keys.W);
        exitMenuItem = new ToolStripMenuItem("E&xit", null, (s, e) => Close(), Keys.Alt | Keys.F4);
        
        fileMenu.DropDownItems.AddRange(new ToolStripItem[] {
            newMenuItem, openMenuItem, new ToolStripSeparator(),
            saveMenuItem, saveAsMenuItem, new ToolStripSeparator(),
            closeMenuItem, new ToolStripSeparator(), exitMenuItem
        });
        
        // Edit Menu
        editMenu = new ToolStripMenuItem("&Edit");
        undoMenuItem  = new ToolStripMenuItem("&Undo",  null, (s, e) => ActiveEditor?.Undo(),  Keys.Control | Keys.Z);
        redoMenuItem  = new ToolStripMenuItem("&Redo",  null, (s, e) => ActiveEditor?.Redo(),  Keys.Control | Keys.Y);
        cutMenuItem   = new ToolStripMenuItem("Cu&t",   null, (s, e) => ActiveEditor?.Cut(),   Keys.Control | Keys.X);
        copyMenuItem  = new ToolStripMenuItem("&Copy",  null, (s, e) => ActiveEditor?.Copy(),  Keys.Control | Keys.C);
        pasteMenuItem = new ToolStripMenuItem("&Paste", null, (s, e) => ActiveEditor?.Paste(), Keys.Control | Keys.V);
        selectAllMenuItem = new ToolStripMenuItem("Select &All", null, (s, e) => ActiveEditor?.SelectAll(), Keys.Control | Keys.A);

        editMenu.DropDownItems.AddRange(new ToolStripItem[] {
            undoMenuItem, redoMenuItem, new ToolStripSeparator(),
            cutMenuItem, copyMenuItem, pasteMenuItem, new ToolStripSeparator(),
            selectAllMenuItem
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
        lightModeMenuItem = new ToolStripMenuItem("&Light Mode", null, (s, e) => SetTheme(EditorTheme.Light));
        darkModeMenuItem = new ToolStripMenuItem("&Dark Mode (experimental)", null, (s, e) => SetTheme(EditorTheme.Dark));
        takeScreenshotItem = new ToolStripMenuItem("&Take Screenshot to Clipboard", null, (s, e) => TakeScreenshot());
        //If this screenshot thing does not work now, I will f... shoot someone
        viewMenu.DropDownItems.AddRange(new ToolStripItem[] {
            lightModeMenuItem, darkModeMenuItem,
            new ToolStripSeparator(),
            takeScreenshotItem
        });

        // Run Menu
        runMenu = new ToolStripMenuItem("&Run");
        runMenuItem = new ToolStripMenuItem("&Run Program", null, (s, e) => RunProgram(), Keys.F5);
        createExeMenuItem = new ToolStripMenuItem("Compile as &Exe", null, (s, e) => CompileAs("-exe"));
        CreateLibMenuItem = new ToolStripMenuItem("Compile as &Library (.bb)", null, (s, e) => CompileAs("-lib"));
        runMenu.DropDownItems.AddRange(new ToolStripItem[] {
            runMenuItem, new ToolStripSeparator(),
            createExeMenuItem, CreateLibMenuItem
        });
        
        // Help Menu
        helpMenu = new ToolStripMenuItem("&Help");
        aboutMenuItem = new ToolStripMenuItem("&About", null, (s, e) => ShowAbout());
        helpMenu.DropDownItems.Add(aboutMenuItem);

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
        };
        
        // Status Strip
        statusStrip = new StatusStrip();
        statusLabel = new ToolStripStatusLabel("Ready") { Spring = true, TextAlign = ContentAlignment.MiddleLeft };
        positionLabel = new ToolStripStatusLabel("Ln 1, Col 1");
        statusStrip.Items.AddRange(new ToolStripItem[] { statusLabel, positionLabel });
        
        // Layout
        this.MainMenuStrip = menuStrip;
        this.Controls.Add(tabControl);
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
            "Integrated development environment for BazzBasic.\n\n" +
            "Shortcuts:\n" +
            "  Ctrl+N  New file\n" +
            "  Ctrl+O  Open file\n" +
            "  Ctrl+S  Save\n" +
            "  Ctrl+W  Close tab\n" +
            "  Ctrl+Z  Undo\n" +
            "  Ctrl+Y  Redo\n" +
            "  Ctrl+X  Cut\n" +
            "  Ctrl+C  Copy\n" +
            "  Ctrl+V  Paste\n" +
            "  Ctrl+A  Select all\n" +
            "  Ctrl+F  Find\n" +
            "  Ctrl+H  Replace\n" +
            "  F5      Run program\n\n" +
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
}
