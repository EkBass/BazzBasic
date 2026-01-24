# Introduction to user-defined functions and scope
*Written by EkBass*

## A function?

Imagine your code is like a car engine. Each part has its own, sometimes very small, but significant task that keeps the engine running.

The accelerator pedal sends a signal to the fuel injectors, "speed up" which causes the fuel injectors to inject more fuel into the cylinder.

The cable coming from the gearbox feeds information to the function "Speedometer(cable rotation speed)" which tells the driver the current speed.

BazzBasic itself already offers a number of different functions.

'LEN("Hello")' returns the length of a word, while 'RND(10)' returns a random number.

## User-defined function

You are programming a classic role-playing game. And if there is one thing that is certain, it requires repeated dice rolling.

There are many different types of dice. A standard 6-sided die is just the beginning.

So you need more than one: d3, d4, d6, d8, d10, d12, d20, d23, d30, d60...

Of course you can place "result$ = RND(sides) + 1" numerous times in your code, but you can convert this to a function, in which case the necessary operation is performed in the function.

```vb
DEF FN DiceRoll$(sides$)
	RETURN RND(sides$) + 1 ' returns random number between 1 and the requested dice
END DEF

PRINT "3-sided dice: "; FN DiceRoll$(3)
PRINT "6-sided dice: "; FN DiceRoll$(6)
PRINT "20-sided dice: "; FN DiceRoll$(20)
```

Or maybe you need quick way to solve, did the attacker hit or not.

```vb
DEF FN DidHit$(defence$, attack$)
	LET defenceChance$ = RND(defence$) + 1
	LET attackChance$ = RND(attack$) + 1
	
	' If attackChance$ is higher, then attacker did hit
	IF attackChance$ > defenceChance$ THEN
		RETURN TRUE
	END if
	
	RETURN FALSE
END DEF

LET defence$ = 15
LET attack$ = 13

IF FN DidHit$(defence$, attack$) = TRUE THEN 
	PRINT "Attacker did hit."
ELSE
	PRINT "Successful defence."
END IF
```

## Rules of user-defined functions

While user-defined functions offers a easy to useful way to expand your program, they need to follow a set of rules.

1. It must be closed between 'DEF FN <name>(<parameters>)' and 'END DEF' lines
2. It must have a unique name with a '$' as suffix
3. It is called with 'FN' prefix
4. Function always returns some value
5. It must be declared before you can call it

## Read more about user-defined functions

There is a useful page about [User-defined functions](https://github.com/EkBass/BazzBasic/blob/main/docs/manual/user-defined-functions.md) in BazzBasic manual I recommend to read next.


# The Scope

A scope is a... well, a scope where variables, arrays and constants are visible.

In some languages, all variables are available where ever inside the program.  
While this sounds like something which makes things easy, it will actually mess you and your code up pretty soon after your program grows any more than few lines long example.

```vb
' Function addFive$ starts
DEF FN addFive$(param$)
	LET x$ = 5
	RETURN x$ + param$
END DEF
' function addFive$ ends

' main program
LET x$ = 1
PRINT FN addFive$(x$) ' Output: 6
' end main program
```

Here happens several things.

1. 'DEF FN addFive$(param$)' param$ is automatically declared to be in use inside 'addFive$' function with value of what ever you pass to it.
2. 'LET x$ = 5'. While 'x$' is declared in main program, it is not visible inside 'addFive$' function. 'x$' declared inside function, is its own independent variable.
3. 'LET x$ = 1' is secured by the scope. Function 'addFive' does not even know such a variable exists in main program
4. 'PRINT addFive(x$)' Here is not passed variable 'x$', only the value of it. From the point of view of 'addFive$', you can give it parameter as variable 'x$' or just raw coded number 5. Result is exactly the same.

## And variables inside function?

The scope makes sure, that variables inside of function lives just as long as the execution of function takes. A function is like a small independent BASIC program that is only run when it is specifically called.

## Constants in scope

Constants are identifiers that represent literals or constant expressions that can not be changed after they are defined.

For example, LET PI# = 3.1415926535897932 will always mean that the identifier PI# refers to the number 3.1415926535897932. The identifier PI# can be used instead of repeating the full number in source.

Unlike variables, constants are not limited by the scope.

```vb
LET FIVE# = 5

' Function addFive$ starts
DEF FN addFive$(param$)
	RETURN param$ + FIVE#
END DEF
' function addFive$ ends

' main program
LET x$ = 1
PRINT FN addFive$(x$) ' Output: 6
' end main program
```

## Read next

After you have learned about variables, constants, arrays, user-defined functions and the scope, the next part of this tutorial series is about how to name them so that it makes things easier.

Tutorial about [Naming things](naming-things.md]
