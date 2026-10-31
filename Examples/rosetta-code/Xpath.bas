' ============================================
' ROSETTA: https://rosettacode.org/wiki/XML/XPath
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Emulates three XPath queries on the task's inventory XML document read from xpath.xml, using plain string searching: the first item element, all price values and an array of all item names.
' CATEGORY: data
' TAGS: xml, xpath, instr, mid
' REQUIRES: xpath.xml
' MINVERSION: 1.5
' ============================================
' BazzBasic has no XML/XPath library, so the three queries
' are emulated with plain string searching (INSTR / MID).
' Save the task's XML document as "xpath.xml" next to this program.

[inits]
    LET XML_FILE# = PRG_ROOT# + "xpath.xml"
    LET xml$       = ""
    LET firstItem$ = ""
    LET p1$        = 0
    LET p2$        = 0
    LET count$     = 0
    DIM names$

[load]
    IF NOT FILEEXISTS(XML_FILE#) THEN
        PRINT "File not found: "; XML_FILE#
        END
    END IF
    xml$ = FILEREAD(XML_FILE#)

' --- //item[1] : the first "item" element ---
[query1]
    p1$ = INSTR(xml$, "<item ")
    p2$ = INSTR(p1$, xml$, "</item>")
    firstItem$ = MID(xml$, p1$, p2$ - p1$ + 7)
    PRINT "The first 'item' element is:"
    PRINT firstItem$

' --- //price/text() : print each price ---
[query2]
    PRINT "\nThe 'prices' are:"
    p1$ = INSTR(xml$, "<price>")
    WHILE p1$ > 0
        p2$ = INSTR(p1$, xml$, "</price>")
        PRINT MID(xml$, p1$ + 7, p2$ - p1$ - 7)
        p1$ = INSTR(p2$, xml$, "<price>")
    WEND

' --- //name : collect all names into an array ---
[query3]
    p1$ = INSTR(xml$, "<name>")
    WHILE p1$ > 0
        p2$ = INSTR(p1$, xml$, "</name>")
        names$(count$) = MID(xml$, p1$ + 6, p2$ - p1$ - 6)
        count$ += 1
        p1$ = INSTR(p2$, xml$, "<name>")
    WEND

    PRINT "\nThe 'names' array:"
    FOR i$ = 0 TO ROWCOUNT(names$()) - 1
        PRINT "names$("; i$; ") = "; names$(i$)
    NEXT
END

' Output:
' The first 'item' element is:
' <item upc="123456789" stock="12">
'       <name>Invisibility Cream</name>
'       <price>14.50</price>
'       <description>Makes you invisible</description>
'     </item>
'
' The 'prices' are:
' 14.50
' 23.99
' 4.95
' 3.56
'
' The 'names' array:
' names$(0) = Invisibility Cream
' names$(1) = Levitation Salve
' names$(2) = Blork and Freen Instameal
' names$(3) = Grob winglets