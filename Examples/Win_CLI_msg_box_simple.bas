' ============================================
' Windows MessageBox via PowerShell
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET MSG# = "Hello from BazzBasic"
    LET ret$ = ""

    ' \"  -> a literal " for the OS shell (escape sequence, unescaped at lex time).
    ' {{-MSG#-}} -> FSTRING substitutes the constant. A plain literal would NOT:
    '              it would pass the text "MSG#" through to PowerShell verbatim.
    LET cmd$ = FSTRING("PowerShell -Command \"Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('{{-MSG#-}}')\"")

[main]
    ' MessageBox blocks until OK is clicked. Default SHELL timeout is 5000 ms,
    ' so give it a long one or the dialog gets killed after 5 seconds.
    ret$ = SHELL(cmd$, 600000)
    PRINT "PowerShell returned: "; ret$       ' MessageBox::Show returns "OK"
    LET kwv$ = WAITKEY()
END

' Output (console, after the dialog is dismissed):
' PowerShell returned: OK