' ============================================
' https://rosettacode.org/wiki/Metaprogramming
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' BazzBasic supports two metaprogramming-style features:
'
' 1. INCLUDE — source-level file insertion.
'    The interpreter replaces INCLUDE "file.bas" with the full
'    contents of that file before execution begins.
'    This allows splitting a program into modules (inits, subs,
'    constants, functions) that are composed at load time.
'
'    INCLUDE also loads compiled BazzBasic libraries (.bb):
'      INCLUDE "MathLib.bb"
'
'    See also: https://rosettacode.org/wiki/Include_a_file#BazzBasic
'
' 2. Dynamic GOTO / GOSUB — indirect label dispatch.
'    A variable or constant can hold a label name as a string,
'    and GOTO / GOSUB will jump to whichever label it contains.
'    This allows runtime-selected dispatch without a chain of IF/ELSEIF.

' --- Dynamic dispatch demo ---

[inits]
    LET GREETING# = "[sub:hello]"
    LET FAREWELL# = "[sub:bye]"
    LET dispatch$

[main]
    dispatch$ = GREETING#
    GOSUB dispatch$

    dispatch$ = FAREWELL#
    GOSUB dispatch$
END

[sub:hello]
    PRINT "Hello from a dynamically dispatched subroutine."
RETURN

[sub:bye]
    PRINT "Goodbye — label chosen at runtime."
RETURN

' Output:
' Hello from a dynamically dispatched subroutine.
' Goodbye — label chosen at runtime.
