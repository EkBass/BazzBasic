# News and changes
These changes are about the current source code.

They take effect once a new binary release is published.

Changes for older versions are in [changes-archive.md](changes-archive.md).

## Version 1.9 (under development) — 27th November 2026

### New
- The IDE has a new **View → Predictive Mode** toggle (checkable, right under Tree View; Ctrl+Space is shown on the item), on by default and saved to `%AppData%\BazzBasic\ide.json` as `PredictiveMode` (an old ide.json without the key gets the mode ON). While typing in code — not inside a comment (`'` / `REM`) or a string — a list of matching reserved words opens by itself after 3 typed letters. **Tab** inserts the chosen word in capitals, **Enter** closes the list and makes a new line without inserting the word, **Esc** closes the list. **Ctrl+Space** opens the list by hand even when Predictive Mode is off or nothing is typed — words shorter than 3 letters (`PI#`, `IF`, `TO`...) appear only this way. The list offers the built-in constants with `#` (`PI#`, `HPI#`, `QPI#`, `TAU#`, `EULER#`, `PHI#`, `GRAV#`, `GRAV_E#`, `AU#`, `BBVER#`, `BBBUILD#`, `PRG_ROOT#` and the colour constants `BLACK#`…`TRANSPARENT#`); it does not offer `KEY_*` / `PAD_*#` constants or your own functions, labels or variables. In Dark Mode the list uses the editor's colours. Documented in the manual (ide-usage.md).

### Bug fixes
- IDE syntax colouring: math/string functions, I/O + file + array words and graphics + mouse + sound words each have their own colour now (before, the math/string functions had the graphics colour, and the I/O and the graphics/sound words were plain text). An unclosed string is now coloured as a string.

### Deprecated
- The plain names of the math constants written without `#` — `PI`, `HPI`, `QPI`, `TAU`, `EULER`, `PHI`, `GRAV`, `GRAV_E` — are deprecated since 1.9; use the `#` forms (`PI#` … `GRAV_E#`). Not a breaking change: both forms still work and give the same values, with no runtime warning. The documented forms are the `#` constants (manual keywords.md, functions.md; see also the 1.8 notes below).

## 27th  November 2026

### Released as version 1.8

### New
- New built-in constants: `PHI#` = 1.618033988749895 (golden ratio), `GRAV#` = 6.67430e-11 (gravitational constant, m^3 kg^-1 s^-2) and `GRAV_E#` = 9.80665 (standard gravity on Earth, m/s^2). Like all `#` constants they are read-only: `LET PHI# = 2` stops with `Error at line N: Cannot redefine constant 'PHI#'`.
- New built-in color constants (32-bit ARGB): `BLACK#`, `WHITE#`, `RED#`, `GREEN#`, `BLUE#`, `YELLOW#`, `CYAN#`, `MAGENTA#`, `GRAY#`, `ORANGE#` and `TRANSPARENT#` (0x00000000).
- (T28) New function `MOUSEWHEEL`: the mouse wheel notches rolled since the previous call (+ = up, - = down, 0 = no movement). Graphics mode only, 0 in console mode.

- The IDE has a new **Help → Autocheck Updates on Startup** toggle (checkable, saved to `%AppData%\BazzBasic\ide.json` like the other IDE settings). When checked, the IDE checks GitHub for a newer release when it starts — at most once a day (the date of the last check is kept in ide.json) — and stays quiet unless a new version is available; then a message shows the new version and the download link. **Help → Check for Updates...** still checks immediately and always shows the result, and a manual check also counts as the day's automatic check. Documented in the manual (ide-usage.md).

### Breaking changes
- The color names above are now built-in constants: `LET RED# = 4` (or `RED# = 4`) stops with `Error at line N: Cannot redefine constant 'RED#'`. Remove such LET lines — the built-in value is used — or rename your own constant. The shipped Examples were adjusted: `LET x# = RGB(...)` lines were removed, and palette-index definitions (0–15, used with `COLOR`) were renamed to `C_<name>#`.

### Bug fixes
- `HASKEY` now accepts several indexes, just like reading an element: `HASKEY(m$(0, "name"))` works and tests the same element as `m$(0, "name")`.
- `DELKEY arr$()` without a key now stops with a clear error instead of silently deleting the element with the empty key `""`.
- `arr$() = value` (an element write without a key, also `+=`, `-=`, `*=`, `/=`) now stops with a clear error instead of silently storing the value under the empty key `""`.
- `DELKEY` on an array that does not exist (never declared, a typo in the name, removed with `DELARRAY`) now stops with `Array not declared, use DIM first` instead of silently doing nothing.
- An error inside a one-line `IF ... THEN ...` no longer leaves the program hanging after the error message; it stops (exit code 1).
- (T24) In a one-line `IF ... THEN ...`, statements after `RETURN` on the same line no longer run inside `DEF FN` (they used to run after the function had already returned).
- (T25) A bare array-element statement without `=` (`arr$(1)`, `arr$()`) is now an error: `Error at line N: Array element alone is not a statement - did you forget '= value'?` - it used to silently do nothing.
- (T26) Closing the graphics window while a one-line `IF ... THEN ...` branch is running now ends the program cleanly (exit code 0) - it used to keep running at 100% CPU with the window gone.
- (T27) An error inside an INCLUDEd `.bas` file now names that file and its own line: `Error in menu.bas line 182: ...` at runtime, `Error: menu.bas line 168: ...` before the program starts. A runtime error inside a `.bb` library function names the library: `Error in mylib.bb line 4: ...`. Errors in the main program keep their form, but the line number is now the main file's own line - it used to count the lines of every included file too.
- (T27) A string literal that runs over several lines (or a label missing its `]`) no longer makes the line numbers of later errors too low.
- (T27) INCLUDE of the same `.bas` file a second time is no longer an error (`Circular INCLUDE detected`): the second INCLUDE is skipped with a warning, `Warning: Line N: Include 'x.bas' already included, skipping.`, just like a duplicate `.bb` library. A real cycle (A includes B, B includes A, or a file includes itself) is still an error.
- The IDE now highlights `TRANSPARENT` and `LOADSOUND`: a missing space in the IDE keyword list had joined them into one word (`transparentloadsound`). Fixed together with T28.
- `PAINT (x, y), fillColor, borderColor` now flood-fills like in QB/FreeBASIC: the contiguous area of the starting pixel's color is filled, stopping at `borderColor` pixels. The border color is optional; without it the fill color acts as the border. Before, `PAINT` painted only a single pixel and a second color argument stopped with `Error at line N: Unexpected ',' - not a valid statement` — which broke the shipped examples `Graphics_01_Drawing_Primitives.bas` and `Draw_a_cuboid.bas` that use the two-color form.

### Other
- New example `Examples\graphics\Solar model\`: a zoomable solar system (49 bodies, 3D orbits drawn top-down, body list, mouse-wheel zoom) made by BazzBasic Studio. Start file `solar.bas`, the rest in `include\`; `solar.bas selftest` runs a built-in test.
- Offline manual (`BazzBasic-Manual.html`): links between manual pages work again. About 36 links pointed to `.md` files that do not exist in the single-file manual.
- The `bazzbasic-code` SKILL is now a folder (`SKILL.md` + `references/*.md` + a `README.md` setup prompt) with a new "Calling AI / LLM APIs" section in `references/network.md`; new example `Examples\HTTP\HTTP_listen_server.bas` (JSON command server for `STARTLISTEN`).
- The BazzBasic AI guide is now named BazzBasic-SKILL. New address: https://huggingface.co/datasets/EkBass/BazzBasic-SKILL (the old `BazzBasic_AI_Guide` address is no longer the current one). The new name and links are updated across the website, the manual, `llms.txt`, `README.md` and the example programs.
- The manual now documents that the `:` in `TIME()` / `TIME("HH:mm:ss")` follows the Windows regional settings (Finnish systems: `18.19.08`); quote it for a fixed separator: `TIME("HH':'mm':'ss")`. Documentation only — no interpreter change (Krisu, 2026-11-18).
- (O16) The manual and the `bazzbasic-code` SKILL now recommend `KEYDOWN` for reading controls and `WAITKEY` for waiting for a key. `INKEY` is still fine for simple polling (Esc to quit, "press any key"), but in a graphics game loop it keeps only the last key pressed since the previous call, so an earlier press can be lost. New `KEYDOWN` one-action-per-press example in the manual. Documentation only, no interpreter change.

## HASKEY with several indexes (T19)
Before, `HASKEY` read exactly one index, so `HASKEY(m$(0, "name"))` stopped with `Error at line N: Expected ')' but found ','`; the workaround was the joined key `HASKEY(m$("0,name"))`. Now `HASKEY` builds the key with the same rule as element read and write: indexes joined with `,` (no spaces), numbers in their shortest form (`1.0` gives `1`), strings as written (case-sensitive). The one-index form is unchanged, so this is not a breaking change.

Why: report from BazzBasic Studio - reading and writing `m$(0, "name")` worked, but checking it with `HASKEY` stopped the program.

Two calls that already stopped the program before now get a clear message instead of a misleading one: `HASKEY(m$())` gives `Error at line N: HASKEY needs a key, e.g. HASKEY(arr$(key))`, and an argument that is not an array element, e.g. `HASKEY("0,name")`, gives `Error at line N: HASKEY expects an array element, e.g. HASKEY(arr$(key))`.

## DELKEY without a key is an error (T20)
Before, `DELKEY arr$()` (also `arr$(,)`) built an empty key and silently deleted the element stored under `""` - no message, the program went on. Now it stops with `Error at line N: DELKEY needs a key, e.g. DELKEY arr$(key)` and nothing is deleted. `DELKEY arr$("")`, the explicit empty text key, still deletes the `""` element. Unchanged: several indexes (`DELKEY users$(1, "email")`), and a missing key does nothing (an undeclared array is an error since T22, below). The form was never documented and no known program uses it, so this is a bug fix, not a breaking change.

Why: a follow-up to the `HASKEY` fix (T19) - `HASKEY(m$())` gives an error, while `DELKEY m$()` quietly deleted data. DELKEY now reads its indexes with the same code as `HASKEY`.

## Element write without a key is an error (T21)
Before, `arr$() = value` (also `arr$(,)`, `+=`, `-=`, `*=`, `/=` and the `LET` forms) silently stored the value under the empty key `""`. Now it stops with `Error at line N: Array assignment needs a key, e.g. arr$(key) = value` and nothing is written. `arr$("") = value`, the explicit empty text key, still works, and reading `arr$()` (e.g. `LEN(arr$())`) is unchanged. Also fixed: when an index fails, e.g. `a$(nope$(1)) = SHELL(...)`, the right-hand side no longer runs after the error message. The form was never documented and no known program uses it, so this is a bug fix, not a breaking change.

Why: the write side of the T20 bug - the value went to a key nobody asked for. Element write now reads its indexes with the same code as `HASKEY` and `DELKEY`.

## DELKEY on an undeclared array is an error (T22)
Before, `DELKEY` on an array that does not exist - never declared, a typo in the name, removed with `DELARRAY`, a plain variable, or an array of the main program used inside `DEF FN` - did nothing, so a typo went unnoticed. Now it stops with the same message as reading an element there: `Error at line N: Array not declared, use DIM first: NAME$` (inside `DEF FN`: `Global array NAME$ is not visible inside DEF FN - ...`). A missing key in an existing array still does nothing. No known program relies on the silent no-op, so this is a bug fix, not a breaking change.

Why: a follow-up to T20 - `DELKEY usres$("ann")` (a typo for `users$`) quietly deleted nothing.

## One-line IF no longer hangs after an error (T23)
Before, an error inside a one-line `IF ... THEN ... [ELSE ...]`, e.g. `IF 1 THEN PRINT nope$`, printed its message and then the program hung at 100% CPU until it was killed (1.7 has the same bug). Now the program stops with exit code 1, like after any other error. Programs without an error are not affected.

Why: found while testing T21/T22 - their new errors inside a one-line IF hit the same hang. The one-line IF loop did not check for an error, so it ran the failed statement again and again.

## One-line IF stops after RETURN (T24)

Before, inside `DEF FN`, a one-line `IF ... THEN ... RETURN [value] : <more>` also ran the statements after `RETURN` on the same line - they executed after the function had already returned. Now the line stops after `RETURN`, exactly like a plain `RETURN` line already did. At the top level (outside `DEF FN`) nothing changes: there `RETURN` already skipped the rest of the line. Error-free programs are not affected, so this is a bug fix, not a breaking change.

Why: the one-line IF loop did not stop after `RETURN` (same root shape as the T23 hang above); only the `DEF FN` path was affected.

## Array element alone is not a statement (T25)

Before, a bare element reference at statement position - `arr$(1)`, `arr$()`, `arr$(1, "x")`, also after `:` or `THEN`/`ELSE` - silently did nothing. Now it stops with `Error at line N: Array element alone is not a statement - did you forget '= value'?` (exit code 1). Reading is unchanged: `arr$()` in an expression still gives the element count, e.g. `LEN(arr$())`, and `arr$("")` remains a legal key. If the name is a `DEF FN` function, e.g. `Foo$(1)` without the `FN` keyword, that message still fires first. The form was never documented and no known program uses it, so this is a bug fix, not a breaking change.

Why: silent no-ops on invalid input become clear errors (D142).

## Error locations in INCLUDEd files (T27)

Before, every line number was a line of the merged program (the main file with all INCLUDEd `.bas` files pasted in), which nobody can see. Now:

- Runtime error in an INCLUDEd file: `Error in <file> line <k>: msg`; found before the program starts: `Error: <file> line <k>: msg`. `<file>` is the name as written in the INCLUDE line, `<k>` is the line inside that file.
- Runtime error in a `.bb` library function: `Error in <lib.bb> line <k>: msg`, `<k>` = line in the library's source file.
- Main program: unchanged forms `Error at line N: msg` and `Error: Line N: msg`, with N = the line in the main file. Without `.bas` INCLUDEs the numbers do not change (except after a multi-line string, see below).
- `INCLUDE "x.bb"` messages (library not found, load error, duplicate warning) and `Invalid INCLUDE syntax` inside an INCLUDEd file use the same `<file> line <k>` form.
- The same `.bas` INCLUDEd twice: the second INCLUDE is skipped with a warning on stderr (`Warning: <file> line <k>: ...` when it sits in an INCLUDEd file); a skipped INCLUDE alone does not stop the program (exit code 0). With `-exe` the warning appears once, when the exe is made.

Also fixed: the lexer did not count the line ends inside a multi-line string literal or a label missing its `]`, so every later error got a line number that was too low. No working program changes behavior and the main-program message text keeps its form, so this is not a breaking change.

Why: an error on line 168 of an INCLUDEd `menu.bas` was reported as `Line 323`, a line number you could not find in any file.

## New built-in constants PHI#, GRAV# and GRAV_E#

New in version 1.8 (added 2026-11-18). Read-only like every built-in constant: `PHI# = 2` and `LET PHI# = 2` both stop with `Error at line N: Cannot redefine constant 'PHI#'`.

```basic
PRINT PHI#       ' 1.618033988749895  (golden ratio)
PRINT GRAV#      ' 6.6743E-11         (gravitational constant, m^3 kg^-1 s^-2)
PRINT GRAV_E#    ' 9.80665            (standard gravity on Earth, m/s^2)

' Newton's law of gravitation:
LET force$ = mass1$ * mass2$ * GRAV# / (dist$ * dist$)
```

- The plain names work as functions too, like `PI`: `PRINT PHI` prints the same value as `PRINT PHI#` (the plain names are deprecated since 1.9).
- Internals: new tokens `TOK_GRAV = 288`, `TOK_GRAV_E = 289`, `TOK_PHI = 290` (nothing renumbered). Old `.bb` libraries load as before; a `.bb` that uses the new names needs 1.8 or newer.
- The IDE and the editor keyword files in `extras/` (Notepad++ UDL, Geany filetypes, reserved-words.xml) highlight the new names, so `PHI`, `GRAV` and `GRAV_E` are coloured like `PI` (deprecated since 1.9).

## AI guide split into a folder; new HTTP_listen_server example; TIME() separator documented

- The `bazzbasic-code` skill is no longer a single `SKILL.md`: the folder holds `SKILL.md` (core language + a "Reference files" index), `references/graphics-sound.md`, `references/mouse-gamepad.md`, `references/file-io.md`, `references/json-xml.md`, `references/network.md`, `references/program-system.md`, `references/ide.md`, and a rewritten `README.md` with a copy-paste setup prompt that lists all files. `references/network.md` adds "Calling AI / LLM APIs" (provider table + a tested request pattern with HTTPERROR and error,message checks). The manual's AI-assist page now describes the folder layout, and the SKILL header reads Version 1.8.
- New example `Examples\HTTP\HTTP_listen_server.bas`: a JSON command server for `STARTLISTEN` (commands add/echo/time/quit); tested with 6 requests including non-JSON and GET, clean stop, exit code 0.
- `TIME()` docs (manual other_functions.md; SKILL references/program-system.md): the `:` in `TIME()` and `TIME("HH:mm:ss")` follows the Windows regional settings (e.g. `18.19.08` on a Finnish system); `TIME("HH':'mm':'ss")` gives a fixed colon on every system. Documentation only, no interpreter change (Krisu, 2026-11-18).

## New built-in color constants (ARGB)

New in version 1.8 (added 2026-11-18). 32-bit ARGB values (0xAARRGGBB), read-only like every `#` constant (`LET RED# = 1` is an error):

| Constant | Value | RGB |
|----------|-------|-----|
| `BLACK#` | 0xFF000000 | (0, 0, 0) |
| `WHITE#` | 0xFFFFFFFF | (255, 255, 255) |
| `RED#` | 0xFFFF0000 | (255, 0, 0) |
| `GREEN#` | 0xFF00FF00 | (0, 255, 0) |
| `BLUE#` | 0xFF0000FF | (0, 0, 255) |
| `YELLOW#` | 0xFFFFFF00 | (255, 255, 0) |
| `CYAN#` | 0xFF00FFFF | (0, 255, 255) |
| `MAGENTA#` | 0xFFFF00FF | (255, 0, 255) |
| `GRAY#` | 0xFF808080 | (128, 128, 128) |
| `ORANGE#` | 0xFFFFA500 | (255, 165, 0) |
| `TRANSPARENT#` | 0x00000000 | (0, 0, 0, alpha 0) |

```basic
SCREEN 320, 200
LINE (10, 10)-(100, 100), RED#     ' red line
CIRCLE (160, 100), 40, YELLOW#     ' yellow circle
PAINT (160, 100), GREEN#           ' flood fill
PRINT TRANSPARENT#                 ' 0  (0x00000000, alpha 0)
```

- Drawing commands (`PSET`, `LINE`, `CIRCLE`, `PAINT`, `DRAWSTRING`, `LOADSHAPE`) accept these like `RGB(r, g, b)` values. `COLOR` still takes a palette index 0–15 only.
- Internals: no new tokens — the constants resolve through the built-in constant table like `AU#`, so old `.bb` libraries are unaffected. The IDE and the editor keyword files in `extras/` highlight the new names. Color arguments of the drawing commands are now read via a `long` intermediate (`ReadColorInt` in `Interpreter.Graphics.cs`): ARGB values with alpha 0xFF (e.g. `RED#` = 0xFFFF0000) exceed `int.MaxValue`, and the old direct `(int)` cast overflowed them to white. Verified: `PSET (50,50), RED#` then `POINT(50,50)` gives the same pixel as `RGB(255, 0, 0)`.
- Examples: 23 files in `Examples\` used these names as their own constants; `LET x# = RGB(...)` lines were removed (the built-in is used) and palette-index definitions (0–15, used with `COLOR`) were renamed to `C_<name>#`.

## MOUSEWHEEL function (T28)

New in version 1.8 (added 2026-11-23). `MOUSEWHEEL` (or `MOUSEWHEEL()`) returns the vertical mouse wheel notches rolled since the previous `MOUSEWHEEL` call, in whole numbers, and then resets the count to 0. Positive = rolled away from the user (up), negative = toward the user (down), 0 = no movement.

```basic
LET w$ = MOUSEWHEEL
IF w$ <> 0 THEN zoom$ = zoom$ * POW(1.25, w$)
```

- Graphics mode only; in console mode it returns 0 without an error, like `MOUSEX`. A new `SCREEN` starts from 0, and the first call returns what was rolled since `SCREEN` (call it once after setup to discard that, if wanted).
- Notches rolled while the program waits in `SLEEP`, `WAITKEY` or graphics `INPUT` are kept. Store the value in a variable: a second call in the same frame returns 0.
- Touchpads and high-resolution wheels: SDL adds sub-notch movement up into whole notches. The horizontal wheel (tilt) is not supported.
- `MOUSEWHEEL(1)` stops with `Error at line N: MOUSEWHEEL takes no arguments - use MOUSEWHEEL or MOUSEWHEEL()`. The older mouse functions (`MOUSEX`, `MOUSEY`, `MOUSELEFT`, ...) still take no parentheses.
- Internals: new token `TOK_MOUSEWHEEL = 362` (nothing renumbered). `SDL_MOUSEWHEEL` events are summed in `Graphics.cs` by both SDL event loops (the regular event pump and the graphics `INPUT` loop), so no notch is lost between calls. Old `.bb` libraries load as before; a `.bb` that uses `MOUSEWHEEL` needs 1.8 or newer. The IDE and the editor keyword files in `extras/` highlight the new name. Variables such as `mousewheel$` are not affected, so this is not a breaking change.

## PAINT flood fill with optional border color

`PAINT (x, y), fillColor[, borderColor]` now flood-fills like in QB/FreeBASIC (fixed for 1.8; the manual already documented the two-color form, but the interpreter never read the border). Starting at (x, y), the contiguous region of the starting pixel's color is painted with `fillColor` and the fill stops at pixels of `borderColor`. If the border color is omitted, the fill color is used as the border (QB default), so the fill stops at any pixel already in the fill color. Starting on a border pixel, off-screen, or on an area already in the fill color is a no-op; in console mode (no `SCREEN`) `PAINT` does nothing, as before.

Before, `PAINT` painted only the single pixel at (x, y), and a second color argument stopped the program with `Error at line N: Unexpected ',' - not a valid statement` — so `Examples\graphics\Graphics_01_Drawing_Primitives.bas` (line 48) and `Examples\rosetta-code\Draw_a_cuboid.bas` (lines 46-48) errored out when run, despite using the documented form.

- Internals: scanline flood fill in `Graphics.Paint()` (`src\Graphics\Graphics.cs`) — reads through the POINT pixel cache, writes horizontal runs with `SDL_RenderDrawLine`, cache updated write-through. `ExecutePaint` (`src\Interpreter\Interpreter.Graphics.cs`) parses the optional border argument. No new tokens; old `.bb` libraries are unaffected. Tested headless (SDL dummy video + software renderer): fill inside a white box stops at the border, borderless fill spreads over the open area, no-op cases behave, console mode unchanged — exit code 0.
