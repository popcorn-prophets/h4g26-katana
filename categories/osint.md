# OSINT

_Open-Source Intelligence: finding public info from a small seed. Passive only, no logging in or attacking ([conduct](../event-briefer.md#v-code-of-conduct))._

Flag comes from a bio, a photo's location, a metadata field, an archived page, or a server banner.

Deep ref: [`ctf-osint` skill](../.agents/skills/ctf-osint/SKILL.md). Primers: [OSINT Framework](https://osintframework.com/), [Bellingcat Toolkit](https://bellingcat.gitbook.io/toolkit).

## First moves

1. `exiftool` every image. GPS, timestamp, author, camera, software.
2. Read the challenge text for puns and date words. They name the technique ("way back" = Wayback).
3. Reverse-image a cropped region (one sign/landmark), not the whole photo.

## Triggers

| Seeing                     | Pattern                           |
| -------------------------- | --------------------------------- |
| Username / handle          | [Username hunt](#username-hunt)   |
| Photo of a place           | [Geolocation](#geolocation)       |
| Photo, "when was this"     | [Chronolocation](#chronolocation) |
| `XXXX+XXX`, lat/long, grid | [Coordinates](#coordinates)       |
| Domain / company           | [Domain recon](#domain-recon)     |
| "Find the file/page"       | [Search dorking](#search-dorking) |
| Deleted / changed page     | [Web archive](#web-archive)       |
| Email address              | [Email pivot](#email-pivot)       |
| GitHub user / repo         | [GitHub history](#github-history) |
| IP address                 | [IP lookup](#ip-lookup)           |
| PH person / gov / business | [PH sources](#ph-sources)         |

## Plays

### Username hunt

**Confirm:** you have a handle and need their other accounts.

**Steps:**

1. [WhatsMyName](https://whatsmyname.app/) or `sherlock <user>` to spread it across sites.
2. Open each hit. Read bio, pinned posts, linked accounts, profile photo.
3. Pivot on anything new: a real name, a second handle, an email.

**Example:** handle `juancruz23` → GitHub profile → bio reads `H4G{found_the_dev}`.

**Gotchas:** expect false positives; confirm it's the same person. Flag often sits in a bio or alt text, not a post.

### Geolocation

_Working out where a photo was taken._

**Confirm:** a photo, and the task wants a place/coords.

**Steps:**

1. `exiftool` first. GPS tags solve it instantly if present.
2. No GPS → reverse image: [Google Lens](https://lens.google/), [Yandex](https://yandex.com/images/) (best on faces/non-Western), [Bing](https://www.bing.com/visualsearch).
3. Crop to one distinctive thing: a storefront, sign, statue, mountain ridge.
4. Read text: shop names, plates, road signs, language/script → country.
5. Match terrain/buildings on [Google Maps](https://maps.google.com/) / Street View. [GeoHints](https://geohints.com/) for clues.

**Example:** cropped jeepney signboard → route "Cubao–Montalban" → area on Maps → `H4G{...}`.

**Gotchas:** social platforms strip EXIF; a challenge-provided original usually keeps it. Verify with two signals (sign text + terrain).

### Chronolocation

_Working out when a photo was taken._

**Steps:**

1. EXIF timestamp if present.
2. Shadow direction + length → time of day via [SunCalc](https://www.suncalc.org/).
3. Weather in frame vs historical weather archive for the area.
4. Dated clues: posters, license plates, construction, foliage season.

**Example:** shadow angle + known location → ~3 PM, date in EXIF → answer.

**Gotchas:** EXIF time can be the wrong timezone or camera-default. Cross-check.

### Coordinates

**Confirm:** a coordinate-shaped string.

**Steps:**

- Plus Code `XXXX+XXX` (chars `23456789CFGHJMPQRVWX`) → paste into [Google Maps](https://maps.google.com/).
- Lat/long → Maps directly.
- MGRS grid like `4V FH 246 677` (military grid) → [Earth Point converter](https://www.earthpoint.us/convert.aspx) → Maps.

**Example:** `7FG8+QX Manila` → drops on a building → name in the task.

**Gotchas:** a bare pin on Maps shows its Plus Code in the details pane (reverse direction).

### Domain recon

**Confirm:** a domain or company name.

**Steps:**

1. `whois <domain>`: registrant, dates, nameservers.
2. Subdomains: [crt.sh](https://crt.sh/) (certificate logs), [DNSDumpster](https://dnsdumpster.com/).
3. Records: `dig +short txt/mx/cname <domain>`. Flags hide in TXT records.
4. Wayback the site for old pages/subdomains.

**Example:** `dig txt ctf.example.com` → `"H4G{dns_txt_flag}"`.

**Gotchas:** check `_` -prefixed and odd subdomains in crt.sh output.

### Search dorking

_Using search-engine operators to find specific exposed content._

**Steps:**

1. `site:example.com filetype:pdf`: files on one host.
2. `intitle:"index of"`: open directory listings.
3. `inurl:` , `intext:` to narrow on a known string.
4. Reference: [Google Hacking Database](https://www.exploit-db.com/google-hacking-database).

**Example:** `site:target.ph filetype:xlsx` → a sheet with the flag inside.

**Gotchas:** combine operators; try Bing/DuckDuckGo too, they index differently.

### Web archive

**Confirm:** a page that's gone, changed, or a "back in the day" hint.

**Steps:**

1. [Wayback Machine](https://web.archive.org/): browse snapshots by date.
2. [archive.today](https://archive.ph/), Google cache as backups.
3. Diff old vs current to find removed content.

**Example:** old snapshot of an "About" page still lists a since-deleted email = the answer.

**Gotchas:** try multiple snapshot dates; not every capture is complete.

### Email pivot

**Steps:**

1. Search the address in quotes across engines and social.
2. [Gravatar](https://gravatar.com/): `gravatar.com/avatar/<md5 of email>` may show a linked profile.
3. Map the username part to other platforms ([Username hunt](#username-hunt)).

**Example:** gravatar of the email → linked WordPress → author page with the flag.

**Gotchas:** breach-check sites only for lookup, never log in anywhere.

### GitHub history

**Confirm:** a GitHub user or repo.

**Steps:**

1. Read commit history, closed PRs, issues, gists, wiki edits.
2. Append `.patch` to a commit URL → reveals author name/email.
3. Search the repo for secrets: `git log -p`, old commits that deleted a key.

**Example:** a reverted commit still in history contains `H4G{leaked_in_git}`.

**Gotchas:** deleted-but-committed data stays in history. Check all branches.

### IP lookup

**Steps:**

1. `curl ip-api.com/json/<ip>`: geo, ISP, org.
2. [Shodan](https://shodan.io/) / [Censys](https://search.censys.io/): open ports, banners, certs on that IP.
3. Reverse DNS and hosted domains.

**Example:** Shodan on the IP shows a service banner containing the flag.

**Gotchas:** don't connect/scan it yourself if out of scope; read Shodan's cached data.

### PH sources

_Philippine-specific, since this is a DICT event._

**Steps:**

1. `.gov.ph` sites, LGU and barangay Facebook pages, local news archives.
2. Business: SEC and DTI name search, Google Maps business listings.
3. Local landmarks: jeepney routes, barangay signage, mall/branch names.

**Example:** an LGU FB post names the official in a photo → matches the task.

**Gotchas:** FB posts are often the only source; use archive if deleted.

## Gotchas (all OSINT)

- Passive only. Read, don't log in or attack ([conduct](../event-briefer.md#v-code-of-conduct)).
- Flags hide in metadata, bios, alt text, TXT records, old snapshots, not the obvious spot.
- Confirm with two independent signals before submitting.
- Yandex beats Google on faces and non-Western places.
