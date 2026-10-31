' ============================================
' ROSETTA: https://rosettacode.org/wiki/Environment_variables
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the value of the PATH environment variable by running echo through SHELL.
' CATEGORY: system
' TAGS: environment variables, path, shell
' MINVERSION: 1.5
' ============================================
PRINT SHELL("echo %PATH%")
END
