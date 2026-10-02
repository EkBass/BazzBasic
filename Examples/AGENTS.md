# AGENTS.md — BazzBasic project

This project is written in **BazzBasic** (Windows x64 BASIC interpreter, .bas files).
BazzBasic is NOT QBasic, QB64, FreeBASIC or VB. Do not assume syntax or
features from other BASIC dialects. If a feature is not documented in the
guide, say so instead of inventing it.

## Full language reference (required)

Before writing or editing any BazzBasic code, read the full AI guide:

https://huggingface.co/datasets/EkBass/BazzBasic_AI_Guide/resolve/main/BazzBasic-AI-guide.md

- Download it as raw text (e.g. `curl -L -o .bazzbasic/guide.md <url>`) and read
  the local copy in full. Do not rely on a summarized web fetch.
- If `.bazzbasic/guide.md` already exists, reuse it. Re-download if it is
  missing or the user says the guide has been updated.
- If the guide cannot be fetched, tell the user and follow the core rules below.

## Core rules (always apply)

- Variables end with `$` (`score$`), constants end with `#` (`MAX#`).
  The suffix is not a data type; `#` only means immutable.
- First use of a variable requires `LET`: `LET x$ = 0`, then `x$ = x$ + 1`.
  `FOR` and `INPUT` auto-declare.
- Arrays are declared with `DIM arr$` before use.
- Functions: `DEF FN Name$(a$, b$) ... END DEF`, defined **before** first call,
  called as `FN Name$(...)`. The return value must be used.
- `DEF FN` scope is isolated: it sees global `#` constants, not `$` variables.
  Arrays cannot be passed — serialize with `ASJSON` / `ASARRAY`.
- Image, sound and shape handles are stored in `#` constants:
  `LET IMG_PLAYER# = LOADIMAGE("player.png")`.
- No line numbers, no line-continuation character (`_`, `\`, `&`),
  no `TRY`/`CATCH`, no `ON ERROR`.
- Labels use brackets: `GOTO [main]`, `GOSUB [sub:draw]` ... `RETURN`.
- Paths use `/` or `\\`, never a single `\`.
  Backslash is an escape character in strings (`\"`, `\\`, `\n`, `\t`).

## Common pitfalls

- **`INPUT` splits on whitespace, unlike QBasic.** Input is split on commas;
  if there are no commas, it is split on spaces/tabs. Each variable gets
  one piece, so `INPUT "Name: ", name$` with `John Smith` gives `"John"`.
  For free text (names, sentences, file paths), always use
  `LINE INPUT "Name: ", name$`, which reads the whole line into one variable.
  Use `INPUT` only for single words or numbers.
- **`DIM x$ = 5` does not create a scalar.** It stores 5 at array index 0.
  Use `LET x$ = 5` for normal variables, `DIM` only for arrays.
- **`LOADSHEET` sprite indexes are 0-based.**
- **Anchors differ:** `LOADSHAPE` shapes are positioned by their center,
  `LOADIMAGE` images by their top-left corner. Images still rotate around
  their own center. To center an image on (x, y), subtract half its width
  and height from the position yourself.
- For multi-dimensional arrays, prefer `ROWCOUNT()` over `LEN()`.

## Running

```
bazzbasic.exe program.bas
```
