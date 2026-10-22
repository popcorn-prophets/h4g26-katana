# Pwn

_Binary exploitation: abuse a memory bug in a running program to hijack it and read the flag. You usually get the binary plus a remote `nc host port`. Understanding the binary first is [reverse](reverse.md)._

Deep ref: [`ctf-pwn` skill](../.agents/skills/ctf-pwn/SKILL.md). Primers: [pwn.college](https://pwn.college/), [Nightmare](https://guyinatuxedo.github.io/), [pwntools docs](https://docs.pwntools.com/).

## First moves

1. `checksec --file=./x`. Shows NX, PIE, canary, RELRO. They decide which attack is possible.
2. `file ./x` and run it: what input does it read, how much, what prints.
3. Decompile `main` in Ghidra ([reverse](reverse.md)) to find the vulnerable read and buffer size.
4. `strings`/Ghidra for a `win`/`system`/`/bin/sh` already in the binary. Often the whole challenge.
5. Scaffold pwntools early:
   ```python
   from pwn import *
   e = ELF('./x'); context.binary = e
   p = process('./x')   # swap for remote('host', port)
   ```

## Triggers

| Seeing                                              | Pattern                             |
| --------------------------------------------------- | ----------------------------------- |
| `gets`/`read` into a small buffer, a `win()` exists | [ret2win](#ret2win)                 |
| Overflow, no `win`, `system`/libc available         | [ret2libc](#ret2libc)               |
| `printf(user_input)` directly                       | [Format string](#format-string)     |
| Canary present, overflow                            | [Leak the canary](#leak-the-canary) |
| NX off, you can jump to your input                  | [Shellcode](#shellcode)             |
| Overflow but need gadgets (NX on)                   | [ROP](#rop)                         |
| `malloc`/`free`, use-after-free, double free        | [Heap](#heap)                       |

## Plays

### ret2win

_Overflow the return address to jump to a win function that's already in the binary._

**Confirm:** a `read`/`gets` with no bound, and a function that prints the flag or calls `system("/bin/sh")`.

**Steps:**

1. Find the offset to the return address: send a [cyclic](https://docs.pwntools.com/en/stable/util/cyclic.html) pattern, crash, read the faulting value, `cyclic_find(...)`.
2. Build: `payload = b'A'*offset + p64(win_addr)`.
3. Stack alignment: if it crashes in `system`, add a `ret` gadget before `win`.

**Example:** `offset=40`, `p64(e.sym.win)` → shell → `cat flag.txt` → `H4G{ret2win}`.

**Gotchas:** 64-bit needs 16-byte stack alignment; a bare `ret` gadget fixes a `movaps` crash.

### ret2libc

**Confirm:** overflow, no `win`, NX on, but you can call libc functions.

**Steps:**

1. Leak a libc address: ROP to `puts(puts@got)`, then return to `main`.
2. Identify libc version from the leak ([libc.rip](https://libc.rip/)) if not given.
3. Second payload: compute `system` and `/bin/sh` from the leaked base, ROP `system("/bin/sh")`.

**Example:** leaked `puts` → libc base → `system('/bin/sh')` → `H4G{ret2libc}`.

**Gotchas:** use the exact remote libc. pwntools `ROP(e)` and `libc.address = leak - libc.sym.puts` do the math.

### Format string

_A `printf` on your input lets you read and write memory._

**Confirm:** your input is printed back and `%p %p %p` leaks stack values.

**Steps:**

1. Read: `%p`/`%x` to leak stack, `%s` to deref, find your buffer's arg index (`%7$p`).
2. Leak the flag/canary/libc from the stack directly if it's there.
3. Write: `%n` family to overwrite a GOT entry or return address; pwntools `fmtstr_payload`.

**Example:** `%7$s` on a pointer prints the flag; or `fmtstr_payload` redirects a GOT entry to `win`.

**Gotchas:** find your arg offset first. `fmtstr_payload(offset, {addr: value})` builds the write.

### Leak the canary

**Confirm:** `checksec` shows a stack canary and you have a leak primitive.

**Steps:**

1. Leak the canary (format string, or an overflow that prints past it).
2. Include it unchanged in the overflow: `b'A'*off + p64(canary) + b'B'*8 + p64(target)`.

**Example:** leaked canary preserved, overflow to `win` → `H4G{canary_bypass}`.

**Gotchas:** canary's low byte is `00`. Leak it, don't guess; re-leak if it changes per run.

### Shellcode

**Confirm:** NX disabled (`checksec` says "NX: No"), and your input lands at a known/leakable address.

**Steps:**

1. Build shellcode: `asm(shellcraft.sh())` with the right `context.arch`.
2. Put it in the buffer, overwrite return to its address.
3. Address unknown? Leak it, or jump via a register pointing at the buffer (`jmp rsp`/`call rax` gadget).

**Example:** shellcode in buffer, ret to it → shell → `H4G{shellcode}`.

**Gotchas:** NX on makes this impossible; use ROP instead. Avoid bad bytes (`\x00`, `\x0a`).

### ROP

_Return-Oriented Programming: chain existing code snippets ("gadgets") ending in `ret` to run your logic without injecting code._

**Confirm:** overflow, NX on, no single `win` that finishes the job.

**Steps:**

1. Find gadgets: `ROPgadget --binary ./x`, or pwntools `ROP(e)`.
2. Common goal: set up registers for `execve("/bin/sh")` or a `syscall`.
3. Build with pwntools: `rop = ROP(e); rop.call('system', [bin_sh]); payload = b'A'*off + rop.chain()`.

**Example:** ROP chain to `system('/bin/sh')` → `H4G{rop_chain}`.

**Gotchas:** keep the stack aligned. Start from pwntools `ROP`; hand-build only when it can't.

### Heap

**Confirm:** menu-driven allocator with malloc/free, and a use-after-free, double free, or overflow.

**Steps:**

1. Map the menu: which option allocates, frees, writes, prints.
2. Classic bugs: UAF to read/write a freed chunk; double free to poison the tcache and get an arbitrary allocation.
3. Target `__free_hook`/`__malloc_hook` (old glibc) or a function pointer, point it at `system`.

**Example:** tcache poisoning returns a chunk over a hook → `system('/bin/sh')` → `H4G{heap}`.

**Gotchas:** heap is glibc-version-sensitive and the hardest tier; attempt last. Deep techniques in [heap-techniques.md](../.agents/skills/ctf-pwn/heap-techniques.md).

## Gotchas (all pwn)

- `checksec` first; the protections pick the attack.
- Find the offset with a cyclic pattern, never by guessing.
- Develop against local `process()`, then flip to `remote()`. Match the remote libc exactly.
- Let pwntools do the work: `ELF`, `ROP`, `fmtstr_payload`, `cyclic`, `shellcraft`.
