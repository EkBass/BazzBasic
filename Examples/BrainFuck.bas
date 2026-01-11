' ============================================
' BRAINFUCK INTERPRETER - BazzBasic Edition
' ============================================
' A simple BF interpreter demonstrating
' BazzBasic's string and array capabilities
' ============================================
' https://github.com/EkBass/BazzBasic


' Color constants
LET BLACK# = 0
LET CYAN# = 11
LET YELLOW# = 14
LET WHITE# = 15
LET LGRAY# = 7
LET LGREEN# = 10
LET LRED# = 12

' BF virtual machine
LET memSize# = 1000
DIM mem$
LET ptr$ = 0
LET pc$ = 1

' Initialize memory to zero
FOR i$ = 0 TO memSize# - 1
    mem$(i$) = 0
NEXT

GOSUB [title]

' ============================================
' TEST PROGRAMS - uncomment one to run
' ============================================

' Hello World!
' LET code$ = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>. >---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

' Cat program (echoes input) - use with caution, needs input!
' LET code$ = ",[.,]"

' Adds two single-digit numbers (input: e.g. "23" outputs "5")
'LET code$ = ",>,[<+>-]<------------------------------------------------."

GOSUB [run]

COLOR WHITE#, BLACK#
PRINT "\n\nDone!"
END

' ============================================
' TITLE
' ============================================
[title]
    CLS
    COLOR YELLOW#, BLACK#
    PRINT "\n "; REPEAT("*", 40)
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " *     ";
    COLOR WHITE#, BLACK#
    PRINT "BRAINFUCK INTERPRETER";
    COLOR YELLOW#, BLACK#
    PRINT "          *"
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " "; REPEAT("*", 40)
    
    COLOR LGRAY#, BLACK#
    PRINT "\n BazzBasic Edition\n"
    
    COLOR CYAN#, BLACK#
    PRINT " Operators: > < + - [ ] , .\n"
    
    COLOR WHITE#, BLACK#
    PRINT REPEAT("-", 45)
    PRINT "\n Running program...\n"
    COLOR LGREEN#, BLACK#
    PRINT " Output: ";
RETURN

' ============================================
' MAIN INTERPRETER
' ============================================
[run]
    LET codeLen$ = LEN(code$)
    
    WHILE pc$ <= codeLen$
        LET op$ = MID(code$, pc$, 1)
        
        ' > move pointer right
        IF op$ = ">" THEN
            ptr$ = ptr$ + 1
            IF ptr$ >= memSize# THEN ptr$ = 0
        ENDIF
        
        ' < move pointer left
        IF op$ = "<" THEN
            ptr$ = ptr$ - 1
            IF ptr$ < 0 THEN ptr$ = memSize# - 1
        ENDIF
        
        ' + increment
        IF op$ = "+" THEN
            mem$(ptr$) = mem$(ptr$) + 1
            IF mem$(ptr$) > 255 THEN mem$(ptr$) = 0
        ENDIF
        
        ' - decrement
        IF op$ = "-" THEN
            mem$(ptr$) = mem$(ptr$) - 1
            IF mem$(ptr$) < 0 THEN mem$(ptr$) = 255
        ENDIF
        
        ' . output
        IF op$ = "." THEN
            PRINT CHR(mem$(ptr$));
        ENDIF
        
        ' , input
        IF op$ = "," THEN
            INPUT "", inp$
            IF LEN(inp$) > 0 THEN
                mem$(ptr$) = ASC(inp$)
            ELSE
                mem$(ptr$) = 0
            ENDIF
        ENDIF
        
        ' [ loop start
        IF op$ = "[" THEN
            IF mem$(ptr$) = 0 THEN
                ' Jump forward to matching ]
                LET depth$ = 1
                WHILE depth$ > 0
                    pc$ = pc$ + 1
                    LET ch$ = MID(code$, pc$, 1)
                    IF ch$ = "[" THEN depth$ = depth$ + 1
                    IF ch$ = "]" THEN depth$ = depth$ - 1
                WEND
            ENDIF
        ENDIF
        
        ' ] loop end
        IF op$ = "]" THEN
            IF mem$(ptr$) <> 0 THEN
                ' Jump back to matching [
                LET depth$ = 1
                WHILE depth$ > 0
                    pc$ = pc$ - 1
                    LET ch$ = MID(code$, pc$, 1)
                    IF ch$ = "]" THEN depth$ = depth$ + 1
                    IF ch$ = "[" THEN depth$ = depth$ - 1
                WEND
            ENDIF
        ENDIF
        
        pc$ = pc$ + 1
    WEND
RETURN
