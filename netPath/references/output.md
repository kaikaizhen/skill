# Reading NetPath JSON (schema_version 1)

Load this at step 6. It maps each field to an evidence level and lists the
conclusions that are **not** allowed.

## Evidence levels

| Level | Meaning | Comes from |
| --- | --- | --- |
| CONFIRMED (this run) | Observed by this machine in this run | `connection.dns.selected`, `connection.local_ip`, `connection.tcp_peer` with `state: observed`, `connection.tls_version`, `connection.http.status_code`, route hops with an `ip` |
| DECLARED | The response says so; may be incomplete or untrue | clues with `confidence: declared_by_response` (e.g. `proxy / via_header`) |
| INFERRED | A header pattern matches; headers can be changed or forged | clues with `confidence: suspected` |
| UNKNOWN | Not observable from here | hops without `ip`, `other intermediaries`, everything beyond the TCP peer |

## Fields

| Field | Read as |
| --- | --- |
| `status` | `completed` - connection answered and route ended normally (or `--connection-only`); `partial` - only part observed; `failed` - nothing usable |
| `connection.proxy.selected` | The CLI used a proxy from `HTTP(S)_PROXY`. `false` does not rule out transparent or system / PAC proxies (`only_env_proxy_evaluated`) |
| `connection.dns` | One system resolution. `observed: false` with a proxy means the proxy resolved the target |
| `connection.tcp_peer` | `observed` = connected; `attempted` = chosen but not connected. `is_proxy: true` = the peer is the proxy, not the site. `failure` (attempted only): `refused` = RST, usually a closed port (a reject-style firewall can also send it); `timeout` = no reply at all, possibly filtered (`tcp_timeout_possibly_filtered`) but also a down host; `unreachable` |
| `connection.test_headers` | Names of test headers sent. The result reflects the **bypassed** path, which ordinary users do not take |
| `connection.http.status_code` | One HEAD. 3xx not followed; 405 / 501 not retried as GET |
| `connection.operations` | Tool-level actions (dns / tcp / http / route_probes), not packet counts |
| `connection.error.stage` | Where it failed: `proxy`, `dns`, `tcp`, `tls`, `http`, `timeout`, `canceled` |
| `route.protocol` | `icmp` / `icmpv6`. Separate traffic from the HTTP request |
| `route.destination_role` | `tcp_peer`, `proxy` (route covers only the segment to the proxy), `attempted_target` (never connected) |
| `route.skipped_reason` | `connection_only`, `permission_denied`, `platform_not_supported`, `ipv6_not_supported`, `route_api_unavailable`, `budget_exhausted`, `no_destination`, `canceled` |
| `route.hops[]` | `responded` (TTL expired at that IP), `target_reached`, `unreachable`, `unknown` (no answer within the hop timeout). `admin_prohibited: true` = ICMP "administratively prohibited": a firewall / ACL actively rejected (Windows IPv4 cannot report this) |
| `route.stop_reason` | `reached`, `terminal_error`, `max_hops`, `budget_exhausted`, `canceled`, `probe_failed` |
| `clues[]` | `{type, category, evidence_key, confidence}` - fixed codes only, never raw header values or cookie names. `category`: `load_balancer`, `waf`, `cdn`, `cache`, `proxy`, `web_server`, `firewall`. Evidence keys starting `cookie_` come from Set-Cookie **names** (e.g. `cookie_bigipserver` F5, `cookie_arraffinity` IIS ARR, `cookie_ts_f5_asm` F5 WAF); `icmp_admin_prohibited` comes from the route |
| `limitations[]` | Must be reflected in the answer, in plain words |

## Not allowed

- Joining route hops and the HTTP request into one proven end-to-end path - ECMP,
  policy routing and VPNs can send ICMP and TCP different ways.
- Naming a WAF / CDN / proxy without a clue, or denying one because there is no clue.
- Treating a hop's IP as the device's forwarding interface (it is the interface that
  sent the ICMP error).
- Reading `unknown` hops as "nothing there", or a run of trailing `unknown` hops as
  "the destination is down" when `connection.http` answered.
- Treating a private first hop (e.g. `192.168.x.1`) as the site's WAF - it is the local
  default gateway; a WAF filters HTTP near the server and is invisible to ICMP.
- Concluding anything about normal users from a run with `test_headers`.
- Saying "there is no load balancer / WAF / firewall" because no clue appeared - transparent
  LBs and drop-style firewalls are invisible from here.
- Calling a TCP `timeout` a confirmed firewall; it is only *possibly filtered*.

## Common patterns

| Pattern | Say |
| --- | --- |
| Hop 1 answers, all later hops `unknown`, HTTP 200 | Path leaves the local gateway; devices after it do not answer ICMP or drop it. The site is reachable over HTTPS. Which devices sit there is UNKNOWN |
| `destination_role: proxy` | Only the segment to the proxy was traced; the site side is invisible from here |
| `skipped_reason: permission_denied` | This OS user may not open unprivileged ICMP sockets; connection data is still valid. Do not suggest elevation |
| Clues from several CDNs | Report each as suspected; do not pick one |
| `tcp_peer.failure: timeout` | No reply to the connection attempt: possibly filtered by a firewall, or the host / route is down. Not proven either way |
| Clue `firewall / icmp_admin_prohibited` | A device on the route explicitly rejected the probe (firewall / ACL). Its IP is the hop marked `admin_prohibited` |
| No `load_balancer` clue | Unknown, not absent: many LBs leave no header or cookie (HEAD responses often set no cookies) |
| `error.stage: tls` | Certificate did not verify; the CLI never disables verification - report, do not retry insecurely |
