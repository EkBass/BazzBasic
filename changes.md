# News and changes

## Jan 2026

### 18th Jan 2026
With all the previous add-ons, BazzBasic ver. 0.6 is not available as binary and source.


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
