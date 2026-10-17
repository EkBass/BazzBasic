# IDE Usage

BazzBasic includes a simple integrated development environment (IDE).

> **Menu change (after v1.4c):** The old **Edit** menu (Find, Replace) was renamed to **Search**, and a new **Edit** menu was added with Undo, Redo, Cut, Copy, Paste and Select All. A new **View** menu switches between Light and Dark Mode. The **Help** menu also gained links to the online manual and Rosetta Code.
>
> If your IDE still shows Find and Replace under **Edit**, you are running an older version. Everything else works the same way.

## Starting the IDE

Run `bazzbasic.exe` without any arguments to open the IDE.

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
| File | Ctrl+W | Close tab | none |
| File | Alt + F4 | Exit | none |
| Edit | Ctrl+Z | Undo | none |
| Edit | Ctrl+Y | Redo | none |
| Edit | Ctrl+X | Cut | none |
| Edit | Ctrl+C | Copy | none |
| Edit | Ctrl+V | Paste | none |
| Edit | Ctrl+A | Select All | none |
| Search | Ctrl+F | Find | none |
| Search | Ctrl+H | Replace | none |
| View | none | Light Mode[4] | none |
| View | none | Dark Mode (experimental)[4] | none |
| View | none | Take Screenshot to Clipboard[5] | none |
| Run | F5 | Run Program | bazzbasic.exe file.bas |
| Run | none | Compile as Exe | bazzbasic.exe -exe file.bas |
| Run | none | Compile as Library (.bb) | bazzbasic.exe -lib file.bas |
| Help | none | About | bazzbasic.exe -v |
| Help | none | Online Manual[1] | none |
| Help | none | Beginner's Guide[2] | bazzbasic.exe -guide |
| Help | none | Rosetta Code[3] | none |
| Help | none | Check For Updates | bazzbasic.exe -checkupdates |

**[1]** Opens the [online manual](https://ekbass.github.io/BazzBasic/manual/#/) in default browser.  
**[2]** Opens [BazzBasic-Beginners-Guide/releases](https://github.com/EkBass/BazzBasic-Beginners-Guide/releases) in default browser.  
**[3]** Opens the [BazzBasic category on Rosetta Code](https://rosettacode.org/wiki/Category:BazzBasic) in default browser.  
**[4]** The choice is saved to `%AppData%\BazzBasic\ide.json` and restored when the IDE starts. Dark Mode is experimental: the Find/Replace dialog, message boxes and the empty area next to the editor tabs stay light.  
**[5]** Copies an image of the IDE window to the clipboard. Paste it with Ctrl+V. No file is saved. When asking for help, prefer sharing the code as text (Ctrl+A, Ctrl+C, Ctrl+V): others can then copy and run it.

## Running Programs

Press **F5** to run the current program. A console window will open showing the output.

If there are errors, they will be displayed with line numbers.
