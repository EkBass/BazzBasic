' ============================================
' Custom 3-button dialog via PowerShell + WinForms
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
[inits]
    LET ret$    = ""
    LET answer$ = ""

    ' A WinForms dialog with three custom buttons. Each button's DialogResult is
    ' set, the form is shown modally, and we print our own label for the choice.
    ' Built as one PowerShell -Command line; \" escapes the outer quotes for the
    ' OS shell. PowerShell statements are separated by ';'.
    LET ps$ = ""
    ps$ += "Add-Type -AssemblyName System.Windows.Forms;"
    ps$ += "$f=New-Object Windows.Forms.Form;"
    ps$ += "$f.Text='BazzBasic';$f.Width=320;$f.Height=130;"
    ps$ += "$f.FormBorderStyle='FixedDialog';$f.StartPosition='CenterScreen';"
    ps$ += "$l=New-Object Windows.Forms.Label;$l.Text='Pick one of three';"
    ps$ += "$l.AutoSize=$true;$l.Top=15;$l.Left=20;$f.Controls.Add($l);"
    ps$ += "$b1=New-Object Windows.Forms.Button;$b1.Text='Apple';$b1.Left=20;$b1.Top=50;$b1.Add_Click({$f.Tag='Apple';$f.Close()});$f.Controls.Add($b1);"
    ps$ += "$b2=New-Object Windows.Forms.Button;$b2.Text='Banana';$b2.Left=110;$b2.Top=50;$b2.Add_Click({$f.Tag='Banana';$f.Close()});$f.Controls.Add($b2);"
    ps$ += "$b3=New-Object Windows.Forms.Button;$b3.Text='Cherry';$b3.Left=200;$b3.Top=50;$b3.Add_Click({$f.Tag='Cherry';$f.Close()});$f.Controls.Add($b3);"
    ps$ += "$f.ShowDialog()|Out-Null;$f.Tag"

    LET cmd$ = FSTRING("PowerShell -Command \"{{-ps$-}}\"")

[main]
    ret$ = SHELL(cmd$, 600000)
    answer$ = TRIM(ret$)

    IF answer$ = "Apple" THEN
        PRINT "User chose Apple"
    ELSEIF answer$ = "Banana" THEN
        PRINT "User chose Banana"
    ELSEIF answer$ = "Cherry" THEN
        PRINT "User chose Cherry"
    ELSE
        PRINT "Closed without choosing (or error): "; answer$
    END IF

    LET kwv$ = WAITKEY()
END