' ============================================
' ROSETTA: https://rosettacode.org/wiki/Include_a_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Builds one program from two source files with INCLUDE and prints a greeting defined in the included file.
' CATEGORY: basics
' TAGS: include, source files, program structure
' REQUIRES: inits.bas, output.bas
' MINVERSION: 1.5
' ============================================
' Run this file. INCLUDE inserts the contents of another file in place
' of itself. INCLUDE can also import BazzBasic libraries (.bb).
'
' Expanded view of main.bas after INCLUDE processing:
'
'   [inits]
'       LET foo$ = "Hello from inits.bas"
'   [output]
'       PRINT foo$
'   END

INCLUDE "inits.bas"
INCLUDE "output.bas"

' Output:
' Hello from inits.bas
