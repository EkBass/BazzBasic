# Changes archive
Older entries moved from [changes.md](changes.md), newest first. Covers version 1.4 and everything before it.

## 16th October 2026
Released as version 1.5

## 16th October 2026

### Fix: `LINE ... B` and `LINE ... BF` now include the second corner

Box forms of `LINE` treated `(x2, y2)` as exclusive, so `LINE (10,10)-(12,12), c, BF` filled only 2×2 pixels while a plain `LINE` included its end point. Boxes are now inclusive like plain `LINE` (QBasic behaviour): the same call fills 3×3. Corners may also be given in any order; reversed corners previously drew inconsistently between `B` and `BF`.

**Possible 1 px change in existing programs:** a box drawn with `x2 = x + w` is now one pixel wider/taller. Use `x + w - 1` for an exact `w`-pixel box. Full-screen clears such as `LINE (0,0)-(640,480), 0, BF` are unaffected (clipped); `(0,0)-(639,479)` now covers the last row and column too.

### New: Gamepad support

BazzBasic now reads game controllers (Xbox, PlayStation, Switch Pro and most compatible pads) through SDL2's GameController API. USB and Bluetooth both work. Five new keywords:

| Keyword | Returns |
|---------|---------|
| `GAMEPADS()` | Number of connected pads (parentheses optional) |
| `PADBUTTON(pad, button)` | TRUE while the button is held |
| `PADAXIS(pad, axis)` | Sticks -1.0 … 1.0, triggers 0.0 … 1.0 |
| `PADNAME(pad)` | Controller name, `""` if not connected |
| `PADRUMBLE pad, strength, ms` | Statement: vibrate, strength 0.0 … 1.0 (parentheses optional) |

New built-in constants: buttons `PAD_A#` `PAD_B#` `PAD_X#` `PAD_Y#` `PAD_BACK#` `PAD_GUIDE#` `PAD_START#` `PAD_LSTICK#` `PAD_RSTICK#` `PAD_LB#` `PAD_RB#` `PAD_UP#` `PAD_DOWN#` `PAD_LEFT#` `PAD_RIGHT#` `PAD_MISC#` `PAD_TOUCHPAD#` (values = SDL button numbers, 0–20 accepted), axes `PAD_LX#` `PAD_LY#` `PAD_RX#` `PAD_RY#` `PAD_LT#` `PAD_RT#`.

- Works in console and graphics mode; no `SCREEN` needed.
- Pads are numbered from 0, max 8. A pad keeps its number while connected.
- A pad that is not connected reads as no input (FALSE / 0 / `""`), never as an error.
- Hot-plug: pads connected or switched on while the program runs are found within ~250 ms.
- Built-in dead zone of 15 % on sticks and triggers.
- Button number outside 0–20 or axis outside 0–5 is an error.

```basic
PRINT "Pads: "; GAMEPADS()
IF PADBUTTON(0, PAD_A#) THEN PRINT "A held"
x$ = x$ + PADAXIS(0, PAD_LX#) * SPEED#
PADRUMBLE 0, 0.5, 200
```

Implementation: new `src/Gamepad/GamepadManager.cs` and `src/Interpreter/Interpreter.Gamepad.cs`, tokens `TOK_GAMEPADS`…`TOK_PADRUMBLE` in the new range 600–649, GameController P/Invoke bindings added to `src/SDL2/SDL2.cs`. Pad state is polled with `SDL_GameControllerUpdate()` instead of read from SDL events (the graphics event loops would otherwise swallow them); joystick/controller events are set to `SDL_IGNORE`. The subsystem is initialized lazily and re-initialized if `Graphics.Shutdown()` has called `SDL_Quit()`. `SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS` is set so pads keep working when the console window has focus. SDL2.dll stays at 2.28.5.

Documented in `docs/manual/input_functions.md` (new Gamepad section) and `docs/manual/variables-and-constants.md`. New examples in `Examples/GamePad/`: `gamepad_test.bas`, `gamepad_graphics.bas`, `Pad-steered_plane_with_screen_wrap.bas`, `2D_maze_FOV_demo_console_PAD.bas`.

### IDE and editor keyword lists

- IDE syntax highlighting: `GAMEPADS`, `PADBUTTON`, `PADAXIS`, `PADNAME`, `PADRUMBLE` added.
- `extras/BazzBasic.udl.xml` (Notepad++) and `extras/reserved-words.xml` re-synced with the interpreter's keyword and constant tables. Both had fallen far behind: they lacked e.g. `ARRKEY`, `FSTRING`, `FILELIST`, `ATAN2`, `INBETWEEN`, `ROWCOUNT`, `ARGS`, `ARGCOUNT`, `LOADFONT`, `DRAWSTRING`, `MOUSEHIDE`, `MOUSESHOW`, `STARTLISTEN`, `GETREQUEST`, `SENDRESPONSE`, `STOPLISTEN`, the numpad operator keys and `PRG_ROOT`, and both still listed `BEEP`. The UDL now also highlights `AND OR NOT TRUE FALSE ON OFF TICKS TIME` and all `PAD_*` constants. `reserved-words.xml` is marked version 1.5 and has new `input-gamepad` and `pad-constants` sections.
- `extras/filetypes.BazzBasic.conf` (Geany) re-synced the same way (was for v1.3b, also listed `BEEP`).
- The VS Code extension (`extras/bazzbasic-1.1.0.vsix` and `extras/vsix_unpack/`) was removed. It was far out of date; a new one may be built later. `extras/readme.md` updated.

### Bug fix: DEF FN functions could read and write global arrays

Functions are meant to be isolated from the main program: they see global constants (`#`) but not global variables. Arrays were an exception by accident: a function could read and change any global array it did not `DIM` itself, just by using its name. Global arrays are now invisible inside a function, the same as global variables. An array goes into a function as a JSON string with `ASJSON()` and is rebuilt inside with `ASARRAY()`, as documented.

```basic
DIM g$
g$(0) = "global"

DEF FN Peek$(i$)
    RETURN g$(i$)
END DEF

PRINT FN Peek$(0)
' was: global
' now: Error: Global array G$ is not visible inside DEF FN - pass it as a parameter with ASJSON() and rebuild it with ASARRAY()
```

Inside a function, `LEN(g$())`, `HASKEY` and the other array functions treat a global array as if it did not exist (`0`), as they do for an undeclared array at the top level. None of the example programs relied on the old behavior.

## 15th October 2026

### IDE: new Edit menu, old Edit menu renamed to Search

The old **Edit** menu only held Find (Ctrl+F) and Replace (Ctrl+H), so it is now called **Search**. A new **Edit** menu has Undo (Ctrl+Z), Redo (Ctrl+Y), Cut (Ctrl+X), Copy (Ctrl+C), Paste (Ctrl+V) and Select All (Ctrl+A). Items that can't be used at the moment are greyed out while the menu is open. The keyboard shortcuts worked in the editor before as well; they are now also visible in the menu.

### IDE: Help menu links to the online manual and Rosetta Code

**Help** now has **Online Manual**, which opens https://ekbass.github.io/BazzBasic/manual/#/, and **Rosetta Code**, which opens the BazzBasic category on rosettacode.org. Both open in the default browser. The About dialog's shortcut list and `docs/manual/ide-usage.md` were updated to match.

### IDE: Light and Dark mode (Dark mode is experimental)

New **View** menu with **Light Mode** and **Dark Mode (experimental)**. Dark mode is usable but not polished: the empty area next to the editor tabs stays light, because WinForms' TabControl doesn't let it be recolored easily. Dark mode colors the editor, syntax highlighting, line numbers, menus, status bar, tabs and (on Windows 10 20H1+ / Windows 11) the title bar. The Find/Replace dialog and message boxes stay light. The choice is saved to `%AppData%\BazzBasic\ide.json` and restored on the next start.

### Bug fix: IDE syntax highlighting missed newer keywords

The IDE's keyword lists had fallen behind the interpreter, so `ARRKEY`, `FSTRING`, `ISSET`, `ATAN2`, `INBETWEEN`, `ROWCOUNT`, `ARGS`, `ARGCOUNT`, `LOADFONT`, `DRAWSTRING`, `MOUSEHIDE`, `MOUSESHOW`, `STARTLISTEN`, `GETREQUEST`, `SENDRESPONSE`, `STOPLISTEN`, `B` and `BF` were not highlighted. The lists also contained `beep`, which is not a BazzBasic keyword, and `filelist` before the function existed (it does now, see below). The lists now match the interpreter's keyword table exactly.

### New: FILELIST()

`FILELIST(arr$, folder$ [, pattern$])` fills `arr$` with the names of the files in `folder$` and returns the count. Only files, no subfolders, names only (no paths), sorted alphabetically, keys `0`..`count-1`. The array is emptied first. `pattern$` takes `*` and `?` wildcards; default is all files. Hidden and system files are skipped. A missing folder returns `0`.

```basic
DIM files$
LET n$ = FILELIST(files$, PRG_ROOT# + "levels", "*.txt")
FOR i$ = 0 TO n$ - 1
    PRINT files$(i$)
NEXT i$
```

### Bug fix: SPLIT() left old elements in the array

`SPLIT()` only overwrote keys `0`..`n-1`, so splitting a shorter string into an array that already held a longer split left the old tail behind: after `SPLIT(p$, "a,b,c,d", ",")` and then `SPLIT(p$, "x,y", ",")`, `LEN(p$())` was still 4 and `p$(2)` was still `"c"`. `SPLIT` now empties the array first, like `FILELIST`. The return value was always correct; code that looped over `LEN(arr$())` or used `HASKEY` saw the stale elements. `SPLIT` now also accepts `arr$()` as the first argument, as `FILELIST` does.

### Removed: BEEB

`BEEB` was an undocumented statement that called `Console.Beep()`, meant as a nod to the `BEEP` of old BASIC dialects. It was never documented and the idea was dropped, so the keyword is gone. Programs that use it now get an error; use `LOADSOUND` and `SOUNDONCE` for sounds. The one example that used it (`Examples/rosetta-code/Days_between_dates.bas`) was updated.

### Bug fix: numpad keys did not match KEY_NUMPAD*# in INKEY and WAITKEY

In graphics mode `INKEY` and `WAITKEY` returned raw SDL values for numpad keys (e.g. 1073741922 for numpad 0), so `KEY_NUMPAD0#`...`KEY_NUMPAD9#` only worked with `KEYDOWN`. Numpad keys now return the same codes as the constants. Numpad Enter now returns 13, the same as `KEY_ENTER#`.

### New: numpad operator constants

`KEY_NUMPAD_PLUS#` (266), `KEY_NUMPAD_MINUS#` (267), `KEY_NUMPAD_MUL#` (268), `KEY_NUMPAD_DIV#` (269), `KEY_NUMPAD_DOT#` (270). They work with `INKEY`, `WAITKEY` and `KEYDOWN` in graphics mode and are the same on every keyboard layout.

### Bug fix: console WAITKEY used different key codes than console INKEY

Console `WAITKEY` returned .NET `ConsoleKey` values, so `WAITKEY(KEY_UP#)`, `WAITKEY(KEY_F1#)` and punctuation never matched. It now uses the same mapping as console `INKEY`.

### Change: console INKEY returns letters as uppercase codes

Console `INKEY` returned 97 for "a" and 65 for "A", so `INKEY = KEY_A#` only matched with Shift or Caps Lock. Letters are now normalized to 65-90 as in graphics mode. Programs that compare console `INKEY` against `ASC("a")` need to use `KEY_A#` or `ASC("A")`.

### Change: KEYDOWN follows the key label, not the key position

`KEYDOWN` checked the physical key position of a US keyboard, while `INKEY` returns the key's label on the current layout. On a Finnish keyboard `KEYDOWN(KEY_MINUS#)` reacted to the "+" key and `KEYDOWN(KEY_EQUALS#)` to the "´" key; on AZERTY `KEYDOWN(KEY_A#)` reacted to the key labelled "Q". `KEYDOWN` now uses the same meaning as `INKEY`: letters, digits and punctuation constants refer to the key that types that character on the current layout. If no key types the character without modifiers (e.g. "=" on a Finnish keyboard), `KEYDOWN` returns FALSE. Arrows, function keys, numpad and modifiers are unchanged.

## 11th October 2026

### Bug fix: arrays DIM'd inside DEF FN kept their contents between calls

All arrays lived in one global table, and `DIM` on an existing name was a no-op. An array declared inside a function therefore survived the call: the next call saw the previous call's keys, recursive calls all shared one array, and a `DIM` inside a function whose name matched a global array silently wrote into the global one. This also affected the documented `ASJSON`/`ASARRAY` pattern: stale keys from an earlier call stayed in the array.

```basic
DEF FN Count$(x$)
    DIM t$
    t$(x$) = 1
    RETURN LEN(t$())
END DEF

PRINT FN Count$(1)   ' 1
PRINT FN Count$(2)   ' was 2, now 1
```

Now each function call (and each recursion level) has its own array table. `DIM` inside a function always creates a fresh, empty local array, shadowing any global array of the same name. `DIM` at the top level is unchanged. (Since 16th October 2026 functions can no longer see global arrays at all, see above.)

## 10th October 2026

### Bug fix: FSTRING() did not recognize built-in constants

`FSTRING()` placeholders only looked up user-defined variables and constants, so built-in constants such as `PI#`, `EULER#` or `KEY_A#` failed with `FSTRING: undefined variable 'EULER#'.`, even though they worked everywhere else in expressions. A constant declared in BazzBasic code itself (`LET FOO# = ...`) was not affected. The same bug also affected built-in constants used as array indexes inside a placeholder.

Placeholders now check built-in constants first and then user variables/constants, in the same order as normal expression evaluation:

```basic
PRINT FSTRING("e = {{-EULER#-}}")          ' e = 2.718281828459045
PRINT FSTRING("pi = {{-PI#-}}")            ' pi = 3.141592653589793
PRINT FSTRING("key: {{-keys$(KEY_A#)-}}")  ' built-in constant as array index
```

## 6th September 2026

### New: ARRKEY() — iterate associative arrays with FOR/NEXT or WHILE/WEND

BazzBasic arrays have always supported string keys (`arr$("name") = ...`) as well as numeric ones, but there was no way to loop over the keys — only `LEN(arr$())` telling you *how many* there were. `ARRKEY(arr$(), i)` returns the key at a given 0-based index, in insertion order:

```basic
DIM car$
	car$("manufacturer") = "Ford"
	car$("engine") = "1.6 Eco"
	car$("color") = "Blue"

FOR i$ = 0 TO LEN(car$()) - 1
	LET key$ = ARRKEY(car$(), i$)
	PRINT key$; " = "; car$(key$)
NEXT i$
```

No new loop keyword needed — `ARRKEY` plus the existing `LEN(arr$())` is enough for both `FOR/NEXT` and `WHILE/WEND`.

Internally, array storage moved from `Dictionary<string, Dictionary<string, Value>>` to `Dictionary<string, OrderedDictionary<string, Value>>` (`OrderedDictionary`, .NET 9+). A plain `Dictionary` only preserves insertion order as an implementation detail, not a documented guarantee — `OrderedDictionary` makes it official and gives `ARRKEY` O(1) indexed lookup instead of an O(n) scan per call. No BASIC-level behavior changes as a result of this — `ROWCOUNT`, `ASJSON`, `JOIN`, `SAVEJSON`, and HTTP header arrays all still work exactly as before.

## 4th September 2026

### Documentation: % as modulo was undocumented

`%` has always worked as the modulo (remainder) operator — `10 % 3` → `1`, same precedence as `*`/`/` — it just was never listed in `operators.md` or mentioned in `math_functions.md`. No code change, documentation only.

---

## Released: version 1.4c (4th September 2026)

### Bug fix: ROUND() used banker's rounding instead of always rounding halves up

`ROUND()` called `Math.Round()` without a midpoint mode, so .NET defaulted to `MidpointRounding.ToEven` ("banker's rounding"): `ROUND(0.5)` gave `0`, `ROUND(10.5)` gave `10`, `ROUND(2.5)` gave `2` — always rounding `.5` to the nearest *even* number instead of always up. Now uses `MidpointRounding.AwayFromZero`, so `.5` always rounds away from zero:

```basic
PRINT ROUND(0.5)    ' now 1 (was 0)
PRINT ROUND(10.5)   ' now 11 (was 10)
PRINT ROUND(-0.5)   ' now -1
```

### Bug fix: SRAND() had a duplicate '0' and a stray '£' in its character set

`SRAND(n)`'s allowed character set accidentally listed `0` twice (giving it double the chance of the other digits) and included the British pound sign `£`, a non-ASCII character that had no business being there. The set is now 81 characters, each with equal probability, `£` removed entirely.

### Bug fix: PRG_ROOT# was missing its trailing directory separator

`PRG_ROOT#` never ended with `\` or `/`, so concatenating a relative path directly (`PRG_ROOT# + "data/file.txt"`) merged the program's folder name with the subfolder name into one broken path (e.g. `...\MyProjectdata\file.txt`) and silently failed to create the file. `PRG_ROOT#` now always ends with a directory separator:

```basic
FILEWRITE PRG_ROOT# + "data/file.txt", content$   ' now works without adding your own separator
```

### Bug fix: FILEREAD-into-array (.env style parsing) broke completely on a single comment line

Assigning `FILEREAD()`'s output to a `DIM`'d array (`DIM env$ = FILEREAD(".env")`) parses `KEY=value` lines into array elements. The parser required *every* line to contain `=`, so a single `#`-prefixed comment line (no `=` at all) made the whole population step silently fail — leaving the array completely empty, including keys that appeared *before* the comment. Blank lines and full-line `#` comments are now skipped before validation. Inline comments (`KEY=value # note`) are not yet supported.

### Bug fix: calling a DEF FN function without the FN keyword silently did nothing

Writing `Foo$(1)` on its own line (forgetting the `FN` keyword, e.g. instead of `FN Foo$(1)`) was silently swallowed — the parser treated it as an array-element assignment target, found no `=` sign after it, and just moved on without calling the function or reporting anything. Now, if the name matches a declared `DEF FN` function, this produces a clear error instead:

```basic
DEF FN Foo$(bar$)
    RETURN bar$ + 1
END DEF

Foo$(1)   ' Error: 'FOO$' is a DEF FN function, not an array — did you forget the FN keyword? Use: FN FOO$(...)
```

### Examples folder reorganized

`Examples/` was a flat pile of ~80 scripts. Split into `Examples/graphics/`, `Examples/audio/`, `Examples/console/` and `Examples/classics/` (ports of classic 1970s/80s BASIC games — Eliza, Acey Ducey, Robots, Towers of Hanoi, Trap, Russian Roulette, Rock-Paper-Scissors, the Wingbermuehle maze generator). Also removed 12 old internal regression-test scripts (`*_test.bas` style files exercising ISSET, FSTRING, line continuation, FastTrig, DISTANCE, HTTP listen/timeout, etc.) that had no demonstration value and were already covered by the automated test pass long ago. `rosetta-code/` is untouched and stays a separate, curated category.

Going forward, more effort should go into graphics examples specifically. BazzBasic still gets mistaken for a console-only interpreter by a lot of people, partly because so many of the earlier example programs were console-based — the graphics/SDL2 side deserves better representation.

---

## Released: version 1.4b (21st May 2026)

## 14th May 2026

### Bug fix: RGB() with low blue values

Fixed a long-standing bug where `RGB(0, 0, b)` with `b` in the range 0–255 produced wrong colors. The classic example: `RGB(0, 0, 255)` drew **white** instead of blue, because the packed RGB value `255` collided with palette index 255 and fell through to the default "white" branch. The same bug also affected any `RGB(0, 0, b)` with `b ≤ 255` and `RGB(0, 0, 0)` happened to work only by coincidence (palette index 0 is also black).

Internally, `RGB()` now sets bit 24 (`0x01000000`) as a flag so RGB values and palette indices can no longer collide. Drawing primitives (`PSET`, `LINE`, `CIRCLE`, `PAINT`, `DRAWSTRING`, `LOADSHAPE`) all route their color parameter through a single resolver in `Graphics.Graphics`.

### DRAWSTRING and LOADSHAPE now accept palette indices

As a side effect of the centralized color resolver, `DRAWSTRING` and `LOADSHAPE` now accept palette indices 0–15 as well as `RGB()` values. Previously they only worked correctly with `RGB()`.

```basic
DRAWSTRING "Hello", 10, 10, 12              ' Palette index 12 (light red) — now works
LET S$ = LOADSHAPE("CIRCLE", 50, 50, 9)     ' Palette index 9 (light blue) — now works
```

### Compatibility note

If you stored raw packed RGB integers in your code (e.g. `LINE (0,0)-(100,100), 16711680` for red), they will no longer be recognized as RGB and will be treated as out-of-range palette indices (defaulting to white). Use `RGB(255, 0, 0)` instead. There was never a documented way to construct raw packed RGB by hand, so this should affect very few programs.


## 1st May 2026
Released as ver. 1.4

## 1st May 2026

### Line Continuation
BazzBasic now supports line continuation, see more from documents.

### Added ISSET.

ISSET returns true of false depending is variable/constant deckared. ISSET() does not care about the value, just the declaration.

```basic
[inits]
    LET a$ ' just declaration
    LET b$ = "b$"
    LET c$ = 123

    LET MY_CONST# = "Foo"

[main]
    PRINT ISSET(a$) ' true
    PRINT ISSET(b$) ' true
    PRINT ISSET(c$) ' true
    PRINT ISSET(MY_CONST#) ' true

    PRINT ISSET(foo$) ' false
    PRINT ISSET(FOO#) ' false
```

## 30th April 2026

Added **FSTRING**. FSTRING() stand for "Fixed String". In other languages it is also known as 'Interpolated strings', 'Template strings', 'Formatted string literals' or 'Embedded expressions in strings'.

```basic
' BazzBasic version 1.3b
' https://ekbass.github.io/BazzBasic/
'
' Consult file "Examples\fstring_test.bas" for more examples or https://ekbass.github.io/BazzBasic/manual/#/string_functions

[inits]
    LET a$ = "Hello"
    LET NAME# = "John Doe"
    LET foo$ = FSTRING("{{-a$-}} there {{-NAME#-}}. How are you?")

    DIM arr$
        arr$(1) = "Bazz"
        arr$("foo") = "Basic"

[main]
    PRINT foo$

    ' To avoid "quot confusion", use literals with out quotes
    PRINT FSTRING("{{-arr$(1)-}} and {{-arr$(foo)-}}")
END

' Output:
' Hello there John Doe. How are you?
' Bazz and Basic
```

## 26th April 2026

Some manual fixes.  
Missing floating point example for RND() etc.

## 19th April 2026

Release as ver. 1.3b

## 18th April 2026

**Fixed:** Concanationing did not work with arrays
```basic
a$+= 5 ' worked
arr$(1) += 5 ' did not work
' but works now with ver. 1.3b
```

**Added:** several more example codes. Rosett-code solutions counter now a bit over 130.

**Added:** MOUSEHIDE and MOUSESHOW statemetens

**MOUSEHIDE** hides mouse cursor on graphics screen  
**MOUSESHOW** brings it back.

Both works only when graphical screen is initialized (SCREEN 'mode')


**Added:** INBETWEEN.
Returns true, if *n* is between *min* and *max* and not equal to them

```vb
INBETWEEN(1, 1, 10) ' false
INBETWEEN(2, 1, 10) ' true
BETWEEN(1, 1, 10) ' true
BETWEEN(2, 1, 10) ' true
```

Unlike BETWEEN which returns true if *n* is equal or between *min* and *max*, INBETWEEN returns true if *n* is not equal and between *min* and *max*

**Added:** ATAN2().
```basic
PRINT ATAN2(x$, y$) ' 0.4636476090008061
```


## 13th April 2026

**Fixed: `LOADSHEET` — sprite indexing now starts at 0**

Sprites loaded from a sheet are now indexed from 0, consistent with all other arrays in BazzBasic. Previously the first sprite was at index 1.

**Fixed: `VSYNC` — keyboard input no longer breaks after toggling VSync at runtime**

`VSYNC(TRUE/FALSE)` now uses `SDL_RenderSetVSync` to switch vertical sync without destroying the renderer. Previously the renderer was recreated on each call, causing the window to briefly lose focus and SDL to reset the keyboard state — making `KEYDOWN` and `INKEY` unresponsive until the next keypress.


## 10th April 2026

Version 1.3 released as binary

**Added: `DRAWSTRING` and `LOADFONT` — text rendering in graphics mode**

Renders text directly to the SDL2 graphics surface. Requires `SDL2_ttf.dll` in the same directory as the interpreter. Prefer over `PRINT` in graphics mode — `PRINT` bypasses the SDL2 rendering pipeline and causes flickering.

```vb
' Default font (Arial, size 20)
DRAWSTRING "Hello!", 100, 200, RGB(255, 255, 255)

' Load alternative font — becomes the new active font
LOADFONT "myfont.ttf", 24
DRAWSTRING "Hello!", 100, 200, RGB(255, 255, 255)

' Reset to default (Arial, size 20)
LOADFONT
```

`DRAWSTRING` positions text by its top-left corner. Copy `.ttf` files next to your `.bas` for portability — Windows system fonts can be referenced by full path but are not recommended for distribution.

**Added: `ROWCOUNT` — count array rows**

Returns the number of distinct first-dimension keys in an array.

```vb
PRINT ROWCOUNT(myArray$)
```

**Added: `ARGCOUNT` and `ARGS()` — command-line arguments**

Access command-line arguments passed to the program.

```vb
PRINT ARGCOUNT          ' Number of arguments
PRINT ARGS(0)           ' First argument
```

**Added: compound assignment operators**

Shorthand for common arithmetic assignments. Works on variables (`$`), not constants (`#`).

```vb
x$ += 5    ' x$ = x$ + 5
x$ -= 2    ' x$ = x$ - 2
x$ *= 3    ' x$ = x$ * 3
x$ /= 4    ' x$ = x$ / 4
str$ += " world"   ' String concatenation
```

**Changed: `INSTR()` — case-sensitivity parameter**

`INSTR` now accepts an optional case-sensitivity flag.

```vb
PRINT INSTR("Hello World", "world")       ' 0 (case-sensitive, not found)
PRINT INSTR("Hello World", "world", 0)    ' 7 (case-insensitive)
```

**Changed: math constants now use `#` suffix**

`PI`, `HPI`, `QPI`, and `TAU` are now `PI#`, `HPI#`, `QPI#`, `TAU#` for consistency with the rest of the language.  
⚠️ Breaking change — update any code using the old names.

**Changed: IDE and CLI improvements**

| Menu | Shortcut | Action | CLI option |
|------|----------|--------|------------|
| File | Ctrl+N | New file | BazzBasic.exe |
| File | Ctrl+O | Open file | none |
| File | Ctrl+S | Save file | none |
| File | Ctrl+Shift+S | Save As | none |
| File | Ctrl+W | Close tab | none |
| File | Alt+F4 | Exit | none |
| Edit | Ctrl+F | Find | none |
| Edit | Ctrl+H | Replace | none |
| Run | F5 | Run Program | BazzBasic.exe file.bas |
| Run | — | Compile as Exe | BazzBasic.exe -exe file.bas |
| Run | — | Compile as Library (.bb) | BazzBasic.exe -lib file.bas |
| Help | — | About | BazzBasic.exe -v |
| Help | — | Beginner's Guide | BazzBasic.exe -guide |
| Help | — | Check For Updates | BazzBasic.exe -checkupdates |

New files now open with a starter template:

```vb
' BazzBasic version 1.3
' https://ekbass.github.io/BazzBasic/
```

**Bugfix: early RETURN inside FOR loop left function scope dirty**

If a function returned early (e.g. via `RETURN` inside a `FOR` loop), local variables were not cleared. This caused stale values on subsequent calls to the same function. Now fixed.

---

## 3rd April 2026

Released as version 1.2 with some bug fixes and new features.

## 3rd April 2026

A Beginners Guide to BazzBasic is now available. It covers all the basics of programming in BazzBasic with what beginner can star at.

https://github.com/EkBass/BazzBasic-Beginners-Guide/blob/main/BazzBasic_Beginners_Guide.md

## Mar 2026

## 31st Mar 2026

**Added: `BBVER#` — version constant**

Returns the running BazzBasic version as a string. Value is read directly from `Version.cs` at startup.

```vb
PRINT "Running BazzBasic "; BBVER#   ' Output: Running BazzBasic 1.1d
```

**Added: `JOIN` — merge two arrays**

Merges `src1$` and `src2$` into `dest$`. If both source arrays share a key, `src2$` overwrites `src1$`.

```vb
JOIN dest$, src1$, src2$
```

**Added: `CURPOS("row"/"col")` — read cursor position**

Returns the current cursor row or column (1-based). Useful after `PRINT` or `LOCATE`.

```vb
LOCATE 5, 10
PRINT "Hello"
PRINT CURPOS("row")   ' Output: 5
PRINT CURPOS("col")   ' Output: 15
```

**Renamed: `ROOT#` → `PRG_ROOT#`**

The built-in system constant holding the program's base directory path has been renamed to `PRG_ROOT#` for clarity.  
⚠️ Breaking change — update any code using `ROOT#`.

**Bugfix: `SCREEN` reinitialization**

Calling `SCREEN` more than once no longer causes a crash or corrupted graphics state. Reinitializing the window mid-program now works correctly.

---

## 26th Mar 2026

I spent a couple of hours editing the already somewhat confusing documentation.

I think the new structure and division is clearer now and it's easier to find what you need.  
*Ek*

## 26th Mar 2026

Due MOUSE issue below is pretty major, BazzBasic 1.1d released as source and binary

## 26th Mar 2026

**Bugfix: Mouse button detection rewrite**

`MOUSEB AND MOUSE_LEFT#` did not work correctly because `AND` in BazzBasic is logical, not bitwise — any non-zero value is TRUE, so all three buttons appeared pressed simultaneously.

**Removed:**
- `MOUSE_LEFT#`, `MOUSE_RIGHT#`, `MOUSE_MIDDLE#` built-in constants
- `MOUSEB` keyword (token kept internally for binary compatibility)

**Added:**
- `MOUSELEFT` — returns 1 if left mouse button is pressed, 0 otherwise
- `MOUSERIGHT` — returns 1 if right mouse button is pressed, 0 otherwise
- `MOUSEMIDDLE` — returns 1 if middle mouse button is pressed, 0 otherwise

```vb
WHILE INKEY <> KEY_ESC#
    LOCATE 1, 1
    PRINT "X:"; MOUSEX; " Y:"; MOUSEY; "   "

    IF MOUSELEFT   THEN PRINT "Left clicked  "
    IF MOUSERIGHT  THEN PRINT "Right clicked "
    IF MOUSEMIDDLE THEN PRINT "Middle clicked"

    SLEEP 10
WEND
```

## 22nd Mar 2026

Quick "rerelease" as 1.1b

- I forgot to update version from source
- I forgot to update syntax files for Notepad++, VS Code, Geany and built-in IDE
- Headers "support" not documented
  
```vb
HTTPGET(url$)                           ' works as before
HTTPGET(url$, headers$)         ' new, optional

HTTPPOST(url$, body$)                       ' works as before
HTTPPOST(url$, body$, headers$)     ' new, optional
```
See [OpenAI API example](https://github.com/EkBass/BazzBasic/blob/main/Examples/OpenAI_request.bas) for more.

## 22nd Mar 2026

Released as version 1.1

## 22nd Mar 2026

At Rosetta code I got inspired to create pendulum animation.
[pendulum_animation.bas](Examples/pendulum_animation.bas)

## 21st Mar 2026

BazzBasic-AI_guide.md is a tutorial for modern AI's. With it, AI can easily teach the user how to use BazzBasic.

Just download the file, attach it as project file or via prompt to AI and you are cool to go.  

[Technical guide ment for AI](https://github.com/EkBass/BazzBasic/discussions/26)

---
Unfortunately, the GamePad support I planned didn't make it to version 1.1

The reason is that the SDL2 library has been having problems for some time, especially with Bluetooth gamepads.

I didn't want to do something half-hearted, so the gamepad support is now on hold until SDL2 gets its library back in condition.

Instead, I added three other functions that I've had in mind for some time: *BASE64ENCODE*, *BASE64DECODE* and *SHA256*

## 21st Mar 2026

Added JSON support: `ASJSON`, `ASARRAY`, `LOADJSON`, `SAVEJSON`

```vb
DIM data$
data$("name") = "Alice"
data$("score") = 9999
data$("address,city") = "New York"

LET json$ = ASJSON(data$)
' Output: {"name":"Alice","score":9999,"address":{"city":"New York"}}

DIM back$
LET count$ = ASARRAY(back$, json$)
PRINT back$("name")         ' Alice
PRINT back$("address,city") ' New York

SAVEJSON data$, "save.json"
DIM loaded$
LOADJSON loaded$, "save.json"
```

Added `BASE64ENCODE`, `BASE64DECODE` and `SHA256`

```vb
LET encoded$ = BASE64ENCODE("Hello, World!")
PRINT encoded$              ' SGVsbG8sIFdvcmxkIQ==

LET decoded$ = BASE64DECODE(encoded$)
PRINT decoded$              ' Hello, World!

LET hash$ = SHA256("password123")
PRINT hash$                 ' ef92b778... (64-char lowercase hex)
```

---

## 14th Mar 2026

### Sound system fix — parallel audio playback

**Problem:** The old implementation loaded MP3/OGG/FLAC files with `Mix_LoadMUS()` which uses the SDL2_mixer's global Music channel — only one sound at a time.

**Fixes:**
- All sounds are now loaded with `Mix_LoadWAV()` → play on their own Mix_Channels in parallel
- `SDL_INIT_AUDIO` added to `SDL_Init()` call in `Graphics.cs`
- `SoundManager` calls `SDL_Init` + `SDL_InitSubSystem` to ensure audio subsystem even without `SCREEN` command
- `SDL_AUDIODRIVER=directsound` set in `Program.cs` to work around WASAPI issues (Nahimic middleware causes "Invalid Handle" error in WASAPI)
- `PlayOnceWait` gets 50ms delay before polling loop due to DirectSound startup delay


## 7th Mar 2026

Added HTTP support for LOADIMAGE
### LOADIMAGE with url
```vb
LET sprite$ = LOADIMAGE("https://example.com/sprite.png")
' → downloads "sprite.png" to root of your program
' → sprite$ works just as with normal file load

' to remove or move the downloaded file
SHELL("move sprite.png images\sprite.png")   ' move to subfolder
' or
FileDelete "sprite.png"                       ' just delete it
```

Added WAITKEY() function. 

### WAITKEY
Halts the execution until requested key is pressed.

```vb
' Wait just the ENTER key
PRINT "ENTER"
PRINT WAITKEY(KEY_ENTER#) ' output: 13

' Wait any of "a", "b" or "esc" keys
PRINT "A, B or ESC"
PRINT WAITKEY(KEY_A#, KEY_B#, KEY_ESC#) ' output: depends of your choice of key

PRINT "Press any key..." 
LET a$ = WAITKEY()
PRINT a$ ' output: val of key you pressed
```

## 2nd Mar 2026

Added SHELL feature

```vb
' SHELL arg$, timeout$
' Sends a command to the system command interpreter  
' Param *timeout$* is optional. If not given, standard 5000 milliseconds used for timeout.

' with default timeout option
LET a$ = SHELL("dir *.txt")
PRINT a$

' sets timeout to 2 seconds
' 1000ms = 1 second etc.
LET a$ = SHELL("dir *.txt", 2000)
PRINT a$
```


## Feb 2026

## 22nd Feb. 2026

- Released as version 1.0, source and binary
  
  
## 21st Feb. 2026
- FILEREAD and FILEWRITE now supports arrays too.
- **Example with array:**
```vb
LET FILENAME# = "array.txt"
DIM a$
a$("first") = 1
a$("second") = 2
a$("third") = 3
a$("fourth") = "Four"
a$("fourth", "temp") = "Temp"
FileWrite FILENAME#, a$
DIM b$ = FileRead(FILENAME#)
PRINT b$("fourth", "temp") ' Output: Temp
```

**array.txt content:**
```
first=1
second=2
third=3
fourth=Four
fourth,temp=Temp
```

## 21st Feb. 2026

- Added statements HTTPPOST and HTTPGET. These statements allow you to send HTTP POST and GET requests to a specified URL and retrieve the response as a string.
```vb
DIM response$
LET response$ = HTTPGET("https://httpbin.org/get")
PRINT response$

DIM postResult$
LET postResult$ = HTTPPOST("https://httpbin.org/post", "{""key"":""value""}")
PRINT postResult$
```


- Added statement LOADSHEET(<path>, <size x>, <size t>)
```vb
REM ============================================
REM LOADSHEET demo: countdown 9 -> 0
REM sheet_numbers.png: 640x256, 128x128 sprites
REM Sprite 1=0, 2=1, 3=2 ... 10=9
REM ============================================

SCREEN 640, 480, "Countdown!"

DIM sprites$
LOADSHEET sprites$, 128, 128, "examples/sheet_numbers.png"

REM Center position for a 128x128 sprite on 640x480 screen
LET x# = 256
LET y# = 176

REM Count down from 9 to 0
REM Sprite index = number + 1  (sprite 10 = digit 9, sprite 1 = digit 0)
FOR i$ = 9 TO 0 STEP -1
    CLS
    LET spriteIndex$
    LET spriteIndex$ = i$ + 1
    MOVESHAPE sprites$(spriteIndex$), x#, y#
    DRAWSHAPE sprites$(spriteIndex$)
    SLEEP 500
NEXT

END
```

- - Added FULLSCREEN TRUE/FALSE. Enables or disables borderless fullscreen mode.
```vb
SCREEN 640, 480, "My title"
FULLSCREEN TRUE   ' borderless fullscreen on
FULLSCREEN FALSE  ' Windowed mode
```


## 14th Feb. 2026

- Fixed INPUT and LINE INPUT when using GFX. Binary release also updated

## 14th Feb. 2026

- Added KEYDOWN(<key constant#>) function with what it's possible to check state of all key constants
- Added key constants to all keys I could imagine. Will add more if figured out some is missing

## 13th Feb. 2026

- Released as version 0.9

## 12th Feb. 2026

- Added LERP(start, end, t). Linear interpolation between two values. Returns a value between *start* and *end* based on parameter *t* (0.0 to 1.0).
- Added EULER, which returns raw coded value of e (EULER) 2.718281828459045
- Added VSYNC(TRUE/FALSE). VSync limits frame rate to display refresh rate (typically 60 FPS) but prevents screen tearing. Disabling VSync allows unlimited frame rate but may cause visual artifacts.
- Added DISTANCE(x1, y1, x2, y2) or DISTANCE(x1, y1, z1, x2, y2, z2) which returns distance of 2D or 3D coordinates
- Added CLAMP(n, min, max). If the given parameter *n* falls below or exceeds the given limit values ​​*min* or *max*, it is returned within the limits

```vb
LET brightness$ = CLAMP(value$, 20, 255)
' Replaces lines
' IF brightness$ < 20 THEN brightness$ = 20
' IF brightness$ > 255 THEN brightness$ = 255
```

### 11th Feb. 2026

- Added TAU, which returns raw coded value of PI * 2
- Added QPI, which returns raw coded value of PI / 4
- Added BETWEEN(value, min, max) which returns TRUE if value is between min and max.

### 8th Feb 2026

Version 0.8 released as binary

### 8th Feb. 2026

- Succesfully changed audio from NAudio to SDL2_mixer.

#### Fast Trigonometry (Lookup Tables)

For graphics-intensive applications (games, raycasting, animations), BazzBasic provides fast trigonometric functions using pre-calculated lookup tables. These are significantly faster than standard `SIN`/`COS` functions but have 1-degree precision.

**Performance:** ~20x faster than `SIN(RAD(x))` for integer degree values.

**Memory:** Uses ~5.6 KB when enabled (360 values   2 tables   8 bytes).


##### FastTrig(enable)
Enables or disables fast trigonometry lookup tables.

**Parameters:**
- `TRUE` (or any non-zero value) - Creates lookup tables
- `FALSE` (or 0) - Destroys lookup tables and frees memory

**Important:** Must call `FastTrig(TRUE)` before using `FastSin`, `FastCos`, or `FastRad`.

```vb
' Enable at program start
FastTrig(TRUE)

' Use fast trig functions...
LET x$ = FastCos(45)
LET y$ = FastSin(45)

' Disable at program end to free memory
FastTrig(FALSE)
```


##### FastSin(angle)
Returns the sine of an angle (in degrees) using a lookup table.

**Parameters:**
- `angle` - Angle in degrees (automatically normalized to 0-359)

**Returns:** Sine value (-1.0 to 1.0)

**Precision:** 1 degree (sufficient for most games and graphics)

```vb
FastTrig(TRUE)

PRINT FastSin(0)    ' Output: 0
PRINT FastSin(90)   ' Output: 1
PRINT FastSin(180)  ' Output: 0
PRINT FastSin(270)  ' Output: -1

' Angles are automatically wrapped
PRINT FastSin(450)  ' Same as FastSin(90) = 1
PRINT FastSin(-90)  ' Same as FastSin(270) = -1

FastTrig(FALSE)
```


##### FastCos(angle)
Returns the cosine of an angle (in degrees) using a lookup table.

**Parameters:**
- `angle` - Angle in degrees (automatically normalized to 0-359)

**Returns:** Cosine value (-1.0 to 1.0)

**Precision:** 1 degree (sufficient for most games and graphics)

```vb
FastTrig(TRUE)

PRINT FastCos(0)    ' Output: 1
PRINT FastCos(90)   ' Output: 0
PRINT FastCos(180)  ' Output: -1
PRINT FastCos(270)  ' Output: 0

' Use in raycasting
FOR angle$ = 0 TO 359
    LET dx$ = FastCos(angle$)
    LET dy$ = FastSin(angle$)
    ' Cast ray in direction (dx, dy)
NEXT

FastTrig(FALSE)
```


##### FastRad(angle)
Converts degrees to radians using an optimized formula.

**Parameters:**
- `angle` - Angle in degrees (automatically normalized to 0-359)

**Returns:** Angle in radians

**Note:** This function doesn't require `FastTrig(TRUE)` but is included for consistency.

```vb
PRINT FastRad(90)   ' Output: 1.5707963267948966 (HPI)
PRINT FastRad(180)  ' Output: 3.141592653589793 (PI)
PRINT FastRad(360)  ' Output: 6.283185307179586 (2*PI)
```


##### Fast Trig Example: Raycasting

```vb
REM Fast raycasting demo
SCREEN 12

' Enable fast trigonometry
FastTrig(TRUE)

LET player_angle$ = 0
LET num_rays# = 320

[mainloop]
    ' Update player rotation
    LET player_angle$ = player_angle$ + 1
    IF player_angle$ >= 360 THEN player_angle$ = 0
    
    ' Cast all rays
    FOR ray$ = 0 TO num_rays# - 1
        LET ray_angle$ = player_angle$ + ray$
        
        ' Fast lookup instead of SIN(RAD(angle))
        LET dx$ = FastCos(ray_angle$)
        LET dy$ = FastSin(ray_angle$)
        
        ' Raycast logic here...
        ' (20x faster than using SIN/COS!)
    NEXT
    
    IF INKEY = KEY_ESC# THEN GOTO [cleanup]
    GOTO [mainloop]

[cleanup]
' Free memory
FastTrig(FALSE)
END
```


##### When to Use Fast Trig

**Use FastTrig when:**
- Rendering graphics at high frame rates (60+ FPS)
- Raycasting or ray tracing
- Rotating sprites or shapes
- Particle systems with many particles
- Any loop that calls `SIN`/`COS` hundreds of times per frame

**Use regular SIN/COS when:**
- Math calculations requiring high precision
- One-time calculations
- Angles are not in integer degrees
- Memory is extremely limited

### 7th Feb. 2026

- Added keyword **HPI** which returns raw coded 1,5707963267929895
- Added keyword **PI** which returns 3.14159265358979  
- Added keywords **RAD** & **DEG**
  
**PI** and **HPI** are raw coded values, so no math involved. Should make performance much better.

```vb
REM Test RAD and DEG functions
PRINT "Testing RAD() and DEG() functions"
PRINT

REM Test degrees to radians
PRINT "90 degrees = "; RAD(90); " radians"
PRINT "180 degrees = "; RAD(180); " radians"
PRINT "360 degrees = "; RAD(360); " radians"
PRINT

REM Test radians to degrees  
PRINT "PI radians = "; DEG(PI); " degrees"
PRINT "PI/2 radians = "; DEG(PI/2); " degrees"
PRINT

REM Test with trigonometry
PRINT "SIN(RAD(90)) = "; SIN(RAD(90))
PRINT "COS(RAD(180)) = "; COS(RAD(180))
PRINT

END
```

```batch
Testing RAD() and DEG() functions

90 degrees = 1.5707963267948966 radians
180 degrees = 3.141592653589793 radians
360 degrees = 6.283185307179586 radians

PI radians = 179.99999999999983 degrees
PI/2 radians = 89.99999999999991 degrees

SIN(RAD(90)) = 1
COS(RAD(180)) = -1
````

### 1st Feb 2026

The documentation has been worked on and is now a bit better than good.

BazzBasic supports creating libraries: bazzbasic.exe -lib file.bas

LINE INPUT is now in the list of supported commands

Version 0.7 released to this date

## Jan 2026

### 18th Jan 2026
With all the previous add-ons, BazzBasic ver. 0.6 is now available as binary and source.


### 18th Jan 2026
Merging BazzBasic and basic code into a single executable file is now possible.

_bazzbasic.exe -exe filename.bas_ produces the _filename.exe_ file.

BazzBasic does not compile the BASIC code, but rather includes it as part of itself.

Read more https://ekbass.github.io/BazzBasic/manual/#/packaging



### 18th Jan 2026
Finished working with PNG and Alpha-color supports.  
LOCATE in graphical screen now overdraws old text instead of just writing new top of it.  

**Supported Formats**

**Format:** PNG  
Transparency: Full alpha (0-255)  
Recomended  

**Format**: BMP  
Transparency: None  
Legacy support

---

### 18th Jan 2026
Generated a manual with Docify.   
BazzBasic homepage now links to it.

Major idea is, that github wiki becomes a as development wiki and this docify as user wiki.

---

### 17th Jan 26
Fixed a bug that prevented to use custom resolution with SCREEN 0  
Terminal now closes if no errors when running via IDE  
Small gap between IDE line numbers and user code.

---

### 17th Jan 26
BazzBasic has now in-built simple IDE.  
Start _bazzbasic.exe_ with out params to open it.  
If opened with params, the .bas file is interpreted normally.  
After few new features, released as version 0.6

---

### 10th Jan 26
Generated __vsix__ file to add BazzBasic syntaxes for VS Code.  
See https://github.com/EkBass/BazzBasic/blob/main/extras/readme.md

---

### 9th Jan 26
Released first one, version 0.5
