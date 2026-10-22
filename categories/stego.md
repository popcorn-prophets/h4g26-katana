# Stego

_Steganography: data hidden inside an image, audio, or video so the file still looks normal. (Hidden in a filesystem, archive, or appended to a file is [file forensics](file-forensics.md).)_

Deep ref: [`ctf-forensics` stego notes](../.agents/skills/ctf-forensics/steganography.md). Primers: [HackTricks Stego Tricks](https://book.hacktricks.wiki/en/stego/stego-tricks.html), [Aperi'Solve](https://www.aperisolve.com/) (runs many image tools at once).

## First moves

1. `file x`, `exiftool x`, `strings -n 6 x | grep -i 'H4G{'`. Metadata and cleartext first.
2. `binwalk x`. Appended/embedded file is file forensics, not stego.
3. Image → drop it in [Aperi'Solve](https://www.aperisolve.com/). It runs zsteg, steghide, binwalk, bit planes in one pass.
4. Audio → open the spectrogram in [Sonic Visualiser](https://www.sonicvisualiser.org/) or Audacity.

## Triggers

| Seeing                                  | Pattern                              |
| --------------------------------------- | ------------------------------------ |
| PNG / BMP                               | [LSB & bit planes](#lsb--bit-planes) |
| JPG / WAV, maybe a password hint        | [steghide](#steghide)                |
| Audio file                              | [Audio stego](#audio-stego)          |
| Odd colors, flat regions, "look closer" | [Visual tricks](#visual-tricks)      |
| Video                                   | [Video stego](#video-stego)          |
| QR / barcode in the image               | [QR / barcode](#qr--barcode)         |

## Plays

### LSB & bit planes

_Least Significant Bit: the lowest bit of each pixel carries hidden data, invisible to the eye._

**Confirm:** a lossless image (PNG, BMP). JPG rarely holds clean LSB.

**Steps:**

1. `zsteg -a x.png` tries every LSB layout and channel at once.
2. Browse bit planes in [StegSolve](https://github.com/zardus/ctf-tools/tree/master/stegsolve) (arrow through planes; data pops on one).
3. Specific channel/bit: `zsteg x.png -E 'b1,rgb,lsb,xy'` to extract.

**Example:** `zsteg -a x.png` prints a line containing `H4G{lsb_png}`.

**Gotchas:** try bit 1, not just bit 0. Aperi'Solve runs zsteg + planes for you.

### steghide

**Confirm:** JPG or WAV, often with a password hint in the challenge.

**Steps:**

1. No password / guessed one: `steghide extract -sf x.jpg -p ''`.
2. Crack it: `stegseek x.jpg /usr/share/wordlists/rockyou.txt`.
3. Check what came out with `file`.

**Example:** `stegseek` finds passphrase `password`, drops `secret.txt` = `H4G{steghide_cracked}`.

**Gotchas:** steghide only does JPG/BMP/WAV/AU. stegseek is far faster than brute-forcing by hand.

### Audio stego

**Confirm:** a WAV/MP3, especially if it sounds like noise or tones.

**Steps:**

1. Spectrogram first: Sonic Visualiser / Audacity. Text or a QR often shows as an image.
2. DTMF / dial tones: decode the touch-tones (dCode or a DTMF decoder).
3. Morse: listen or read the waveform.
4. LSB in samples: try [WavSteg](https://github.com/ragibson/Steganography) / DeepSound (DeepSound needs a password).

**Example:** the spectrogram spells `H4G{hidden_in_sound}`.

**Gotchas:** choose a log frequency scale and zoom. Stereo channels may differ; check both.

### Visual tricks

**Confirm:** flat color areas, odd palette, "look closer", or a seemingly plain image.

**Steps:**

1. StegSolve color maps and plane views to surface low-contrast text.
2. Shrink/grow contrast, invert, or isolate one channel (CyberChef, GIMP).
3. Transparency: flatten alpha; text may hide in a near-invisible layer.
4. PNG IHDR: an image cropped short hides pixels below. Fix the height.

**Example:** inverting the red channel reveals `H4G{channel_swap}`.

**Gotchas:** cheap wins: max contrast, invert, split channels. Do these before heavy tools.

### Video stego

**Confirm:** an MP4/MKV/GIF.

**Steps:**

1. `ffmpeg -i x.mp4 frames/%04d.png` then scan frames (one may hold the flag or a QR).
2. Extra streams/subtitles: `ffprobe x.mkv`, `ffmpeg` to dump each stream.
3. Audio track → [audio stego](#audio-stego). Frame diffs (GIF) may blink Morse.

**Example:** one extracted frame contains `H4G{frame_by_frame}`.

**Gotchas:** check every stream in the container, not just video. GIFs: diff consecutive frames.

### QR / barcode

**Steps:**

1. Decode: `zbarimg x.png`, or [ZXing online](https://zxing.org/w/decode.jspx).
2. Damaged/partial: reconstruct in GIMP (fix finder squares, contrast) then decode; QR error-correction fills gaps.
3. Rotated/mirrored: flip and retry.

**Example:** `zbarimg` reads the QR to `H4G{scan_me}`.

**Gotchas:** a QR split across frames or color channels must be reassembled first.

## Gotchas (all stego)

- Metadata and `strings` before any stego tool. Many "stego" flags are just in EXIF.
- Image: run Aperi'Solve, it covers the common cases in one shot.
- Audio: always check the spectrogram.
- Appended or embedded file = [file forensics](file-forensics.md), not stego.
