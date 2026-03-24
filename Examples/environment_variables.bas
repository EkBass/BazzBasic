This also is pretty clear. Via SHELL, the environment vars are available. BazzBasic itself does not have functions for them.



[code lang='BazzBasic']

' ============================================
' https://rosettacode.org/wiki/Environment_variables
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
PRINT SHELL("echo %PATH%")
END

[/code]
