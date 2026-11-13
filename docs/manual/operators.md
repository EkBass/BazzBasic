# Operators

## Logical Values
### TRUE, FALSE

Boolean constants.
```vb
LET gameOver$ = FALSE

WHILE NOT gameOver$
    ' game loop
    IF lives$ = 0 THEN gameOver$ = TRUE
WEND
```
## Arithmetic Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Addition | `5 + 3` → `8` |
| `-` | Subtraction | `5 - 3` → `2` |
| `*` | Multiplication | `5 * 3` → `15` |
| `/` | Division | `10 / 3` → `3.333...` |
| `%` | Modulo (remainder) | `10 % 3` → `1` |

**Division by zero** does not stop the program, it gives `0`. This is the same for `/`, `/=`, `%` and `MOD`:
```vb
LET a$ = 10
a$ /= 0
PRINT 10 / 0       ' Output: 0
PRINT a$           ' Output: 0
PRINT 10 % 0       ' Output: 0
PRINT MOD(10, 0)   ' Output: 0
```
Check the divisor first if that matters.

BazzBasic has no `\` (integer division) or `^` (power) operator. Use `INT(a / b)` and `POW(a, b)`:
```vb
PRINT INT(10 / 3)    ' Output: 3
PRINT POW(2, 8)      ' Output: 256
```
Writing `10 \ 3` or `2 ^ 8` stops the program before it starts, with a hint: `Error: Line 1: Unexpected character '\' - BazzBasic has no integer division operator, use INT(a / b)`. Any other character that is not part of the language (outside strings, comments and labels), such as `@`, is an error too.

## Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equal to | `x = 5` |
| `<>` | Not equal to | `x <> 5` |
| `<` | Less than | `x < 10` |
| `>` | Greater than | `x > 0` |
| `<=` | Less than or equal | `x <= 100` |
| `>=` | Greater than or equal | `x >= 1` |

### Comparing text

Comparisons between two strings **ignore case**: `"abc" = "ABC"` is `1` (true), and `"a" < "B"` is `1` too.

To compare exactly, for example a password, a key or an ID, use `SAME(a$, b$)`. It returns `1` only if both texts are identical, case included:
```vb
LET password$ = "Open Sesame"
LET guess$    = "open sesame"

IF guess$ = password$ THEN PRINT "= says: match"

IF SAME(guess$, password$) THEN
    PRINT "SAME: match"
ELSE
    PRINT "SAME: no match"
END IF
' Output:
' = says: match
' SAME: no match
```
`SAME` compares text. For numbers use `=`.

**Before version 1.7** there is no `SAME`. Check the length and use `INSTR`, which is case-sensitive:
```vb
LET password$ = "Open Sesame"
LET guess$    = "open sesame"

IF LEN(guess$) = LEN(password$) AND INSTR(guess$ + "~", password$ + "~") = 1 THEN
    PRINT "Exact: match"
ELSE
    PRINT "Exact: no match"
END IF
' Output:
' Exact: no match
```
The `+ "~"` is needed so that two empty strings count as equal (`INSTR("", "")` gives `0`). Any character works, as long as both sides get the same one.

## Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `AND` | Logical AND | `x > 0 AND x < 10` |
| `OR` | Logical OR | `x < 0 OR x > 100` |
| `NOT` | Logical NOT | `NOT finished` |

## String Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Concatenation | `"Hello" + " " + "World"` → `"Hello World"` |

If either side of `+` is a string, `+` joins instead of adding, from left to right: `"12" + 3` → `123`, `1 + 2 + "Foo"` → `3Foo`. See [Comparing variables](variables-and-constants.md?id=comparing-variables).

## Operator Precedence

From highest to lowest:

1. `()` - Parentheses
2. `NOT` - Logical NOT
3. `*`, `/`, `%` - Multiplication, Division, Modulo
4. `+`, `-` - Addition, Subtraction
5. `=`, `<>`, `<`, `>`, `<=`, `>=` - Comparison
6. `AND` - Logical AND
7. `OR` - Logical OR
