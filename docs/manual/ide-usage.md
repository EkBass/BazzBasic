# IDE Usage

BazzBasic includes a simple development environment (IDE), _BazzBasic-IDE.exe_.

> **Since version 1.6** the IDE is a separate program from the interpreter (_BazzBasic.exe_). The IDE is the editor; when you run or compile a program, it starts _BazzBasic.exe_ to do the work. Keep both in the same folder.

> **Menu change (after v1.4c):** The old **Edit** menu (Find, Replace) was renamed to **Search**, and a new **Edit** menu was added with Undo, Redo, Cut, Copy, Paste and Select All. A new **View** menu switches between Light and Dark Mode. The **Help** menu also gained links to the online manual and Rosetta Code.
>
> If your IDE still shows Find and Replace under **Edit**, you are running an older version. Everything else works the same way.

## Starting the IDE

Double-click `BazzBasic-IDE.exe`.

Running `bazzbasic.exe` without any arguments (or double-clicking it) also opens the IDE, as in earlier versions: it starts `BazzBasic-IDE.exe` from the same folder.

## Which BazzBasic.exe the IDE uses

Run Program (F5), Compile as Exe and Compile as Library use the interpreter, `BazzBasic.exe`. The IDE looks for it in this order:

1. The path set in **Run → Path to BazzBasic.exe...**
2. The IDE's own folder.
3. The folders in the `PATH` environment variable (see [Running BazzBasic from anywhere](Running_BazzBasic_from_anywhere.md)).

With the release package nothing needs to be set: `BazzBasic.exe` is in the same folder as the IDE.

## Editor Features

- **Syntax highlighting** for BazzBasic keywords
- **Line numbers** for easy navigation
- **Multiple tabs** for working with several files

## Keyboard Shortcuts & Menu Map

| Menu | Shortcut | Action | CLI option |
|----------|--------|--------|--------|
| File | Ctrl+N | New file | none |
| File | Ctrl+O | Open file | none |
| File | Ctrl+S | Save file | none |
| File | Ctrl+Shift+S | Save As | none |
| File | none | Save All[13] | none |
| File | Ctrl+W | Close tab | none |
| File | none | Close All[14] | none |
| File | none | Restore Session on Startup[6] | none |
| File | Ctrl+P | Print[9] | none |
| File | Alt + F4 | Exit | none |
| Edit | Ctrl+Z | Undo | none |
| Edit | Ctrl+Y | Redo | none |
| Edit | Ctrl+X | Cut | none |
| Edit | Ctrl+C | Copy | none |
| Edit | Ctrl+V | Paste | none |
| Edit | Ctrl+A | Select All | none |
| Edit | Ctrl+Q | Comment Selection[10] | none |
| Edit | Ctrl+Shift+Q | Uncomment Selection[12] | none |
| Search | Ctrl+F | Find | none |
| Search | Ctrl+H | Replace | none |
| View | none | Tree View[15] | none |
| View | none | Open Console[7] | none |
| View | none | Open File Browser[7] | none |
| View | none | Light Mode[4] | none |
| View | none | Dark Mode (experimental)[4] | none |
| View | none | Syntax Coloring  | none |
| View | none | Take Screenshot to Clipboard[5] | none |
| View | Ctrl++ | Zoom In[11] | none |
| View | Ctrl+- | Zoom Out[11] | none |
| Run | F5 | Run Program | bazzbasic.exe file.bas |
| Run | none | Compile as Exe | bazzbasic.exe -exe file.bas |
| Run | none | Compile as Library (.bb) | bazzbasic.exe -lib file.bas |
| Run | none | Path to BazzBasic.exe...[16] | none |
| Help | none | About | bazzbasic.exe -v |
| Help | none | Homepage[8] | none |
| Help | none | Online Manual[1] | none |
| Help | none | Beginner's Guide[2] | bazzbasic.exe -guide |
| Help | none | Rosetta Code[3] | none |
| Help | none | Check For Updates | bazzbasic.exe -checkupdate |

**[1]** Opens the [online manual](https://ekbass.github.io/BazzBasic/manual/#/) in default browser.  
**[2]** Opens [BazzBasic-Beginners-Guide/releases](https://github.com/EkBass/BazzBasic-Beginners-Guide/releases) in default browser.  
**[3]** Opens the [BazzBasic category on Rosetta Code](https://rosettacode.org/wiki/Category:BazzBasic) in default browser.  
**[4]** The choice is saved to `%AppData%\BazzBasic\ide.json` and restored when the IDE starts. Dark Mode is experimental: the Find/Replace dialog, message boxes and the empty area next to the editor tabs stay light.  
**[5]** Copies an image of the IDE window to the clipboard. Paste it with Ctrl+V. No file is saved. When asking for help, prefer sharing the code as text (Ctrl+A, Ctrl+C, Ctrl+V): others can then copy and run it.  
**[6]** When checked, the IDE reopens the files that were open when it was last closed. Only saved files are restored; Untitled tabs are not. Files that no longer exist are skipped and listed in a message. The setting is saved to `%AppData%\BazzBasic\ide.json`.  
**[7]** Opens a command prompt (Open Console) or Windows File Explorer (Open File Browser) in the folder of the file in the active tab. For an unsaved file, the IDE's own folder is used.  
**[8]** Opens the [BazzBasic homepage](https://ekbass.github.io/BazzBasic/) in default browser.  
**[9]** Prints the file in the active tab with syntax highlighting, on a white background also in Dark Mode. To get a PDF, choose **Microsoft Print to PDF** as the printer.  
**[10]** Adds the comment mark `'` to the start of every selected line. Without a selection, the line with the cursor is commented. A line where the selection only touches the very beginning is left out. The whole change is one Undo step (Ctrl+Z). Useful for disabling several lines at once, since BazzBasic has no multi-line comments.  
**[11]** Makes the editor text larger or smaller in the active tab. Works with the +/- keys on both the main keyboard and the numeric keypad.  
**[12]** Removes the comment mark `'` from the start of every selected line: `' text` and `'text` both become `text`. The mark is also found after indentation, and the indentation is kept. Lines without a comment mark, and `REM` comments, are left as they are. Selection and Undo work as in Comment Selection.  
**[13]** Saves every tab that has unsaved changes. For an Untitled tab, the Save As dialog opens and that tab is shown so you can see which file it is for. Cancelling the dialog skips only that file.  
**[14]** Closes all tabs. For each tab with unsaved changes you are asked whether to save it. **Cancel** stops Close All and keeps the remaining tabs open. When all tabs are closed, a new empty Untitled tab is opened.  
**[15]** When checked, a panel on the left lists the functions (`DEF FN`) and labels (`[label]`) of the file in the active tab. Click an item to jump to that line. The list updates shortly after you stop typing. Functions and labels from `INCLUDE` files are not listed. Drag the panel edge to change its width. The on/off choice and the width are saved to `%AppData%\BazzBasic\ide.json`.  
**[16]** Chooses which `BazzBasic.exe` is used by Run Program and the Compile commands. Leave the field empty (**Clear**) to let the IDE find it automatically: first in the IDE's own folder, then in the folders listed in the `PATH` environment variable. A path you set always comes first. The dialog shows which file is currently used and where it was found. If the interpreter cannot be found, Run and Compile tell you and offer to open this dialog. The setting is saved to `%AppData%\BazzBasic\ide.json`.

## Closing the IDE

If any tab has unsaved changes when you close the IDE, you are asked whether to save each one. Choose **Cancel** to keep the IDE open.

The IDE remembers its window size and position, and whether it was maximized, and opens the same way next time. If it was last on a screen that is no longer connected, it opens centered on the main screen.

## Running Programs

Press **F5** to run the current program. The IDE runs it with `BazzBasic.exe`, and a console window opens showing the output.

When the program ends normally, the console window closes. If the program stops on an error, the window stays open and shows the error with its line number. Press any key to close it.
