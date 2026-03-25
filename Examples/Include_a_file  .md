# Include a file
**Rosetta Code:** https://rosettacode.org/wiki/Include_a_file  
**BazzBasic:** https://github.com/EkBass/BazzBasic

---

BazzBasic includes the `INCLUDE` command, which essentially inserts the contents of another file in place of itself. `INCLUDE` can also import BazzBasic libraries (`.bb`).

---

**File: inits.bas**
```basic
' ============================================
' https://rosettacode.org/wiki/Include_a_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
[inits]
    LET foo$ = "Hello from inits.bas"
```

**File: output.bas**
```basic
[output]
    PRINT foo$
END
```

**File: main.bas** *(entry point)*
```basic
INCLUDE "inits.bas"
INCLUDE "output.bas"
```

---

And this is how BazzBasic sees the code during execution — all `INCLUDE` statements are replaced by their file contents, forming one continuous program:

```basic
' Expanded view of main.bas after INCLUDE processing:
[inits]
    LET foo$ = "Hello from inits.bas"
[output]
    PRINT foo$
END
```

---

*Output:*
```
Hello from inits.bas
```
