' ============================================
' ROSETTA: https://rosettacode.org/wiki/Terminal_control/Ringing_the_terminal_bell
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Rings the terminal bell by printing the BEL character (ASCII 7).
' CATEGORY: system
' TAGS: terminal bell, bel character, chr, terminal control
' MINVERSION: 1.5
' ============================================

[inits]
    LET BELL# = CHR(7)

[main]
    PRINT BELL#
END
