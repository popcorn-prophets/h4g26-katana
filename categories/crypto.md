# Crypto & encoding

_Scrambled text or numbers you must reverse. Encoding is reversible with no key; a cipher needs a key or a weakness._

Deep ref: [`ctf-crypto` skill](../.agents/skills/ctf-crypto/SKILL.md). Primers: [CyberChef](https://gchq.github.io/CyberChef/), [dCode](https://www.dcode.fr/), [CryptoHack](https://cryptohack.org/).

## First moves

1. Paste into [CyberChef](https://gchq.github.io/CyberChef/), run **Magic** (auto-detects encodings/ciphers). Scripting it? [`chepy`](https://github.com/securisec/chepy) is CyberChef as a CLI/Python lib.
2. Paste into [dCode cipher identifier](https://www.dcode.fr/cipher-identifier) for classical ciphers.
3. Count the character set: only `A-Z` = classical; `A-Za-z0-9+/=` = base64; `0-9a-f` = hex; huge number = RSA.
4. Hash-shaped? `hashid '<string>'`, then look it up ([crackstation](https://crackstation.net/)).

## Triggers

| Seeing                                   | Pattern                               |
| ---------------------------------------- | ------------------------------------- |
| Letters shifted, looks readable-ish      | [Classical cipher](#classical-cipher) |
| `A-Za-z0-9+/=`, `0-9a-f`, dots/dashes    | [Encoding](#encoding)                 |
| Two ciphertexts, or a repeating key hint | [XOR](#xor)                           |
| `n`, `e`, `c` given (big integers)       | [RSA](#rsa)                           |
| 32/40/64 hex chars, "crack this"         | [Hash](#hash)                         |
| Repeating blocks in ciphertext           | [AES ECB](#aes-ecb)                   |
| Padding error oracle, IV given           | [AES CBC](#aes-cbc)                   |

## Plays

### Classical cipher

**Confirm:** only letters, roughly word-shaped, or dCode identifies it.

**Steps:**

1. Caesar/ROT: try all 25 shifts (CyberChef **ROT13 Brute Force**).
2. Vigenere: need a key; [dCode Vigenere](https://www.dcode.fr/vigenere-cipher) with automatic analysis (Kasiski).
3. Substitution: [quipqiup](https://quipqiup.com/) for frequency solving.
4. Atbash, rail fence, etc.: dCode has a solver each.

**Example:** title "Shift happens" points to Caesar; brute-forcing shifts lands on `H4G{caesar_shift}`.

**Gotchas:** title/filename usually names the cipher. The flag prefix `H4G{` is your crib to confirm the right shift/key.

### Encoding

_Reversible transforms, no key needed._

**Steps:**

1. base64 (`A-Za-z0-9+/=`): `base64 -d`, or CyberChef.
2. hex (`0-9a-f`): **From Hex**. binary (`01` groups): **From Binary**.
3. Morse (dots/dashes), base32, base58, base85: CyberChef has each.
4. Chained? Keep decoding; **Magic** with "intensive" follows multiple layers.

**Example:** base64 → hex → ascii gives `H4G{layered_encoding}`.

**Gotchas:** base64 ending `=` and length multiple of 4 is the tell. Decode order matters; Magic finds it.

### XOR

**Confirm:** ciphertext same length as guessed plaintext, or two messages with one key.

**Steps:**

1. Known prefix: `xor(ciphertext, b'H4G{')` reveals key bytes (pwntools `from pwn import xor`).
2. Single-byte key: brute 0-255, look for printable output.
3. Repeating key: [xortool](https://github.com/hellman/xortool) `xortool -c 20 file`.
4. Two ciphertexts, same key (many-time pad): XOR them together, crib-drag.

**Example:** single-byte XOR 0x42 over the blob prints `H4G{xor_key}`.

**Gotchas:** flag prefix is the crib. CyberChef **XOR Brute Force** covers single-byte fast.

### RSA

**Confirm:** you're given `n`, `e`, `c` (and maybe `p`, `q`).

**Steps:**

1. Throw it at [RsaCtfTool](https://github.com/RsaCtfTool/RsaCtfTool): `python3 RsaCtfTool.py -n N -e E --uncipher C`.
2. Small `n` → factor: [factordb](https://factordb.com/) or `sympy.factorint(n)`.
3. Small `e` (3) + small message → cube root of `c`.
4. Given `p`,`q` → compute `d` directly and decrypt.

**Example:** factordb splits `n`, compute `d`, decrypt `c` → `H4G{textbook_rsa}`.

**Gotchas:** convert the final integer to bytes (`long_to_bytes`). Advanced variants (Wiener, common modulus, Hastad) in [rsa-attacks.md](../.agents/skills/ctf-crypto/rsa-attacks.md).

### Hash

**Confirm:** fixed-length hex (32=MD5, 40=SHA1, 64=SHA256).

**Steps:**

1. Look it up first: [crackstation](https://crackstation.net/), Google the hash.
2. Crack: `hashcat -m <mode> hash.txt /usr/share/wordlists/rockyou.txt` (`hashid` gives the mode).
3. `john hash.txt --wordlist=rockyou.txt`.

**Example:** SHA256 of a weak password reverses on crackstation to `H4G{...}`.

**Gotchas:** salted hashes need the salt and the right hashcat mode. Don't burn time cracking strong hashes; it's probably not the path.

### AES ECB

_Electronic Codebook: identical plaintext blocks encrypt to identical ciphertext blocks._

**Confirm:** repeating 16-byte blocks in the ciphertext.

**Steps:**

1. Spot repeats: hex-dump, look for duplicate 16-byte chunks.
2. Byte-at-a-time: if you control part of the input (an oracle), leak the secret one byte per request.
3. Cut-and-paste: rearrange ciphertext blocks to forge a valid message.

**Example:** controlled prefix leaks the appended secret byte by byte → `H4G{ecb_oracle}`.

**Gotchas:** ECB = no IV, deterministic. Full method in [modern-ciphers-2.md](../.agents/skills/ctf-crypto/modern-ciphers-2.md).

### AES CBC

**Confirm:** an IV is given, and errors differ on bad padding (a padding oracle).

**Steps:**

1. Bit-flip: flip a byte in a ciphertext block to flip the matching plaintext byte in the next block (auth/role bypass).
2. Padding oracle: decrypt a block byte by byte using the server's padding error ([padbuster](https://github.com/AonCyberLabs/PadBuster) or a script).

**Example:** flip the IV to turn `admin=0` into `admin=1`, or oracle-decrypt to `H4G{cbc_oracle}`.

**Gotchas:** needs a distinguishable padding error. See [modern-ciphers.md](../.agents/skills/ctf-crypto/modern-ciphers.md).

## Gotchas (all crypto)

- Identify before attacking. CyberChef Magic and dCode save most of the time.
- The flag prefix `H4G{` is a crib for XOR, shift, and key confirmation.
- Convert integers to bytes at the end; the flag is ASCII.
- Regional-level crypto is usually classical, encoding, or textbook RSA. Don't reach for lattices first.
