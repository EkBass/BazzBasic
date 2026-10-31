' ============================================
' ROSETTA: https://rosettacode.org/wiki/Create_an_HTML_table
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints an HTML page with a table of four rows of random numbers under the column headings X, Y and Z.
' CATEGORY: data
' TAGS: html, table, markup generation, random numbers
' MINVERSION: 1.5
' ============================================

[inits]
    LET NROWS# = 4
    LET NCOLS# = 3
    LET row$ = 0
    LET col$ = 0

[header]
    PRINT "<!DOCTYPE html>"
    PRINT "<html>"
    PRINT "<head>"
    PRINT "<style>"
    PRINT "table { border-collapse: collapse; }"
    PRINT "th, td { border: 1px solid black; padding: 4px 10px; }"
    PRINT "td { text-align: right; }"
    PRINT "</style>"
    PRINT "</head>"
    PRINT "<body>"
    PRINT "<table>"
    PRINT "<tr><th></th>";
    FOR col$ = 1 TO NCOLS#
        PRINT "<th>"; MID("XYZ", col$, 1); "</th>";
    NEXT
    PRINT "</tr>"

[body]
    FOR row$ = 1 TO NROWS#
        PRINT "<tr><th>"; row$; "</th>";
        FOR col$ = 1 TO NCOLS#
            PRINT "<td>"; RND(9999); "</td>";
        NEXT
        PRINT "</tr>"
    NEXT

[footer]
    PRINT "</table>"
    PRINT "</body>"
    PRINT "</html>"
END

' Output:
' <!DOCTYPE html>
' <html>
' <head>
' <style>
' table { border-collapse: collapse; }
' th, td { border: 1px solid black; padding: 4px 10px; }
' td { text-align: right; }
' </style>
' </head>
' <body>
' <table>
' <tr><th></th><th>X</th><th>Y</th><th>Z</th></tr>
' <tr><th>1</th><td>6751</td><td>6565</td><td>7456</td></tr>
' <tr><th>2</th><td>6889</td><td>8109</td><td>2813</td></tr>
' <tr><th>3</th><td>7411</td><td>4166</td><td>4772</td></tr>
' <tr><th>4</th><td>1784</td><td>8755</td><td>6239</td></tr>
' </table>
' </body>
' </html>