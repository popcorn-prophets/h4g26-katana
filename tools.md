# Tools

Install before the event. Keep tools, wordlists, and CyberChef offline. Usage goes in the category notes.

Base OS: [Kali](https://www.kali.org/docs/). Most tools below are preinstalled.

```sh
sudo apt update && sudo apt install -y \
  wireshark tshark binwalk foremost libimage-exiftool-perl pngcheck \
  steghide zbar-tools john hashcat ffuf gobuster sqlmap seclists sherlock ghidra
sudo gunzip /usr/share/wordlists/rockyou.txt.gz
```

Not in apt: `pipx install pwntools volatility3`, `sudo gem install zsteg`, stegseek (`.deb`), [CyberChef](https://github.com/gchq/CyberChef/releases) (download zip), [RsaCtfTool](https://github.com/RsaCtfTool/RsaCtfTool) (git clone).

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

| Tool                                        | What it does                    |
| ------------------------------------------- | ------------------------------- |
| `sherlock`                                  | Find a username across sites    |
| `whois`                                     | Domain registration lookup      |
| [crt.sh](https://crt.sh/)                   | Subdomains via certificate logs |
| [Wayback Machine](https://web.archive.org/) | Archived page versions          |
| [Google dorks](https://www.exploit-db.com/google-hacking-database) | `site:` `filetype:` `inurl:` `intitle:` operators to find exposed files and pages |

## Web

| Tool       | What it does                                |
| ---------- | ------------------------------------------- |
| Burp Suite | Intercepting proxy; inspect and replay HTTP |
| `ffuf`     | Fast fuzzer for dirs, files, params         |
| `gobuster` | Directory and DNS brute force               |
| `sqlmap`   | Automated SQL injection                     |
| `curl`     | Scripted HTTP requests                      |

## Network forensics

| Tool      | What it does                      |
| --------- | --------------------------------- |
| Wireshark | GUI packet analysis               |
| `tshark`  | CLI Wireshark; filter and extract |

## Crypto

| Tool                           | What it does                   |
| ------------------------------ | ------------------------------ |
| [dCode](https://www.dcode.fr/) | Cipher identifier and solvers  |
| RsaCtfTool                     | Automated RSA attacks          |
| `hashcat`                      | GPU hash cracking              |
| `john`                         | CPU hash and password cracking |

## Stego and file forensics

| Tool       | What it does                             |
| ---------- | ---------------------------------------- |
| `steghide` | Hide/extract data in JPG, WAV (password) |
| `stegseek` | Brute-force steghide passphrases         |
| `zsteg`    | LSB stego in PNG, BMP                    |
| `pngcheck` | Validate and inspect PNG chunks          |
| `zbarimg`  | Decode QR and barcodes                   |

## Reversing and pwn

| Tool         | What it does                |
| ------------ | --------------------------- |
| Ghidra       | Disassembler and decompiler |
| `pwntools`   | Python exploit framework    |
| Volatility 3 | Memory dump forensics       |
