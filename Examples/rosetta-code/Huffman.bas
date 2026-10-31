' ============================================
' ROSETTA: https://rosettacode.org/wiki/Huffman_coding
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Huffman coding from the command line: encodes text into a code table and a self-contained package, and decodes such a package back to text.
' CATEGORY: algorithms
' TAGS: huffman coding, compression, binary tree, command line arguments
' MINVERSION: 1.5
' ============================================
' Usage:
'   BazzBasic.exe huffman.bas -encode "this is an example for huffman encoding"
'   BazzBasic.exe huffman.bas -decode "116:1,104:2,105:3,115:2,32:6,97:3,110:4,101:3,120:1,109:2,112:1,108:1,102:3,111:2,114:1,117:1,99:1,100:1,103:1/0101011111100100101011001001010111000001011101010111100001101100011011101101111001000111010111111011111110111000111100000101110100010000010010001100100011110"
'
' -encode prints a code table and a self-contained PACKAGE:
'     <ascii>:<count>,<ascii>:<count>,.../<bits>
' The header (counts) is what lets -decode rebuild the exact same tree.
' A bare bit string alone cannot be decoded - the tree is part of the data.

[inits]
    LET SEP_PACKAGE# = "/"      ' header / bits separator (safe in cmd.exe, unlike "|")
    LET SEP_ENTRY#   = ","      ' between header entries
    LET SEP_PAIR#    = ":"      ' between ascii code and count
    LET NO_SYMBOL#   = -1       ' marks an internal tree node / missing child

    LET mode$     = ""
    LET text$     = ""
    LET package$  = ""
    LET header$   = ""
    LET bits$     = ""
    LET decoded$  = ""
    LET errorMsg$ = ""

    ' Symbol table, index 0..symCount$-1 in order of first appearance
    DIM symCode$                ' symCode$(i)    = ASCII code of symbol i
    DIM symFreq$                ' symFreq$(i)    = occurrences of symbol i
    DIM symIndex$               ' symIndex$(asc) = i (reverse lookup / duplicate check)
    LET symCount$  = 0
    LET totalFreq$ = 0

    ' Huffman tree as parallel arrays. Leaves are 0..symCount$-1,
    ' internal nodes are appended after them. The last node is the root.
    DIM nodeWeight$, nodeLeft$, nodeRight$, nodeSym$, nodeUsed$
    LET nodeCount$   = 0
    LET activeCount$ = 0
    LET rootNode$    = NO_SYMBOL#
    LET picked$      = 0
    LET firstPick$   = 0
    LET secondPick$  = 0

    ' Code table: huffCode$(asc) = "0101" (always a STRING of 0/1 chars)
    DIM huffCode$

    ' Explicit stack for walking the tree (no recursion needed)
    DIM stackNode$, stackCode$
    LET stackTop$ = 0
    LET curNode$  = 0
    LET curCode$  = ""

    ' Parsing / misc helpers
    DIM entries$, pair$
    LET entryCount$ = 0
    LET pairCount$  = 0
    LET sepPos$     = 0
    LET ch$         = 0
    LET idx$        = 0
    LET bit$        = ""
    LET newCode$    = 0
    LET newFreq$    = 0
    LET label$      = ""
    LET origBits$   = 0
    LET ratio$      = 0

[main]
    IF ARGCOUNT <> 2 THEN
        GOSUB [sub:usage]
        END
    END IF

    ' String "=" is case-insensitive in BazzBasic, so -ENCODE works too.
    mode$ = ARGS(0)

    IF mode$ = "-encode" THEN
        text$ = "" + ARGS(1)        ' "" + forces a string, even for input like 2024
        GOSUB [sub:encode]
    ELSEIF mode$ = "-decode" THEN
        package$ = "" + ARGS(1)
        GOSUB [sub:decode]
    ELSE
        errorMsg$ = "Unknown mode '" + mode$ + "'. Use -encode or -decode."
    END IF

    IF errorMsg$ <> "" THEN PRINT "Error: "; errorMsg$
END

' ============================================
' Top-level operations
' ============================================

[sub:usage]
    PRINT "Huffman coding demo"
    PRINT "  BazzBasic.exe huffman.bas -encode \"text to encode\""
    PRINT "  BazzBasic.exe huffman.bas -decode \"<package from -encode>\""
RETURN

[sub:encode]
    IF LEN(text$) = 0 THEN
        errorMsg$ = "Nothing to encode."
    ELSE
        GOSUB [sub:countSymbols]
        GOSUB [sub:buildTree]
        GOSUB [sub:buildCodes]

        ' Replace each character with its code
        bits$ = ""
        FOR pos$ = 1 TO LEN(text$)
            bits$ += huffCode$(ASC(MID(text$, pos$, 1)))
        NEXT

        GOSUB [sub:makeHeader]
        GOSUB [sub:printTable]

        origBits$ = LEN(text$) * 8
        ratio$    = ROUND(LEN(bits$) / origBits$ * 1000) / 10
        PRINT ""
        PRINT "Original : "; origBits$; " bits (8 bits per char)"
        PRINT "Encoded  : "; LEN(bits$); " bits ("; ratio$; "% of original, header not counted)"
        PRINT "Bits     : "; bits$
        PRINT "Package  : "; header$ + SEP_PACKAGE# + bits$
    END IF
RETURN

[sub:decode]
    sepPos$ = INSTR(package$, SEP_PACKAGE#)
    IF sepPos$ = 0 THEN
        errorMsg$ = "Package must look like <header>/<bits>. Did you pass only the bits?"
    ELSE
        header$ = LEFT(package$, sepPos$ - 1)
        bits$   = MID(package$, sepPos$ + 1)
        IF LEN(bits$) = 0 THEN errorMsg$ = "Package contains no bits."
    END IF

    IF errorMsg$ = "" THEN GOSUB [sub:parseHeader]

    IF errorMsg$ = "" THEN
        GOSUB [sub:buildTree]       ' same counts + same tie-break = same tree
        GOSUB [sub:buildCodes]
        GOSUB [sub:printTable]
        GOSUB [sub:walkBits]
    END IF

    IF errorMsg$ = "" THEN
        PRINT ""
        PRINT "Decoded  : "; decoded$
    END IF
RETURN

' ============================================
' Building blocks
' ============================================

[sub:countSymbols]
    ' Frequencies, keyed by ASCII code. Codes are used instead of the characters
    ' themselves because array keys are case-sensitive but "=" is not - numbers
    ' are unambiguous both ways.
    FOR pos$ = 1 TO LEN(text$)
        ch$ = ASC(MID(text$, pos$, 1))
        IF HASKEY(symIndex$(ch$)) THEN
            idx$ = symIndex$(ch$)
            symFreq$(idx$) = symFreq$(idx$) + 1
        ELSE
            symIndex$(ch$)       = symCount$
            symCode$(symCount$)  = ch$
            symFreq$(symCount$)  = 1
            symCount$ += 1
        END IF
    NEXT
    totalFreq$ = LEN(text$)
RETURN

[sub:parseHeader]
    ' "72:1,101:1,..." -> symCode$ / symFreq$ in the SAME order the encoder used
    entryCount$ = SPLIT(entries$, header$, SEP_ENTRY#)
    FOR e$ = 0 TO entryCount$ - 1
        IF errorMsg$ = "" THEN
            pairCount$ = SPLIT(pair$, entries$(e$), SEP_PAIR#)
            IF pairCount$ <> 2 THEN
                errorMsg$ = "Bad header entry '" + entries$(e$) + "'."
            ELSE
                newCode$ = VAL(pair$(0))
                newFreq$ = VAL(pair$(1))
                IF newCode$ < 1 OR newFreq$ < 1 THEN
                    errorMsg$ = "Bad header entry '" + entries$(e$) + "'."
                ELSEIF HASKEY(symIndex$(newCode$)) THEN
                    errorMsg$ = "Symbol " + newCode$ + " appears twice in header."
                ELSE
                    symIndex$(newCode$)  = symCount$
                    symCode$(symCount$)  = newCode$
                    symFreq$(symCount$)  = newFreq$
                    totalFreq$ += newFreq$
                    symCount$ += 1
                END IF
            END IF
        END IF
    NEXT
RETURN

[sub:buildTree]
    ' One leaf per symbol
    FOR leaf$ = 0 TO symCount$ - 1
        nodeWeight$(leaf$) = symFreq$(leaf$)
        nodeLeft$(leaf$)   = NO_SYMBOL#
        nodeRight$(leaf$)  = NO_SYMBOL#
        nodeSym$(leaf$)    = symCode$(leaf$)
        nodeUsed$(leaf$)   = FALSE
    NEXT
    nodeCount$   = symCount$
    activeCount$ = symCount$

    ' Repeatedly merge the two lightest unused nodes into a new parent
    WHILE activeCount$ > 1
        GOSUB [sub:pickLightest]
        firstPick$ = picked$
        GOSUB [sub:pickLightest]
        secondPick$ = picked$

        nodeWeight$(nodeCount$) = nodeWeight$(firstPick$) + nodeWeight$(secondPick$)
        nodeLeft$(nodeCount$)   = firstPick$      ' left  = bit 0
        nodeRight$(nodeCount$)  = secondPick$     ' right = bit 1
        nodeSym$(nodeCount$)    = NO_SYMBOL#
        nodeUsed$(nodeCount$)   = FALSE
        nodeCount$   += 1
        activeCount$ -= 1
    WEND
    rootNode$ = nodeCount$ - 1
RETURN

[sub:pickLightest]
    ' Lowest weight wins; on a tie the LOWEST index wins (strict "<").
    ' This fixed rule is what makes encoder and decoder build identical trees.
    ' Two separate IFs on purpose: BazzBasic does not short-circuit OR, so
    ' "picked$ = -1 OR nodeWeight$(scan$) < nodeWeight$(picked$)" would read
    ' nodeWeight$(-1), which does not exist.
    picked$ = NO_SYMBOL#
    FOR scan$ = 0 TO nodeCount$ - 1
        IF nodeUsed$(scan$) = FALSE THEN
            IF picked$ = NO_SYMBOL# THEN
                picked$ = scan$
            ELSEIF nodeWeight$(scan$) < nodeWeight$(picked$) THEN
                picked$ = scan$
            END IF
        END IF
    NEXT
    nodeUsed$(picked$) = TRUE
RETURN

[sub:buildCodes]
    ' Walk the tree with an explicit stack; path to a leaf = its code.
    IF nodeSym$(rootNode$) <> NO_SYMBOL# THEN
        ' Only one distinct symbol (e.g. "aaaa"): the root is a leaf and the
        ' path would be empty, so give it the 1-bit code "0".
        huffCode$(nodeSym$(rootNode$)) = "0"
    ELSE
        stackNode$(0) = rootNode$
        stackCode$(0) = ""
        stackTop$ = 1
        WHILE stackTop$ > 0
            stackTop$ -= 1
            curNode$ = stackNode$(stackTop$)
            curCode$ = stackCode$(stackTop$)
            IF nodeSym$(curNode$) <> NO_SYMBOL# THEN
                huffCode$(nodeSym$(curNode$)) = curCode$
            ELSE
                stackNode$(stackTop$) = nodeRight$(curNode$)
                stackCode$(stackTop$) = curCode$ + "1"
                stackTop$ += 1
                stackNode$(stackTop$) = nodeLeft$(curNode$)
                stackCode$(stackTop$) = curCode$ + "0"
                stackTop$ += 1
            END IF
        WEND
    END IF
RETURN

[sub:makeHeader]
    header$ = ""
    FOR h$ = 0 TO symCount$ - 1
        IF h$ > 0 THEN header$ += SEP_ENTRY#
        header$ += symCode$(h$) + SEP_PAIR# + symFreq$(h$)
    NEXT
RETURN

[sub:printTable]
    PRINT "Symbol  Count  Code"
    FOR t$ = 0 TO symCount$ - 1
        label$ = "'" + CHR(symCode$(t$)) + "'"
        PRINT LEFT(label$ + REPEAT(" ", 8), 8);
        PRINT LEFT(STR(symFreq$(t$)) + REPEAT(" ", 7), 7);
        PRINT huffCode$(symCode$(t$))
    NEXT
RETURN

[sub:walkBits]
    ' 0 = go left, 1 = go right; reaching a leaf emits a char and restarts at root
    decoded$ = ""
    curNode$ = rootNode$
    FOR b$ = 1 TO LEN(bits$)
        IF errorMsg$ = "" THEN
            bit$ = MID(bits$, b$, 1)
            IF bit$ <> "0" AND bit$ <> "1" THEN
                errorMsg$ = "Invalid character '" + bit$ + "' in bits at position " + b$ + "."
            ELSEIF nodeSym$(rootNode$) <> NO_SYMBOL# THEN
                ' Single-symbol tree: every "0" is one character
                IF bit$ = "0" THEN
                    decoded$ += CHR(nodeSym$(rootNode$))
                ELSE
                    errorMsg$ = "Bit '1' is impossible for a single-symbol tree."
                END IF
            ELSE
                IF bit$ = "0" THEN
                    curNode$ = nodeLeft$(curNode$)
                ELSE
                    curNode$ = nodeRight$(curNode$)
                END IF
                IF nodeSym$(curNode$) <> NO_SYMBOL# THEN
                    decoded$ += CHR(nodeSym$(curNode$))
                    curNode$ = rootNode$
                END IF
            END IF
        END IF
    NEXT

    ' Integrity checks: no half-finished code, and the length must match the counts
    IF errorMsg$ = "" AND curNode$ <> rootNode$ THEN
        errorMsg$ = "Bits end in the middle of a code - package is truncated."
    ELSEIF errorMsg$ = "" AND LEN(decoded$) <> totalFreq$ THEN
        errorMsg$ = "Decoded " + LEN(decoded$) + " chars but header says " + totalFreq$ + "."
    END IF
RETURN

' Output:
' > BazzBasic.exe huffman.bas -encode "this is an example for huffman encoding"
' Symbol  Count  Code
' 't'     1      01010
' 'h'     2      11111
' 'i'     3      1001
' 's'     2      0010
' ' '     6      101
' 'a'     3      1100
' 'n'     4      000
' 'e'     3      1101
' 'x'     1      01011
' 'm'     2      0011
' 'p'     1      01100
' 'l'     1      01101
' 'f'     3      1110
' 'o'     2      0100
' 'r'     1      01110
' 'u'     1      01111
' 'c'     1      10000
' 'd'     1      10001
' 'g'     1      11110

' Original : 312 bits (8 bits per char)
' Encoded  : 157 bits (50.3% of original, header not counted)
' Bits     : 0101011111100100101011001001010111000001011101010111100001101100011011101101111001000111010111111011111110111000111100000101110100010000010010001100100011110
' Package  : 116:1,104:2,105:3,115:2,32:6,97:3,110:4,101:3,120:1,109:2,112:1,108:1,102:3,111:2,114:1,117:1,99:1,100:1,103:1/0101011111100100101011001001010111000001011101010111100001101100011011101101111001000111010111111011111110111000111100000101110100010000010010001100100011110

' Output:
' > BazzBasic.exe huffman.bas -decode "116:1,104:2,105:3,115:2,32:6,97:3,110:4,101:3,120:1,109:2,112:1,108:1,102:3,111:2,114:1,117:1,99:1,100:1,103:1/0101011111100100101011001001010111000001011101010111100001101100011011101101111001000111010111111011111110111000111100000101110100010000010010001100100011110"
' Symbol  Count  Code
' 't'     1      01010
' 'h'     2      11111
' 'i'     3      1001
' 's'     2      0010
' ' '     6      101
' 'a'     3      1100
' 'n'     4      000
' 'e'     3      1101
' 'x'     1      01011
' 'm'     2      0011
' 'p'     1      01100
' 'l'     1      01101
' 'f'     3      1110
' 'o'     2      0100
' 'r'     1      01110
' 'u'     1      01111
' 'c'     1      10000
' 'd'     1      10001
' 'g'     1      11110

' Decoded  : this is an example for huffman encoding