# Network forensics

_Analyzing captured traffic. You get a `.pcap`/`.pcapng`; the flag is in a transferred file, a credential, a decoded stream, or a hidden channel._

Deep ref: [`ctf-forensics` network notes](../.agents/skills/ctf-forensics/network.md). Primers: [Wireshark docs](https://www.wireshark.org/docs/), [HackTricks Pcap Inspection](https://book.hacktricks.wiki/en/generic-methodologies-and-resources/pentesting-network/pcap-inspection/index.html).

## First moves

1. `capinfos file.pcap`: size, packet count, time span, link type.
2. Wireshark → **Statistics > Protocol Hierarchy**. What protocols are present tells you the challenge type.
3. **Statistics > Conversations**: who talks to whom, biggest flows.
4. **File > Export Objects > HTTP**: pull transferred files in one click.
5. Broken file? `pcapfix -d file.pcap`.
6. Quick grep: `strings file.pcap | grep -i 'H4G{'`.

## Triggers

| Seeing                            | Pattern                                   |
| --------------------------------- | ----------------------------------------- |
| HTTP traffic, downloads/uploads   | [File extraction](#file-extraction)       |
| FTP/Telnet/HTTP logins, POSTs     | [Credential capture](#credential-capture) |
| Lots of odd DNS queries           | [DNS exfiltration](#dns-exfiltration)     |
| HTTPS/TLS, plus a key/log file    | [TLS decryption](#tls-decryption)         |
| `URB`/USB packets                 | [USB HID decode](#usb-hid-decode)         |
| 802.11 / WPA handshake            | [Wi-Fi decryption](#wi-fi-decryption)     |
| Regular ICMP/timing, weird fields | [Covert channel](#covert-channel)         |
| Readable app protocol (IRC, SMTP) | [Follow the stream](#follow-the-stream)   |

## Plays

### File extraction

**Confirm:** HTTP, FTP, SMB, or TFTP carrying a file.

**Steps:**

1. Wireshark: **File > Export Objects > HTTP** (or SMB/TFTP). Save everything.
2. CLI: `tshark -r f.pcap --export-objects http,./out`.
3. `file out/*` then inspect. The payload may itself need forensics (zip, image, stego).

**Example:** exported `secret.zip` → unzip → `flag.txt` = `H4G{exfil_over_http}`.

**Gotchas:** uploads are multipart POSTs, not just GET downloads. Reassemble split transfers in order.

### Credential capture

**Confirm:** a plaintext protocol with a login (FTP, Telnet, HTTP Basic, POST form, IMAP/POP).

**Steps:**

1. Filter: `ftp.request.command == "USER" || ftp.request.command == "PASS"`.
2. HTTP form: `http.request.method == "POST"`, read the body.
3. Right-click a packet → **Follow > TCP Stream** to see the whole exchange.

**Example:** Telnet stream shows `login: admin` / `pass: H4G{cleartext_creds}`.

**Gotchas:** HTTP Basic auth = base64 in the `Authorization` header; decode it.

### DNS exfiltration

_Data smuggled inside DNS query names._

**Confirm:** many queries to one domain with long/random subdomains.

**Steps:**

1. Filter `dns`, list query names: `tshark -r f.pcap -Y dns -T fields -e dns.qry.name`.
2. The subdomain labels are the payload. Strip the base domain.
3. Concatenate in order, then decode (hex, base32, base64).

**Example:** labels join to base64 → decode → `H4G{dns_tunnel}`.

**Gotchas:** dedupe retransmits. Tools like dnscat2 add a header to strip ([advanced notes](../.agents/skills/ctf-forensics/network-advanced.md)).

### TLS decryption

**Confirm:** encrypted TLS, and the challenge provides a keylog file or private key.

**Steps:**

1. Keylog (`SSLKEYLOGFILE`): Wireshark → **Preferences > Protocols > TLS > (Pre)-Master-Secret log filename**.
2. RSA private key: same menu, **RSA keys list** (only works without forward secrecy).
3. Traffic decrypts in place; now export objects / follow streams.

**Example:** after loading `keylog.txt`, HTTPS reveals a POST with the flag.

**Gotchas:** no key provided = not the intended path; look elsewhere. Key may be hidden in a coredump.

### USB HID decode

_Reconstructing keystrokes or mouse moves from captured USB._

**Confirm:** USB URB packets, HID interrupt transfers.

**Steps:**

1. Extract the data field: `tshark -r f.pcap -Y 'usb.transfer_type==1' -T fields -e usb.capdata` (or `usbhid.data`).
2. Keyboard: 8-byte reports; byte 2 = keycode, byte 0 = modifiers (shift). Map via HID usage table.
3. Use a decoder script ([peripheral notes](../.agents/skills/ctf-forensics/peripheral-capture.md)).

**Example:** decoding keycodes spells `H4G{keystrokes_recovered}`.

**Gotchas:** mouse HID encodes movement deltas → plot them to draw the flag.

### Wi-Fi decryption

**Confirm:** 802.11 frames with a WPA handshake (EAPOL).

**Steps:**

1. `aircrack-ng -w /usr/share/wordlists/rockyou.txt capture.pcap`.
2. In Wireshark, add the key: **Preferences > Protocols > IEEE 802.11 > Decryption keys** (`wpa-pwd`).
3. Decrypted traffic → export objects / follow streams.

**Example:** cracked PSK decrypts an HTTP session with the flag.

**Gotchas:** need the full 4-way handshake in the capture. WEP cracks with enough IVs.

### Covert channel

_Data hidden in packet metadata, not payload._

**Confirm:** uniform traffic (ICMP pings, steady TCP) where fields or timing vary.

**Steps:**

1. Check ICMP payload lengths/contents, TTLs, TCP flags, inter-packet timing.
2. Two distinct values → bits. Extract the sequence as a field: `tshark -T fields -e frame.time_delta -e data.len`.
3. Group bits to bytes, decode.

**Example:** inter-packet gaps (short=0, long=1) decode to `H4G{timing_channel}`.

**Gotchas:** subtle; only chase this once obvious paths fail. See [advanced notes](../.agents/skills/ctf-forensics/network-advanced.md).

### Follow the stream

**Confirm:** a readable application protocol (IRC, SMTP, HTTP, plain TCP).

**Steps:**

1. Right-click any packet → **Follow > TCP/UDP Stream**.
2. Read the conversation top to bottom; switch direction with the dropdown.
3. CLI: `tshark -r f.pcap -q -z follow,tcp,ascii,0`.

**Example:** IRC stream shows a user pasting `H4G{chat_logs}`.

**Gotchas:** scan every conversation in **Statistics > Conversations**, not just the first.

## Gotchas (all network)

- Protocol Hierarchy first; it names the challenge type.
- `strings | grep H4G{` catches flags sitting in cleartext before you dig.
- The extracted file is often the real challenge (pivot to stego/crypto).
- Work on a copy; keep the original `.pcap` untouched.
