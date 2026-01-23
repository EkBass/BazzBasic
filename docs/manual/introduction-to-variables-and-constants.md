# Introduction to Variables and Constants
*Written by EKBass*

Variables and Constants form the "backbone" of all programs.  
If there is no data, there is nothing that needs functions, conditionals, printing, etc.

Arrays can also be counted on this same spine. But for clarity, I will cover them in the separate guide.

## What is a variable?

In the simplest terms, a variable is a place in the computer's memory where it stores information.

Variable declaration, initialization and processing are handled slightly differently in different languages.

In early BASIC interpreters, there was no need to declare them at all. Modern style, however, prefers that they be declared for the sake of clarity of the program, but also to find possible typos, etc.

## How do I declare it?

BazzBasic requires variables to be declared before they can be used. It is also important to use '$' as suffix when naming it.

```vb
LET foo$ ' Declares variable with a name 'foo$'
```
After declaring this, BazzBasic knows that there is a variable called 'foo$' and is ready to put data into it whenever the code wants to do so.

It is allowed to declare several variables on the same line, as long as they are separated by a comma.

```vb
LET foo$, bar$, name$, age$ ' Declares variables 'foo$', 'bar$', 'name$' and 'age$'
```

## How I give and change values of them?

BazzBasic is typeless - the same variable can hold both numbers and strings.

Once variable is declared, adjusting its value comes easy.

```vb
LET foo$
foo$ = "Hello World" ' Declares variable with a name 'foo$' and value 'Hello World'
```

Declaration can be done at same time with value.

```vb
LET foo$ = "Hello World" ' Declares variable with a name 'foo$' and value 'Hello World'
```

Now, every time you point to a variable 'foo$', you are actually pointing to its value 'Hello World'.

```vb
LET foo$ = "Hello World", bar$ = 1
PRINT foo$ ' Output: Hello World
PRINT bar$ ' Output: 1
```

If you want to change the value of variable, you use '='.

```vb
LET foo$ = "Hello World"
PRINT foo$ ' Output: Hello World
foo$ = "BazzBasic"
PRINT foo$ ' Output: BazzBasic
```

## How I compare variables?

Variables can be compared in same way as normal numbers.

```vb
LET foo$ = 1, bar$ = 2

IF foo$ > bar$ THEN
	PRINT "foo$ is bigger."
ELSEIF bar$ > foo$ THEN
	PRINT "bar$ is bigger."
ELSE
	PRINT "They have same value."
ENDIF
' Output: bar$ is bigger.
```

## Operating with numerical variables.

You can do same math calculations with variables as with numbers.

```vb
LET foo$ = 2, bar$ = 5
PRINT foo$ + bar$ ' Output: 7
PRINT foo$ * bar$ ' Output: 10
```

## Operating with string Variables

While you can compare or add two string variables together, naturally dividing string from a string is not possible.

```vb
LET foo$ = "Hello", bar$ = "World"
IF foo$ = bar$ THEN
	PRINT "foo$ and bar$ has same data"
ELSE
	PRINT "foo$ and bar$ has not same data."
ENDIF
' Output: foo$ and bar$ has not same data.
```

## Constants

There are three significant differences between a constant and a variable.

1. Whereas new data can be placed into a variable endlessly throughout the program's execution, a constant can be initialized and a value placed into it only once during the entire program's execution.
2. A constant is available throughout the program, a variable only in the part of the program where it is declared. This is called 'Scope' and more about it in a tutorial dedicated to it.
3. Constant requires '#' as suffix.

```vb
LET VERSION# = "1.0"
LET MAX_ROUNDS# = 100
```

Unlike with variables, it is important to give the value at same time as it is declared.

```vb
LET VERSION#
VERSION# = "1.0" ' This will not work, value should have been given in previous line.
' Output: Syntax error
```

## Operating with constants

Operating with constant works same way as with variables. Numerical or string.

You can also compare constants to variables and vice versa.

```vb
LET FOO# = 1, bar$ = 2

IF FOO# > bar$ THEN
	PRINT "FOO# is bigger."
ELSEIF bar$ > FOO# THEN
	PRINT "bar$ is bigger."
ELSE
	PRINT "They have same value."
ENDIF
' Output: bar$ is bigger.
```

## Exception for declaring them

BazzBasic allows you to declare variable or a constant when you use 'INPUT' or 'FOR...NEXT' with it.

```vb
INPUT "What is your name", name$ ' allowed way

FOR i$ = 1 TO 100	' allowed too
	PRINT i$
NEXT
```

## What next?

After learning the basics of variables and constants, you should next read following tutorial.

[Introdutcion to arrays](introduction-to-arrays.md)

