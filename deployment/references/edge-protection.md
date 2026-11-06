# Edge Protection (assess / review / extend-existing only)

For repositories that already contain the traffic-facing layer of a delivery: reverse
proxy (nginx), Kubernetes Gateway / Ingress (Envoy Gateway), bot / abuse detection
(CrowdSec), a challenge or decision service (captcha gate). v1 **does not design** this
layer (`existing-platform.md` §1): it recognises it, reviews it, and extends it by
copying an existing pattern. Never introduce a WAF, honeypot or bot-detection product
the repository does not already use.

## 1. Layers and who is allowed to set what

```
edge router / WAF  ->  Gateway (Envoy)  ->  nginx  ->  decision service / app
                              \-> access logs -> detector (CrowdSec) -> verdict back to decision service
```

| Rule | Why |
|---|---|
| Client IP, TLS fingerprint (JA3/JA4), country and "is bot" headers are **set (overwritten)** by the first hop you trust, never appended or passed through from the client | A client can send `X-Real-IP` / `X-Ja3-Fingerprint` itself; a pass-through header turns a detection signal into an attacker-controlled input |
| Each hop states who it trusts (`set_real_ip_from`, `clientIPDetection`, `externalTrafficPolicy: Local` so the source IP survives the load balancer) | Without it every request appears to come from the proxy |
| A header that cannot exist at a given hop is left empty and documented | E.g. TLS terminated at an upstream edge router -> no JA3/JA4 at the gateway; the nginx `map` must default to `""`, not trust a header |
| Do not append `$remote_addr` to `X-Forwarded-For` when an upstream hop already put the real client IP there | Duplicated entries break rate-limit keys |

## 2. Decision service + honeypot (decoy) pattern

Seen as: nginx `auth_request` to a decision service, with the result mapped by status.

| Decision service answers | nginx does | Notes |
|---|---|---|
| `200` | serves the real content | headers returned by the service (type, nonce, reason) are copied with `auth_request_set` |
| `401` | challenge page (captcha), `proxy_pass_request_body off` | challenge endpoints are reachable but not indexable; `error_page 403 =404` hides them from scanners |
| `403` | **honeypot handler**: returns decoy content from the decision service instead of a block page | the client sees a normal-looking `200`, so it learns nothing about being detected and does not adapt |
| `skip-content` reason | `204` | non-document requests (prefetch, sub-resources) cost nothing and are not decoyed |

Review and extend rules for this pattern:

- The decoy contains **no real data** and is cheap to produce; it is served by the
  decision service, never by the real backend, and the request body is not forwarded
  (`proxy_pass_request_body off`, empty `Content-Length`).
- The original-URL header is blanked on the honeypot hop so the decoy cannot be used to
  probe internal routing.
- Every honeypotted request is **observable**: a dedicated access-log field
  (e.g. `hnp:$is_honeypot`), so a false-positive review is a log query, not a guess.
- Internal traffic, health checks, known good crawlers and monitoring are allowlisted
  **before** the decision call (`auth_request` handler returns `200` for them). A decoy
  shown to your own monitoring is an incident.
- Decide and record fail-open vs fail-closed for a decision-service outage
  (`auth_request` 5xx -> nginx 500). Silence here is a Finding (Medium).
- Hard blocks are a separate, louder mechanism (custom status such as 449/429,
  redirect, or a joke page). Prefer decoy for suspected automation and hard block for
  confirmed abuse (known-bad ASN / UA / IP); do not mix the two in one `if`.
- Per-environment copies of the same location blocks are the usual source of drift
  (commit history says "sync nginx config across envs"). Report drift as a Finding and
  recommend one base + per-environment overlay; do not restructure on your own.

## 3. Detector -> verdict feedback (CrowdSec style)

- Scenarios live in version control and are mounted read-only from ConfigMaps
  (`/etc/crowdsec/scenarios/local`, parsers per stage). A new scenario is a new file
  copied from a sibling.
- `remediation: false` marks **detect-only**: the alert is shipped (HTTP notification
  to the decision service and to the log store) but no IP ban decision is created.
  The decision service owns the verdict (decoy / challenge). Real bans exist only for
  scenarios with `remediation: true`, with an explicit `duration`.
- Notification profiles are ordered with `on_success: continue` / `break`; a catch-all
  profile before a specific one hides it. Test the order.
- Allowlists (good bots, ASN lists, ad-tracker partners) are parsers in `s02-enrich`;
  generated lists (IP / ASN) come from a script in the repository with the source
  recorded, not hand-edited.
- Bouncer keys, enroll keys, registration tokens and DB passwords come from Kubernetes
  Secrets (`secretKeyRef`); `trusted_ips` / `allowed_ranges` stay on private CIDRs.
- New or changed scenarios are exercised in a lower environment first; the detector
  runs with resource limits (`lapi`, `appsec` replicas) sized from observed load.

## 4. Rate limiting and blocking in nginx

- Limit zones are layered (per IP, per IP+UA, long-term per IP+UA, per search, per
  country / ASN). A zone key mapped to `""` is **not counted** - this is how internal
  and allowlisted bots are exempted.
- The effective quota is `rate x nginx replicas`; the comment must say so, and a
  replica change is a rate-limit change.
- Block lists by User-Agent version, fingerprint, ASN or IP are `map`s. Each entry
  carries a comment saying why and when (e.g. "crawler at 05:00, 12:00, 17:00"), so it
  can be expired.
- Ops endpoints (`/_hc`, `/_readiness`, `/metrics`, `stub_status`, admin, swagger) use
  `allow <private CIDR>; deny all;` and answer **404**, not 403, to the outside
  (`error_page 403 = @hidden` returning 404).
- `server_tokens off`, HSTS with `always`, HTTP -> HTTPS redirect keyed on
  `X-Forwarded-Proto`.

## 5. Findings specific to this layer

| Severity | Finding |
|---|---|
| High | Credential in a tracked values / config file (e.g. an `Authorization: Basic ...` header inside a notification or exporter config, DB password, API key). Report path:line, mask the value, recommend rotation and a Secret (`secrets.md` §4) |
| High | Client-controlled header (IP, JA3, country) trusted by a rule that blocks or allows |
| Medium | Tracked `.env` with real values; plain-HTTP management endpoint carrying credentials (log store bulk API over `http://`) |
| Medium | Decision service outage behaviour undefined; honeypot / challenge with no log field |
| Medium | Namespace `Role` with `apiGroups/resources/verbs: ["*"]` used for a human or CI identity - prefer a narrower role (`targets/kubernetes.md` §6.2) |
| Medium | Same location block copied per environment with drift |
| Low | Readiness and liveness probes are the same `tcpSocket` check on a proxy that has a real health path |
| Low | Base images pulled with `curl` of a remote script / module at image build without a checksum |

## 6. Gateway API / Ingress resources (extend by copying)

| Resource | Facts to preserve |
|---|---|
| `Gateway` listeners | one listener per hostname family with its TLS Secret; `allowedRoutes.namespaces.from: All` is a recorded choice, not a default |
| `HTTPRoute` | per-environment file; header `set` filters (client IP from `%DOWNSTREAM_REMOTE_ADDRESS_WITHOUT_PORT%`, fingerprints only where TLS terminates here); a **separate route for static assets** can bypass a SecurityPolicy to cut first-paint time - keep that split when adding paths |
| `SecurityPolicy` `extAuth` | `failOpen: true|false` is a security-vs-availability decision; record it in the Assessment. `bodyToExtAuth.maxRequestBytes` bounds what is sent to the bouncer |
| `BackendTrafficPolicy` | tracing `samplingFraction`; 100 % needs a stated reason |
| `Backend` | external IP/port or FQDN with `tls.wellKnownCACertificates: System`; an IP literal is `INFERRED` stable |
| `ClientTrafficPolicy` | TLS fingerprints, `clientIPDetection.customHeader`; Service `externalTrafficPolicy: Local` |
| `EnvoyProxy` | access-log JSON fields (include JA3/JA4, request id, route name, response flags); replicas stated |

Ingress controller (ingress-nginx) values: `enable-real-ip` + `proxy-real-ip-cidr`
limited to private ranges, `compute-full-forwarded-for`, `externalTrafficPolicy: Local`,
replica count, log format with upstream/service names and trace id.

- `allow-snippet-annotations: true` together with `annotations-risk-level: Critical` lets
  any Ingress author inject nginx config. Finding (Medium) unless the namespace is
  restricted by policy.
- Regex path lists repeated verbatim in several Ingress/HTTPRoute objects drift. Finding
  (Low); recommend one source for the path list.
- Management paths (`/_hc`, `/metrics`, admin) are not routed through the public
  gateway or are limited by `allow <CIDR>` (§4).

## 7. What this reference does not do

No new detection rules, WAF policies, block lists or honeypot endpoints are generated.
Recommendations are written in the Report; Extend is limited to copying an existing
location / scenario / route for a new environment or service and changing values.
