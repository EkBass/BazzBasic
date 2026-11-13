# Arrays & JSON
Arrays store collections of values. BazzBasic arrays are fully dynamic and support numeric, string, or mixed indexing.

- Arrays store values that can change during program execution.
- All array names must end with `$`.

## Initialization
- Arrays must be initialized with `DIM` before they can be used
- Like variables or constants, arrays are not strongly typed
- An array needs the suffix '$'. `DIM MAX#` stops the program: `Error at line 1: DIM: expected an array name ending in $, got 'MAX#'`.
- Re-declaring an existing array in the main program with `DIM` does not clear it; use `DELARRAY` to remove it. (Inside a function, `DIM` always creates a fresh, empty local array.)
- Arrays have no fixed size. `DIM scores$(10)` is accepted, but the `(10)` is ignored: you get the same empty array as with `DIM scores$`. Nothing inside the parentheses is read, so `DIM scores$(n$)` declares only `scores$`.
- `DIM x$ = 5` declares the array `x$` and stores 5 in `x$(0)`. For a plain variable, use `LET x$ = 5`. (A text of `key=value` lines fills named keys instead, see *Loading key=value Files into Arrays* below.) A name takes a size or a value, not both: `DIM a$(10) = 5` is an error.
```vb
DIM scores$
DIM names$
DIM matrix$
```

Multiple declarations:
```vb
DIM a$, b$, c$
```

`DIM` ends at the end of the line or at `:`, so other statements can follow on the same line:
```vb
DIM a$, b$ : a$(0) = 1 : b$(0) = 2
PRINT a$(0) + b$(0)    ' Output: 3
```

## Numeric Indexing
Use numbers as indices (0-based):
```vb
DIM scores$
	scores$(0) = 95
	scores$(1) = 87
	scores$(2) = 92

PRINT scores$(0)         ' Output: 95
```

## String Indexing (Associative Arrays)
Use strings as keys:
```vb
DIM player$
	player$("name") 		= "Alice"
	player$("score") 	= 1500
	player$("level") 	= 3

PRINT player$("name")    ' Output: Alice
```

String keys are **case-sensitive**: `"name"`, `"Name"` and `"NAME"` are three different keys. The array name itself is not case-sensitive, so `player$`, `PLAYER$` and `Player$` all refer to the same array.
```vb
DIM word$
	word$("apple") = 1
	word$("Apple") = 2

PRINT LEN(word$())       ' Output: 2
PRINT word$("apple")     ' Output: 1
```

If you want keys that ignore case, normalize them yourself with `UCASE()` or `LCASE()`:
```vb
DIM count$
LET key$ = "Apple"
	count$(LCASE(key$)) = 1
PRINT count$("apple")    ' Output: 1
```

## Multi-dimensional Arrays
Use multiple indices separated by commas:

```vb
DIM matrix$
	matrix$(0, 0) = "A1"
	matrix$(0, 1) = "A2"
	matrix$(1, 0) = "B1"
	matrix$(1, 1) = "B2"
	
PRINT matrix$(1, 0)      ' Output: B1
```

## Mixed Indexing
Combine numeric and string indices:
```vb
DIM data$
	data$(1, "header") 	= "Name"
	data$(1, "value") 	= "Alice"
	data$(2, "header") 	= "Age"
	data$(2, "value") 	= 30

PRINT data$(1, "value")  ' Output: Alice
```

## Array Functions

### DELARRAY
Removes the entire array and all its elements:
```vb
DIM arr$
	arr$("name") 	= "Test"
	arr$(0) 			= "Zero"

PRINT LEN(arr$())	' Output: 2

DELARRAY arr$

' Array no longer exists, can be re-declared
DIM arr$
PRINT LEN(arr$())             ' Output: 0
```

### DELKEY
Removes an element from the array:
```vb
DIM cache$
	cache$("temp") = "value"
	
PRINT HASKEY(cache$("temp"))  ' Output: 1

DELKEY cache$("temp")
PRINT HASKEY(cache$("temp"))  ' Output: 0
```

---

### HASKEY
Returns 1 if the key exists, 0 otherwise:
```vb
DIM config$
	config$("debug") = 1

IF HASKEY(config$("debug")) THEN
    PRINT "Debug mode is set"
END IF

IF HASKEY(config$("verbose")) = 0 THEN
    PRINT "Verbose not set"
END IF
```

---

### JOIN
Merges two source arrays into a destination array. If both arrays share the same key, `src2$` overwrites `src1$`.
```vb
DIM a$
DIM b$
DIM c$

a$("name") 	= "Alice"
a$("score") 	= 100

b$("score") 	= 999   ' Same key as a$ — this wins
b$("level") 	= 5

JOIN c$, a$, b$

PRINT c$("name")    ' Output: Alice  (from a$)
PRINT c$("score")   ' Output: 999    (b$ overwrote a$)
PRINT c$("level")   ' Output: 5      (from b$)
```

---

### LEN and ROWCOUNT

| Function | Meaning |
|----------|---------|
| `LEN(arr$())` | Total element count across **all** dimensions (note empty parens) |
| `ROWCOUNT(arr$())` | Count of **first-dimension** keys only — use for FOR loops over multi-dim arrays |

```vb
DIM sounds$
    sounds$("guns", "shotgun_shoot")    = "shoot_shotgun.wav"
    sounds$("guns", "shotgun_reload")   = "reload_shotgun.wav"
    sounds$("guns", "ak47_shoot")       = "shoot_ak47.wav"
    sounds$("guns", "ak47_reload")      = "reload_ak47.wav"
    sounds$("food", "ham_eat")          = "eat_ham.wav"

PRINT LEN(sounds$())        ' 5 - total elements across both "guns" and "food" groups
PRINT ROWCOUNT(sounds$())   ' 2, "guns" & "food"
```

---

### ARRKEY

Returns the key at a given 0-based index, in insertion order. Pairs with `LEN(arr$())` to loop over associative (string-keyed) arrays using ordinary `FOR/NEXT` or `WHILE/WEND` — BazzBasic has no dedicated `FOREACH`.

```vb
DIM car$
	car$("manufacturer") 	= "Ford"
	car$("engine") 			= "1.6 Eco"
	car$("color") 			= "Blue"

FOR i$ = 0 TO LEN(car$()) - 1
	LET key$ = ARRKEY(car$(), i$)
	PRINT key$; " = "; car$(key$)
NEXT i$
' Output:
' manufacturer = Ford
' engine = 1.6 Eco
' color = Blue
```

Also works with `WHILE/WEND`:
```vb
LET i$ = 0
WHILE i$ < LEN(car$())
	LET key$ = ARRKEY(car$(), i$)
	PRINT key$; " = "; car$(key$)
	i$ = i$ + 1
WEND
```

Numeric-keyed arrays work the same way — `ARRKEY` returns the key as a string regardless of whether the array uses numbers or names as keys. An out-of-range index produces an error rather than an empty string, so a typo in the loop bound won't fail silently:
```vb
PRINT ARRKEY(car$(), 99)
' Error at line N: ARRKEY: index 99 out of range for array CAR$
```

---

## Practical Examples

### Pass values to user-defined functions
Arrays cannot be passed directly to functions. Instead, pass individual elements as values or whole array as JSON string.

### As single values
```vb
DIM a$
	a$("name") = "Foo"
	a$("age") = 19
	a$(1) = 1

DEF FN func$(a$, b$, c$)
    PRINT a$
    PRINT b$
    PRINT c$
    RETURN 0
END DEF

LET b$ = FN func$(a$("name"), a$("age"), a$(1))
' Output:
' Foo
' 19
' 1
```

### As JSON

The entire JSON dataset is processed as one large string, so it can be passed as a single parameter to a function.

```vb
' ==================================================
' Example how to pass array to user-defined function
' Starting from ver. 1.2
' EkBass, public domain
' ==================================================

 ' User-defined functions
DEF FN ArrayAsParam$(data$)
    DIM array$

    LET count$= ASARRAY(array$, data$)
    LET daString$
        daString$ = array$("name") + "\n"
        daString$ = daString$ + array$("score") + "\n"
        daString$ = daString$ + array$("address,city") + "\n"
        daString$ = daString$ + array$("skills,0") + "\n"
        daString$ = daString$ + array$("skills,1") + "\n"

    RETURN daString$
END DEF

[inits]
    DIM player$
        player$("name") 			= "Alice"
        player$("score") 		= 9999
        player$("address,city") 	= "New York"
        player$("skills,0") 		= "JavaScript"
        player$("skills,1") 		= "Python"

    LET json$

[main]
    json$ = ASJSON(player$)
    ' json$ now: "{\"name\":\"Alice\",\"score\":9999,\"address\":{\"city\":\"New York\"},\"skills\":[\"JavaScript\",\"Python\"]}"

[output]
    PRINT FN ArrayAsParam$(json$)
END

' Output:
' Alice
' 9999
' New York
' JavaScript
' Python
```

### Simple List
```vb
DIM fruits$
LET count$ = 0

fruits$(count$) = "Apple"
count$ = count$ + 1
fruits$(count$) = "Banana"
count$ = count$ + 1
fruits$(count$) = "Cherry"

FOR i$ = 0 TO count$
    PRINT fruits$(i$)
NEXT
```

### Dictionary / Map
```vb
DIM translations$
	translations$("hello") 		= "hei"
	translations$("goodbye") 	= "nakemiin"
	translations$("thanks")		 = "kiitos"

' using INPUT auto-initialization here for word$'
INPUT "English word: ", word$

IF HASKEY(translations$(word$)) THEN
    PRINT "Finnish: "; translations$(word$)
ELSE
    PRINT "Translation not found"
END IF
```

### Iterating an Associative Array
Combine `LEN` and `ARRKEY` to walk every key/value pair:
```vb
DIM scores$
	scores$("Alice") = 95
	scores$("Bob")   = 87
	scores$("Carol") = 92

FOR i$ = 0 TO LEN(scores$()) - 1
    LET name$ = ARRKEY(scores$(), i$)
    PRINT name$; ": "; scores$(name$)
NEXT i$
```
Output:
```
Alice: 95
Bob: 87
Carol: 92
```

### 2D Grid
```vb
DIM grid$

' Initialize 3x3 grid
FOR row$ = 0 TO 2
    FOR col$ = 0 TO 2
        grid$(row$, col$) = "."
    NEXT
NEXT

' Place some markers
grid$(0, 0) = "X"
grid$(1, 1) = "O"
grid$(2, 2) = "X"

' Print grid
FOR row$ = 0 TO 2
    FOR col$ = 0 TO 2
        PRINT grid$(row$, col$); " ";
    NEXT
    PRINT ""
NEXT
```

Output:
```
X . .
. O .
. . X
```

## Error Handling

### Array Not Declared
```vb
scores$(0) = 95
' Error at line 1: Array not declared, use DIM first: SCORES$
```

### Element Not Initialized
```vb
DIM data$
PRINT data$(0)
' Error at line 2: Array element DATA$(0) not initialized
```

### Array Used Without an Index
```vb
DIM nums$
nums$(0) = 7
PRINT nums$
' Error at line 3: NUMS$ is an array - use an element like NUMS$(0), or the whole array as a JSON string with ASJSON(NUMS$)
```

Error messages show array names in uppercase.

Always check with `HASKEY` or initialize elements before reading.

---

## Arrays and JSON

BazzBasic arrays map naturally to JSON. Nested JSON objects and arrays become multi-dimensional keys using comma-separated indices.

### ASJSON
Converts a BazzBasic array to a JSON string:
```vb
DIM player$
	player$("name") 			= "Alice"
	player$("score") 		= 9999
	player$("address,city") 	= "New York"
	player$("skills,0") 		= "JavaScript"
	player$("skills,1") 		= "Python"

LET json$ = ASJSON(player$)
PRINT json$
' Output: {"name":"Alice","score":9999,"address":{"city":"New York"},"skills":["JavaScript","Python"]}
```

Numeric keys decide the shape, at every nesting level: a level becomes a JSON **array** only when every key at that level is a plain non-negative number (`"0"`, `"1"`, `"2"`, ... — no sign, no leading zeros, no spaces) **and** the largest index is at most 1,000,000 or the level is dense (largest index below `4 * key count + 64`). Otherwise the level becomes a JSON **object** with the original keys as property names.
```vb
DIM a$
a$(0) = "x"
a$(5) = "y"
PRINT ASJSON(a$)     ' Output: ["x",null,null,null,null,"y"]

DIM b$
b$("2147483647") = 1
PRINT ASJSON(b$)     ' Output: {"2147483647":1}

DIM c$
c$("-5") = 1
c$("007") = 2
PRINT ASJSON(c$)     ' Output: {"-5":1,"007":2}
```
Dense arrays (for example `SPLIT` results or a `FOR i$ = 0 TO n` loop filling `arr$(i$)`) and small sparse arrays like `a$` above stay JSON arrays, so their output is unchanged from older versions. Keys like `"-5"`, `"007"` or `" 5"` are kept as object properties instead of being dropped, and a huge key such as `"2147483647"` returns instantly instead of freezing the program (before version 1.7).

JSON object keys keep the array key's case verbatim — case-sensitive, same as array string keys (see String Indexing above). `ASARRAY`/`LOADJSON` read property names verbatim too, so a JSON round-trip preserves case in both directions.
```vb
DIM a$
a$("key") = "lower"
a$("KEY") = "upper"
PRINT ASJSON(a$)     ' Output: {"key":"lower","KEY":"upper"}
```
Before version 1.7, keys differing only by case collapsed in `ASJSON`/`SAVEJSON` output and one value was silently lost (`{"key":{"":"upper"}}`).

### ASARRAY
Converts a JSON string into a BazzBasic array. Returns number of elements loaded:
```vb
DIM data$
LET count$ = ASARRAY(data$, "{\"name\":\"Bob\",\"score\":42}")

PRINT data$("name")    ' Output: Bob
PRINT data$("score")   ' Output: 42
PRINT count$           ' Output: 2
```

Nested JSON becomes comma-separated keys:
```vb
[inits]
    DIM data$
    LET json$ = "{\"player\":{\"name\":\"Alice\",\"hp\":100},\"skills\":[\"fire\",\"ice\"]}"

[main]
    LET count$ = ASARRAY(data$, json$)
    PRINT data$("player,name")   ' Alice
    PRINT data$("player,hp")     ' 100
    PRINT data$("skills,0")      ' fire
    PRINT data$("skills,1")      ' ice
    PRINT count$                 ' number of elements
END
```

Both output shapes read back to the same keys: a JSON array becomes keys `"0"` to `"n-1"`, a JSON object keeps its property names as they are. JSON `null` holes are skipped — they stay uninitialized and are not counted.
```vb
DIM a$
a$(0) = "x"
a$(5) = "y"
DIM b$
LET count$ = ASARRAY(b$, ASJSON(a$))
PRINT count$          ' Output: 2 (the null holes are skipped)
PRINT b$(0) + b$(5)   ' Output: xy

DIM h$
h$("2147483647") = 1
DIM g$
LET n$ = ASARRAY(g$, ASJSON(h$))
PRINT n$              ' Output: 1
PRINT g$("2147483647") ' Output: 1
```

`ASARRAY` reads JSON property names verbatim — case preserved — so a round-trip `ASARRAY(b$, ASJSON(a$))` keeps keys like `"key"` and `"KEY"` distinct.

### LOADJSON
Loads a JSON file directly into an array:
```vb
DIM scores$
LOADJSON scores$, "highscores.json"

PRINT scores$("first,name")   ' Output: depends on file contents
```

`LOADJSON` reads both shapes like `ASARRAY` does (arrays become keys `"0"` to `"n-1"`, objects keep their property names with their case, `null` values are skipped).

### SAVEJSON
Saves an array as a formatted JSON file:
```vb
DIM save$
	save$("level") = 3
	save$("hp") = 80
	save$("position,x") = 100
	save$("position,y") = 200

SAVEJSON save$, "savegame.json"
```

The resulting `savegame.json`:
```json
{
  "level": 3,
  "hp": 80,
  "position": {
    "x": 100,
    "y": 200
  }
}
```

`SAVEJSON` writes the same shape `ASJSON` produces (both share the same code), formatted as shown above; JSON object keys keep their case.

### Practical example: HTTP API + JSON
```vb
DIM response$
LET raw$ = HTTPGET("https://api.example.com/user/1")
LET count$ = ASARRAY(response$, raw$)

PRINT "Name: "; response$("name")
PRINT "Email: "; response$("email")
```

### XML (light model)

BazzBasic can also read and write XML, mainly so that an RSS or Atom feed reader is easy to make. **JSON is still the recommended format.** XML is heavier, does not map to arrays as cleanly, and its keys are longer. Use XML when the data only comes as XML.

> XML is not HTML. A web page does not parse as XML and gives an error.

`ASARRAY` recognizes the format by itself from the first character: `{` or `[` means JSON, `<` means XML. Nothing else needs to change.

```vb
LET xml$ = HTTPGET("https://www.example.com/rss.xml")
IF HTTPERROR <> "" THEN
    PRINT "Feed is down: "; HTTPERROR
    END
END IF

DIM feed$
LET count$ = ASARRAY(feed$, xml$)

PRINT feed$("rss,channel,0,title,0")
LET i$ = 0
WHILE HASKEY(feed$("rss,channel,0,item," + i$ + ",title,0"))
    PRINT "- "; feed$("rss,channel,0,item," + i$ + ",title,0")
    i$ += 1
WEND
END
```

**How XML becomes keys**

Every element below the root gets an index — even when there is only one. The keys are longer than in JSON, but the same loop works for a feed with one item and a feed with a hundred.

```xml
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>My feed</title>
    <item>
      <title>First post</title>
      <guid isPermaLink="false">id-1</guid>
      <category>News</category>
      <category>Weather</category>
      <dc:creator>Krisu</dc:creator>
    </item>
  </channel>
</rss>
```

| Key | Value |
|-----|-------|
| `rss,@version` | `2.0` |
| `rss,@xmlns:dc` | `http://purl.org/dc/elements/1.1/` |
| `rss,channel,0,title,0` | `My feed` |
| `rss,channel,0,item,0,title,0` | `First post` |
| `rss,channel,0,item,0,guid,0,@isPermaLink` | `false` |
| `rss,channel,0,item,0,guid,0,#text` | `id-1` |
| `rss,channel,0,item,0,category,0` | `News` |
| `rss,channel,0,item,0,category,1` | `Weather` |
| `rss,channel,0,item,0,dc:creator,0` | `Krisu` |

- **Attributes** get `@` in front of their name.
- **Text** of an element that also has attributes or child elements is in `#text`.
- **Prefixes** such as `dc:` are kept as written in the file. Their `xmlns:` declarations are attributes too, so `ASXML` can write them back.
- **CDATA** is read as plain text.
- All values are **strings** — XML has no number type. Use `VAL()` when you need a number.
- Comments and the `<!DOCTYPE ...>` line are ignored.

**Not supported:** text and elements mixed together (`<p>Hello <b>world</b>!</p>`) keeps the text and the elements, but not their order. Feeds rarely need this.

### ASXML
Converts a BazzBasic array to an XML string. If the array has a single top-level key, it becomes the root element; otherwise the root is `<root>`:
```vb
DIM player$
    player$("player,@id")   = 7
    player$("player,name")  = "Alice"
    player$("player,score") = 9999

PRINT ASXML(player$)
' Output: <player id="7"><name>Alice</name><score>9999</score></player>
```

Keys must be valid XML names: `player$("high score")` gives an error in `ASXML`, because an XML element name cannot contain a space.

### LOADXML
Loads an XML file directly into an array:
```vb
DIM cfg$
LOADXML cfg$, "settings.xml"

PRINT cfg$("config,player,0")
```

### SAVEXML
Saves an array as a formatted XML file:
```vb
DIM cfg$
    cfg$("config,player,0") = "Krisu"
    cfg$("config,volume,0") = 80
    cfg$("config,setting,0,@name") = "fullscreen"
    cfg$("config,setting,0,#text") = "on"

SAVEXML cfg$, "settings.xml"
```

The resulting `settings.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
  <player>Krisu</player>
  <volume>80</volume>
  <setting name="fullscreen">on</setting>
</config>
```

---

## HTTP Headers with Arrays

HTTPGET and HTTPPOST accept an optional `headers$` array as the last parameter. This enables authenticated API calls, custom content types, and any other HTTP header needs.

```vb
DIM headers$
	headers$("Authorization") = "Bearer mytoken123"
	headers$("Content-Type") = "application/json"

LET raw$ = HTTPGET("https://api.example.com/data", headers$)
```

```vb
DIM headers$
	headers$("Authorization") = "Bearer mytoken123"
	headers$("Content-Type") = "application/json"

DIM body$
	body$("model") = "gpt-4.1-mini"
	body$("messages,0,role") = "user"
	body$("messages,0,content") = "Hello"
	body$("max_tokens") = 100

LET raw$ = HTTPPOST("https://api.openai.com/v1/chat/completions", ASJSON(body$), headers$)

DIM result$
LET count$ = ASARRAY(result$, raw$)
PRINT result$("choices,0,message,content")
```

---

## Loading key=value Files into Arrays

`FILEREAD` can populate an array directly from a `key=value` formatted text file. If the target variable is a `DIM`'d array, BazzBasic automatically parses the file contents line by line into array elements.

```vb
DIM config$ = FILEREAD("settings.txt")

PRINT config$("width")    ' Output: 800
PRINT config$("height")   ' Output: 600
```

Where `settings.txt` contains:
```
width=800
height=600
# Comment, ignored, only when reading to array!
title=My Game
```


### .env files

This makes `.env` files work naturally for storing API keys and configuration outside of source code:

```vb
IF FILEEXISTS(".env") = 0 THEN
    PRINT "Error: .env file not found"
    END
END IF
DIM env$ = FILEREAD(".env")
PRINT env$("OPENAI_API_KEY")
```

Where `.env` contains:
```
OPENAI_API_KEY=sk-proj-...
# Comment
ANTHROPIC_API_KEY=sk-ant-...
# Important! In-line comments not yet supported
```

**Important:** Add `.env` to your `.gitignore` to keep API keys out of version control.
