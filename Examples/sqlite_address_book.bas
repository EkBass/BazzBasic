REM ============================================================
REM SQLite Address Book - companion example for docs/manual/sqlite.md
REM
REM Requires sqlite3 in PATH:
REM    winget install SQLite.SQLite
REM    (then open a fresh terminal)
REM
REM Walks through every operation covered in the manual page:
REM   create table, insert, select, update, delete, count, search,
REM   error handling.
REM ============================================================

LET DB# = "contacts.db"

REM Clean slate so the demo is repeatable
LET out$ = SHELL("sqlite3 " + DB# + " \"DROP TABLE IF EXISTS contacts\" 2>&1")

PRINT "=== Creating table ==="
LET sql$ = "CREATE TABLE contacts (" +
           "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
           "name TEXT NOT NULL, " +
           "phone TEXT, " +
           "address TEXT, " +
           "email TEXT)"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEN(out$) > 0 THEN
    PRINT "Error: " + out$
    END
END IF
PRINT "Table ready."
PRINT ""

PRINT "=== Inserting rows ==="
LET sql$ = "INSERT INTO contacts (name, phone, address, email) VALUES " +
           "('Krisu Virtanen', '+358 45 340 1515', 'Viljakkala', 'krisu.virtanen@gmail.com'), " +
           "('Jane Doe',       '+1 555 1234',      'New York',  'jane@example.com'), " +
           "('John Smith',     '+44 20 7946 0958', 'London',    'john.s@example.com')"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEN(out$) > 0 THEN PRINT "Error: " + out$
PRINT "3 rows inserted."
PRINT ""

PRINT "=== Listing all contacts ==="
LET cmd$ = "sqlite3 " + DB# +
           " \"SELECT id, name, phone, email FROM contacts ORDER BY name\" 2>&1"
LET out$ = SHELL(cmd$)

DIM lines$
LET nLines$ = SPLIT(lines$, out$, CHR(10))
FOR i$ = 0 TO nLines$ - 1
    LET row$ = TRIM(lines$(i$))
    IF LEN(row$) > 0 THEN
        DIM cells$
        LET nCells$ = SPLIT(cells$, row$, "|")
        PRINT "  [" + cells$(0) + "] " + cells$(1)
        PRINT "      phone: " + cells$(2)
        PRINT "      email: " + cells$(3)
    END IF
NEXT i$
PRINT ""

PRINT "=== Updating Krisu's phone ==="
LET sql$ = "UPDATE contacts SET phone='+358 50 999 0000' WHERE name='Krisu Virtanen'"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEN(out$) > 0 THEN PRINT "Error: " + out$

LET cmd$ = "sqlite3 " + DB# +
           " \"SELECT phone FROM contacts WHERE name='Krisu Virtanen'\" 2>&1"
PRINT "New phone: " + TRIM(SHELL(cmd$))
PRINT ""

PRINT "=== Counting rows ==="
LET cmd$ = "sqlite3 " + DB# + " \"SELECT COUNT(*) FROM contacts\" 2>&1"
PRINT "Total: " + TRIM(SHELL(cmd$))
PRINT ""

PRINT "=== Searching with LIKE ==="
LET sql$ = "SELECT name FROM contacts WHERE name LIKE '%doe%' COLLATE NOCASE"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
PRINT "Match: " + TRIM(SHELL(cmd$))
PRINT ""

PRINT "=== Deleting John Smith ==="
LET sql$ = "DELETE FROM contacts WHERE name='John Smith'"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEN(out$) > 0 THEN PRINT "Error: " + out$

LET cmd$ = "sqlite3 " + DB# + " \"SELECT COUNT(*) FROM contacts\" 2>&1"
PRINT "Remaining: " + TRIM(SHELL(cmd$))
PRINT ""

PRINT "=== Error handling demo ==="
LET cmd$ = "sqlite3 " + DB# + " \"SELECT FOOBAR FROM contacts\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEFT(out$, 6) = "Error:" THEN
    PRINT "Caught a SQL error - the program kept running."
    PRINT "Details: " + TRIM(out$)
END IF
PRINT ""

PRINT "Demo complete. Database file: " + DB#
END