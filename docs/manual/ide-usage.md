# IDE Usage

BazzBasic includes a simple integrated development environment (IDE).

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
| Edit | Ctrl+F | Find | none |
| Edit | Ctrl+H | Replace | none |
| Run | F5 | Run Program | bazzbasic.exe file.bas |
| Run | none | Compile as Exe | bazzbasic.exe -exe file.bas |
| Run | none | Compile as Library (.bb) | bazzbasic.exe -lib file.bas |
| Help | none | About | bazzbasic.exe -v |
| Help | none | Beginner's Guide[1] | bazzbasic.exe -guide |
| Help | none | Check For Updates | bazzbasic.exe -checkupdates |

**[1]** Opens [BazzBasic-Beginners-Guide/releases](https://github.com/EkBass/BazzBasic-Beginners-Guide/releases) in default browser.

## Running Programs

Press **F5** to run the current program. A console window will open showing the output.

If there are errors, they will be displayed with line numbers.
