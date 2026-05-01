# SQLite Database

SQLite is a small, fast, file-based database engine that fits BazzBasic perfectly: no server to install, no daemon to manage, and the whole database lives in a single file you can copy, back up, or delete like any other. This page shows how to use it from BazzBasic without any external library — we just call the official `sqlite3` command-line tool through `SHELL()`.

This guide gets you started with create / read / update / delete on a small address book. For everything else (transactions, joins, indexes, full-text search, …), the official [SQLite documentation](https://sqlite.org/lang.html) is excellent.

## Prerequisites

You need the `sqlite3` command-line tool installed and on your `PATH`.

**Windows (recommended):**
```
winget install SQLite.SQLite
```

You can also download the official ZIP from <https://sqlite.org/download.html> (look for `sqlite-tools-win-x64-*.zip`) and extract `sqlite3.exe` somewhere on your `PATH`, e.g. `C:\sqlite\`.

> **Important:** After installing, **open a new terminal window** before running BazzBasic. Existing terminals (and editors that spawn terminals) keep the old `PATH` and will not find `sqlite3` until restarted.

Verify the install:
```
sqlite3 -version
```

You should see something like `3.50.4 2025-07-30 ...`. Any 3.x version is fine for this guide.

## How it works

BazzBasic talks to SQLite by running the `sqlite3` command-line tool with `SHELL()`:

```vb
LET out$ = SHELL("sqlite3 mydata.db \"SELECT * FROM contacts\" 2>&1")
PRINT out$
```

A few things to know:

- `SHELL(cmd$)` runs `cmd$` through the OS shell and returns whatever it printed to standard output as a string.
- The trailing `2>&1` redirects error output into the same stream, so SQL errors come back as part of the returned string instead of vanishing silently.
- The outer SQL statement must be wrapped in double quotes for the OS shell. Inside a BazzBasic string, write `"` as `\"` — the backslash is BazzBasic's escape character.
- Each `SHELL()` call starts a new `sqlite3` process. That is fine for a few hundred queries; if you need to insert tens of thousands of rows, batch them into a single call.

Inside the SQL itself, **single quotes** are used for text literals: `'Krisu'`, `'krisu@gmail.com'`, etc. Avoid putting single quotes inside user-supplied data for now — see *Limitations* below.

## The running example

We will build a simple address book. The schema:

| Column   | Type    | Note                          |
|----------|---------|-------------------------------|
| id       | INTEGER | Primary key, auto-increment   |
| name     | TEXT    | Required                      |
| phone    | TEXT    | Optional                      |
| address  | TEXT    | Optional                      |
| email    | TEXT    | Optional                      |

The database file path goes into a constant so we only write it once:

```vb
LET DB# = "C:/Users/me/contacts.db"
```

Use forward slashes `/` or doubled backslashes `\\` in paths — never a single `\`, because BazzBasic treats it as an escape character.

## Creating the database and table

There is no separate "create database" step. Just running `sqlite3` with a filename creates the file if it does not exist.

```vb
LET DB# = "C:/Users/me/contacts.db"

LET sql$ = "CREATE TABLE IF NOT EXISTS contacts (" +
           "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
           "name TEXT NOT NULL, " +
           "phone TEXT, " +
           "address TEXT, " +
           "email TEXT)"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEN(out$) > 0 THEN
    PRINT "Error: " + out$
ELSE
    PRINT "Table ready."
END IF
```

`CREATE TABLE IF NOT EXISTS` makes the script safe to run repeatedly — the table is only created the first time. If everything goes well, `sqlite3` prints nothing, so an empty `out$` means success.

## Inserting data

Single row:
```vb
LET sql$ = "INSERT INTO contacts (name, phone, address, email) VALUES " +
           "('Krisu Virtanen', '+358 040 123 54321', 'Viljakkala', 'some.email@gmail.com')"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEN(out$) > 0 THEN PRINT "Error: " + out$
```

Multiple rows in one call (faster, since `sqlite3` is launched only once):
```vb
LET sql$ = "INSERT INTO contacts (name, phone, address, email) VALUES " +
           "('Jane Doe',   '+1 555 1234',       'New York', 'jane@example.com'), " +
           "('John Smith', '+44 20 7946 0958',  'London',   'john.s@example.com')"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
```

We did not specify `id` — SQLite assigns it automatically because the column is `INTEGER PRIMARY KEY AUTOINCREMENT`.

## Reading data

By default, `sqlite3` outputs rows as `|`-separated text, one row per line:

```
2|Jane Doe|+1 555 1234|jane@example.com
3|John Smith|+44 20 7946 0958|john.s@example.com
1|Krisu Virtanen|+358 040 123 54321|some.email@gmail.com
```

This is easy to parse with `SPLIT()`. Split first by newline `CHR(10)`, then each row by `|`:

```vb
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
        PRINT "id=" + cells$(0) +
              " name="  + cells$(1) +
              " phone=" + cells$(2) +
              " email=" + cells$(3)
    END IF
NEXT i$
```

The inner `IF LEN(row$) > 0` skips the trailing empty line that `sqlite3` always adds.

### Reading a single value

When you only need one cell — a name, an id, a count — `TRIM()` the output and use it directly:

```vb
LET cmd$ = "sqlite3 " + DB# +
           " \"SELECT name FROM contacts WHERE id=1\" 2>&1"
LET name$ = TRIM(SHELL(cmd$))
PRINT "Name: " + name$
```

`TRIM()` removes the newline that `sqlite3` always appends.

## Updating data

```vb
LET sql$ = "UPDATE contacts SET phone='+358 50 999 0000' WHERE name='Krisu Virtanen'"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
IF LEN(out$) > 0 THEN PRINT "Error: " + out$
```

`UPDATE` without a `WHERE` clause changes every row in the table. SQLite will let you do it without warning, so always double-check the `WHERE`.

## Deleting data

```vb
LET sql$ = "DELETE FROM contacts WHERE name='John Smith'"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
LET out$ = SHELL(cmd$)
```

Same warning: `DELETE FROM contacts` with no `WHERE` empties the whole table.

## Counting and searching

`COUNT(*)` returns a single number:
```vb
LET cmd$ = "sqlite3 " + DB# + " \"SELECT COUNT(*) FROM contacts\" 2>&1"
LET total$ = TRIM(SHELL(cmd$))
PRINT "Total contacts: " + total$
```

Partial-text search uses `LIKE` with `%` as the wildcard:
```vb
LET sql$ = "SELECT name, email FROM contacts WHERE name LIKE '%doe%' COLLATE NOCASE"
LET cmd$ = "sqlite3 " + DB# + " \"" + sql$ + "\" 2>&1"
PRINT SHELL(cmd$)
```

`COLLATE NOCASE` makes the match case-insensitive.

## Error handling

Because of the trailing `2>&1`, SQL errors come back inside the output string. They always begin with `Error:`:

```
Error: in prepare, no such column: FOOBAR
  SELECT FOOBAR FROM contacts
         ^--- error here
```

A simple way to detect them:

```vb
LET out$ = SHELL(cmd$)
IF LEFT(out$, 6) = "Error:" THEN
    PRINT "Database error: " + out$
ELSE
    REM normal handling
END IF
```

For statements that should produce no output on success (`CREATE`, `INSERT`, `UPDATE`, `DELETE`), an even simpler check is `IF LEN(out$) > 0 THEN ...` — anything in the output string means something went wrong.

## Limitations of this approach

This `SHELL()`-based pattern is intentionally simple and fits the spirit of BazzBasic, but you should be aware of the trade-offs.

- **Performance.** Every `SHELL()` call launches a new `sqlite3` process. For interactive tools or modest data (hundreds of queries) it is plenty fast. For bulk imports, batch many statements into a single call.
- **Single quotes in user input.** SQL uses `'` to delimit text. If a user's name contains an apostrophe (`O'Reilly`), passing it raw will break the SQL. The fix is to double the quote: `O''Reilly`. For now, the safest approach is to validate input and reject or escape `'` before building the SQL.
- **Path escapes.** Inside `SHELL()` strings, use `/` or `\\` for path separators, never a single `\`. A single backslash before a letter is interpreted as an escape sequence by BazzBasic's string parser.
- **No prepared statements.** Every query is built by string concatenation. That is fine for a single-user local tool, but do not expose this directly to untrusted input.

## Where to go next

The official SQLite documentation is the best second step:

- [SQL syntax reference](https://sqlite.org/lang.html) — every statement and function
- [Datatypes](https://sqlite.org/datatype3.html) — SQLite is dynamically typed; this page explains the rules
- [Command-line tool docs](https://sqlite.org/cli.html) — output modes (`.mode csv`, `.mode json`), pragmas, dot-commands

Anything you can do in `sqlite3` interactively, you can do from BazzBasic with the same `SHELL()` pattern.