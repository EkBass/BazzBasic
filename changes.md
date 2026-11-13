# News and changes
These changes are about the current source code.

They take effect once a new binary release is published.

Changes for older versions are in [changes-archive.md](changes-archive.md).

## 7th November 2026

## Division by zero gives 0 for /=, % and MOD too (T14)
Krisu's rule (D84): dividing by zero gives `0` everywhere, not only with `/`. Before, `a$ /= 0` gave `Infinity` (on a variable and on an array element), and `10 % 0` and `MOD(10, 0)` gave `NaN`, which then spread through every later calculation. Now all four give `0`. A divisor that is already `NaN` still gives `NaN`.
- Visible in two `Examples\rosetta-code` programs, only when the user types 0: `Arithmetic_Integer.bas` prints `Remainder:  0` instead of `Remainder:  NaN`, and in `General_FizzBuzz.bas` a factor of 0 now prints its word on every line (before: never, because `NaN = 0` is false).

## SRAND with a negative or huge length gives a line-numbered error (T13)
Found during the H1 documentation check. `SRAND(-1)` stopped with `Error: Arithmetic operation resulted in an overflow.` and `SRAND(10000000000)` with `Error: Insufficient memory to continue the execution of the program.`, both without a line number. Now: `Error at line N: SRAND: length must be 0 or more, got -1` and `Error at line N: SRAND: length 2147483647 is too large` (exit code 1 as before). The decimal part is still dropped: `SRAND(3.7)` gives 3 characters, `SRAND(-0.5)` gives `""`.
- Comments only: the old `PI#`, `QPI#` and `TAU#` digits in `Examples\rosetta-code\Real_constants_and_functions.bas` and `Special_variables.bas` now match what the interpreter prints. Program output is unchanged.

## DEF FN: parameters must end in $, calls must pass the right number of arguments (T12)
Found while fixing BazzBasic Studio's report B5 (T8).
- A parameter that does not end in `$` is now an error when the program reaches the `DEF FN` line: `Error at line N: DEF FN P$: expected a parameter name ending in $, got 'B#' - # names are constants and cannot be parameters`. Before, it was skipped silently, so `DEF FN P$(a$, b#)` became a one-parameter function. A number, a missing comma or a trailing comma in the list is an error too (`DEF FN Q$: expected ',' or ')' after A$, got 'B$'`), and a missing `)` is reported on its own line instead of `line 0`.
- Every `FN` call must pass exactly as many arguments as the definition has: `Error at line N: FN ADD$: expected 2 arguments, got 1`. Before, missing arguments became `0` and extra ones were ignored. `FN F$` and `FN F$()` pass none.
- Applies to functions in `.bb` libraries too, also to libraries built with an older version. A program already packaged with `-exe` keeps the interpreter it was built with.

## DIM stops at ':' and ELSE, accepts only $ names (T11)
Found while fixing BazzBasic Studio's report B5 (T8).
- `DIM` now ends at the end of the line, at `:` or at `ELSE`, so the rest of the line runs: `DIM n$ : n$(0) = 1 : PRINT "ok"`. Before, everything after `DIM` on that line was skipped silently (`DIM a$ : LET b$ = 5` even turned `b$` into an array).
- Grammar: `DIM name$ [(size)] [= value] {, name$}`. A name that does not end in `$` is an error: `Error at line N: DIM: expected an array name ending in $, got 'PI#'` (also for a number, an empty `DIM` and a trailing comma; a `,` at the end of a line continues onto the next line, so the error names that line's first word). A missing comma, or a size and a value together (`DIM a$(10) = 5`), gives `DIM: expected ',' or end of statement after A$, got '='`. A missing `)` gives `DIM: missing ')' after the array size`.
- The size is still ignored, and nothing inside it is read any more: `DIM b$(n$)` declares only `b$`. Before, `n$` became an array too.
- Unchanged: `DIM a$, b$`, `DIM x$ = 5` (stores 5 in `x$(0)`), `key=value` text, re-DIM keeps contents, `DIM` inside `DEF FN` gives a fresh local array.

## New function SAME: exact text comparison (T10)
New in version 1.7. Requested by Krisu following BazzBasic Studio's report #15. `SAME(a$, b$)` returns `1` if both values are identical character for character (case included, ordinal compare), otherwise `0`. `=` still ignores case between strings (H2).
```basic
IF SAME(pass$, input$) THEN PRINT "Welcome"
PRINT SAME("Secret1", "secret1")  ' 0
PRINT SAME("", "")                ' 1
```
- Exactly two arguments, otherwise `Error at line N: SAME: expected 2 arguments`. A bare `SAME` gives `Expected '(' after SAME`.
- Numbers are compared by their text form: `SAME(1, "1")` → `1`, `SAME("1.0", 1)` → `0`, `SAME(-0, 0)` → `0`. Use `=` for numbers. `INPUT` / `LINE INPUT` always store text, so `SAME` compares exactly what was typed.
- The `LEN` / `INSTR` + `"~"` idiom from the H2 entry still works and stays documented for versions before 1.7.
- New token `TOK_SAME = 320` (nothing renumbered). Old `.bb` libraries load as before; a `.bb` that uses `SAME` needs 1.7 or newer (an older interpreter stops with `Unexpected '320' in expression`). Names such as `same$`, `SAME#` and `[same]` are unaffected.

## Documentation: string comparison ignores case; how to compare exactly (H2)
Manual and `SKILL.md` now say clearly that `=`, `<>`, `<`, `>`, `<=` and `>=` ignore case between strings (`"abc" = "ABC"` → `1`), while array string keys and `INSTR` (by default) are case-sensitive. For an exact compare (passwords, keys, IDs): `LEN(a$) = LEN(b$) AND INSTR(a$ + "~", b$ + "~") = 1`. No interpreter change.

## PI, HPI, QPI and TAU functions return full precision (T9)
The functions `PI`, `HPI`, `QPI` and `TAU` now return exactly the same values as the constants `PI#`, `HPI#`, `QPI#` and `TAU#` (`PI` = 3.141592653589793). Before, they returned hardcoded literals: `PI` and `TAU` had only 15 digits and `QPI` was wrong in the 16th digit (0.7853981633974475 instead of 0.7853981633974483). They now use `Math.PI` like the constants.

## Unknown characters are an error, built-in constants cannot be redefined, clearer array message (T8)
Reported by BazzBasic Studio (B5).
- A character outside strings, comments and labels that is not part of the language now stops the program before it runs: `Error: Line N: Unexpected character '@'` (exit code 1). Before, the lexer silently dropped it, so `PRINT 10 \ 3` printed `103` and `PRINT 7 ^ 2` printed `72`. `\` and `^` get a hint (`use INT(a / b)`, `use POW(a, b)`); non-ASCII characters also show their code point, e.g. `'€' (U+20AC)`. Whitespace (also form feed and non-breaking space) and a stray byte-order mark are still skipped. `-lib` reports the same error and writes no `.bb`.
- `LET` on a built-in constant (`PI#`, `KEY_ESC#`, `AU#`, ...) now stops with `Error at line N: Cannot redefine constant 'PI#'`. Before, it was silently ignored (built-ins live in their own table, which `LET` did not check). Without `LET`, `PI# = 3` now says `Cannot change constant PI#` instead of the misleading "Constants must be declared with LET". This replaces the note in the AU# entry below: a `LET AU# = ...` line is now an error, remove it.
- Reading an array name as a plain value (`PRINT nums$`) now says `Error at line N: NUMS$ is an array - use an element like NUMS$(0), or the whole array as a JSON string with ASJSON(NUMS$)` instead of `Undefined variable: NUMS$`. A main-program array read inside `DEF FN` still says `Undefined variable` (arrays are not visible there, like `$` variables).

## Documentation corrections (H1)
Manual and AI guide (`SKILL.md`) fixes from BazzBasic Studio's Q&A run. No interpreter change.
- `+` joins text when either side is a string, left to right, `*` and `/` first: `"12" + 3` → `123`, `1 + 2 + "Foo" + 4 * 5` → `3Foo20`. The "Comparing variables" example wrongly said `12 + "12"` gives `24` (it gives `1212`) and was rewritten.
- `LOADIMAGE` / `LOADSHAPE` / `LOADSHEET` / `LOADSOUND` return string handles (`SHAPE1`..., GUID-style for sounds), not integers assigned by SDL2.
- `PI#`, `HPI#`, `QPI#` and `TAU#` now show the digits the interpreter prints (`PI#` = 3.141592653589793).
- `SKILL.md` keyboard list now includes the punctuation keys (`KEY_COMMA#` ...).
- Sample error messages use the real `Error at line N: ...` text (array errors, `ARRKEY`, calling a function before its `DEF FN`).
- New notes: `/` by zero gives `0`; `DIM a$(10)` ignores the size; `DIM x$ = 5` stores 5 in `x$(0)`.
- Constant examples no longer use the built-in name `PI#` (`LET PI# = 3.14159` → `LET GRAVITY# = 9.81` / `LET MAX_LIVES# = 3`).

## Runtime errors are now always line-numbered (T6)
All runtime errors now print `Error at line N: <message>` and stop the program with exit code 1. Before, several handler errors escaped as a line-number-less `Error: <message>`: `LOADSOUND` and `SOUNDONCE` / `SOUNDREPEAT` / `SOUNDONCEWAIT` on a missing file or unknown sound ID, compound array assignment (`arr$(k) += ...`) on an undeclared array or uninitialized element, `FASTSIN` / `FASTCOS` used before `FASTTRIG(TRUE)` (which also printed the wrong format `Error: Line N:`), `ASJSON` on non-finite numbers (infinity), and the `GETREQUEST` body read.

Why: those handlers let manager exceptions escape to the `Program.cs` catch-all, or (FASTSIN/FASTCOS) threw deliberately with the line number baked into the message; they now use the standard `Error()` pattern (as T2 did for the console commands).

Deliberately unchanged: `HTTPGET` / `HTTPPOST` do not halt on a failed request — they return `""` and set `HTTPERROR()` (an invalid URL is still a line-numbered error). The missing line number of `LOADSOUND` mentioned in the T4 entry below is fixed by this entry. The only remaining line-number-less `Error:` prints are pre-interpreter failures (INCLUDE / lexer / library load) and the interpreter's last-resort catch-all.

## Packaged -exe programs now receive command-line arguments (T5)
A program packaged with `-exe` now sees its command-line arguments through `ARGCOUNT` / `ARGS`, exactly like a script run with the interpreter: `prog.exe arg1 arg2` gives ARGCOUNT = 2, ARGS(0) = "arg1", ARGS(1) = "arg2" (0-based). Before this fix, a packaged exe always saw ARGCOUNT = 0.

Why: the embedded-program branch in `Program.cs` passed no user arguments to the interpreter. Flag-like arguments are not special inside a packaged exe — `prog.exe -v` simply gives ARGS(0) = "-v" (the interpreter's own `-exe` / `-lib` / `-v` flags apply only to `bazzbasic.exe` itself, not to a packaged program).

## LOADIMAGE / LOADSHEET / LOADSOUND resolve relative paths from the program folder (T4)
`LOADIMAGE`, `LOADSHEET` and `LOADSOUND` now resolve relative paths against the program's base directory (`PRG_ROOT#`) — the same rule as all file commands, `LOADFONT` and `SAVESCREEN`. Before, these three used the folder the program was launched from (process CWD), so running `bb.bat ..\bas\prog.bas` from another folder loaded the wrong file or failed. Now `LOADIMAGE("assets/plane.png")` works no matter where you launch from. Absolute paths are used as-is, and `LOADIMAGE` still accepts `http(s)://` URLs (downloaded into the program folder first, as before).

Why: bug report B2 from BazzBasic Studio — the manual's Path Resolution section already promised `PRG_ROOT#`, the code just did not apply it to these three loaders.

Missing-file errors halt the program (exit code 1) and now show the resolved path: `LOADIMAGE` stops with `Error at line N: Failed to load image: File not found: <path>`, `LOADSHEET` with `Error at line N: File not found: <path>`, and `LOADSOUND` with `Error: Sound file not found: <path>` (its missing line number is a pre-existing quirk, unchanged).

Also fixed: `bb.bat` no longer prints a stray `'#' is not recognized...` to stderr on every launch (the `#` comment line is now a `REM`).

## Regression fix: first DIM of a top-level array (T1)
Fixed: the first DIM of an array in the main scope not creating the array (inverted condition in `DimArray`). Array element keys remain case-sensitive by design — `arr$("name")` and `arr$("Name")` are different elements (see below). Re-DIM of an existing top-level array keeps its contents. (Arrays are not global - inside DEF FN they are not visible; pass one in as an `ASJSON()` string and rebuild it with `ASARRAY()`.)

## Console commands report line numbers under redirected I/O (T2)
INKEY, WAITKEY, SLEEP (key wait), CLS and CURPOS now catch console errors and stop with a proper `Error at line N: ...` (exit code 1) instead of a line-number-less `Error: ...` when the program runs without a real console (stdin/stdout redirected). `INPUT` / `LINE INPUT` from piped stdin is unaffected and keeps working.

## New built-in constant AU#
`AU#` = 149597870700 — the astronomical unit in metres, exact by the IAU 2012 definition. Like all `#` constants: read-only, usable in arithmetic, assigning without `LET` is an error.

Note: if your code declares its own `AU#` with `LET`, remove that line — the built-in constant takes precedence, so reads always see 149597870700.

```basic
PRINT AU#         ' 149597870700
PRINT AU# / 1000  ' 149597870.7  (kilometres)
```

## Array string keys are now case-sensitive (breaking change)
`arr$("name")` and `arr$("NAME")` are now two different elements. Before this they pointed to the same element.

```basic
DIM a$
a$("name") = 1
a$("NAME") = 2
PRINT LEN(a$())     ' 2 (was 1)
```

Why: keys are usually data (user input, files, JSON), not code. A letter counter could not tell `A` from `a`, and JSON objects such as `{"Name":1,"name":2}` lost a value. Case-insensitive keys are still easy to get with `arr$(UCASE(key$))`, but the opposite was not possible.

Array *names*, variables, constants, labels and keywords stay case-insensitive. `HASKEY`, `DELKEY` and `ARRKEY` follow the same rule.

## Interpreter clean-up: faster variable access
Removed needless `ToUpperInvariant()` calls from variable, constant and array lookups (the lexer already upper-cases names), `FOR`/`NEXT` no longer pops and re-pushes its loop state on every iteration, and the built-in constant table is checked only for constant tokens. A plain `FOR` loop with one assignment runs about 21 % faster.

## 6th November 2026

## ASC() accepts an optional position
`ASC(s$, pos)` returns the code of the character at 1-based position `pos`. Same result as `ASC(MID(s$, pos, 1))`, but no temporary substring is created.

```basic
PRINT ASC("xyz")      ' 120 (x)
PRINT ASC("xyz", 2)   ' 121 (y)
PRINT ASC("xyz", 4)   ' 0   out of range
```

Out of range (`pos < 1` or `pos > LEN(s$)`) returns `0`, the same as `ASC("")`. The one-argument form is unchanged.

In a character-by-character summing loop this was about 34 % faster than `ASC(MID(s$, j$, 1))` (310 ms → 205 ms for 1.56 million characters).

## New built-in constant BBBUILD#
Returns the build time of the interpreter as `"dd-mm-yyyy hh:mm:ss"`.

```basic
PRINT BBVER#     ' 1.7
PRINT BBBUILD#   ' 06-11-2026 20:45:57
```

A program compiled with `-exe` reports the build time of the interpreter it was made with.

Related fixes:
- The build timestamp generated by `BazzBasic.csproj` produced broken C# (unescaped `;` in MSBuild) and a culture-dependent time separator (`20.47.16` on Finnish systems). Now always `dd-mm-yyyy hh:mm:ss`.
- The IDE now highlights `BBVER#`, `BBBUILD#` and `PRG_ROOT#`. `BBBUILD#` was also added to the Notepad++, Geany and reserved-words files.

## Duplicate label now causes an error
This was unnoticed bug so far.

```basic
[inits]
    LET a$ = 1

[label:here]
    PRINT a$

[inits] ' second time: Error at line 12: Duplicate label [INITS].
    PRINT a$ + a$

[no-way]
    PRINT "This should never happen."
END
```

### New: XML support (light model) — ASXML, LOADXML, SAVEXML

Meant mainly for reading RSS and Atom feeds. JSON is still the recommended format: XML is heavier and does not map to arrays as cleanly. XML is also not HTML — HTML pages do not parse as XML.

`ASARRAY` now picks the format from the first character (BOM and leading whitespace skipped): `{` or `[` = JSON, `<` = XML. Existing programs work as before.

```basic
LET xml$ = HTTPGET("https://example.com/rss.xml")
DIM feed$
LET n$ = ASARRAY(feed$, xml$)
LET i$ = 0
WHILE HASKEY(feed$("rss,channel,0,item," + i$ + ",title,0"))
    PRINT feed$("rss,channel,0,item," + i$ + ",title,0")
    i$ += 1
WEND
```

- Every element below the root gets an index, even a single one: `rss,channel,0,item,0,title,0`. Longer keys, but a loop never silently finds nothing when a feed has only one item.
- Attributes: `...,guid,0,@isPermaLink`. Text next to attributes or child elements: `...,guid,0,#text`.
- Prefixes are kept as written: `...,dc:creator,0`. CDATA is read as plain text.
- Comments, processing instructions and DTDs are ignored (DTDs for safety: no external entities).
- Not supported: the order of mixed text and elements (`<p>a <b>b</b> c</p>`). All values are strings.
- `ASXML(arr$)` builds XML from an array. A single top-level key becomes the root element, otherwise `<root>` is used. A key that is not a valid XML name is an error.
- `LOADXML arr$, path$` / `SAVEXML arr$, path$` work like LOADJSON / SAVEJSON. SAVEXML writes an indented file with an XML declaration.
- `ASARRAY` errors: empty data now says so and points to HTTPERROR; data that is neither JSON nor XML gets its own message; parse errors say which format was tried.
- Internals: new tokens `TOK_ASXML = 141`, `TOK_LOADXML = 142`, `TOK_SAVEXML = 143`. New file `src/Interpreter/Interpreter.Xml.cs`. Only System.Xml / System.Xml.Linq, no NuGet packages, no reflection.

IDE keyword list and `extras/BazzBasic.udl.xml` updated. Manual not yet updated.
