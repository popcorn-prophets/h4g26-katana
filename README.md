# h4g26-katana

CTF playbook for Hack4Gov 2026. Find the signal, name the pattern, try the approach.

## Index

- [`methodology.md`](methodology.md): triage and team workflow
- Categories: [OSINT](categories/osint.md), [web](categories/web.md), [network forensics](categories/network-forensics.md), [crypto](categories/crypto.md), [stego and file forensics](categories/stego-forensics.md), [misc](categories/misc.md)
- [`tools.md`](tools.md): install checklist
- [`writeups/`](writeups/): external writeups
- [`event-briefer.md`](event-briefer.md): rules and scope

## First pass on any file

```sh
file x; exiftool x; strings -n 6 x | less; binwalk x; xxd x | head
```

For odd text, try [CyberChef](https://gchq.github.io/CyberChef/) Magic and the [dCode cipher identifier](https://www.dcode.fr/cipher-identifier).

## References

- [JohnHammond/katana](https://github.com/JohnHammond/katana)
- [CTF 101](https://ctf101.org/)
- [HackTricks](https://book.hacktricks.wiki/)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
