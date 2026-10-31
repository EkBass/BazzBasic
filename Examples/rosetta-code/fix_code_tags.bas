' ============================================
' ROSETTA: https://rosettacode.org/wiki/Rosetta_Code/Fix_code_tags
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Rosetta Code wiki task: converts old lang tags (opening tags with or without a language name, and closing tags) in wiki text to the current syntax highlighting tags, leaving other tags untouched, and prints three sample texts before and after.
' CATEGORY: strings
' TAGS: tag conversion, text replacement, wiki markup, instr, def fn
' MINVERSION: 1.5
' ============================================
' (SH below stands for the word "syntax" + "highlight". The full tag can't be
'  written literally here, or it would end the wiki's own code block.)
'
' Change <lang %s> to <SH lang=%s>
' Change <lang>    to <SH lang=text>
' Change </lang>   to </SH>
' Whitespace and optional quotes around the language name are tolerated.
' Tags whose "name" is not a plain language name (e.g. <lang $1>) are left as is.

' Tag name built in two parts so it never appears literally in the source
LET SH# = "syntax" + "highlight"

' Characters allowed in a language name, and whitespace characters
LET LANG_CHARS# = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
LET WS# = " \t\r\n"

' TRUE if s$ is a non-empty string made of LANG_CHARS# only
DEF FN IsLangName$(s$)
    LET ok$ = LEN(s$) > 0
    LET i$ = 1
    WHILE ok$ AND i$ <= LEN(s$)
        IF INSTR(LANG_CHARS#, MID(s$, i$, 1)) = 0 THEN ok$ = FALSE
        i$ += 1
    WEND
    RETURN ok$
END DEF

' tag$ is the text between "<" and ">".
' Returns the replacement tag, or "" if the tag must be left untouched.
DEF FN ConvertTag$(tag$)
    LET rest$, name$

    ' </lang> with optional trailing whitespace
    IF INSTR(tag$, "/lang") = 1 THEN
        IF TRIM(MID(tag$, 6)) = "" THEN RETURN "</" + SH# + ">"
        RETURN ""
    END IF

    IF INSTR(tag$, "lang") <> 1 THEN RETURN ""
    rest$ = MID(tag$, 5)

    ' <lang> with optional whitespace
    IF TRIM(rest$) = "" THEN RETURN "<" + SH# + " lang=text>"

    ' <lang name>: "lang" must be followed by whitespace (rejects <language> etc.)
    IF INSTR(WS#, LEFT(rest$, 1)) = 0 THEN RETURN ""

    name$ = TRIM(rest$)
    IF LEFT(name$, 1) = "\"" THEN name$ = MID(name$, 2)
    IF LEN(name$) > 0 THEN
        IF RIGHT(name$, 1) = "\"" THEN name$ = LEFT(name$, LEN(name$) - 1)
    END IF
    name$ = TRIM(name$)

    IF FN IsLangName$(name$) = FALSE THEN RETURN ""
    RETURN "<" + SH# + " lang=" + name$ + ">"
END DEF

' Scan src$ for <...> tags and convert the lang tags
DEF FN FixTags$(src$)
    LET result$ = ""
    LET from$ = 1
    LET at$ = INSTR(1, src$, "<")
    LET gt$ = 0
    LET repl$ = ""

    WHILE at$ > 0
        IF at$ > from$ THEN result$ += MID(src$, from$, at$ - from$)

        repl$ = ""
        gt$ = INSTR(at$, src$, ">")
        IF gt$ > 0 THEN repl$ = FN ConvertTag$(MID(src$, at$ + 1, gt$ - at$ - 1))

        IF repl$ = "" THEN
            ' not a lang tag: keep the "<" and continue right after it
            result$ += "<"
            from$ = at$ + 1
        ELSE
            result$ += repl$
            from$ = gt$ + 1
        END IF

        at$ = INSTR(from$, src$, "<")
    WEND

    IF from$ <= LEN(src$) THEN result$ += MID(src$, from$)
    RETURN result$
END DEF

[inits]
    DIM tests$
    tests$(0) = "<lang AutoHotkey>; usage: > fixtags.ahk input.txt ouput.txt\n" +
        "FileRead, text, %1%\n" +
        "langs = ada,awk,autohotkey,etc\n" +
        "slang = /lang\n" +
        "slang := \"<\" . slang . \"/>\"\n" +
        "Loop, Parse, langs, `,\n" +
        "{\n" +
        "  tag1 = <%A_LoopField%>\n" +
        "  tag2 = </%A_LoopField%>\n" +
        "  text := RegExReplace(text, tag1, \"<lang \" . A_LoopField . \">\")\n" +
        "  text := RegExReplace(text, tag2, slang)\n" +
        "  text := RegExReplace(text, \"<code (.+?)>(.*?)</code>\"\n" +
        "          , \"<lang $1>$2\" . slang)\n" +
        "}\n" +
        "FileAppend, % text, %2%\n" +
        "</lang>"

    tests$(1) = "<lang perl>my @langs = qw(ada cpp-qt pascal lscript z80 visualprolog\n" +
        "html4strict cil objc asm progress teraterm hq9plus genero tsql\n" +
        "email pic16 tcl apt_sources io apache vhdl avisynth winbatch\n" +
        "vbnet ini scilab ocaml-brief sas actionscript3 qbasic perl bnf\n" +
        "cobol powershell php kixtart visualfoxpro mirc make javascript\n" +
        "cpp sdlbasic cadlisp php-brief rails verilog xml csharp\n" +
        "actionscript nsis bash typoscript freebasic dot applescript\n" +
        "haskell dos oracle8 cfdg glsl lotusscript mpasm latex sql klonec\n" +
        "ruby ocaml smarty python oracle11 caddcl robots groovy smalltalk\n" +
        "diff fortran cfm lua modula3 vb autoit java text scala\n" +
        "lotusformulas pixelbender reg _div whitespace providex asp css\n" +
        "lolcode lisp inno mysql plsql matlab oobas vim delphi xorg_conf\n" +
        "gml prolog bf per scheme mxml d basic4gl m68k gnuplot idl abap\n" +
        "intercal c_mac thinbasic java5 xpp boo klonecpp blitzbasic eiffel\n" +
        "povray c gettext);\n" +
        "\n" +
        "my $text = join \"\", <STDIN>;\n" +
        "my $slang=\"/lang\";\n" +
        "for (@langs) {\n" +
        "    $text =~ s|<$_>|<lang $_>|g;\n" +
        "    $text =~ s|</$_>|<$slang>|g;\n" +
        "}\n" +
        "\n" +
        "$text =~ s|<code (.+?)>(.*?)</code>|<lang $1>$2<$slang>|sg;\n" +
        "\n" +
        "print $text;</lang>"

    tests$(2) = "<lang>HAI 1.3\n" +
        "\n" +
        "I HAS A bottles ITZ 99 I HAS A plural ITZ \"Z\" I HAS A lyric ITZ \"99 BOTTLZ OV BEER\"\n" +
        "\n" +
        "IM IN YR song\n" +
        "\n" +
        "   VISIBLE lyric \" ON TEH WALL\"\n" +
        "   VISIBLE lyric\n" +
        "   VISIBLE \"TAEK 1 DOWN, PAZ IT AROUN\"\n" +
        "   bottles R DIFF OF bottles AN 1\n" +
        "   NOT bottles, O RLY?\n" +
        "       YA RLY, VISIBLE \"NO MOAR BOTTLZ OV BEER ON TEH WALL\", GTFO\n" +
        "   OIC\n" +
        "   BOTH SAEM bottles AN 1, O RLY?\n" +
        "       YA RLY, plural R \"\"\n" +
        "   OIC\n" +
        "   lyric R SMOOSH bottles \" BOTTL\" plural \" OV BEER\" MKAY\n" +
        "   VISIBLE lyric \" ON TEH WALL:)\"\n" +
        "IM OUTTA YR song\n" +
        "\n" +
        "KTHXBYE</lang>\n"

[main]
    FOR i$ = 0 TO ROWCOUNT(tests$()) - 1
        PRINT tests$(i$)
        PRINT "=>"
        PRINT FN FixTags$(tests$(i$))
        PRINT
    NEXT
END

' Output (tag lines only; everything else is printed unchanged):
' (SH = "syntax" + "highlight", see header)
' <lang AutoHotkey>; usage: ...          =>  <SH lang=AutoHotkey>; usage: ...
'   text := RegExReplace(text, tag1, "<lang " . A_LoopField . ">")   (unchanged)
'           , "<lang $1>$2" . slang)                                  (unchanged)
' </lang>                                 =>  </SH>
' <lang perl>my @langs = ...             =>  <SH lang=perl>my @langs = ...
'     $text =~ s|<$_>|<lang $_>|g;                                    (unchanged)
' $text =~ s|<code (.+?)>(.*?)</code>|<lang $1>$2<$slang>|sg;         (unchanged)
' print $text;</lang>                    =>  print $text;</SH>
' <lang>HAI 1.3                          =>  <SH lang=text>HAI 1.3
' KTHXBYE</lang>                         =>  KTHXBYE</SH>
