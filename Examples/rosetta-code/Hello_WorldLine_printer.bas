' ============================================
' ROSETTA: https://rosettacode.org/wiki/Hello_world/Line_printer
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the line Hello World! on the Windows default printer by calling PowerShell's Out-Printer through SHELL.
' CATEGORY: api
' TAGS: line printer, shell, powershell, out-printer
' MINVERSION: 1.5
' ============================================
' Cause a line printer attached to the computer to print a line
' containing the message: Hello World!
'
' SHELL runs commands through cmd.exe, so PowerShell is invoked
' explicitly to reach its Out-Printer cmdlet. The line goes to the
' Windows default printer.

[inits]
    LET MESSAGE# = "Hello World!"

[main]
    SHELL("powershell -NoProfile -Command \"'" + MESSAGE# + "' | Out-Printer\"", 15000)
END

' Output:
' (no console output - the default printer prints one line)
' Hello World!
