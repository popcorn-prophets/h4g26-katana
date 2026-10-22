# Tools

Install before the event. Keep tools, wordlists, and CyberChef offline. Usage goes in the category notes.

Base OS: [Kali](https://www.kali.org/docs/). Most tools below are preinstalled.

```sh
sudo apt update && sudo apt install -y \
  wireshark tshark pcapfix aircrack-ng dnsutils whois nmap \
  binwalk foremost sleuthkit autopsy libimage-exiftool-perl pngcheck \
  poppler-utils fcrackzip p7zip-full \
  steghide zbar-tools ffmpeg audacity sonic-visualiser \
  john hashcat hashid ffuf gobuster sqlmap seclists sherlock \
  ghidra radare2 gdb ltrace strace upx-ucl jadx apktool
sudo gunzip /usr/share/wordlists/rockyou.txt.gz
```

Python: `pipx install pwntools volatility3 angr; pip install pycryptodome sympy gmpy2 z3-solver flask-unsign xortool oletools ROPgadget`
Other: `sudo gem install zsteg one_gadget`, stegseek (`.deb`), [pwndbg](https://github.com/pwndbg/pwndbg) (gdb plugin), [StegSolve](http://www.caesum.com/handbook/Stegsolve.jar) (jar), [CyberChef](https://github.com/gchq/CyberChef/releases) (zip), [RsaCtfTool](https://github.com/RsaCtfTool/RsaCtfTool) (git clone).

## Aliases

Source [`aliases.sh`](aliases.sh) to get short commands for the common moves (`triage`, `fg` flag-grep, `b64d`, `serve`, `cs`, `pcapstat`, XOR/binary helpers). Install:

```sh
echo "export FLAG=H4G; source $(pwd)/aliases.sh" >> ~/.zshrc
```

## Cheatsheets

Forgot a flag or syntax? Look it up locally instead of guessing. Install these too; most work offline.

| Tool                                                | What it does                                          | Install                                         |
| --------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------- |
| [tealdeer](https://github.com/tealdeer-rs/tealdeer) | Fast `tldr` client: short usage examples per command  | `cargo install tealdeer` (then `tldr --update`) |
| [navi](https://github.com/denisidoro/navi)          | Interactive cheatsheet, pick a command and fill args  | `cargo install navi`                            |
| [eg](https://github.com/srsudar/eg)                 | Worked examples for common commands                   | `pipx install eg`                               |
| [cheat.sh](https://cheat.sh/)                       | One-liner cheatsheets via curl; `curl cheat.sh/<cmd>` | online, or `cht.sh` client for offline          |

## Triage

| Tool                                           | What it does                                                       |
| ---------------------------------------------- | ------------------------------------------------------------------ |
| `file`                                         | Identify type by magic bytes                                       |
| `strings`                                      | Dump printable strings                                             |
| `xxd`                                          | Hex dump                                                           |
| `binwalk`                                      | Find and extract embedded files                                    |
| `foremost`                                     | Carve files by signature                                           |
| `exiftool`                                     | Read and edit metadata                                             |
| [CyberChef](https://gchq.github.io/CyberChef/) | Browser multi-tool for encode, decode, decrypt; Magic auto-detects |

## OSINT

| Tool                                                               | What it does                                                        |
| ------------------------------------------------------------------ | ------------------------------------------------------------------- |
| `sherlock`                                                         | Find a username across sites                                        |
| `whois`                                                            | Domain registration lookup                                          |
| `dig`                                                              | DNS record lookup (TXT, MX, CNAME)                                  |
| [crt.sh](https://crt.sh/)                                          | Subdomains via certificate logs                                     |
| [Wayback Machine](https://web.archive.org/)                        | Archived page versions                                              |
| [Shodan](https://shodan.io/)                                       | Internet host/service search                                        |
| [Google dorks](https://www.exploit-db.com/google-hacking-database) | `site:` `filetype:` `inurl:` `intitle:` to find exposed files/pages |

## Web

| Tool           | What it does                                |
| -------------- | ------------------------------------------- |
| Burp Suite     | Intercepting proxy; inspect and replay HTTP |
| `ffuf`         | Fast fuzzer for dirs, files, params         |
| `gobuster`     | Directory and DNS brute force               |
| `sqlmap`       | Automated SQL injection                     |
| `curl`         | Scripted HTTP requests                      |
| `flask-unsign` | Crack and forge Flask session cookies       |

## Network forensics

| Tool          | What it does                                |
| ------------- | ------------------------------------------- |
| Wireshark     | GUI packet analysis                         |
| `tshark`      | CLI Wireshark; filter and extract           |
| `capinfos`    | Summary of a capture (ships with Wireshark) |
| `pcapfix`     | Repair broken pcap files                    |
| `aircrack-ng` | Crack WPA/WEP from a capture                |

## Crypto

| Tool                           | What it does                    |
| ------------------------------ | ------------------------------- |
| [dCode](https://www.dcode.fr/) | Cipher identifier and solvers   |
| RsaCtfTool                     | Automated RSA attacks           |
| `hashid`                       | Identify a hash type            |
| `hashcat`                      | GPU hash cracking               |
| `john`                         | CPU hash and password cracking  |
| `xortool`                      | Recover repeating XOR keys      |
| pycryptodome / sympy / gmpy2   | Python crypto and number theory |

## File & disk forensics

| Tool                             | What it does                              |
| -------------------------------- | ----------------------------------------- |
| Autopsy                          | GUI disk-image forensics                  |
| Sleuth Kit (`mmls`/`fls`/`icat`) | CLI disk image: partitions, list, recover |
| `ouch`                           | Auto-extract any archive by type (`ouch d file`)            |
| `fcrackzip`                      | Crack password-protected zips             |
| `7z`                             | Extract many archive formats              |
| `pdfinfo` / `pdftotext`          | PDF metadata and text (poppler)           |
| `olevba`                         | Extract Office macros (oletools)          |
| Volatility 3                     | Memory dump forensics                     |

## Stego

| Tool                                                             | What it does                                                                    |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| [Aperi'Solve](https://www.aperisolve.com/)                       | Runs zsteg, steghide, binwalk, bit planes in one pass                           |
| [stego-toolkit](https://github.com/dominicbreuker/stego-toolkit) | Docker image with most stego tools preinstalled; `docker pull` before the event |
| `zsteg`                                                          | LSB stego in PNG, BMP                                                           |
| `steghide`                                                       | Hide/extract data in JPG, WAV (password)                                        |
| `stegseek`                                                       | Brute-force steghide passphrases                                                |
| StegSolve                                                        | Browse bit planes and color maps                                                |
| `zbarimg`                                                        | Decode QR and barcodes                                                          |
| `pngcheck`                                                       | Validate and inspect PNG chunks                                                 |
| `ffmpeg`                                                         | Split video frames, dump streams                                                |
| Audacity / Sonic Visualiser                                      | Audio editing and spectrogram                                                   |

## Reverse engineering

| Tool                | What it does                              |
| ------------------- | ----------------------------------------- |
| Ghidra              | Disassembler and decompiler               |
| `radare2`           | CLI disassembler, debugger, patcher       |
| `gdb` + pwndbg      | Dynamic analysis and debugging            |
| `ltrace` / `strace` | Trace library and system calls            |
| `upx`               | Unpack UPX-packed binaries                |
| angr / z3           | Symbolic execution and constraint solving |
| `jadx` / `apktool`  | Decompile and unpack Android APKs         |

## Pwn

| Tool                          | What it does                                           |
| ----------------------------- | ------------------------------------------------------ |
| `pwntools`                    | Python exploit framework (`checksec`, `cyclic`, `ROP`) |
| `gdb` + pwndbg                | Debug and develop the exploit                          |
| `ROPgadget`                   | Find ROP gadgets in a binary                           |
| `one_gadget`                  | Find one-shot libc `execve` gadgets                    |
| [libc.rip](https://libc.rip/) | Identify libc from leaked addresses                    |
