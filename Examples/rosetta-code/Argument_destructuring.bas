' ============================================
' https://rosettacode.org/wiki/Argument_destructuring
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: apply a function to arguments stored in a data structure.
' BazzBasic has no first-class functions or spread operator, so it is
' exempt; this shows the alternative: positional arguments unpacked
' from an array, named arguments passed as a JSON map and looked up
' by key inside the function.
' ============================================

' x$ and y$ are positional; named$ carries the named arguments as JSON
DEF FN ShowArgs$(x$, y$, named$)
    DIM opt$
    LET n$ = ASARRAY(opt$, named$)
    LET result$ = "This function's arguments are:\n"
    result$ += x$ + "\n"
    result$ += y$ + "\n"
    result$ += opt$("z") + "\n"     ' looked up by name, so order
    result$ += opt$("w")            ' in the caller doesn't matter
    RETURN result$
END DEF

[inits]
    DIM positional$
    positional$(0) = "x - positional"
    positional$(1) = "y - positional"

    DIM named$
    named$("w") = "w - named"
    named$("z") = "z - named"

[main]
    PRINT FN ShowArgs$(positional$(0), positional$(1), ASJSON(named$))
END

' Output:
' This function's arguments are:
' x - positional
' y - positional
' z - named
' w - named