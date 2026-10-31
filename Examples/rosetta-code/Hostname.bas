' ============================================
' ROSETTA: https://rosettacode.org/wiki/Hostname
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Reads the computer's hostname with SHELL and prints it.
' CATEGORY: system
' TAGS: hostname, shell, computer name
' MINVERSION: 1.5
' ============================================
[inits]
    LET resp$

[main]
    resp$ = SHELL("HOSTNAME")

[output]
    PRINT resp$

' Output:
' EK-Lenovo