' ============================================
' ROSETTA: https://rosettacode.org/wiki/String_interpolation
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Inserts the word little into the sentence Mary had a lamb with FSTRING, and for comparison with REPLACE and plain concatenation.
' CATEGORY: strings
' TAGS: string interpolation, fstring, replace
' MINVERSION: 1.5
' ============================================
' BazzBasic has native string interpolation via FSTRING() since v1.3.
' Placeholders use the {{- name$ -}} syntax — chosen to avoid collisions
' with normal text. REPLACE() and concatenation are shown for comparison.

[inits]
    LET word$ = "little"

[main]
    ' 1. FSTRING — idiomatic, native interpolation
    PRINT FSTRING("Mary had a {{-word$-}} lamb.")

    ' 2. REPLACE — substitute a placeholder token with a value
    LET template$ = "Mary had a %s lamb."
    PRINT REPLACE(template$, "%s", word$)

    ' 3. Concatenation — build the string directly
    PRINT "Mary had a " + word$ + " lamb."
END

' Output:
' Mary had a little lamb.
' Mary had a little lamb.
' Mary had a little lamb.