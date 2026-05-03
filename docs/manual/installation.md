## Issues Found in `installation.md`

---

### 1. Malformed terminal command lines — extra underscores/italics breaking syntax

The "Use with terminal" section uses `_italic_` markdown formatting around filenames and flags, which causes the angle brackets and parts of commands to render incorrectly. Specifically:

```markdown
- _bazzbasic.exe_ <filename.bas>_ launches your BazzBasic code
- _bazzbasic.exe_ -exe <filename.bas>_ generates executable from _filename.bas_
- _bazzbasic.exe_ -lib <filename.bas> generates a tokenized library from _filename.bas_
- bazzbasic.exe -guide_ Get link to BazzBasic Beginner's guide
```

Problems per line:
- Line 2: trailing `_` after `<filename.bas>` closes an italic block that shouldn't be there
- Line 3: same — `<filename.bas>_` creates broken italic
- Line 4: `-lib` line is missing the closing `_` after `<filename.bas>` — inconsistent with others
- Line 6: `bazzbasic.exe -guide_` — missing opening `_`, so `-guide_` looks like `-guide` followed by an italic artefact

The whole section would be much cleaner and unambiguous using backtick code spans instead of italics for commands:

```markdown
- `bazzbasic.exe` — launches BazzBasic IDE
- `bazzbasic.exe <filename.bas>` — launches your BazzBasic code
- `bazzbasic.exe -exe <filename.bas>` — generates executable from filename.bas
- `bazzbasic.exe -lib <filename.bas>` — generates a tokenized library from filename.bas
- `bazzbasic.exe -v` — check current version
- `bazzbasic.exe -checkupdates` — check for updates
- `bazzbasic.exe -guide` — get link to BazzBasic Beginner's guide
```

---

### 2. "Visual Studio 2026" — Doesn't exist
```markdown
Repository is a _Visual Studio 2026_ project.
```
As of today (May 2026), Visual Studio 2026 has not been released. The current release is **Visual Studio 2022**. This is almost certainly a typo — probably meant **2022**.

---

### 3. Awkward phrasing — "In order you to run"
```markdown
In order you to run your BazzBasic code with built-in IDE...
```
Missing word. Should be: **"In order for you to run"** — or more naturally just **"To run your BazzBasic code with the built-in IDE"**.

---

### 4. "by switching to the GitHub release" — unclear meaning
```markdown
by switching to the GitHub release and providing the correct metadata during the compilation phase
```
This sentence is confusing. "Switching to the GitHub release" doesn't make clear sense to a new user. It likely means *signing the binary* or *providing code-signing metadata*, but as written it reads as if the user should do something, when it's actually the developer's task. Worth rewriting for clarity.

---

### 5. Minor — "github" not capitalized in source link
```markdown
available at [github](https://github.com/EkBass/BazzBasic/tree/main)
```
Should be **GitHub** (capital G and H) — it's a proper noun/brand name.

---

### Summary Table

| # | Location | Issue | Severity |
|---|----------|-------|----------|
| 1 | Use with terminal | Broken italic markers mangling command syntax | High |
| 2 | Source section | "Visual Studio 2026" doesn't exist — likely 2022 | High |
| 3 | Run BazzBasic IDE | "In order you to run" — missing word | Moderate |
| 4 | Firewall issues | "switching to the GitHub release" — unclear meaning | Moderate |
| 5 | Source section | `github` → `GitHub` | Minor |

---

Ready for the next page.
