# Tutorial: Hello World

Your first BazzBasic program!

## Step 1: Create a New File

Open the BazzBasic IDE (run `BazzBasic.exe` without arguments) and create a new file.

## Step 2: Write the Code

```basic
REM My first BazzBasic program
PRINT "Hello, World!"
```

## Step 3: Run It

Press **F5** to run. You should see:

```
Hello, World!
```

## Step 4: Make It Interactive

```basic
REM Interactive greeting
LET name$

PRINT "What is your name?"
INPUT name$
PRINT "Hello, "; name$; "!"
PRINT "Welcome to BazzBasic!"
```

## What You Learned

- `REM` creates comments
- `PRINT` outputs text
- `LET` declares variables
- `INPUT` reads user input
- String variables end with `$`

## Next Steps

- [Guessing Game Tutorial](tutorial-guessing-game.md)
- [Variables & Constants Reference](variables-and-constants.md)
