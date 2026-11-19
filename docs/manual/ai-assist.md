
# AI assisted learning

BazzBasic is a young language, so AI models have seen very little of it in their training data. Left alone, an AI will happily guess and write BASIC that looks right but uses syntax from QBasic, FreeBASIC or some other dialect.

To fix that, BazzBasic has an official AI guide: a skill folder named `bazzbasic-code` built around `SKILL.md` (the core language) plus topic files in `references/` — graphics & sound, mouse & gamepad, file I/O, JSON & XML, network (including calling AI/LLM APIs), date & time and the IDE. Together they teach an AI the language — syntax, variable rules, commands, functions, common pitfalls and idioms.

[BazzBasic AI guide (the `bazzbasic-code` skill folder) on Hugging Face](https://huggingface.co/datasets/EkBass/BazzBasic-SKILL)

The guide was originally written by uploading the BazzBasic documentation to Claude, ChatGPT and Mistral Le Chat and asking them to build a reference that works specifically as an aid for AI. It has been refined against the interpreter source ever since.

## What is a SKILL?

A *skill* is a way to give an AI a piece of expert knowledge it can pick up when it needs it. The format was introduced by Anthropic for Claude in October 2025 as **Agent Skills** and published as an open standard ([agentskills.io](https://agentskills.io)) in December 2025. Since then it has been adopted by many AI tools and coding agents.

A skill is simply a folder containing a file named `SKILL.md`. The file is plain Markdown with a short header at the top:

```
---
name: bazzbasic-code
description: "BazzBasic BASIC interpreter language reference. Use when writing,
  debugging, or explaining BazzBasic code (.bas files). ..."
---

# BazzBasic Language Reference
...
```

- **name** — a short identifier for the skill.
- **description** — tells the AI *when* to use the skill.
- Everything after the header is the actual knowledge.

The clever part is how the AI uses it. At first the AI only reads the name and the description, which costs almost nothing. When you ask something that matches the description — for example "write me a BazzBasic program that draws a starfield" — the AI loads the full guide and follows it. When you talk about something else, the guide stays out of the way.

A skill folder may also contain extra files, and the BazzBasic guide uses them: the large topics live in `references/*.md`, which `SKILL.md` points to, and `README.md` carries a copy-paste setup prompt that lists every file.

## How to use it

**Tools that support skills** (for example Claude, Claude Code and many other coding agents):

1. Download the whole `bazzbasic-code` folder — `SKILL.md`, `README.md` and all of `references/`.
2. Add the folder to your tool's skills directory, or upload it as a skill in the tool's settings.

After that the AI uses the guide automatically whenever BazzBasic comes up.

### Native SKILL.md support

These popular AI services can all load `SKILL.md` as a skill automatically (as of October 2026):

- Anthropic Claude (Claude.ai, Claude Code)
- OpenAI ChatGPT and Codex
- Google Gemini CLI
- Mistral Vibe
- GitHub Copilot (VS Code agent mode, Copilot CLI)
- Microsoft 365 Copilot (Cowork)
- xAI Grok
- OpenCode.AI
- DeepSeek Seek Code
- OpenClaw.AI
- OpenCode.AI
- Tricentis Tabnine
- Kimi.com
- ...and many more.

The list grows all the time.  
See [agentskills.io/clients](https://agentskills.io/clients) for them all.

**Every other AI** understands it too. The files are plain Markdown — attach them to the chat or paste them into your project instructions. `README.md` contains a ready-made setup prompt that lists every file: copy-paste it.

## License and updates

The guide is published under the MIT license. It evolves together with BazzBasic itself, and the version number at the top of the file tells which BazzBasic version it describes. Check for a newer copy from time to time — especially after a new BazzBasic release.
