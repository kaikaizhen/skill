---
name: netpath
description: Run the local NetPath CLI once against ONE http(s) URL the user names and explain what the network path from THIS machine looks like - DNS answer, local IP, TCP peer, TLS, one HTTP HEAD, device clues (CDN / WAF / proxy / Envoy / IIS ...) and one ICMP route round (one probe per hop) - separating observed, suspected and unknown. Use when the user asks which nodes / devices sit between this machine and a URL, whether a request passes a proxy, CDN or WAF, why the same URL behaves differently from this machine, or explicitly asks to run netpath (「這台連到某網址經過哪些節點」「幫我跑 netpath」「看一下有沒有經過 WAF / CDN / Proxy」「從這台測 stg 網址的連線路徑」). Do NOT use for generic networking questions (what is traceroute / WAF), for running tracert / ping / curl / nslookup, for scanning or monitoring, for more than one target, or when the agent is not running on the user's own machine.
version: 1.0
status: draft
---

# NetPath

**Operating layer only.** The probing logic lives in the NetPath CLI; this skill finds
the CLI, runs it **once** with fixed arguments, and interprets its JSON. It is not a
privilege-elevation path and never re-implements or supplements the probe.

```
user URL ─▶ gates (place · target · data) ─▶ netpath --json <url> (once) ─▶ interpret ─▶ answer
```

## Hard rules

1. **This machine only.** Run only when the agent executes on the user's own machine
   (or a VM / server the user explicitly named and the agent is actually on). A cloud
   or remote agent's path is not the user's path: stop and give the user the command
   to run themselves.
2. **One target, one run.** Exactly the URL the user gave. No extra targets, no
   retries, no reruns with other flags unless the user asks.
3. **No supplements.** Never add `tracert`, `ping`, `curl`, `nslookup`, port checks,
   reverse DNS, GeoIP / whois lookups or browser automation to "fill gaps". Unknown
   stays unknown.
4. **No elevation.** Never run as administrator / sudo, never change
   `ping_group_range`, firewall or proxy settings. A `permission_denied` /
   `platform_not_supported` route is a result, not a problem to work around.
5. **No disguise.** Never forge a browser User-Agent or replay browser requests. For
   test environments behind a captcha gate, use the sanctioned test header (step 4).
6. **Secrets never shown.** Test-header values are loaded from a file into the
   environment inside the command; they never appear in the command text, the answer,
   memory or any file the skill writes.
7. **Nothing persisted or shared.** Do not save results to files or memory, do not
   upload or paste them anywhere else. The answer in the conversation is the only output.

## Workflow

### 1. Place gate
Confirm the agent runs on the user's machine (local shell, local paths). If not,
stop: reply with the exact command for the user to run locally.

### 2. Target gate
- Take the single http(s) URL from the request. If it has `user:pass@`, `?query` or
  `#fragment`, ask the user for the origin instead of editing it silently (the CLI
  rejects them anyway).
- Default probes the origin `/`. Use `--exact-path` only if the user asks to test that
  path.

### 3. Data gate
If the target is internal (private IP, internal domain, staging host) and the user has
not already indicated the results may enter this conversation, say once that the
output will include internal IPs / hostnames and that running the CLI directly keeps
them out of the conversation; proceed only on their go-ahead.

### 4. Locate the CLI and test headers
Read `workspace/config.yaml` (copy from `config.example.yaml` on first use):
- `binary`: path to the CLI. Fallbacks: `$NETPATH_BIN`, then `netpath` on `PATH`.
  If none exists, stop and tell the user how to build it (`scripts/build.ps1` in the
  NetPath repository). Run `<binary> --version` once; if `sha256` is configured,
  verify it and stop on mismatch.
- `test_headers`: entries `{host_suffix, file}`. If the target host ends with a
  `host_suffix`, this run **must** send that file's headers: the file holds
  `Name=Value;Name=Value` (in git-ignored `workspace/.secrets/`). Load it inside the
  command, never echo it:
  - bash: `NETPATH_TEST_HEADER="$(cat '<file>')" '<binary>' --json --test-header <url>`
  - PowerShell: `$env:NETPATH_TEST_HEADER = Get-Content -Raw '<file>'; & '<binary>' --json --test-header <url>; Remove-Item Env:NETPATH_TEST_HEADER`
  Only https targets accept test headers; never send them to hosts not listed.

### 5. Run once
```
<binary> --json [--connection-only] [--max-hops N] [--exact-path] [--test-header] <url>
```
- Add `--connection-only` when the user wants no ICMP probes; `--max-hops N` (1-30)
  when the user asks or the destination is known to sit few hops away.
- Allow up to ~40 s (whole-run budget is 35 s). Do not interrupt and rerun.
- Exit codes: 0 completed, 3 partial, 4 no result, 2 usage error, 130 canceled. A
  non-zero exit still has JSON on stdout - interpret it.

### 6. Interpret
Load `references/output.md` and answer in this order:
1. **Result in one line** - reached or not, through a proxy or not, status.
2. **What was observed (CONFIRMED for this run)** - DNS answer used, local IP, TCP
   peer, TLS, HTTP status, route hops that answered.
3. **What is suspected (INFERRED)** - device clues with their evidence keys.
4. **What is unknown (UNKNOWN)** - silent hops, devices beyond the TCP peer, anything
   the limitations list rules out.
5. **What would settle it** - e.g. ask the network / ops team, run the CLI from another
   network, compare with / without a test header - offered, not executed.

Never merge the ICMP route and the HTTP request into one proven path, never name a
device that has no clue, never read a silent hop as "no device".

## Boundary

Owns: running the NetPath CLI once and explaining its result.
Does not own: building or changing NetPath (normal development in its repository),
network configuration, monitoring, or diagnosing the application behind the URL.
