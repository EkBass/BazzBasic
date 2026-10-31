' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Error test: SAVESCREEN with a .jpg file name must stop the program with a line-numbered error (only .png is allowed), so the FILEWRITE after it must never run.
' CATEGORY: drawing
' TAGS: regression test, savescreen, error handling
' MINVERSION: 1.5
' ============================================
SCREEN 0, 100, 100
SAVESCREEN "nope.jpg"
FILEWRITE "savescreen_err_test.log", "SHOULD NOT RUN"
END
