# File & disk forensics

_You get a file, archive, disk image, or memory dump. The flag is inside: hidden, deleted, embedded, or in metadata. (Data hidden in pixels/audio is [stego](stego.md).)_

Deep ref: [`ctf-forensics` skill](../.agents/skills/ctf-forensics/SKILL.md). Primers: [HackTricks Forensics](https://book.hacktricks.wiki/en/forensics/basic-forensic-methodology/index.html), [Sleuth Kit docs](https://sleuthkit.org/sleuthkit/docs.php).

## First moves

1. `file x` then `exiftool x`. Wrong/forged extension and metadata solve many challenges outright.
2. `binwalk x`. Embedded files? `binwalk -e x` to extract.
3. `strings -n 6 x | grep -i 'H4G{'`. Flag may sit in cleartext.
4. `xxd x | head`. Check the real magic bytes against the extension.

## Triggers

| Seeing                                      | Pattern                                              |
| ------------------------------------------- | ---------------------------------------------------- |
| `.zip`, `.rar`, `.7z`, `.tar.gz`            | [Archive](#archive)                                  |
| `.dd`, `.E01`, `.img`, `.raw`, "disk image" | [Disk image](#disk-image)                            |
| File that won't open, odd magic bytes       | [Corrupt / wrong type](#corrupt--wrong-type)         |
| `binwalk` shows embedded files              | [Carving](#carving)                                  |
| `.pdf`, `.docx`, `.xlsx`                    | [Documents](#documents)                              |
| `.raw`/`.mem`/`.vmem`, "memory dump"        | [Memory dump](#memory-dump)                          |
| `.pcap`                                     | network forensics → [see page](network-forensics.md) |

## Plays

### Archive

**Confirm:** a compressed archive, maybe password-protected or nested.

**Steps:**

1. Extract: `unzip x.zip`, `7z x x.7z`, `tar xf x.tar.gz`.
2. Password-protected zip: `fcrackzip -u -D -p rockyou.txt x.zip`, or `zip2john x.zip > h && john h`.
3. Nested ("matryoshka"): script a loop that keeps extracting.
4. `binwalk`/`strings` the archive itself for appended data.

**Example:** `zip2john` + john cracks the password → unzip → `H4G{zip_cracked}`.

**Gotchas:** a zip with one wrong byte in the header still extracts with `binwalk` or after repair. Check for data after the archive's end.

### Disk image

_A copy of a filesystem. Browse it, recover deleted files, read the timeline._

**Confirm:** `.dd`, `.E01`, `.img`, `.raw`, or `file` says "filesystem".

**Steps:**

1. GUI: open in [Autopsy](https://www.autopsy.com/) for browsing, deleted files, keyword search, timeline.
2. CLI (Sleuth Kit):
   - `mmls x.dd` list partitions and offsets.
   - `fls -r -o <offset> x.dd` list files, including deleted (marked `*`).
   - `icat -o <offset> x.dd <inode> > out` extract a file by inode.
   - `tsk_recover -e -o <offset> x.dd outdir` dump everything.
3. Or mount read-only: `sudo mount -o ro,loop,offset=$((512*OFFSET)) x.dd /mnt`.

**Example:** `fls` shows a deleted `flag.txt`; `icat` by its inode prints `H4G{deleted_but_recovered}`.

**Gotchas:** deleted files show with `*` in `fls`. Use the partition offset from `mmls` on every Sleuth Kit command.

### Corrupt / wrong type

**Confirm:** a file that won't open, or magic bytes that don't match the extension.

**Steps:**

1. `xxd x | head` and compare the header to the [magic-byte list](https://en.wikipedia.org/wiki/List_of_file_signatures).
2. Wrong extension → rename and open (a "PNG" that's really a zip).
3. Broken header → fix the magic bytes in a hex editor (`PNG\r\n`, `PK\x03\x04`, `%PDF`).
4. `pngcheck -v x.png` pinpoints bad PNG chunks.

**Example:** header is `PK` not `JPG`; rename to `.zip`, unzip, get the flag.

**Gotchas:** dimensions in a PNG IHDR can be shrunk to hide pixels; fix the height. Trailing junk after a valid file often is the payload.

### Carving

_Pulling embedded files out of a container file._

**Steps:**

1. `binwalk x` to see what's embedded, `binwalk -e x` to extract.
2. `foremost -i x -o out` carves by signature when binwalk misses.
3. Recurse: carved files may themselves hide more.

**Example:** `binwalk -e cover.jpg` extracts an appended zip containing `H4G{appended_zip}`.

**Gotchas:** binwalk extraction lands in `_x.extracted/`. If it refuses, carve the offset manually with `dd`.

### Documents

**Confirm:** PDF or Office file.

**Steps:**

1. Metadata: `exiftool x.pdf`, `pdfinfo x.pdf`.
2. PDF: `pdftotext`, `pdf-parser`/`peepdf` for objects, streams, embedded files, JS.
3. Office (`.docx`/`.xlsx` are zips): `unzip` and read the XML; check for macros (`olevba`).
4. `strings` for hidden/white text and object streams.

**Example:** `exiftool` on the PDF shows a custom field = `H4G{pdf_metadata}`.

**Gotchas:** text can be white-on-white or in an unrendered object. Office macros may build/decode the flag.

### Memory dump

**Confirm:** `.raw`/`.mem`/`.vmem` or "memory dump".

**Steps:**

1. Identify: `vol.py -f dump.raw windows.info` (Volatility 3).
2. Processes: `windows.pslist`, command lines: `windows.cmdline`.
3. Pull artifacts: `windows.filescan` + `windows.dumpfiles`, `windows.hashdump`, browser/clipboard plugins.
4. Fast win: `strings dump.raw | grep -i 'H4G{'`.

**Example:** `windows.cmdline` shows a command with the flag as an argument.

**Gotchas:** match the OS plugin set (`windows.*` vs `linux.*`). Volatility is heavy; try `strings` first.

## Gotchas (all file/disk)

- `file` + `exiftool` + `binwalk` + `strings` solves a large share before any deep tooling.
- Trust magic bytes over the extension.
- The payload is often appended after a valid file or in a deleted/slack region.
- Work on a copy; never carve the original.
