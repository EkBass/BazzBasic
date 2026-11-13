' ============================================
' ROSETTA: https://rosettacode.org/wiki/XML/XPath
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Runs the three XPath queries of the task on the store inventory. LOADXML parses the file into an array; every element below the root is indexed (section,0 / item,1 ...), attributes are "@name" keys. The first item is copied into its own array and written back out with ASXML.
' CATEGORY: data
' TAGS: xml, xpath, loadxml, asxml, attributes
' REQUIRES: assets/xpath.xml
' MINVERSION: 1.7
' ============================================

[inits]
    LET ROOT# = "xml,inventory,0,"      ' the file wraps <inventory> in <xml>
    DIM doc$
    LOADXML doc$, PRG_ROOT# + "assets/xpath.xml"

    DIM first$                          ' //item[1] as its own array
    DIM names$                          ' //name
    LET prefix$ = ""
    LET key$    = ""
    LET s$      = 0                     ' section index
    LET n$      = 0                     ' item index inside a section
    LET count$  = 0

[query1]
    ' //item[1] - copy every key under the first item, then ASXML it
    prefix$ = ROOT# + "section,0,item,0,"
    FOR i$ = 0 TO LEN(doc$()) - 1
        key$ = ARRKEY(doc$(), i$)
        IF LEFT(key$, LEN(prefix$)) = prefix$ THEN
            first$("item," + MID(key$, LEN(prefix$) + 1)) = doc$(key$)
        END IF
    NEXT
    PRINT "The first 'item' element is:"
    PRINT ASXML(first$)

[query2]
    ' //price/text() and //name - walk every item of every section
    PRINT "\nThe 'prices' are:"
    WHILE HASKEY(doc$(ROOT# + "section," + s$ + ",@name"))
        n$ = 0
        WHILE HASKEY(doc$(ROOT# + "section," + s$ + ",item," + n$ + ",@upc"))
            prefix$ = ROOT# + "section," + s$ + ",item," + n$ + ","
            PRINT doc$(prefix$ + "price,0")
            names$(count$) = doc$(prefix$ + "name,0")
            count$ += 1
            n$ += 1
        WEND
        s$ += 1
    WEND

[query3]
    PRINT "\nThe 'names' array:"
    FOR i$ = 0 TO count$ - 1
        PRINT "names$("; i$; ") = "; names$(i$)
    NEXT
END

' Output:
' The first 'item' element is:
' <item upc="123456789" stock="12"><name>Invisibility Cream</name><price>14.50</price><description>Makes you invisible</description></item>
'
' The 'prices' are:
' 14.50
' 23.99
' 4.95
' 3.56
'
' The 'names' array:
' names0 = Invisibility Cream
' names1 = Levitation Salve
' names2 = Blork and Freen Instameal
' names3 = Grob winglets
