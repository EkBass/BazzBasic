# News and changes
These changes are about the current source code. These are effected once new binary release is published

## Feb 2026

### 7th Feb. 2026

Added keyword **HPI** which returns raw coded 1,5707963267929895

**PI** and **HPI** are raw coded values, so no math involved. Should make performance much better.

### 7th Feb 2026

Added keyword **PI** which returns 3.14159265358979  
Added keywords RAD & DEG

```vb
REM Test RAD and DEG functions
PRINT "Testing RAD() and DEG() functions"
PRINT

REM Test degrees to radians
PRINT "90 degrees = "; RAD(90); " radians"
PRINT "180 degrees = "; RAD(180); " radians"
PRINT "360 degrees = "; RAD(360); " radians"
PRINT

REM Test radians to degrees  
PRINT "PI radians = "; DEG(PI); " degrees"
PRINT "PI/2 radians = "; DEG(PI/2); " degrees"
PRINT

REM Test with trigonometry
PRINT "SIN(RAD(90)) = "; SIN(RAD(90))
PRINT "COS(RAD(180)) = "; COS(RAD(180))
PRINT

END
```

```batch
Testing RAD() and DEG() functions

90 degrees = 1.5707963267948966 radians
180 degrees = 3.141592653589793 radians
360 degrees = 6.283185307179586 radians

PI radians = 179.99999999999983 degrees
PI/2 radians = 89.99999999999991 degrees

SIN(RAD(90)) = 1
COS(RAD(180)) = -1
````

### 1st Feb 2026

The documentation has been worked on and is now a bit better than good.

BazzBasic supports creating libraries: bazzbasic.exe -lib file.bas

LINE INPUT is now in the list of supported commands

Version 0.7 released to this date

## Jan 2026

### 18th Jan 2026
With all the previous add-ons, BazzBasic ver. 0.6 is now available as binary and source.


### 18th Jan 2026
Merging BazzBasic and basic code into a single executable file is now possible.

_bazzbasic.exe -exe filename.bas_ produces the _filename.exe_ file.

BazzBasic does not compile the BASIC code, but rather includes it as part of itself.

Read more https://ekbass.github.io/BazzBasic/manual/#/packaging



### 18th Jan 2026
Finished working with PNG and Alpha-color supports.  
LOCATE in graphical screen now overdraws old text instead of just writing new top of it.  

**Supported Formats**

**Format:** PNG  
Transparency: Full alpha (0-255)  
Recomended  

**Format**: BMP  
Transparency: None  
Legacy support

---

### 18th Jan 2026
Generated a manual with Docify.   
BazzBasic homepage now links to it.

Major idea is, that github wiki becomes a as development wiki and this docify as user wiki.

---

### 17th Jan 26
Fixed a bug that prevented to use custom resolution with SCREEN 0  
Terminal now closes if no errors when running via IDE  
Small gap between IDE line numbers and user code.

---

### 17th Jan 26
BazzBasic has now in-built simple IDE.  
Start _bazzbasic.exe_ with out params to open it.  
If opened with params, the .bas file is interpreted normally.  
After few new features, released as version 0.6

---

### 10th Jan 26
Generated __vsix__ file to add BazzBasic syntaxes for VS Code.  
See https://github.com/EkBass/BazzBasic/blob/main/extras/readme.md

---

### 9th Jan 26
Released first one, version 0.5
