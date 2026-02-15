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
    
    private ToolStripMenuItem editMenu = null!;
    private ToolStripMenuItem findMenuItem = null!;
    private ToolStripMenuItem replaceMenuItem = null!;
    
    private ToolStripMenuItem runMenu = null!;
    private ToolStripMenuItem runMenuItem = null!;
    
    private ToolStripMenuItem helpMenu = null!;
    private ToolStripMenuItem aboutMenuItem = null!;
    
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
        findMenuItem = new ToolStripMenuItem("&Find...", null, (s, e) => ShowFindDialog(), Keys.Control | Keys.F);
        replaceMenuItem = new ToolStripMenuItem("&Replace...", null, (s, e) => ShowReplaceDialog(), Keys.Control | Keys.H);
        
        editMenu.DropDownItems.AddRange(new ToolStripItem[] {
            findMenuItem, replaceMenuItem
        });
        
        // Run Menu
        runMenu = new ToolStripMenuItem("&Run");
        runMenuItem = new ToolStripMenuItem("&Run Program", null, (s, e) => RunProgram(), Keys.F5);
        runMenu.DropDownItems.Add(runMenuItem);
        
        // Help Menu
        helpMenu = new ToolStripMenuItem("&Help");
        aboutMenuItem = new ToolStripMenuItem("&About", null, (s, e) => ShowAbout());
        helpMenu.DropDownItems.Add(aboutMenuItem);
        
        menuStrip.Items.AddRange(new ToolStripItem[] { fileMenu, editMenu, runMenu, helpMenu });
        
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
        using var bgBrush = new SolidBrush(isSelected ? SystemColors.Window : SystemColors.Control);
        e.Graphics.FillRectangle(bgBrush, tabRect);
        
        // Draw tab text
        var textRect = new Rectangle(tabRect.X + 4, tabRect.Y + 4, tabRect.Width - 24, tabRect.Height - 4);
        TextRenderer.DrawText(e.Graphics, tabPage.Text, tabControl.Font, textRect, 
            SystemColors.ControlText, TextFormatFlags.Left | TextFormatFlags.VerticalCenter);
        
        // Draw close button (X)
        var closeRect = GetCloseButtonRect(tabRect);
        using var closeFont = new Font("Arial", 8, FontStyle.Bold);
        TextRenderer.DrawText(e.Graphics, "×", closeFont, closeRect, 
            Color.FromArgb(120, 120, 120), TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter);
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
}
