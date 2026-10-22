# Basics

Shell, filesystem, and `curl` basics you reach for in every category. Not a tutorial; a lookup.

Primer if rusty: [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) (the fastest way to drill these).

## Shell survival

| Do                         | Command                                       |
| -------------------------- | --------------------------------------------- |
| Where am I / what's here   | `pwd`, `ls -lah`                              |
| Read a file                | `cat f`, `less f`, `head -n20 f`, `tail -f f` |
| Find text in files         | `grep -rniE 'pattern' .`                      |
| Find files by name         | `find . -iname '*.pcap'`                      |
| Find files by content type | `find . -type f -exec file {} +`              |
| History / rerun            | `history`, `!!`, `!123`, `Ctrl+R` search      |
| Stop / background a job    | `Ctrl+C`, `Ctrl+Z`, `bg`, `jobs`, `fg`        |
| Help for a command         | `man cmd`, `cmd --help`, `tldr cmd`           |

## Pipes and redirects

| Do                          | Command                                        |
| --------------------------- | ---------------------------------------------- |
| Send output to next command | `cmd1 \| cmd2`                                 |
| Save output to file         | `cmd > out` (overwrite), `cmd >> out` (append) |
| Feed a file as input        | `cmd < in`                                     |
| Capture errors too          | `cmd > out 2>&1`                               |
| Use output as arguments     | `cmd1 \| xargs cmd2`                           |
| Count lines / words         | `wc -l`, `wc -c`                               |
| Sort / unique               | `sort`, `sort -u`, `uniq -c`                   |
| Slice columns               | `cut -d: -f1`, `awk '{print $2}'`              |
| Find-and-replace in stream  | `sed 's/a/b/g'`, `tr 'A-Z' 'a-z'`              |

## Linux filesystem

| Path                    | Holds                                                |
| ----------------------- | ---------------------------------------------------- |
| `/etc/passwd`           | User accounts (world-readable; a classic LFI target) |
| `/etc/shadow`           | Password hashes (root only)                          |
| `/home/<user>`, `/root` | Home dirs; check `.bash_history`, `.ssh/`, dotfiles  |
| `/tmp`, `/dev/shm`      | World-writable scratch space                         |
| `/var/log`              | Logs (`auth.log`, `syslog`, web logs)                |
| `/proc/<pid>`           | Live process info; `/proc/self/environ` for env vars |
| `/flag`, `/flag.txt`    | Common flag location on pwn/web boxes                |

Hidden files start with `.` and need `ls -a`. Permissions: `rwx` for user/group/other; `chmod +x f` to run a script, `ls -l` to read them.

## curl

| Do                         | Command                                                     |
| -------------------------- | ----------------------------------------------------------- |
| Fetch a page               | `curl URL`                                                  |
| Show response headers only | `curl -I URL`                                               |
| Headers + body             | `curl -D - URL`                                             |
| Follow redirects           | `curl -L URL`                                               |
| POST form data             | `curl -d 'a=1&b=2' URL`                                     |
| POST JSON                  | `curl -H 'Content-Type: application/json' -d '{"a":1}' URL` |
| Send a cookie              | `curl -b 'session=abc' URL`                                 |
| Send a header              | `curl -H 'X-Foo: bar' URL`                                  |
| Custom method              | `curl -X PUT URL`                                           |
| Save to file               | `curl -o out URL`, `curl -O URL` (keep name)                |
| Verbose (see the wire)     | `curl -v URL`                                               |
| Ignore bad TLS cert        | `curl -k URL`                                               |

## Connecting

| Do                          | Command                               |
| --------------------------- | ------------------------------------- |
| Talk to a raw port          | `nc host port`                        |
| Scripted input to a service | `echo -e 'a\nb' \| nc host port`      |
| SSH in                      | `ssh user@host`, `-p PORT` for non-22 |
| Copy a file over SSH        | `scp user@host:/path .`               |
| Serve the current dir       | `python3 -m http.server 8000`         |
| What's listening locally    | `ss -tlnp`                            |

## Quick decode on the CLI

| Do         | Command                                                                               |
| ---------- | ------------------------------------------------------------------------------------- |
| base64     | `echo <b64> \| base64 -d`                                                             |
| hex to raw | `echo <hex> \| xxd -r -p`                                                             |
| URL-decode | `python3 -c 'import urllib.parse,sys;print(urllib.parse.unquote(sys.argv[1]))' '<s>'` |
| ROT13      | `echo <s> \| tr 'A-Za-z' 'N-ZA-Mn-za-m'`                                              |

See [`aliases.sh`](aliases.sh) to shortcut most of these.
