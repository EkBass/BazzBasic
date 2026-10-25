# News and changes
These changes are about the current source code.

They take effect once a new binary release is published.

Changes for older versions are in [changes-archive.md](changes-archive.md).

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