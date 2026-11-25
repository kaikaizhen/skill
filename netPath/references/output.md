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
| `connection.tcp_peer` | `observed` = connected; `attempted` = chosen but not connected. `is_proxy: true` = the peer is the proxy, not the site |
| `connection.test_headers` | Names of test headers sent. The result reflects the **bypassed** path, which ordinary users do not take |
| `connection.http.status_code` | One HEAD. 3xx not followed; 405 / 501 not retried as GET |
| `connection.operations` | Tool-level actions (dns / tcp / http / route_probes), not packet counts |
| `connection.error.stage` | Where it failed: `proxy`, `dns`, `tcp`, `tls`, `http`, `timeout`, `canceled` |
| `route.protocol` | `icmp` / `icmpv6`. Separate traffic from the HTTP request |
| `route.destination_role` | `tcp_peer`, `proxy` (route covers only the segment to the proxy), `attempted_target` (never connected) |
| `route.skipped_reason` | `connection_only`, `permission_denied`, `platform_not_supported`, `ipv6_not_supported`, `route_api_unavailable`, `budget_exhausted`, `no_destination`, `canceled` |
| `route.hops[]` | `responded` (TTL expired at that IP), `target_reached`, `unreachable`, `unknown` (no answer within the hop timeout) |
| `route.stop_reason` | `reached`, `terminal_error`, `max_hops`, `budget_exhausted`, `canceled`, `probe_failed` |
| `clues[]` | `{type, evidence_key, confidence}` - fixed codes only, never raw header values |
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

## Common patterns

| Pattern | Say |
| --- | --- |
| Hop 1 answers, all later hops `unknown`, HTTP 200 | Path leaves the local gateway; devices after it do not answer ICMP or drop it. The site is reachable over HTTPS. Which devices sit there is UNKNOWN |
| `destination_role: proxy` | Only the segment to the proxy was traced; the site side is invisible from here |
| `skipped_reason: permission_denied` | This OS user may not open unprivileged ICMP sockets; connection data is still valid. Do not suggest elevation |
| Clues from several CDNs | Report each as suspected; do not pick one |
| `error.stage: tls` | Certificate did not verify; the CLI never disables verification - report, do not retry insecurely |
