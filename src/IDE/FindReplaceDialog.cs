/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: IDE\FindReplaceDialog.cs
 Find & replace stuff for IDE

 Licence: MIT
*/

using System.ComponentModel;

namespace BazzBasic.IDE;

public class FindReplaceDialog : Form
{
    private TextBox searchTextBox = null!;
    private TextBox replaceTextBox = null!;
    private CheckBox matchCaseCheckBox = null!;
    private Button findNextButton = null!;
    private Button replaceButton = null!;
    private Button replaceAllButton = null!;
    private Label findLabel = null!;
    private Label replaceLabel = null!;
    
    public event EventHandler<FindEventArgs>? FindNext;
    public event EventHandler<ReplaceEventArgs>? Replace;
    public event EventHandler<ReplaceEventArgs>? ReplaceAll;

    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    [Browsable(false)]
    public string SearchText
    {
        get => searchTextBox.Text;
        set => searchTextBox.Text = value;
    }

    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    [Browsable(false)]
    public bool ShowReplace
    {
        get => replaceTextBox.Visible;
        set
        {
            replaceTextBox.Visible = value;
            replaceLabel.Visible = value;
            replaceButton.Visible = value;
            replaceAllButton.Visible = value;
            this.Text = value ? "Replace" : "Find";
            this.ClientSize = new Size(900, value ? 300 : 300);
        }
    }

    public FindReplaceDialog()
    {
        InitializeComponent();
        WireEvents();
    }

    private void InitializeComponent()
    {
        findLabel = new Label();
        searchTextBox = new TextBox();
        replaceLabel = new Label();
        replaceTextBox = new TextBox();
        matchCaseCheckBox = new CheckBox();
        findNextButton = new Button();
        replaceButton = new Button();
        replaceAllButton = new Button();
        SuspendLayout();

        // findLabel
        findLabel.AutoSize = true;
        findLabel.Location = new Point(15, 18);
        findLabel.Name = "findLabel";
        findLabel.Size = new Size(65, 32);
        findLabel.TabIndex = 0;
        findLabel.Text = "Find:";
        // 
        // searchTextBox
        // 
        searchTextBox.Location = new Point(86, 18);
        searchTextBox.Name = "searchTextBox";
        searchTextBox.Size = new Size(400, 39);
        searchTextBox.TabIndex = 1;
        // 
        // replaceLabel
        // 
        replaceLabel.AutoSize = true;
        replaceLabel.Location = new Point(15, 65);
        replaceLabel.Name = "replaceLabel";
        replaceLabel.Size = new Size(101, 32);
        replaceLabel.TabIndex = 2;
        replaceLabel.Text = "Replace:";
        replaceLabel.Visible = false;
        // 
        // replaceTextBox
        // 
        replaceTextBox.Location = new Point(122, 58);
        replaceTextBox.Name = "replaceTextBox";
        replaceTextBox.Size = new Size(364, 39);
        replaceTextBox.TabIndex = 3;
        replaceTextBox.Visible = false;
        // 
        // matchCaseCheckBox
        // 
        matchCaseCheckBox.AutoSize = true;
        matchCaseCheckBox.Location = new Point(15, 125);
        matchCaseCheckBox.Name = "matchCaseCheckBox";
        matchCaseCheckBox.Size = new Size(166, 36);
        matchCaseCheckBox.TabIndex = 4;
        matchCaseCheckBox.Text = "Match case";

        // findNextButton
        // 
        findNextButton.Location = new Point(521, 18);
        findNextButton.Name = "findNextButton";
        findNextButton.Size = new Size(311, 45);
        findNextButton.TabIndex = 5;
        findNextButton.Text = "Find Next";
        // 
        // replaceButton
        // 
        replaceButton.Location = new Point(521, 69);
        replaceButton.Name = "replaceButton";
        replaceButton.Size = new Size(311, 41);
        replaceButton.TabIndex = 6;
        replaceButton.Text = "Replace";
        replaceButton.Visible = false;
        // 
        // replaceAllButton
        // 
        replaceAllButton.Location = new Point(521, 125);
        replaceAllButton.Name = "replaceAllButton";
        replaceAllButton.Size = new Size(311, 47);
        replaceAllButton.TabIndex = 7;
        replaceAllButton.Text = "Replace All";
        replaceAllButton.Visible = false;
        // 
        // FindReplaceDialog
        // 
        ClientSize = new Size(874, 229);
        Controls.Add(findLabel);
        Controls.Add(searchTextBox);
        Controls.Add(replaceLabel);
        Controls.Add(replaceTextBox);
        Controls.Add(matchCaseCheckBox);
        Controls.Add(findNextButton);
        Controls.Add(replaceButton);
        Controls.Add(replaceAllButton);
        FormBorderStyle = FormBorderStyle.FixedDialog;
        KeyPreview = true;
        MaximizeBox = false;
        MinimizeBox = false;
        Name = "FindReplaceDialog";
        ShowInTaskbar = false;
        StartPosition = FormStartPosition.CenterParent;
        Text = "Find";
        ResumeLayout(false);
        PerformLayout();
    }

    private void WireEvents()
    {
        searchTextBox.KeyDown += SearchTextBox_KeyDown;
        findNextButton.Click += FindNextButton_Click;
        replaceButton.Click += ReplaceButton_Click;
        replaceAllButton.Click += ReplaceAllButton_Click;

        this.KeyDown += Form_KeyDown;
        this.FormClosing += Form_FormClosing;
    }

    private void SearchTextBox_KeyDown(object? sender, KeyEventArgs e)
    {
        if (e.KeyCode == Keys.Enter)
        {
            OnFindNext();
            e.Handled = true;
            e.SuppressKeyPress = true;
        }
    }

    private void FindNextButton_Click(object? sender, EventArgs e)
    {
        OnFindNext();
    }

    private void ReplaceButton_Click(object? sender, EventArgs e)
    {
        OnReplace();
    }

    private void ReplaceAllButton_Click(object? sender, EventArgs e)
    {
        OnReplaceAll();
    }

    private void CloseButton_Click(object? sender, EventArgs e)
    {
        this.Hide();
    }

    private void Form_KeyDown(object? sender, KeyEventArgs e)
    {
        if (e.KeyCode == Keys.Escape)
        {
            this.Hide();
            e.Handled = true;
        }
    }

    private void Form_FormClosing(object? sender, FormClosingEventArgs e)
    {
        if (e.CloseReason == CloseReason.UserClosing)
        {
            e.Cancel = true;
            this.Hide();
        }
    }

    private void OnFindNext()
    {
        if (!string.IsNullOrEmpty(searchTextBox.Text))
        {
            FindNext?.Invoke(this, new FindEventArgs(searchTextBox.Text, matchCaseCheckBox.Checked));
        }
    }

    private void OnReplace()
    {
        if (!string.IsNullOrEmpty(searchTextBox.Text))
        {
            Replace?.Invoke(this, new ReplaceEventArgs(
                searchTextBox.Text, 
                replaceTextBox.Text, 
                matchCaseCheckBox.Checked));
        }
    }

    private void OnReplaceAll()
    {
        if (!string.IsNullOrEmpty(searchTextBox.Text))
        {
            ReplaceAll?.Invoke(this, new ReplaceEventArgs(
                searchTextBox.Text, 
                replaceTextBox.Text, 
                matchCaseCheckBox.Checked));
        }
    }

    protected override void OnShown(EventArgs e)
    {
        base.OnShown(e);
        searchTextBox.Focus();
        searchTextBox.SelectAll();
    }
}
