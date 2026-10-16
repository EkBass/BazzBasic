/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: IDE\EditorTheme.cs
 Light/Dark color themes for the IDE, menu renderer and settings persistence

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

#nullable enable

using System.Runtime.InteropServices;
using System.Text.Json;

namespace BazzBasic.IDE;

/// <summary>All colors used by the IDE for one theme.</summary>
internal sealed record EditorTheme(
    string Name,
    bool IsDark,
    // Editor
    Color Back, Color Fore,
    Color Gutter, Color GutterFore,
    Color Selection, Color Caret,
    Color Comment, Color Number, Color Keyword, Color String, Color Operator,
    Color Keyword2, Color Keyword3, Color Keyword4,
    // Window chrome
    Color ChromeBack, Color ChromeFore, Color ChromeHover, Color ChromeBorder,
    Color DropDownBack, Color DisabledFore,
    Color TabActive, Color TabInactive, Color TabClose)
{
    public static readonly EditorTheme Light = new(
        "Light", false,
        Back: Color.White, Fore: Color.Black,
        Gutter: Color.FromArgb(240, 240, 240), GutterFore: Color.FromArgb(100, 100, 100),
        Selection: Color.FromArgb(173, 214, 255), Caret: Color.Black,
        Comment: Color.FromArgb(0, 128, 0), Number: Color.FromArgb(255, 128, 0),
        Keyword: Color.Blue, String: Color.FromArgb(163, 21, 21), Operator: Color.Black,
        Keyword2: Color.DarkCyan, Keyword3: Color.DarkMagenta, Keyword4: Color.Teal,
        ChromeBack: SystemColors.Control, ChromeFore: SystemColors.ControlText,
        ChromeHover: SystemColors.Highlight, ChromeBorder: SystemColors.ControlDark,
        DropDownBack: SystemColors.Window, DisabledFore: SystemColors.GrayText,
        TabActive: SystemColors.Window, TabInactive: SystemColors.Control,
        TabClose: Color.FromArgb(120, 120, 120));

    public static readonly EditorTheme Dark = new(
        "Dark", true,
        Back: Color.FromArgb(30, 30, 30), Fore: Color.FromArgb(212, 212, 212),
        Gutter: Color.FromArgb(37, 37, 38), GutterFore: Color.FromArgb(133, 133, 133),
        Selection: Color.FromArgb(38, 79, 120), Caret: Color.FromArgb(240, 240, 240),
        Comment: Color.FromArgb(106, 153, 85), Number: Color.FromArgb(181, 206, 168),
        Keyword: Color.FromArgb(86, 156, 214), String: Color.FromArgb(206, 145, 120),
        Operator: Color.FromArgb(212, 212, 212),
        Keyword2: Color.FromArgb(220, 220, 170), Keyword3: Color.FromArgb(78, 201, 176),
        Keyword4: Color.FromArgb(197, 134, 192),
        ChromeBack: Color.FromArgb(45, 45, 48), ChromeFore: Color.FromArgb(241, 241, 241),
        ChromeHover: Color.FromArgb(62, 62, 64), ChromeBorder: Color.FromArgb(63, 63, 70),
        DropDownBack: Color.FromArgb(27, 27, 28), DisabledFore: Color.FromArgb(110, 110, 110),
        TabActive: Color.FromArgb(30, 30, 30), TabInactive: Color.FromArgb(45, 45, 48),
        TabClose: Color.FromArgb(160, 160, 160));

    public static EditorTheme FromName(string? name) =>
        string.Equals(name, Dark.Name, StringComparison.OrdinalIgnoreCase) ? Dark : Light;
}

/// <summary>Colors for MenuStrip / StatusStrip in dark mode.</summary>
internal sealed class ThemeColorTable(EditorTheme t) : ProfessionalColorTable
{
    public override Color MenuStripGradientBegin => t.ChromeBack;
    public override Color MenuStripGradientEnd => t.ChromeBack;
    public override Color StatusStripGradientBegin => t.ChromeBack;
    public override Color StatusStripGradientEnd => t.ChromeBack;
    public override Color ToolStripDropDownBackground => t.DropDownBack;
    public override Color ImageMarginGradientBegin => t.DropDownBack;
    public override Color ImageMarginGradientMiddle => t.DropDownBack;
    public override Color ImageMarginGradientEnd => t.DropDownBack;
    public override Color MenuBorder => t.ChromeBorder;
    public override Color MenuItemBorder => t.ChromeBorder;
    public override Color MenuItemSelected => t.ChromeHover;
    public override Color MenuItemSelectedGradientBegin => t.ChromeHover;
    public override Color MenuItemSelectedGradientEnd => t.ChromeHover;
    public override Color MenuItemPressedGradientBegin => t.DropDownBack;
    public override Color MenuItemPressedGradientMiddle => t.DropDownBack;
    public override Color MenuItemPressedGradientEnd => t.DropDownBack;
    public override Color SeparatorDark => t.ChromeBorder;
    public override Color SeparatorLight => t.ChromeBorder;
    public override Color CheckBackground => t.ChromeHover;
    public override Color CheckSelectedBackground => t.ChromeHover;
    public override Color CheckPressedBackground => t.ChromeHover;
    public override Color ButtonSelectedBorder => t.ChromeBorder;
}

/// <summary>Menu renderer that also recolors item text and submenu arrows.</summary>
internal sealed class ThemeRenderer(EditorTheme t) : ToolStripProfessionalRenderer(new ThemeColorTable(t))
{
    protected override void OnRenderItemText(ToolStripItemTextRenderEventArgs e)
    {
        e.TextColor = e.Item.Enabled ? t.ChromeFore : t.DisabledFore;
        base.OnRenderItemText(e);
    }

    protected override void OnRenderArrow(ToolStripArrowRenderEventArgs e)
    {
        e.ArrowColor = t.ChromeFore;
        base.OnRenderArrow(e);
    }

    protected override void OnRenderItemCheck(ToolStripItemImageRenderEventArgs e)
    {
        // Default check mark is black and invisible on dark background: draw our own
        var r = e.ImageRectangle;
        using var bg = new SolidBrush(t.ChromeHover);
        e.Graphics.FillRectangle(bg, r);
        using var pen = new Pen(t.ChromeFore, 2f);
        e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
        e.Graphics.DrawLines(pen, new[] {
            new Point(r.Left + r.Width / 4, r.Top + r.Height / 2),
            new Point(r.Left + r.Width / 2 - 1, r.Bottom - r.Height / 4),
            new Point(r.Right - r.Width / 5, r.Top + r.Height / 4)
        });
    }
}

/// <summary>Dark title bar on Windows 10 (20H1+) and Windows 11.</summary>
internal static class TitleBar
{
    [DllImport("dwmapi.dll")]
    private static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int value, int size);

    [DllImport("user32.dll")]
    private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int x, int y, int cx, int cy, uint flags);

    private const int DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    private const int DWMWA_USE_IMMERSIVE_DARK_MODE_OLD = 19; // Windows 10 before 20H1

    // Redraw the frame without moving, resizing or activating the window
    private const uint SWP_FRAMECHANGED_ONLY = 0x0020 | 0x0001 | 0x0002 | 0x0004 | 0x0010;

    public static void SetDark(IntPtr hwnd, bool dark)
    {
        int value = dark ? 1 : 0;
        try
        {
            if (DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, ref value, sizeof(int)) != 0)
                DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE_OLD, ref value, sizeof(int));
            SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY);
        }
        catch
        {
            // Not supported on this Windows version, keep default title bar
        }
    }
}

/// <summary>IDE settings stored in %AppData%\BazzBasic\ide.json.</summary>
internal sealed class IdeSettings
{
    public string Theme { get; set; } = EditorTheme.Light.Name;

    private static string FilePath => System.IO.Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "BazzBasic", "ide.json");

    public static IdeSettings Load()
    {
        try
        {
            if (System.IO.File.Exists(FilePath))
                return JsonSerializer.Deserialize<IdeSettings>(System.IO.File.ReadAllText(FilePath)) ?? new IdeSettings();
        }
        catch
        {
            // Broken or unreadable settings file: fall back to defaults
        }
        return new IdeSettings();
    }

    public void Save()
    {
        try
        {
            System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(FilePath)!);
            System.IO.File.WriteAllText(FilePath, JsonSerializer.Serialize(this, new JsonSerializerOptions { WriteIndented = true }));
        }
        catch
        {
            // Settings are a convenience; never crash the IDE over them
        }
    }
}
