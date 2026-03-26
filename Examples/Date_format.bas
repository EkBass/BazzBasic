' ============================================
' https://rosettacode.org/wiki/Date_format
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Task: Display the current date in two formats:
'   2007-11-23
'   Friday, November 23, 2007
' ============================================

PRINT TIME("yyyy-MM-dd")          ' e.g. 2026-03-26
PRINT TIME("dddd, MMMM dd, yyyy") ' e.g. Thursday, March 26, 2026
END

' Other TIME() format examples:
' PRINT TIME()              ' Default time:   "16:30:45"
' PRINT TIME("HH:mm:ss")   ' 24-hour clock:  "16:30:45"
' PRINT TIME("HH:mm")      ' Short time:     "16:30"
' PRINT TIME("dd.MM.yyyy") ' European date:  "26.03.2026"
' PRINT TIME("MMMM")       ' Month name:     "March"
' PRINT TIME("dddd")       ' Weekday name:   "Thursday"
