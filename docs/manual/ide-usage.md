# IDE Usage

BazzBasic includes a simple integrated development environment (IDE).

## Starting the IDE

Run `BazzBasic.exe` without any arguments to open the IDE.

## Editor Features

- **Syntax highlighting** for BazzBasic keywords
- **Line numbers** for easy navigation
- **Multiple tabs** for working with several files

## Keyboard Shortcuts & Menu Map

| Menu | Shortcut | Action | CLI option |
|----------|--------|--------|--------|
| File | Ctrl+N | New file | BazzBasic.exe |
| File | Ctrl+O | Open file | none |
| File | Ctrl+S | Save file | none |
| File | Ctrl+Shift+S | Save As | none |
| File | Ctrl+W | Close tab | none |
| File | Alt + F4 | Exit | none |
| Edit | Ctrl+F | Find | none |
| Edit | Ctrl+H | Replace | none |
| Run | F5 | Run Program | BazzBasic.exe file.bas |
| Run | none | Compile as Exe | BazzBasic.exe -exe file.bas |
| Run | none | Compile as Library (.bb) | BazzBasic.exe -lib file.bas |
| Help | none | About | BazzBasic.exe -v |
| Help | none | Beginner's Guide[1] | BazzBasic.exe -guide |
| Help | none | Check For Updates | BazzBasic.exe -checkupdates |

**[1]** Opens [BazzBasic-Beginners-Guide/releases](https://github.com/EkBass/BazzBasic-Beginners-Guide/releases) in default www-browser.

## Running Programs

Press **F5** to run the current program. A console window will open showing the output.

If there are errors, they will be displayed with line numbers.
