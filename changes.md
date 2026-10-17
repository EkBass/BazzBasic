# News and changes
These changes are about the current source code. They take effect once a new binary release is published.

Changes in version 1.4 and older are in [changes-archive.md](changes-archive.md).

## 17th October 2026

### New: IDE screenshot to clipboard

New menu item **View → Take Screenshot to Clipboard**. It copies an image of the IDE window (only the IDE, not the whole desktop) to the clipboard, ready to paste with Ctrl+V into Discord, a forum post or an image editor. No file is saved.

Tip for anyone asking for help: share the code itself as text (Ctrl+A, Ctrl+C, Ctrl+V) whenever you can. Text can be copied, run and fixed; a picture cannot. Use the screenshot when the layout or an error dialog is what matters.

Implementation: `TakeScreenshot()` in `src/IDE/` captures `this.Bounds` with `Graphics.CopyFromScreen` and stores it with `Clipboard.SetImage`. Does not depend on the Windows Print Screen key setting.

## 16th October 2026 (after the 1.5 release)

### Bug fix: filled `LOADSHAPE` rectangles and triangles lost their fill when rotated

`LOADSHAPE("RECTANGLE", ...)` was drawn filled only at exactly 0°. At any other angle set with `ROTATESHAPE`, only the outline was drawn. `LOADSHAPE("TRIANGLE", ...)` was never properly filled at any angle: it was drawn as an outline plus three lines from the centre to the corners. Both are now solid at every angle. `"CIRCLE"` and `LOADIMAGE` shapes were not affected.

Typical symptom: a car drawn as a filled rectangle looks solid at the start and turns into a hollow outline as soon as it steers.

- Rotated rectangles with odd width or height are no longer one pixel narrower than at 0°.
- Programs that used `LOADIMAGE` sprites as a workaround keep working unchanged.

Implementation: new scanline helper `FillConvexPolygon` in `src/Graphics/ShapeManager.cs`, used by `DrawRotatedRectangle` and `DrawRotatedTriangle`. It uses only `SDL_RenderDrawLine`, so no newer SDL2 version is needed. Test: `Examples/rotated_fill_test.bas`.

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
