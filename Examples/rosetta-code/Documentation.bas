' ============================================
' ROSETTA: https://rosettacode.org/wiki/Documentation
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows how to document BazzBasic code with apostrophe comments, REM comments and end-of-line comments (there are no documentation comments).
' CATEGORY: basics
' TAGS: comments, documentation, rem, syntax
' MINVERSION: 1.5
' ============================================

' BazzBasic supports classic BASIC styles for comments.
' "'" and "REM" both works
' But no support currently 'documentation comments' as such

' Common one-line comment
DEF FN MyFunc$(foo$) ' end of line comment
    RETURN foo$ + foo$
END DEF

REM Classic one-line comment works too

[main]
    PRINT FN MyFunc$("Hello")

' No support for multiline comments at version 1.4
' Another comment
END