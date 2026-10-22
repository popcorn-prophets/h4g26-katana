#!/usr/bin/env bash
# CTF shell aliases and functions. Install: echo "source $(pwd)/aliases.sh" >> ~/.zshrc
# Set your flag prefix once; used by the grep helpers.
export FLAG="${FLAG:-H4G}"

## Triage
alias ll='ls -lah'
# triage FILE: file + exiftool + strings + binwalk + hexdump head in one go
triage() {
  file "$1"; echo; exiftool "$1"; echo
  strings -n 6 "$1" | head -40; echo
  binwalk "$1"; echo
  xxd "$1" | head
}
# fg FILE/DIR: grep the flag prefix (plain) recursively
fg() { grep -rniE "${FLAG}\{" "${1:-.}"; }
# fgx FILE: hunt the flag in a binary's strings
fgx() { strings -n 4 "$1" | grep -iE "${FLAG}\{|flag|pass"; }

## Encoding (pipe text in)
alias b64d='base64 -d'
alias b64e='base64 -w0'
alias unhex='xxd -r -p'
alias tohex='xxd -p | tr -d "\n"'
rot13() { tr 'A-Za-z' 'N-ZA-Mn-za-m'; }
urld() { python3 -c 'import sys,urllib.parse as u;print(u.unquote(sys.stdin.read()))'; }
# xorb HEX KEY: single-byte-or-repeating XOR via pwntools
xorb() { python3 -c "from pwn import xor;import sys;print(xor(bytes.fromhex('$1'),b'$2'))"; }

## Web
alias serve='python3 -m http.server 8000'          # serve cwd for file transfer
alias headers='curl -sS -D - -o /dev/null'          # headers FULL_URL
ffuz() { ffuf -u "$1/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/common.txt; }

## Network
alias nc='nc -v'
pcapstat() { capinfos "$1"; tshark -r "$1" -q -z io,phs; }  # protocol hierarchy

## Reverse / pwn
alias cs='checksec --file'
alias dis='objdump -d -M intel'
gdbp() { gdb -q "$@"; }   # assumes pwndbg sourced in ~/.gdbinit

## Crypto / hash
alias hid='hashid'
alias sage='sage'         # if installed

## Misc
# b2a BIN: binary string (01010...) to ASCII
b2a() { python3 -c "import sys;b=sys.argv[1].replace(' ','');print(''.join(chr(int(b[i:i+8],2)) for i in range(0,len(b),8)))" "$1"; }
