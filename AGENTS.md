# AGENTS.md

CTF playbook for HackForGov 2026, modeled on John Hammond's [Katana](https://github.com/JohnHammond/katana). It teaches pattern recognition, not answers.

Rules and scope are in [`event-briefer.md`](event-briefer.md). AI tools are banned during the event, so a human must be able to follow every entry unaided.

## Rules

- **Signal, pattern, approach.** Start each entry from something observable, like a file type, header, charset or URL parameter. Name the pattern it points to. List approaches from most to least likely, and say why each works.
- **Link out.** Summarize briefly and link to external tutorials, cheat sheets, docs and writeups. Write our own text only for what the sources lack, such as the exact command we ran or a gotcha.
- **Skimmable.** Use headings, bullets and copy-paste commands. Lead each entry with "seeing X? try Y".
- **Terse.** Write short, direct, mechanical text. Cut filler, narration and summaries. Load the `unslop` skill before writing prose.
- **By category.** One note per challenge domain under `categories/`.
- **Writeups.** Link external writeups in `writeups/README.md`. Extract each one's signal and pattern into the matching category note.
- **Tools.** Put usage in the category note that uses the tool. Tools used in every category go in the README first pass. `tools.md` holds install commands and doc links only.
