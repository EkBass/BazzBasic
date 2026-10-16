# Running BazzBasic from anywhere

This guide shows how to:

1. Add `BazzBasic.exe` to your **PATH**, so you can run `BazzBasic myprog.bas` from any folder.
2. Associate `.bas` files with BazzBasic, so you can run programs by **double-clicking** them.

Everything here applies to your own Windows user account only. **No administrator rights are needed.**

All commands are for **PowerShell**. To open it, press the Windows key, type `powershell` and press Enter.

Every command in this guide is safe to run more than once. If something doesn't seem to work, you can run the same step again without making things worse.

---

## Before you start: choose a permanent folder

Put BazzBasic in a folder that won't move, for example:

```
C:\BazzBasic\
```

The rest of this guide uses `C:\BazzBasic\BazzBasic.exe`. If your folder is different, change the path in each command.

> **Tip:** Avoid the Downloads folder and other temporary locations. If you later move or delete the folder, the PATH entry and the file association will stop working.

> **Downloaded a zip?** Windows marks files downloaded from the internet, and SmartScreen may interrupt the first launch. Before extracting, right-click the zip file, choose **Properties**, tick **Unblock** and click **OK**. Then extract it.

---

## Part 1: Add BazzBasic to PATH

PATH is a list of folders.

When you type a command, Windows looks inside each of these folders for a matching program. So you add the folder where *BazzBasic.exe* is *(C:\BazzBasic)*, **not the path of the file itself** *(C:\BazzBasic\BazzBasic.exe)*.

Windows then finds *BazzBasic.exe* inside the folder by its name.

### Option A: PowerShell (quickest)

```powershell
$dir = "C:\<path to your BazzBasic.exe folder>"
$old = [Environment]::GetEnvironmentVariable("Path", "User")
$parts = @($old -split ";" | Where-Object { $_ -ne "" })
if ($parts -notcontains $dir) {
    [Environment]::SetEnvironmentVariable("Path", (($parts + $dir) -join ";"), "User")
    "Added $dir to PATH."
} else {
    "$dir is already in PATH."
}
```

The command checks whether the folder is already listed, so running it twice doesn't add a duplicate.

### Option B: Windows settings

1. Press the Windows key and type **environment variables**.
2. Open **Edit environment variables for your account**.
3. Under *User variables*, select **Path** and click **Edit**.
4. Click **New** and enter `C:\BazzBasic`.
5. Click **OK** in each window.

### Test it

Programs that were already open don't see the change. Close your terminal and open a new one.

> **Using a terminal inside another program?** The terminal in VS Code, Visual Studio and similar editors gets its settings from the editor. Closing the terminal tab is not enough: close and restart the **whole editor**. The same goes for Windows Terminal: close the entire app, not just the tab.

Then run:

```powershell
where.exe BazzBasic
```

Type `where.exe`, not just `where`. In PowerShell, `where` means something else.

The output should show the path to `BazzBasic.exe`. You can now run programs from any folder:

```powershell
BazzBasic myprog.bas
```

> **Programs that load files.** If a program loads images, sounds or data with relative paths (for example `assets/coin.mp3`), go to the program's own folder first and run it from there:
>
> ```powershell
> cd C:\Games\MyGame
> BazzBasic MyGame.bas
> ```

> **Avoid `setx PATH "%PATH%;..."`**. You'll see this command suggested on many websites, but it cuts PATH off at 1024 characters and can mix the system PATH into your user PATH. The commands above don't have these problems.

---

## Part 2: Run `.bas` files by double-clicking

Run this in PowerShell, with `$exe` set to where your `BazzBasic.exe` is:

```powershell
$exe = "C:\<path to BazzBasic.exe itself>"

# Creates a registry key only if it is missing, then sets its default value.
# Existing settings under the key (such as the Edit menu below) are kept.
function Set-RegDefault($path, $value) {
    if (-not (Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-Item $path -Value $value
}

# Link the .bas extension to a "BazzBasic.Program" file type
Set-RegDefault "HKCU:\Software\Classes\.bas"                          "BazzBasic.Program"
Set-RegDefault "HKCU:\Software\Classes\BazzBasic.Program"             "BazzBasic Program"
Set-RegDefault "HKCU:\Software\Classes\BazzBasic.Program\DefaultIcon" "`"$exe`",0"

# Double-click (Open) runs the program with BazzBasic
Set-RegDefault "HKCU:\Software\Classes\BazzBasic.Program\shell\open\command" "`"$exe`" `"%1`" %*"
```

After this, double-clicking a `.bas` file runs it with BazzBasic. The icon may not update until you restart Explorer or sign out and back in.

### Optional: add an "Edit" menu item

When double-click runs a program, you'll want an easy way to edit it too. This adds **Edit** to the right-click menu. The example uses Notepad++; use any editor's path you like:

```powershell
$editor = "C:\Program Files\Notepad++\notepad++.exe"

function Set-RegDefault($path, $value) {
    if (-not (Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-Item $path -Value $value
}

Set-RegDefault "HKCU:\Software\Classes\BazzBasic.Program\shell\edit\command" "`"$editor`" `"%1`""
```

> **Windows 11:** the new right-click menu shows only some commands. Look for **Edit** under **Show more options**, or press Shift+F10 on the file.

### If double-click still opens another program

If you have ever chosen an app for `.bas` files (for example "Always open with Notepad++"), that choice wins over the settings above. Fix it once:

1. Right-click any `.bas` file.
2. Choose **Open with** → **Choose another app**.
3. Select **BazzBasic**, or click *Choose an app on your PC* and browse to `BazzBasic.exe`.
4. Click **Always**.

---

## Optional: run programs without typing `.bas`

To run `myprog.bas` by typing just `myprog`, add `.BAS` to the PATHEXT variable:

```powershell
$ext = [Environment]::GetEnvironmentVariable("PATHEXT", "Machine")
if (($ext -split ";") -notcontains ".BAS") {
    [Environment]::SetEnvironmentVariable("PATHEXT", "$ext;.BAS", "User")
}
```

Open a new terminal afterwards.

- In **cmd**, `myprog` now runs `myprog.bas`.
- In **PowerShell**, a program in the current folder needs `.\` in front: `.\myprog`.

The command copies the system list first because a user-level PATHEXT *replaces* the system list instead of being added to it. Leaving that step out would break `.exe`, `.bat` and other file types.

---

## Things to know

- **Text output and console windows.** A program started by double-clicking gets its own console window, and that window closes as soon as the program ends. If you need to read a text-mode program's output, run it from a terminal with `BazzBasic myprog.bas`, or make the program wait for a key press before it ends:

  ```vb
  [inits]
      LET key$ = 0

  [main]
      PRINT "Hello from BazzBasic!"
      PRINT "Press any key to close..."
      key$ = WAITKEY()
  END
  ```

  Graphics programs work fine either way.
- **Other BASICs use `.bas` too.** QB64, FreeBASIC and Visual Basic 6 also use the `.bas` extension. The association sends all `.bas` files to BazzBasic, so if you use those tools as well, you may prefer to skip Part 2.
- **Moving BazzBasic.** If you move `BazzBasic.exe` to a new folder, remove the old folder from PATH (see *Undo everything*), add the new one (Part 1), and run Part 2 again with the new path. Your Edit menu item is kept.

---

## Undo everything

Remove the file association:

```powershell
Remove-Item "HKCU:\Software\Classes\.bas" -Recurse -ErrorAction SilentlyContinue
Remove-Item "HKCU:\Software\Classes\BazzBasic.Program" -Recurse -ErrorAction SilentlyContinue
```

Remove the PATHEXT change, if you made it:

```powershell
[Environment]::SetEnvironmentVariable("PATHEXT", $null, "User")
```

Remove BazzBasic from PATH:

```powershell
$dir = "C:\BazzBasic"
$old = [Environment]::GetEnvironmentVariable("Path", "User")
$parts = @($old -split ";" | Where-Object { $_ -ne "" -and $_ -ne $dir })
[Environment]::SetEnvironmentVariable("Path", ($parts -join ";"), "User")
```

Or do it by hand: open **Edit environment variables for your account** (see Part 1, Option B), select the `C:\BazzBasic` entry under Path, and click **Delete**.

## Disclaimer:
This guide has been implemented and tested with the Finnish version of Windows 11 x64. However, it should work on all modern versions of Windows