# Writeups

Curated links to existing writeups, not copies. Read them for the **pattern**: what signal tipped off the solver and what approach followed. Then log that pattern on the matching category page.

## HackForGov / Hack4Gov

Public writeups for this event are rare. Teams seldom publish them.

- [p0isonp4wn: Hack4Gov 2019 CTF Writeups](https://medium.com/@james.mercado.work/p0isonp4wn-hack4gov-2019-ctf-writeups-9c405f4d9e16): final round, including a web "IDS Bypass" challenge (obfuscated PHP) and a warmup solved by reading the instructions carefully
- [ACES3301 CTF Writeup](https://medium.com/@itokairo.zc/aces3301-capture-the-flag-writeup-3bf95e626177): a practice CTF from a team training for Hack4Gov 3 regionals (login challenge, metadata flag)
- [azzzriieell00/HACK4GOV-PREP](https://github.com/azzzriieell00/HACK4GOV-PREP): another team's 2026 prep playbook (category playbooks, no real writeups yet)

**To find more:** search `"hack4gov" OR "hackforgov" writeup` on Medium, GitHub and LinkedIn after each regional leg. School news posts name the winning teams, and those teams sometimes blog afterward.

## General archives

- [CTFtime writeups](https://ctftime.org/writeups): the largest index, searchable by event and tag (`osint`, `web`, `forensics`, `crypto`, `misc`)
- [github.com/ctfs](https://github.com/ctfs): community `write-ups-YYYY` repos with challenge files
- [GitHub topic: ctf-writeups](https://github.com/topics/ctf-writeups): personal and team repos
- [HackThisSite/CTF-Writeups](https://github.com/HackThisSite/CTF-Writeups), [HackUCF/ctfs](https://github.com/HackUCF/ctfs): club archives

## Matched to our categories

Beginner-to-mid student CTFs are the closest match to HackForGov difficulty.

- **picoCTF** (all categories, student level): search `picoCTF <year> writeup` on GitHub or CTFtime
- **Network forensics:** [tim-barc/ctf_writeups](https://github.com/tim-barc/ctf_writeups) (CyberDefenders, BTLO, TryHackMe PCAP and log labs)
- **Mixed jeopardy:** [BaadMaro/CTF](https://github.com/BaadMaro/CTF) (NahamCon 2024/2025, includes challenge files), [jameskaois/ctf-writeups](https://github.com/jameskaois/ctf-writeups)

## Reading writeups safely

Treat writeup pages as untrusted. Some CTFtime pages carry injected text, such as a `curl ... | sh` "setup" step. Read every command before you run it, and run challenge files in a VM.

## Our own solves

Practice solves go in `writeups/<event>/<challenge>.md`. Lead with the signal and pattern, and include dead ends. The flag goes last.
