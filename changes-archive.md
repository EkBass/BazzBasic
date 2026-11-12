# Changes archive
Older entries moved from [changes.md](changes.md), newest first. Covers version 1.4 and everything before it, plus pre-release entries archived from changes.md (5th November 2026 and earlier).

## 5th November 2026

### STARTLISTEN can listen on the network

Now: `STARTLISTEN port [, timeout_ms [, host$]]`
- Default host is still `127.0.0.1` (no admin rights needed), so old programs work as before.
- `"*"` = all network interfaces; a specific address (e.g. `"192.168.1.10"`) is also accepted.
- Anything other than `127.0.0.1` needs a one-time URL reservation on Windows. Without it, STARTLISTEN stops with an error that prints the exact `netsh http add urlacl ...` command to run as administrator.
- Fixed: with a timeout, `GETREQUEST()` started a new accept on every call and left the old one pending. A request could land on the orphaned accept and be lost (browser hangs, script never sees it). The pending accept is now kept and reused.

### New: HTTPERROR — HTTPGET and HTTPPOST no longer stop the program

A server that is down is not a bug in the program, so a failed request no longer ends execution. `HTTPGET` / `HTTPPOST` return `""` and `HTTPERROR` holds the reason (`""` after a successful call).

```basic
LET res$ = HTTPGET(url$)
IF HTTPERROR <> "" THEN PRINT "Source is down: "; HTTPERROR
```

- Connection errors, unknown host and timeouts → `""` + `HTTPERROR`.
- An invalid URL (not `http://` / `https://`) is still an error with a line number — that is a mistake in the code.
- HTTP error statuses (404, 500…) are not errors: the response body is returned and `HTTPERROR` is `""`.
- Internals: new token `TOK_HTTPERROR = 140`. Fixed the HTTPPOST invalid-URL message, which said `HTTPGET:`.

`extras/*` syntax files updated for HTTPERROR and SAVESCREEN. Manual updated: network.md, graphics.md, keywords.md.
## 30th October 2026

### New: SAVESCREEN

Saves the graphics screen as a PNG file. Relative paths resolve against the program's folder.

```basic
SCREEN 0, 320, 200
CIRCLE (160, 100), 50, RGB(255, 0, 0), 1
SAVESCREEN "circle.png"
```

- Only `.png` is supported; any other extension is an error.
- Error without graphics mode: `SAVESCREEN: graphics mode not initialized. Use SCREEN first.`
- Internals: new token `TOK_SAVESCREEN = 124`. Uses System.Drawing.Common (already used by LOADIMAGE), works in the trimmed build.
- Syntax files, manual and AI guide updated 5.11.2026.

### Graphics: persistent canvas — POINT works, PSET loops are fast

All drawing now goes to an off-screen canvas texture that is copied to the window when shown. Before this, `POINT` read the window's back buffer, which SDL leaves undefined after every screen update — so POINT often returned garbage, and every PSET updated the screen at monitor refresh speed. A 293×341 POINT/PSET loop (Rosetta Code *Grayscale image*) took an estimated ~28 minutes and looked frozen; it now runs in ~0.6 seconds.

- `POINT` reads from a memory copy of the canvas: one screen read when needed, then plain lookups. `PSET` updates the copy directly; other drawing commands mark it stale.
- Automatic screen updates (PSET, LINE, CIRCLE, PRINT, CLS, DRAWSHAPE, DRAWSTRING...) are shown at most about 60 times a second. A skipped update is shown within ~16 ms, or right away by SLEEP, WAITKEY and INPUT. `SCREENLOCK OFF` always shows the frame immediately, so SCREENLOCK-based games keep their timing.
- `PRINT` and `CLS` in graphics mode now respect `SCREENLOCK ON` (they used to update the screen even while locked, which could cause flicker).
- In fullscreen, `POINT` now uses program coordinates (it used to read real window pixels).
- `MOUSEX`/`MOUSEY` keep working in fullscreen (mapped through the window, not the canvas).
- If `VSYNC` has to recreate the renderer (old SDL2/driver fallback), the screen content is kept. Shapes and fonts are still lost in that rare path, as before.

### Graphics: window close button works

- Closing the graphics window now ends the program cleanly (no error, exit code 0) — also during `SLEEP`, `WAITKEY` and `INPUT`. Before, the close button did nothing and the program had to be killed.
- The interpreter handles window events every ~16 ms while a program runs, so the window no longer goes "Not responding" during long calculations.
- `SLEEP` in graphics mode sleeps in short slices and keeps the window responsive.

### Tests

- `Examples\point_cache_test.bas` — POINT/PSET/LINE/CIRCLE/DRAWSHAPE cache checks + SAVESCREEN, writes `point_cache_test.log`
- `Examples\savescreen_err_test.bas` — wrong extension must stop with a line-numbered error

## 25th October 2026

### Homepage several small changes
Lots of small changes to the website. It highlights the technical side a bit more, rather than just "emotional fluff."

### Library loading
- Including the same library more than once now prints a warning with the line number of the duplicate `INCLUDE`. The duplicate is skipped and the program continues normally.
- Libraries compiled with an older BazzBasic now load with a warning instead of being rejected. Recompiling is recommended.
- Libraries compiled with a newer BazzBasic are refused with a clear error message asking to update BazzBasic.

### Other
- BazzBasic-AI-guide.md renamed to SKILL.md (it is a valid Agent Skills file)
- Manual page "AI assisted learning" (ai-assist.md) rewritten: explains what a SKILL is and how to use the guide
- That was done by Claude.

## 24th October 2026

Some tweaks to homepage.
- Fixed typos
- Adjusted metadata: page descriptions, link previews (og:image) for Discord, forums etc.
- New examples.html with a few short example codes, now its own "Examples" button in the menu
- "About" is a plain menu link again instead of a dropdown
- Added llms.txt, a short summary of BazzBasic for AI assistants
- Added sitemap.xml and generate_sitemap script to rebuild it

## 24th October 2026

Released as version 1.6

### New: EXIT WHILE and EXIT FOR

Leave a loop early without `GOTO`. `EXIT WHILE` continues after the innermost `WEND`, `EXIT FOR` after the innermost `NEXT`.

```basic
WHILE 1
    IF INKEY = KEY_ESC# THEN EXIT WHILE
WEND

FOR i$ = 1 TO 100
    IF i$ * i$ > 50 THEN EXIT FOR
NEXT
PRINT i$   ' 8 - the loop variable keeps its value
```

- Works in one-line IF, inside IF...END IF blocks and inside inner loops of the other kind; any IF blocks and inner loops it leaves are cleaned up.
- Inside `DEF FN`, EXIT only leaves loops that are inside the function.
- Errors: `EXIT WHILE without WHILE`, `EXIT FOR without FOR`, `Expected WHILE or FOR after EXIT`.
- Internals: new token `TOK_EXIT = 23`. WHILE and FOR stack entries now remember the IF/FOR/WHILE stack depths at loop entry. The WHILE/WEND and FOR/NEXT skippers ignore the `WHILE`/`FOR` of an `EXIT WHILE`/`EXIT FOR`.
- `EXIT` added to the IDE highlighting, `extras` syntax files, manual and AI guide. Example: `Examples\console\exit_loops.bas`.

### Homepage: Example Code page

- New page `docs/examples.html` with three code boxes (white on black, dark blue on light grey, white on black) ready for short example programs. Paste code between `<code>` and `</code>`; escape `<`, `>` and `&`.
- Navigation: `About` is now a dropdown on every page with *About BazzBasic* and *Example Code*.
- New CSS section 13 (`.code-showcase`, `.code-box`, `.code-box--dark`, `.code-box--light`) in `styles.css`.
- `sitemap.xml`: added `examples.html`.

## 23rd October 2026

Robustness fixes from a source audit. A typo or a mistake in a BASIC program now stops with a clear error message instead of hanging, crashing the whole interpreter, or being silently ignored.

### Fix: typos could hang the interpreter until it ran out of memory

An unexpected token inside an expression used to evaluate silently to 0 without moving forward, so loops such as `PRINT` spun forever. `PRINT (1 + 2` (missing `)`) and `PRINT OFF` both hung until .NET reported "Insufficient memory".

- An unexpected token in an expression is now an error: `Unexpected 'PRINT' in expression`.
- A missing `)` is reported: `Missing ')' - found 'PRINT'`.
- `PRINT` and all argument-list loops stop as soon as an error happens.
- A `PRINT` whose expression fails no longer prints a half-evaluated result (e.g. `7NaN`).
- Only the first error is reported; follow-up errors from the same broken statement are no longer printed.
- Error messages show symbols instead of internal names: `Expected '(' but found end of line` instead of `Expected TOK_LPAREN`.

### Fix: one-line IF with PRINT before ELSE hung

`IF a$ = 1 THEN PRINT "yes" ELSE PRINT "no"` never finished, because `PRINT` did not treat `ELSE` as the end of its list. It now works.

### Fix: unknown statements were silently ignored

Anything the interpreter did not recognise at the start of a statement was skipped without a word. Now it is an error: `Unexpected 'SIN' - not a valid statement`. Old-style line numbers (`10 PRINT`) are reported the same way.

- `FN Name$(...)` on its own line now explains that a function call needs to be used: `LET r$ = FN Name$(...)`.
- The `:` statement separator, which only worked by accident before, is now handled explicitly.

### Fix: SHELL as a statement never ran the command

`SHELL("command")` on its own line, as shown in the manual, was silently skipped and the command never ran. It now runs the command and discards the output. Use `LET out$ = SHELL(...)` when the output is needed, as before.

### New: ON and OFF work as values

`ON` and `OFF` now work anywhere a value is expected, exactly like `TRUE` (1) and `FALSE` (0): `LET a$ = ON`, `IF NOT OFF THEN ...`, `PRINT OFF`. Before, `ON`/`OFF` worked only right after `SCREENLOCK` and `VSYNC`, and `PRINT OFF` hung the interpreter.

### Fix: constants require LET and cannot be changed

- `c# = 99` and `c# += 1` on an existing constant used to be ignored silently; now: `Cannot change constant C#`.
- A constant without LET (`NEW# = 5`) is an error: `Constants must be declared with LET`. LET is required for both variables and constants.

### Fix: `x$ += 1` on an undefined variable stopped the program without a line number

Now reported normally: `Error at line N: Undefined variable: X$ (use LET for first assignment)`.

### Fix: deep recursion crashed the whole interpreter

`DEF FN` recursion deeper than about 500-700 levels killed the process with an uncatchable .NET `Stack overflow`. The program now runs on its own thread with a 256 MB stack (reserved, used only as needed), and the interpreter checks the remaining stack before each `DEF FN` call.

- Recursion now reaches roughly 90 000-200 000 levels depending on the function.
- Beyond that the program stops with a BASIC error: `Recursion too deep in FN R$ - out of stack space`.

## 20th October 2026

### New: View → Syntax Coloring on/off

The View menu has a new **Syntax Coloring** checkbox, right under Light/Dark Mode. Unchecked, the editor shows BazzBasic code as plain monochrome text in the theme's normal text colour; checked (the default), keywords, strings, comments, numbers and operators are coloured as before.

- Line numbers, the selection highlight and the caret keep their theme colours in both states, only the code colours change.
- The choice is remembered in `ide.json` between sessions.
- Printing follows the setting: colored text prints with syntax colours on white paper, plain text prints black on white.

## 19th October 2026

### Documentation: manual keyword list re-synced with reserved-words.xml

`docs/manual/keywords.md` was missing 42 entries that `extras/reserved-words.xml` already listed. All added, with descriptions written from the interpreter source:

- Graphics: `B`, `BF` (the `LINE` box flags)
- I/O: `ISSET`
- Network & Data: `GETREQUEST`, `SENDRESPONSE`, `STARTLISTEN`, `STOPLISTEN`
- File: `FILELIST`
- Math Functions: `ATAN2`, `INBETWEEN`
- String Functions: `FSTRING`
- Input & Mouse: `MOUSEHIDE`, `MOUSESHOW`
- Arrays: `ARRKEY`
- New Gamepad section: `GAMEPADS`, `PADAXIS`, `PADBUTTON`, `PADNAME`, `PADRUMBLE`
- New Gamepad constants section: all 23 `PAD_*#` constants (17 buttons, 6 axes)
- New Command Line section: `-exe`, `-lib`, `-v`, `-version`

The reverse gap was closed too: `LINE INPUT` was documented in the manual but missing from `reserved-words.xml`. It is now in the XML's io section, with a comment noting that `input` (console input) and `line` (graphics draw) are also used independently of the two-word statement.

`-guide`/`-help` and `-checkupdate` were deliberately left out of the keyword list: they are interpreter launch arguments, documented in the IDE manual.

## 18th October 2026

### Change: the IDE and the interpreter are now separate programs

BazzBasic now comes as two programs in the same folder:

| File | What it is | Size |
|------|------------|------|
| `BazzBasic.exe` | The interpreter. A console program that runs and compiles `.bas` files. | about 15 MB |
| `BazzBasic-IDE.exe` | The code editor. A Windows program with no console window behind it. | about 111 MB |

Earlier both were the same `BazzBasic.exe`, which was about 111 MB.

What stays the same:

- The interpreter is still called `BazzBasic.exe`, so the command line, `.bat` files, editor settings (Notepad++, Geany, VS Code), the PATH setting and `.bas` file associations work as before.
- Double-clicking `BazzBasic.exe`, or running it without arguments, still opens the IDE: it starts `BazzBasic-IDE.exe` from the same folder. If the IDE is not there, it prints the command line usage instead, and the window waits for a key press so the text can be read.
- In the IDE, Run (F5), Compile as Exe and Compile as Library work as before. The IDE finds `BazzBasic.exe` in its own folder, in PATH, or where **Run → Path to BazzBasic.exe...** points.

The biggest gain is the size of **compiled programs**. A program compiled with `-exe` (or Compile as Exe in the IDE) is a copy of the interpreter with your code inside, so it shrinks from about 111 MB to about 15 MB.

To use only the interpreter, for example with another editor, `BazzBasic-IDE.exe` and the `runtimes` folder can be left out. The interpreter needs only the SDL2 dll files next to it.

Implementation:

- The IDE is its own project: `IDE\BazzBasic-IDE.csproj` (`WinExe`, `UseWindowsForms`, Scintilla5.NET), with its own `IDE\Program.cs`. The source moved from `src\IDE\` to `IDE\`.
- The IDE contains no interpreter code. `src\Version.cs` (`AppInfo`) and `src\UpdateChecker.cs` are shared as linked files.
- `BazzBasic.csproj` no longer uses `UseWindowsForms`. That alone took the interpreter from about 111 MB to about 72 MB, because the WindowsDesktop runtime is no longer included. `net10.0-windows` is kept for `System.Drawing.Common` (LOADIMAGE, LOADSHEET).
- The interpreter is published with `PublishTrimmed`, which takes it to about 15 MB. The build has no trim warnings.
- Shared metadata (version 1.6.0, author, copyright) is in `Directory.Build.props`, used by both projects.
- `build.bat` builds both into `bin\Release\net10.0-windows\win-x64\publish`. `Scintilla.dll` and `Lexilla.dll` must stay in `runtimes\win-x64\native\`: the IDE does not start without them. The extra copies in the publish root are removed automatically.

### Fix: `ASJSON` and `SAVEJSON` work in the trimmed interpreter, `ASJSON` of an empty array

`ASJSON` and `SAVEJSON` built a tree of `Dictionary` and `List` objects and serialized it with `JsonSerializer`, which needs reflection. Reflection is not available in the trimmed interpreter, so both stopped with an error. They now build a `JsonObject` / `JsonArray` tree (`System.Text.Json.Nodes`) and write it with `ToJsonString()`. The JSON produced is exactly the same as before, including non-ASCII characters, quotes, nested arrays, gaps in indexes and the indented `SAVEJSON` file.

Also fixed: `ASJSON` of an array with no elements stopped with the error "Sequence contains no elements". It now returns `{}`.

Implementation: `BuildJsonTree()` and `ResolveNode()` in `src/Interpreter/Interpreter.Network.cs`.

### Fix: update check reported an older or equal version as new

**Help → Check for Updates** and `bazzbasic.exe -checkupdate` said "New version available: 15 (you have 1.5b)". Two problems:

- The release tag was `BazzBasic_15` (without the dot), so the version was read as "15". The tag has been renamed to `BazzBasic_1.5`.
- The check only looked at whether the two version texts were equal. Any difference was reported as a new version, even when the running version was newer than the release.

The check now reads the version from the tag with or without a dot (`BazzBasic_1.5`, `BazzBasic_15` and `BazzBasic_14c` all work) and compares versions in order: 1.5 < 1.5b < 1.5c < 1.6. It reports one of three things: a newer version is available, you are running the latest version, or you are running a version newer than the latest release.

Implementation: `ParseVersion()` and `CompareVersions()` in `src/UpdateChecker.cs`.

### Fix: `-checkupdates` was not recognised

The manual showed `bazzbasic.exe -checkupdates`, but the interpreter only recognised `-checkupdate` and tried to run a file called `-checkupdates`. Both spellings now work.

### Fix: IDE window icon

The IDE loaded its window icon from an `icon.png` file next to the exe, which was not part of the release, so the window showed the default icon. The icon is now taken from the exe itself.

### New: IDE Run → Path to BazzBasic.exe...

New menu item **Run → Path to BazzBasic.exe...**, at the bottom of the Run menu. It opens a small dialog for choosing which `BazzBasic.exe` the IDE uses for **Run Program** (F5), **Compile as Exe** and **Compile as Library**. This prepares for version 1.6, where the IDE and the interpreter become separate programs.

The IDE looks for the interpreter in this order:

1. The path set in this dialog.
2. The IDE's own folder.
3. The folders in the `PATH` environment variable.

- The dialog shows live which file would be used and where it was found (set by you, IDE folder or PATH).
- **Browse...** picks the file, **Clear** empties the setting and goes back to automatic lookup.
- **OK** accepts only an existing file or an empty field.
- If a path is set but the file no longer exists, the IDE says so instead of quietly using another `BazzBasic.exe`.
- If no interpreter is found, Run and Compile show a message and offer to open the dialog.
- The setting is saved to `%AppData%\BazzBasic\ide.json`.

Since the IDE and the interpreter were separated (see above), automatic lookup finds `BazzBasic.exe` next to `BazzBasic-IDE.exe`.

Implementation: `ResolveInterpreterPath()`, `GetInterpreterPathOrAsk()` and `ShowInterpreterPathDialog()` in `src/IDE/MainForm.cs`; the dialog is `src/IDE/InterpreterPathDialog.cs`. The dialog uses `TableLayoutPanel` with `AutoSize` and sizes based on the font height, so it scales with Windows display scaling. New setting `InterpreterPath` in `IdeSettings`.

### New: IDE View → Tree View

New menu item **View → Tree View** (check mark, off by default), at the top of the View menu. It shows a panel on the left side of the editor that lists the functions and labels of the file in the active tab. Clicking an item moves the cursor to that line and scrolls it near the top of the editor. Helpful for moving around in long files.

- **Functions**: every `DEF FN` line, shown with its parameters, e.g. `HexToDec$(hex$)`. Not case sensitive.
- **Labels**: every `[label]` alone on its line (a comment after it is allowed). Anything between the brackets counts, as in the interpreter, so `[sub:box]` works.
- Both groups show how many items they contain, e.g. `Functions (3)`, with an empty line between the groups.
- The list updates half a second after you stop typing, and when you switch or close tabs. While typing, the list keeps its scroll position.
- Code from `INCLUDE` files is not shown.
- The panel width can be changed by dragging its edge. The on/off choice and the width are saved to `%AppData%\BazzBasic\ide.json`.
- Colours follow the editor theme, also in Dark Mode.

Implementation: `RefreshCodeTree()` and related methods in the `Tree View` region of `src/IDE/MainForm.cs`. Lines are matched with two anchored regular expressions, not the Lexer, so text inside strings and comments is not picked up. A 500 ms `Timer` debounces updates. If the names have not changed, only the stored line numbers are updated instead of rebuilding the tree. The on/off check uses the menu state, because `Control.Visible` reads `false` until the form is shown, which broke the update for the tab restored at startup. New settings `ShowTreeView` and `TreeViewWidth` in `IdeSettings`.

### New: IDE remembers its window size, position and maximized state

When the IDE closes, it saves its window size and position, and whether it was maximized, to `%AppData%\BazzBasic\ide.json`. The next start opens it the same way.

- A maximized IDE also remembers its normal size, so un-maximizing goes back to the size you last set.
- If the saved position is on a screen that is no longer connected, the window opens centered on the main screen instead.
- An IDE closed while minimized opens normally next time.
- Without saved settings the IDE opens as before: 1200×800, centered.

Implementation: `RestoreWindowPlacement()` and `SaveWindowPlacement()` in `src/IDE/MainForm.cs`, using `RestoreBounds` for the normal size. New settings `WindowX`, `WindowY`, `WindowWidth`, `WindowHeight` and `WindowMaximized` in `IdeSettings`.

### New: IDE Edit → Comment Selection (Ctrl+Q)

New menu item **Edit → Comment Selection** (Ctrl+Q), at the bottom of the Edit menu below **Select All**. It adds the comment mark `' ` to the start of every selected line, which makes it easy to disable a block of code. BazzBasic has no multi-line comments, so this saves commenting lines one by one.

- Without a selection, the line with the cursor is commented.
- If the selection ends at the very start of a line, that line is not included.
- The whole operation is one Undo step: Ctrl+Z removes all the added marks at once.

Implementation: `AddComment()` in `src/IDE/`. Lines are processed from last to first so inserting text does not shift the positions of the remaining lines. Wrapped in `BeginUndoAction()` / `EndUndoAction()`.

### New: IDE Edit → Uncomment Selection (Ctrl+Shift+Q)

New menu item **Edit → Uncomment Selection** (Ctrl+Shift+Q), right below **Comment Selection**. It removes the comment mark from the start of every selected line.

- `' text` becomes `text` (the mark and one space are removed).
- `'text` becomes `text` (only the mark is removed).
- The mark is also found after indentation; the indentation is kept.
- Lines without a comment mark are left as they are. `REM` comments are not touched.
- Selection rules and the single Undo step work the same way as in Comment Selection.

Implementation: `RemoveComment()` in `src/IDE/`.

### New: IDE File → Save All and Close All

New menu items in the File menu, no keyboard shortcuts:

- **File → Save All**, below **Save As**, saves every tab with unsaved changes. Untitled tabs open the Save As dialog, with that tab shown so it is clear which file the dialog is for. Cancelling a dialog skips only that file.
- **File → Close All**, below **Close Tab**, closes all tabs. Tabs with unsaved changes ask Yes / No / Cancel one by one. Cancel stops the whole operation and keeps the remaining tabs open. When everything is closed, a new empty Untitled tab is opened, the same as after closing the last tab.

Implementation: `SaveAll()` and `CloseAll()` in `src/IDE/`. Both loop over a snapshot of the tab list and reuse `SaveFile()` / `CloseTab()`, which now return `bool` so a cancelled save or close can be detected.

### Fix: closing a tab lost changes when Save As was cancelled

Closing a modified Untitled tab, answering **Yes** to "Save changes?" and then cancelling the Save As dialog closed the tab anyway, and the changes were lost. The tab now stays open.

### Fix: console window stays open when a program stops on an error

When a program run from the IDE (F5) stopped on an error, the console window closed immediately and the error message disappeared with it. The window now stays open with the error message and waits for a key press. A program that ends normally closes the window as before.

Cause: the interpreter printed the error but still exited with code 0, so the `|| pause` in the IDE's run command never triggered. `Interpreter` now exposes `HasError`, and `RunProgram()` in `src/Program.cs` returns it, so `bazzbasic.exe` exits with code 1 after an error. This also applies to compiled executables, and gives scripts and `.bat` files a correct exit code.

### New: IDE View → Zoom In / Zoom Out

New menu items **View → Zoom In** (Ctrl++) and **View → Zoom Out** (Ctrl+-), at the bottom of the View menu. They make the editor text in the active tab larger or smaller.

Both the numeric keypad +/- and the main keyboard +/- keys work, so the shortcuts are usable on laptops without a numeric keypad.

Implementation: the menu items call Scintilla's `ZoomIn()` / `ZoomOut()` on the active editor. The menu shows `Ctrl++` / `Ctrl+-` via `ShortcutKeyDisplayString` instead of the default "Ctrl+Add" / "Ctrl+Subtract". The main keyboard keys (`Keys.Oemplus`, `Keys.OemMinus`) are handled in `ProcessCmdKey`, since a menu item can only have one shortcut.

## 17th October 2026

### New: IDE screenshot to clipboard

New menu item **View → Take Screenshot to Clipboard**. It copies an image of the IDE window (only the IDE, not the whole desktop) to the clipboard, ready to paste with Ctrl+V into Discord, a forum post or an image editor. No file is saved.

Tip for anyone asking for help: share the code itself as text (Ctrl+A, Ctrl+C, Ctrl+V) whenever you can. Text can be copied, run and fixed; a picture cannot. Use the screenshot when the layout or an error dialog is what matters.

Implementation: `TakeScreenshot()` in `src/IDE/` captures `this.Bounds` with `Graphics.CopyFromScreen` and stores it with `Clipboard.SetImage`. Does not depend on the Windows Print Screen key setting.

### New: IDE View → Open Console and Open File Browser

- **View → Open Console** opens a command prompt (`cmd.exe`).
- **View → Open File Browser** opens Windows File Explorer.

Both open in the folder of the file in the active tab. For an unsaved (Untitled) tab, or if that folder no longer exists, they open in the folder of the IDE executable (`Application.StartupPath`). The current directory is not used, because the Open/Save dialogs and shortcut settings change it.

### New: IDE File → Print (Ctrl+P)

New menu item **File → Print** (Ctrl+P) prints the file in the active tab with syntax highlighting. Colours are printed on a white background, also in Dark Mode. Choose **Microsoft Print to PDF** as the printer to save a PDF.

Implementation: `PrintTab()` in `src/IDE/MainForm.cs` renders pages with Scintilla's `SCI_FORMATRANGE` onto the printer HDC, page by page.

- Page margins are converted from 1/100 inch to printer pixels, taking the printer's hard margins into account.
- Document length comes from `SCI_GETLENGTH` (bytes), since Scintilla positions are UTF-8 byte positions, not characters.
- `SCI_SETPRINTCOLOURMODE` is set to `SC_PRINT_COLOURONWHITE`.
- If no progress is made on a page, printing stops instead of looping endlessly. Errors cancel the print job and show a message instead of leaving a broken file.

### New: IDE Help → Homepage

New menu item **Help → Homepage**, right below **About**. It opens the BazzBasic homepage (https://ekbass.github.io/BazzBasic/) in the default browser, in the same way as Online Manual and Rosetta Code.

### New: IDE session restore

New menu item **File → Restore Session on Startup** (check mark, off by default). When ON, the IDE reopens the files that were open when it was last closed and selects the tab that was active. When OFF, the IDE starts with an empty file as before.

- Only saved files are part of the session. Untitled tabs are not restored.
- Files that no longer exist (deleted, moved, renamed) are skipped. One message lists them after the IDE window has opened, and they are dropped from the session.
- The open files are recorded every time the IDE closes, also while the option is off, so switching it on restores the most recent session.
- The setting and the file list are stored in `%AppData%\BazzBasic\ide.json` next to the theme choice.

### Fix: IDE now asks to save changes when the window is closed

Closing the IDE with the window's X button, Alt+F4 or **File → Exit** discarded unsaved changes without asking. It now asks for each modified tab (Yes / No / Cancel). Cancel, or cancelling Save As, keeps the IDE open.

### Fix: opening a file marked the previous tab as modified

Opening a file added the ` *` modified marker to the tab that was active before, so closing that tab asked to save it even though nothing had changed. A new untouched **Untitled** tab no longer counts as modified either.

Implementation: `OnFormClosing`, `OnShown` and `RestoreSession()` in `src/IDE/MainForm.cs`; `RestoreSession`, `SessionFiles` and `SessionActiveIndex` added to `IdeSettings` in `src/IDE/EditorTheme.cs`. The editor `TextChanged` handler now marks the tab that owns the editor instead of the selected tab.

## 16th October 2026

### Bug fix: filled `LOADSHAPE` rectangles and triangles lost their fill when rotated

`LOADSHAPE("RECTANGLE", ...)` was drawn filled only at exactly 0°. At any other angle set with `ROTATESHAPE`, only the outline was drawn. `LOADSHAPE("TRIANGLE", ...)` was never properly filled at any angle: it was drawn as an outline plus three lines from the centre to the corners. Both are now solid at every angle. `"CIRCLE"` and `LOADIMAGE` shapes were not affected.

Typical symptom: a car drawn as a filled rectangle looks solid at the start and turns into a hollow outline as soon as it steers.

- Rotated rectangles with odd width or height are no longer one pixel narrower than at 0°.
- Programs that used `LOADIMAGE` sprites as a workaround keep working unchanged.

Implementation: new scanline helper `FillConvexPolygon` in `src/Graphics/ShapeManager.cs`, used by `DrawRotatedRectangle` and `DrawRotatedTriangle`. It uses only `SDL_RenderDrawLine`, so no newer SDL2 version is needed. Test: `Examples/rotated_fill_test.bas`.

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
