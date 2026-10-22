# Recent vulns

CTF authors anchor challenges on real, recent, high-profile bugs. If a version banner or stack matches one below, that's likely the intended path. Only the last ~12 months are worth tracking here (older bugs are common knowledge); everything below is Nov 2025 or later.

Deep ref: [`ctf-web` CVE notes](.agents/skills/ctf-web/cves.md). Live sources: [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog), [exploit-db](https://www.exploit-db.com/), GitHub PoC search.

## How to use

1. Fingerprint the target: response headers (`X-Powered-By`, `Server`), version strings, dependency files, framework artifacts.
2. Match the version to an entry below, or search `<tech> <version> CVE`.
3. Find a public PoC (GitHub, exploit-db), understand it, run it against the authorized target only.
4. The flag sits behind the access or RCE the bug grants.

## Deserialization & injection RCE

| Vuln | CVE (date) | Tell | What it does | How |
| --- | --- | --- | --- | --- |
| React2Shell | CVE-2025-55182 (Dec 2025) | React 19 RSC / Next.js 16 App Router | Unauth RCE via insecure deserialization in the RSC "Flight" protocol. Next.js tracks it as CVE-2025-66478 | [Datadog analysis](https://securitylabs.datadoghq.com/articles/cve-2025-55182-react2shell-remote-code-execution-react-server-components/), [PoC](https://github.com/knightwolf01/React2Shell) |
| Langflow RCE | CVE-2026-33017 (Mar 2026) | Langflow < 1.9.0 (AI pipeline tool) | One unauth POST to `/api/v1/build_public_tmp/{id}/flow` runs attacker code via `exec()` | [writeup](https://medium.com/@aviral23/cve-2026-33017-how-i-found-an-unauthenticated-rce-in-langflow-by-reading-the-code-they-already-dc96cdce5896), [PoC](https://github.com/z4yd3/PoC-CVE-2026-33017) |
| Xoscar / Xinference | (Oct 2026, verify ID) | Xoscar actor pool, Python | Unauth RCE: every inbound TCP message is `cloudpickle`-deserialized before any auth | [VulnCheck blog](https://www.vulncheck.com/blog) |
| Apache OFBiz | CVE-2026-31986 (2026) | OFBiz with SSO enabled | Pre-auth RCE via two GET requests | [Novee writeup](https://novee.security/blog/pre-auth-rce-in-enterprise-java/) |
| KnowledgeDeliver | CVE-2026-5426 (2026) | ASP.NET, ViewState | Predictable/shared machine key → ViewState deserialization RCE | [Mandiant analysis](https://cloud.google.com/blog/topics/threat-intelligence/knowledgedeliver-viewstate-deserialization-vulnerability) |

## Auth & JWT bypass

| Vuln | CVE (date) | Tell | What it does | How |
| --- | --- | --- | --- | --- |
| pac4j-jwt bypass | CVE-2026-29000 (2026) | Java, pac4j-jwt (< 4.5.9/5.7.9/6.3.3) | Forge tokens using only the server's public key; CVSS 10 | [Snyk analysis](https://snyk.io/articles/public-key-breaks-authentication-pac4j-jwt/), [PoC](https://github.com/yasirr10/CVE-2026-29000) |
| Authlib alg:none | CVE-2026-28802 (Feb 2026) | Python Authlib, OAuth/OIDC | Signature-verification bypass via `alg:none` | [ARMO analysis](https://www.armosec.io/blog/authlib-cve-2026-28802-jwt-signature-verification-bypass/) |
| PyJWT JWK bypass | CVE-2026-48523 (2026) | PyJWT 2.9.0-2.12.1, PyJWK verify | Algorithm-confusion auth bypass when verifying with a JWK | [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-48523) |

## Header / proxy trust

| Vuln | CVE (date) | Tell | What it does | How |
| --- | --- | --- | --- | --- |
| Gitea Docker proxy trust | CVE-2026-20896 (Jun 2026) | Gitea Docker <= 1.26.2 behind a proxy | Default wildcard trusted-proxy means a forged `X-WEBAUTH-USER` header logs you in as anyone. Forge it with curl | [Penligent lab](https://www.penligent.ai/hackinglabs/cve-2026-20896/) |

## Runtime (famous, harder to weaponize)

| Vuln | CVE (date) | Tell | What it does | How |
| --- | --- | --- | --- | --- |
| PHP2Shell | CVE-2026-109618 / -109619 (Oct 2026) | PHP < 8.5.12/8.4.27/8.3.36/8.2.35, mod_php | Unauth RCE via OOM memory corruption on crafted multipart requests. Big news; unlikely as a solvable CTF challenge | [Sansec research](https://sansec.io/research/php2shell) |

## Keep this updated

Before each event, skim the last ~12 months and add any that fit a likely challenge stack. Drop anything older than ~12 months.

- [CISA KEV](https://www.cisa.gov/known-exploited-vulnerabilities-catalog): actively exploited, authoritative
- [SoCRadar](https://socradar.io/blog/) / [Security Boulevard](https://securityboulevard.com/) monthly "top CVEs" roundups
- Recent CTF writeups ([writeups/](writeups/)) for which CVEs are being turned into challenges

Entries tagged `(verify)` or with a vague date need confirming against the vendor advisory or NVD before you rely on the ID or version range.
