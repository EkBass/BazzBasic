/*
 * BazzBasic IDE - Path to BazzBasic.exe dialog
 * MIT License - Copyright (c) 2025 Kristian Virtanen
 */

namespace BazzBasic.IDE;

/// <summary>
/// Lets the user set the interpreter used by Run and Compile, or clear it to use
/// automatic lookup (IDE folder, then PATH). Shows live which exe would be used.
/// </summary>
internal sealed class InterpreterPathDialog : Form
{
    private readonly TextBox _pathBox;
    private readonly Label _currentLabel;
    private readonly Func<string?, (string? Path, string Source)> _resolve;

    /// <summary>The chosen path, or null for automatic lookup. Valid after DialogResult.OK.</summary>
    public string? SelectedPath { get; private set; }

    public InterpreterPathDialog(string? currentSetting, Func<string?, (string? Path, string Source)> resolve)
    {
        _resolve = resolve;

        Text = "Path to BazzBasic.exe";
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = false;
        StartPosition = FormStartPosition.CenterParent;

        // No fixed pixel sizes: the dialog sizes itself to its content and font,
        // so it looks right at any Windows display scaling (100 %, 150 %, 200 % ...).
        AutoSize = true;
        AutoSizeMode = AutoSizeMode.GrowAndShrink;
        Font = SystemFonts.MessageBoxFont ?? Font;

        int em = Font.Height;              // one text line, scales with DPI
        int boxWidth = em * 34;            // room for a typical full path
        int buttonWidth = em * 6;

        var infoLabel = new Label
        {
            Text = "Leave empty to find BazzBasic.exe automatically (IDE folder, then PATH).",
            AutoSize = true,
            Margin = new Padding(0, 0, 0, em / 2)
        };

        _pathBox = new TextBox
        {
            Width = boxWidth,
            Text = currentSetting ?? "",
            Anchor = AnchorStyles.Left | AnchorStyles.Right
        };
        _pathBox.TextChanged += (s, e) => UpdateCurrentLabel();

        var browseButton = new Button { Text = "&Browse...", AutoSize = true, MinimumSize = new Size(buttonWidth, 0) };
        browseButton.Click += (s, e) => Browse();

        // Wraps long paths onto more lines instead of cutting them off
        _currentLabel = new Label
        {
            AutoSize = true,
            MaximumSize = new Size(boxWidth + buttonWidth + em, 0),
            Margin = new Padding(0, em / 2, 0, em)
        };

        var clearButton = new Button { Text = "&Clear", AutoSize = true, MinimumSize = new Size(buttonWidth, 0) };
        clearButton.Click += (s, e) => _pathBox.Text = "";

        // OK validates before closing, so it does not use DialogResult directly
        var okButton = new Button { Text = "OK", AutoSize = true, MinimumSize = new Size(buttonWidth, 0) };
        okButton.Click += (s, e) => Accept();

        var cancelButton = new Button { Text = "Cancel", AutoSize = true, MinimumSize = new Size(buttonWidth, 0), DialogResult = DialogResult.Cancel };

        // Bottom row: Clear on the left, OK + Cancel on the right
        var okCancel = new FlowLayoutPanel { AutoSize = true, WrapContents = false, Anchor = AnchorStyles.Right, Margin = Padding.Empty };
        okCancel.Controls.AddRange(new Control[] { okButton, cancelButton });

        var buttonRow = new TableLayoutPanel { AutoSize = true, ColumnCount = 2, Dock = DockStyle.Fill, Margin = Padding.Empty };
        buttonRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        buttonRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        clearButton.Anchor = AnchorStyles.Left;
        buttonRow.Controls.Add(clearButton, 0, 0);
        buttonRow.Controls.Add(okCancel, 1, 0);

        // Main grid: 2 columns (text box | Browse), rows stacked top to bottom
        var layout = new TableLayoutPanel
        {
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink,
            ColumnCount = 2,
            Padding = new Padding(em),
            Dock = DockStyle.Fill
        };
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));

        layout.Controls.Add(infoLabel, 0, 0);
        layout.SetColumnSpan(infoLabel, 2);
        layout.Controls.Add(_pathBox, 0, 1);
        layout.Controls.Add(browseButton, 1, 1);
        layout.Controls.Add(_currentLabel, 0, 2);
        layout.SetColumnSpan(_currentLabel, 2);
        layout.Controls.Add(buttonRow, 0, 3);
        layout.SetColumnSpan(buttonRow, 2);

        Controls.Add(layout);
        AcceptButton = okButton;
        CancelButton = cancelButton;

        UpdateCurrentLabel();
    }

    private static string Clean(string text) => text.Trim().Trim('"').Trim();

    // Show what Run would use right now, with the text box content as the setting
    private void UpdateCurrentLabel()
    {
        var (path, source) = _resolve(Clean(_pathBox.Text));
        // A long path wraps onto more lines; the AutoSize dialog grows to fit
        _currentLabel.Text = path != null
            ? $"Currently used: {path} ({source})"
            : $"Not found ({source})";
    }

    private void Browse()
    {
        using var dialog = new OpenFileDialog
        {
            Title = "Select BazzBasic.exe",
            Filter = "BazzBasic.exe|BazzBasic.exe|Programs (*.exe)|*.exe",
            CheckFileExists = true
        };

        string current = Clean(_pathBox.Text);
        if (current.Length > 0)
        {
            try
            {
                var dir = System.IO.Path.GetDirectoryName(current);
                if (!string.IsNullOrEmpty(dir) && System.IO.Directory.Exists(dir))
                    dialog.InitialDirectory = dir;
            }
            catch (ArgumentException) { /* invalid characters in the box: ignore */ }
        }

        if (dialog.ShowDialog(this) == DialogResult.OK)
            _pathBox.Text = dialog.FileName;
    }

    private void Accept()
    {
        string path = Clean(_pathBox.Text);

        if (path.Length > 0 && !System.IO.File.Exists(path))
        {
            MessageBox.Show(this, $"File not found:\n{path}", Text,
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return; // keep the dialog open
        }

        SelectedPath = path.Length > 0 ? System.IO.Path.GetFullPath(path) : null;
        DialogResult = DialogResult.OK;
    }
}
