# Introduction to Arrays
*Written by EkBass*

Arrays allow you to store multiple values under a single name. Instead of creating dozens of separate variables, you can organize related data into one structure.

## What is an array?

Think of an array as a row of numbered boxes. Each box can hold one piece of data, and you access it by its position number (called an index).

```
myArray:  [ "Apple" ] [ "Banana" ] [ "Cherry" ]
index:         0           1           2
```

## How do I declare an array?

Arrays are declared using the `DIM` keyword:

```vb
DIM fruits$ ' Declares an array called 'fruits$'
```

You can declare multiple arrays on the same line:

```vb
DIM fruits$, numbers$, names$
```

## How do I add values?

BazzBasic arrays are dynamic - they grow automatically when you add new elements.

```vb
DIM fruits$
fruits$(0) = "Apple"
fruits$(1) = "Banana"
fruits$(2) = "Cherry"

PRINT fruits$(1) ' Output: Banana
```

## String keys (associative arrays)

One of BazzBasic's powerful features is that arrays can use strings as keys, not just numbers. This creates what other languages call a "dictionary" or "hash map".

```vb
DIM person$
person$("name") = "John"
person$("age") = 30
person$("city") = "Helsinki"

PRINT person$("name") ' Output: John
PRINT person$("age")  ' Output: 30
```

## Mixing numeric and string keys

The same array can use both numeric and string keys:

```vb
DIM data$
data$(0) = "First item"
data$(1) = "Second item"
data$("label") = "My Data"

PRINT data$(0)       ' Output: First item
PRINT data$("label") ' Output: My Data
```

## Multi-dimensional arrays

BazzBasic supports arrays with multiple dimensions. Simply use comma-separated indices:

```vb
DIM grid$

FOR row$ = 0 TO 2
    FOR col$ = 0 TO 2
        grid$(row$, col$) = row$ * 3 + col$
    NEXT
NEXT

PRINT grid$(0, 0) ' Output: 0
PRINT grid$(1, 1) ' Output: 4
PRINT grid$(2, 2) ' Output: 8
```

This works for any number of dimensions:

```vb
DIM cube$
cube$(0, 0, 0) = "Origin"
cube$(1, 2, 3) = "Deep inside"
```

## Checking if a key exists

Use `HASKEY` to check whether a specific key exists in an array:

```vb
DIM inventory$
inventory$("sword") = 1
inventory$("shield") = 1

IF HASKEY(inventory$, "sword") THEN
    PRINT "You have a sword!"
ENDIF

IF NOT HASKEY(inventory$, "potion") THEN
    PRINT "No potions in inventory."
ENDIF
```

## Removing elements

Use `DELKEY` to remove an element from an array:

```vb
DIM inventory$
inventory$("sword") = 1
inventory$("shield") = 1

DELKEY inventory$, "sword"

IF NOT HASKEY(inventory$, "sword") THEN
    PRINT "Sword has been removed."
ENDIF
```

## Looping through arrays

When using numeric indices, you can loop through an array with `FOR...NEXT`:

```vb
DIM numbers$
FOR i$ = 0 TO 4
    numbers$(i$) = (i$ + 1) * 10
NEXT

FOR i$ = 0 TO 4
    PRINT "numbers$("; i$; ") = "; numbers$(i$)
NEXT
```

## Practical example: A simple phonebook

```vb
DIM phone$
phone$("Alice") = "555-1234"
phone$("Bob") = "555-5678"
phone$("Charlie") = "555-9999"

INPUT "Enter name to look up: ", name$

IF HASKEY(phone$, name$) THEN
    PRINT name$ + "'s number is: " + phone$(name$)
ELSE
    PRINT "Name not found in phonebook."
ENDIF
```

## Arrays vs Variables

| Feature | Variable | Array |
|---------|----------|-------|
| Declaration | `LET name$` | `DIM name$` |
| Holds | One value | Multiple values |
| Access | `name$` | `name$(index)` |
| Keys | N/A | Numbers or strings |
| Dimensions | N/A | Unlimited |

## What next?

Now that you understand arrays, you might want to explore:

[Introduction to user-defined functions and scope.md](introduction-to-user-defined-functions-and-scope.md)
