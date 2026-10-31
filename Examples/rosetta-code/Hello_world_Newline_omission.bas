' ============================================
' ROSETTA: https://rosettacode.org/wiki/Hello_world/Newline_omission
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints Goodbye, World! without a trailing newline by ending the PRINT statement with a semicolon.
' CATEGORY: basics
' TAGS: hello world, print, newline omission
' MINVERSION: 1.5
' ============================================
' A trailing ';' on PRINT suppresses the newline.

PRINT "Goodbye, World!";
END

' Output:
' Goodbye, World!_
' (cursor stays on the same line; no newline emitted)