# Observability Stack (assess / review / extend-existing only)

For repositories that already carry logging, metrics or tracing configuration (Filebeat /
Logstash / Elasticsearch, Prometheus, Grafana, Tempo, Alloy / OpenTelemetry collector).
v1 does not design this stack; it recognises it, reviews it, and extends it by copying a
sibling (`existing-platform.md` §1). It matters for delivery because deploy verification,
rollback diagnosis and rate-limit / abuse analysis all read from it.

## 1. Recognising the pipeline

```
container stdout -> Filebeat (DaemonSet) -> Logstash -> Elasticsearch (index + ingest pipeline per app)
                                                   \-> syslog/UDP clone -> detector (CrowdSec)
app / proxy / gateway -> OTLP -> collector (Alloy) -> Tempo (S3 backend)  ;  Prometheus (remote-write receiver, exemplars)
```

| Stage | What to look at |
|---|---|
| Collection | Filebeat `paths` are an explicit list of container log files: a new workload is **not collected until its file pattern is added**. `add_kubernetes_metadata` + `rename` normalise labels (`app`, `namespace`, `podName`) |
| Routing | Logstash `translate` dictionaries map `app` -> index and `app` -> ingest pipeline, with a **fallback index**. A new app = one dictionary line in each |
| Dual output | A log line may be cloned to a second sink (syslog to the detector) while the original goes to the store. Large events are trimmed (empty fields removed) to stay under the UDP datagram limit |
| Correlation | The access log format carries `trace id`, client IP, JA3/JA4, and decision flags (bot, captcha, honeypot). Keep any new log format a superset of the existing one |
| Metrics | Per-Pod scrape annotations (`prometheus.io/scrape|port|path`) + exporter sidecar (nginx exporter on `stub_status`) |
| Traces | Sampling fraction is set on the traffic policy or the SDK; backend storage and `block_retention` bound disk |

## 2. Extending

- New service in an existing environment: add its log path to Filebeat, one line to each
  Logstash dictionary, scrape annotations to its Deployment. Do not edit ingest pipelines
  or index templates without the user (Gate 6).
- A new environment copies the nearest environment folder; hosts, namespaces and index
  names are the only differences (`targets/kubernetes.md` §4 for the overlay shape).
- Operator-managed stacks (ECK `Beat` / `Logstash` custom resources) are applied like any
  manifest; the operator install (`crds.yaml`, `operator.yaml`, pinned version) is a
  one-time Manual setup item, not a pipeline step.

## 3. Sizing and retention facts to record, not invent

JVM heap (`-Xms`/`-Xmx`) and container memory limit (heap must leave at least the same
again for off-heap: `mem_limit` of at least 2x heap); Prometheus `retention` **and**
`retentionSize` (both, whichever hits first); Tempo `block_retention`; persistent volume
size and replica count (a storage class with replica count 1 plus a backup target is a
conscious trade-off to state); Logstash memory limit. All are `Unknown` unless the
repository or user states them (`decision-rules.md` §9).

## 4. Metrics, alerting and deploy verification

- **Scrape model**: Prometheus scrapes targets on an interval (15 s is typical);
  exporters cover what the app cannot (host: node exporter, run with the host root
  mounted **read-only** and `--path.rootfs`; data stores: a Redis / database exporter
  per instance, with an `alias` label relabelled to `instance` so graphs name the
  service, not an address). A new exporter is a scrape job copied from a sibling.
- **Receivers**: a remote-write receiver (`web.enable-remote-write-receiver`) lets a
  collector push metrics; exemplar storage links a metric point to a trace id. Both
  are explicit server arguments - check they are on before relying on them.
- **Retention**: set both time and size (`retention`, `retentionSize`); the volume must
  hold the size value with headroom (§3).
- **Alerting is a separate layer.** A stack with Prometheus and Grafana but no rule
  files, no alert manager and no notification channel **detects nothing by itself**;
  someone has to be looking. State which of the three exists. Minimum worth proposing
  (never creating, `existing-platform.md` §1): target down, Pod restart count rising,
  error-rate ratio, p95 latency, disk / volume nearly full, certificate expiry,
  backup age (`backup-restore.md`).
- **Deploy verification reads these signals**, in this order, after `rollout status`:
  Pod restarts and readiness -> 5xx ratio vs the previous hour -> latency -> one
  traced request end to end (the trace id from the access log opens the trace) ->
  the log store for new error signatures. Record which of them the repository can
  actually answer; a missing one is a gap in the verification, not a pass.
- **Dashboards and notification setup are state**: dashboards created by clicking
  live only in Grafana's volume (back it up, `backup-restore.md`) unless provisioned
  from files; SMTP / webhook channels are config values, credentials by Secret.
  Open edit rights for viewers (`viewers_can_edit`) let anyone change a shared panel.

## 5. Host and build-runner monitoring

CI runners and plain VM targets are not covered by Pod metrics. Seen patterns:

- Host metrics via a node exporter container with host network / PID namespace and a
  read-only root mount; pin the image tag (not `latest`).
- **Event log to the system journal** with a tag (a small service that logs container
  start / die events of CI job containers; query with `journalctl -t <tag> --since`).
  It turns "the runner was slow at 14:00" into a timeline.
- **Periodic resource guard** (cron, minutes): log a one-line sample (RSS, mount count,
  unit count, running job ids) to the journal; above a limit, **dump diagnostic state
  first** (status, maps, stack samples, container list) and only then take the
  corrective action. Calls that can hang (`systemctl`, `docker`) run under `timeout`.
- Every such host script states the symptom that justified it and the condition for
  removing it (`review.md`, host workarounds); otherwise it outlives its cause.

## 6. Findings

| Severity | Finding |
|---|---|
| High | Object-store / database / API credentials in a tracked config (e.g. an `access_key` / `secret_key` pair in a tracing or metrics backend config). Mask, rotate, move to a Secret (`secrets.md` §4) |
| High | Credentials sent over plain `http://` (log store bulk API, metrics write endpoint) |
| Medium | TLS verification disabled in a collector exporter (`insecure_skip_verify: true`, `insecure: true`) |
| Medium | Trace sampling at 100 % on a high-traffic route |
| Medium | Image `latest` for monitoring components; operator / CRD installed from an unpinned URL |
| Medium | Security disabled on the search/log cluster transport or HTTP while the port is published on the host |
| Low | Host-name -> IP pinned with `hostAliases` instead of DNS (breaks silently when the IP moves) |
| Low | Collector / DaemonSet runs as root with `hostPath` mounts - acceptable for log collection; record why |
| Low | Index fallback receives unclassified logs with no alert on volume |
| Medium | Metrics and dashboards exist but **no alert rules / alert manager / channel**: failures are found only by a person looking |
| Medium | Deploy verification names a signal (latency, 5xx) the stack cannot answer |
| Low | Exporter / monitoring image on `latest`; dashboards click-made and not backed up or provisioned |
| Low | Host guard script with no stated symptom or removal condition |

Also list what is good (explicit retention, memory limits on sidecars, correlation ids in
the log format).
