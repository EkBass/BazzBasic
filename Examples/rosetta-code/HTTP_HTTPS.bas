' ============================================
' https://rosettacode.org/wiki/HTTP
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' HTTPGET supports both, HTTP and HTTPS calls
LET response$ = HTTPGET("https://ekbass.github.io/BazzBasic/")
PRINT response$
