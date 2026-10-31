' ============================================
' ROSETTA: https://rosettacode.org/wiki/Chinese_zodiac
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the Chinese zodiac element, animal, yin/yang polarity and cycle year for a list of given years.
' CATEGORY: system
' TAGS: chinese zodiac, calendar, modulo, lookup tables
' MINVERSION: 1.5
' ============================================

[inits]
    DIM animals$, elements$, polarities$, years$
    LET count$ = SPLIT(animals$, "Rat,Ox,Tiger,Rabbit,Dragon,Snake,Horse,Goat,Monkey,Rooster,Dog,Pig", ",")
    count$ = SPLIT(elements$, "Wood,Fire,Earth,Metal,Water", ",")
    count$ = SPLIT(polarities$, "Yang,Yin", ",")
    count$ = SPLIT(years$, "1935,1938,1968,1972,1976,1984,2017", ",")

    LET year$ = 0
    LET element$ = ""
    LET animal$ = ""
    LET polarity$ = ""
    LET cycle$ = 0

[main]
    PRINT " ****       Chinese zodiac       ****"
    PRINT ""
    FOR i$ = 0 TO count$ - 1
        year$     = VAL(years$(i$))
        element$  = elements$(INT(MOD(year$ - 4, 10) / 2))
        animal$   = animals$(MOD(year$ - 4, 12))
        polarity$ = polarities$(MOD(year$, 2))
        cycle$    = MOD(year$ - 4, 60) + 1
        PRINT FSTRING("{{-year$-}} is the year of the {{-element$-}} {{-animal$-}} ({{-polarity$-}}), year {{-cycle$-}} of the cycle.")
    NEXT
END

' Output:
'  ****       Chinese zodiac       ****
'
' 1935 is the year of the Wood Pig (Yin), year 12 of the cycle.
' 1938 is the year of the Earth Tiger (Yang), year 15 of the cycle.
' 1968 is the year of the Earth Monkey (Yang), year 45 of the cycle.
' 1972 is the year of the Water Rat (Yang), year 49 of the cycle.
' 1976 is the year of the Fire Dragon (Yang), year 53 of the cycle.
' 1984 is the year of the Wood Rat (Yang), year 1 of the cycle.
' 2017 is the year of the Fire Rooster (Yin), year 34 of the cycle.