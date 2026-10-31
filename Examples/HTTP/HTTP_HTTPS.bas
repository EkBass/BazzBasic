' ============================================
' ROSETTA: https://rosettacode.org/wiki/HTTP
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Fetches the BazzBasic homepage over HTTPS with HTTPGET and prints the returned HTML.
' CATEGORY: network
' TAGS: httpget, http, https
' MINVERSION: 1.5
' ============================================

' HTTPGET supports both, HTTP and HTTPS calls
LET response$ = HTTPGET("https://ekbass.github.io/BazzBasic/")
PRINT response$
