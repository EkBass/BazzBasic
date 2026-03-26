## Comments

BazzBasic supports two comment styles.

### REM
Traditional BASIC keyword comment.
```vb
REM This is a comment
REM Initialize player position
LET x$ = 100
```

### Single Quote
Shorter alternative, works inline too.
```vb
' This is a comment
LET x$ = 100    ' Inline comment
```

Both styles are completely identical in behavior — use whichever you prefer. Single quote `'` is generally preferred for its brevity.

```vb
' ============================================
' player.bas - Player movement logic
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET x$ = 320    ' Start at center X
    LET y$ = 240    ' Start at center Y
```
