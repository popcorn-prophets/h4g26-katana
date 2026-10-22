# Reverse engineering

_You get a program. Work out what it does to recover a flag it checks, prints, or builds. Understand first; exploiting memory bugs is [pwn](pwn.md)._

Deep ref: [`ctf-reverse` skill](../.agents/skills/ctf-reverse/SKILL.md). Primers: [HackTricks Reversing](https://book.hacktricks.wiki/en/reversing/reversing-tools-basic-methods/index.html), [crackmes.one](https://crackmes.one/) for practice.

## First moves

1. `file x`. Architecture, stripped or not, language, packer.
2. `strings -n 6 x | grep -iE 'H4G\{|flag|pass|correct|wrong'`. Flag or the compare strings often sit in cleartext.
3. Run it (in a VM): see what input it wants and how it responds.
4. `ltrace ./x` and `strace ./x`. A `strcmp` against your input leaks the expected value.
5. Load in [Ghidra](https://ghidra-sre.org/) and read `main` in the decompiler.

## Triggers

| Seeing                         | Pattern                                  |
| ------------------------------ | ---------------------------------------- |
| Native ELF/EXE, asks for input | [Static analysis](#static-analysis)      |
| `strcmp`/`strncmp` in `ltrace` | [Compare leak](#compare-leak)            |
| Input transformed then checked | [Reverse the check](#reverse-the-check)  |
| "wrong" branch blocks the flag | [Patching](#patching)                    |
| `file` says UPX / high entropy | [Packed](#packed)                        |
| .NET, Java, Python, Go, WASM   | [Managed & bytecode](#managed--bytecode) |
| `.apk`                         | [Android](#android)                      |

## Plays

### Static analysis

**Confirm:** a native binary; you want to read the logic without running it.

**Steps:**

1. Ghidra: auto-analyze, open `main`, read the decompiled C.
2. Rename variables as you understand them; follow the input to the check.
3. Identify the win condition: what makes it print the flag or "correct".
4. `radare2`/`objdump -d` for a quick disassembly when Ghidra is overkill.

**Example:** `main` XORs input with a constant and compares to a byte array; reversing it yields `H4G{static_re}`.

**Gotchas:** stripped binary has no `main` label; start from `entry`/the libc `__libc_start_main` arg. Read the decompiler, not just assembly.

### Compare leak

**Confirm:** the program compares your input to the real value as a whole string.

**Steps:**

1. `ltrace ./x` and type anything. Watch for `strcmp("yours", "SECRET")`.
2. The second argument is the password/flag.
3. No ltrace output (static binary)? Set a breakpoint on the compare in gdb and read the register.

**Example:** `ltrace` shows `strcmp("test", "H4G{ltrace_win}")`.

**Gotchas:** per-character or hashed comparison defeats this; move to [reverse the check](#reverse-the-check).

### Reverse the check

**Confirm:** input is transformed (math, XOR, per-char loop) before comparison.

**Steps:**

1. Read the transform in Ghidra; note the operations and constants.
2. Invert it: if it does `input ^ k == target`, then `flag = target ^ k`.
3. Non-invertible or messy? Let [angr](https://angr.io/) or [Z3](https://github.com/Z3Prover/z3) solve for the input that reaches "correct".

**Example:** loop checks `in[i] + i == const[i]`; solving gives `H4G{solved_constraints}`.

**Gotchas:** watch index order and off-by-one. Z3 is faster than hand-inverting a tangled check.

### Patching

**Confirm:** a conditional jump gates the flag and you just need it to take the win branch.

**Steps:**

1. Find the branch in Ghidra/radare2 (`je`/`jne` after the check).
2. Patch: flip the jump or NOP it so it always "succeeds".
   - radare2: `r2 -w x`, seek, `wa nop` or rewrite the opcode.
3. Run the patched binary; it prints the flag.

**Example:** NOP the `jne` after the password check so it always prints `H4G{patched}`.

**Gotchas:** patching reveals a path, not always the flag itself; if the flag is computed from the key, reverse the check instead.

### Packed

**Confirm:** `file`/entropy says packed, few strings, a `UPX!` marker.

**Steps:**

1. UPX: `upx -d x` to unpack, then analyze normally.
2. Other packers: run under a debugger, dump memory after it unpacks itself.

**Example:** `upx -d` restores readable code; Ghidra then shows the flag logic.

**Gotchas:** custom packers won't `upx -d`; dump from memory after the unpack stub runs.

### Managed & bytecode

_Compiled from a higher-level language; often decompiles almost to source._

**Steps:**

1. .NET (`.exe`/`.dll`): [dnSpy](https://github.com/dnSpy/dnSpy) / ILSpy decompile to C#.
2. Java (`.jar`/`.class`): [jd-gui](http://java-decompiler.github.io/) / CFR.
3. Python (`.pyc`): [decompyle3](https://github.com/rocky/python-decompile3) / uncompyle6; PyInstaller EXE → `pyinstxtractor` first.
4. Go: stripped but [GoReSym](https://github.com/mandiant/GoReSym) recovers symbols.
5. WASM (`.wasm`): `wasm2wat` to read text form.

**Example:** dnSpy shows the C# method returning `H4G{dotnet_decompiled}`.

**Gotchas:** match the Python version for pyc decompilers. Go binaries are large; GoReSym makes `main.main` findable.

### Android

**Confirm:** an `.apk`.

**Steps:**

1. [jadx](https://github.com/skylot/jadx) decompiles the APK to Java; read `MainActivity`.
2. Strings and resources: `apktool d x.apk`, check `res/`, `assets/`, `strings.xml`.
3. Native `.so` inside → treat as a normal ELF ([static analysis](#static-analysis)).

**Example:** jadx shows the flag check in `MainActivity.onClick`.

**Gotchas:** logic may be in a bundled `.so` or fetched at runtime, not in Java.

## Gotchas (all reverse)

- `strings` + `ltrace` + `strace` solve easy ones before you open a decompiler.
- Read Ghidra's decompiled C, not raw assembly, unless you have to.
- Run unknown binaries only in a VM.
- Stuck on a transform? Let Z3/angr solve it instead of inverting by hand.
