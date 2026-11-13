' ============================================
' ROSETTA: https://rosettacode.org/wiki/XML/Input
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Extracts the list of student names from an XML fragment held in a string. ASARRAY parses the XML into an array; every Student element is indexed, and its Name attribute is the key "@Name". Character references such as &#x00C9; are decoded by the parser.
' MINVERSION: 1.7
' ============================================

[inits]
    LET xml$ = "<Students>\n" +
        "  <Student Name=\"April\" Gender=\"F\" DateOfBirth=\"1989-01-02\" />\n" +
        "  <Student Name=\"Bob\" Gender=\"M\"  DateOfBirth=\"1990-03-04\" />\n" +
        "  <Student Name=\"Chad\" Gender=\"M\"  DateOfBirth=\"1991-05-06\" />\n" +
        "  <Student Name=\"Dave\" Gender=\"M\"  DateOfBirth=\"1992-07-08\">\n" +
        "    <Pet Type=\"dog\" Name=\"Rover\" />\n" +
        "  </Student>\n" +
        "  <Student DateOfBirth=\"1993-09-10\" Gender=\"F\" Name=\"&#x00C9;mily\" />\n" +
        "</Students>\n"

    DIM doc$
    LET count$ = ASARRAY(doc$, xml$)
    LET i$ = 0

[main]
    ' Every element below the root is indexed, even a single one: Student,0 / Student,1 ...
    WHILE HASKEY(doc$("Students,Student," + i$ + ",@Name"))
        PRINT doc$("Students,Student," + i$ + ",@Name")
        i$ += 1
    WEND
END

' Output:
' April
' Bob
' Chad
' Dave
' Émily