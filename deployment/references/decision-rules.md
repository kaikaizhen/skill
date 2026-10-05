# Decision Rules

Turns the Discovery inventory into the Assessment's decisions. Status vocabulary and
its meaning are defined in `SKILL.md` §Decision status; this file says **how to assign
it**.

## 1. Precedence

For every decision, the first rule that applies wins:

```
1. User hard constraint          -> decides the Desired state
2. Existing repository design    -> continue it; if it conflicts with 1, it decides
                                    the migration risk (§1.1), not the outcome
3. User explicit preference      -> follow it where nothing above decides
4. Evidence-based inference      -> the rules in §2-§9
5. Nothing decides it            -> Unknown
```

**Hard constraint vs preference.** A hard constraint requires or forbids:
「不要 K8s」,「只有一台 VM」,「改成 VM」,「必須用 GitHub Actions」,「prod 要自動部署」.
A preference is hedged: 「比較想用 K8s」,「可以考慮 Compose」. A preference never
overrides an existing design - it is noted as an option. Unclear which one it is and it
would cause a migration -> treat it as a preference and ask inside the Gate 4 question.

A preference or inference that contradicts the evidence is still stated once, in one or
two lines, with the evidence that disagreed. No argument loop.

### 1.1 Constraint vs existing design: migration

When a hard constraint names a target, provider or mechanism different from what the
repository already uses:

```
Existing Target:    <what the repository uses, CONFIRMED>
Desired Target:     <what the constraint requires>
Migration Required: Yes
Risk:               deployment mechanism replacement (+ concrete risks: downtime at
                    cutover, lost HA / autoscaling, config / secret relocation, ...)
```

- This is **Gate 4** (`SKILL.md`), always - even in Generate / Extend.
- The constraint decides **what** the target becomes; the existing design decides
  **how risky** the change is. Neither is dropped.
- After the user confirms: generate the Desired target **alongside** the existing
  mechanism. Existing files (manifests, deploy jobs, scripts) are **not deleted**; the
  Report lists them under "To decommission after cutover". Deleting them is a
  separate, explicit request (Gate 5).
- Cutover order (lower environments first, production last) goes in the Report;
  production cutover is also Gate 3.

## 2. Assigning status

| Status | Assign when |
|---|---|
| Required | a hard constraint or the user's request needs it, the repository already uses it (and no hard constraint forbids it), or another Required decision depends on it (CD on a container target makes Container Required) |
| Recommended | not required; at least one CONFIRMED signal favours it and nothing CONFIRMED argues against it |
| Not Recommended | CONFIRMED evidence shows it does not fit, or a hard constraint forbids it |
| Unknown | the fact that would decide it is missing |

**`Unknown` is not a soft `Not Recommended`.** Absence of evidence ("nothing says
there is a cluster") is Unknown; evidence of absence ("the user says there is no
cluster") can be Not Recommended. Facts that are true of almost every repository - one
service in this repository, a Dockerfile present, ASP.NET Core - are not by themselves
evidence for or against a deployment target.

`Unknown` lists the missing fact and the question that would resolve it. If the request
needs it and the fact is a target (host, cluster, registry, feed, CI provider), it is
Gate 1; a required operational value is §9; otherwise follow the nearest existing
pattern and say so, or leave it as an open item.

## 3. Application classification

Classify each unit from stack evidence (`stacks/<stack>.md` §Classification):

| Type | Default delivery |
|---|---|
| Library / Package | CI + package publish; no runtime CD |
| Web API | CI + runtime CD |
| Frontend | CI; runtime CD if it has a server runtime or an existing hosting method |
| Worker / Background Service | CI + runtime CD, no inbound port |
| CLI | CI + release artifact; no runtime CD |
| Scheduled Job | CI + scheduled runtime (K8s CronJob / systemd timer) |
| Other | Unknown until the user describes how it runs |

The default is a starting point; the request and repository override it (a library
the user wants deployed as a demo site is the user's call).

## 4. CI

Required unless the unit has nothing to build or the user declines it. Per step,
record **Need / Exists / Action** (`keep` | `extend` | `create` | `skip`):

| Step | Need when | Skip / note when |
|---|---|---|
| Build | always | - |
| Test | test project / script exists | none -> `skip`, list "no tests" as a gap; never create tests |
| Lint / format | linter or analyzer config exists | no config -> `skip`; do not introduce a linter |
| Security scan | user asks, or it already exists | otherwise `skip` + suggest the stack's dependency audit in the Report |
| Package | Library / CLI | runtime-only app |
| Docker build | target is container-based, or CI already builds images | systemd target, library |
| Docker push | a CD target pulls from a registry | registry `Unknown` -> Gate 1 for the CD part |

Merge-request / pull-request pipelines run build + test only - no push, no deploy.

## 5. CD

| Situation | CD status |
|---|---|
| Existing deploy job / script | Required (continue) |
| User asked for CD / CI/CD / an environment | Required |
| Runtime app, no request, no existing CD (Assess / Review) | Recommended; target from §6 (may be Unknown) |
| Library / CLI | Not Recommended (package / release instead) |
| Not known whether the unit runs anywhere | Unknown |

## 6. Target

Apply §1 in order:

1. **Hard constraint names a target** ("只有一台 VM", "改成 VM", "必須用 K8s") ->
   Desired Target = that. If the repository already deploys elsewhere -> §1.1
   (Migration Required, Gate 4).
2. **Existing Platform** - the repository already deploys somewhere and no constraint
   conflicts -> that target. Generated in v1 only if it is a v1 target; anything else:
   `existing-platform.md`.
3. **User preference** ("可以考慮 K8s") -> that target when nothing above decides.
4. **Evidence** -> Kubernetes vs VM by §8.
5. **Nothing decides** -> Unknown (Gate 1 if the request needs CD). Never pick a target
   because a Dockerfile exists.

**VM sub-choice** (Compose vs systemd), once the target is a VM:

| Choose | When |
|---|---|
| Docker Compose | Dockerfile already exists, or several containers must run together (API + Redis), or a registry is already available, or the user says the VM runs Docker |
| systemd | none of the above is CONFIRMED: a single .NET process, no container assets, no registry - no registry to provision, no Docker daemon to run |
| Unknown | the user says the VM forbids one of them and the other is not viable |

State the sub-choice and its reason in the Assessment; the user may override.

## 7. Container

Derived from the target, not chosen on its own:

| Target | Container |
|---|---|
| Kubernetes, Compose | Required |
| systemd | Not Recommended (adds a registry and a daemon for no gain) unless the repository already ships images |
| CI Only (package) | Not Recommended |
| Existing Platform | whatever the platform requires |
| Target Unknown | Unknown - even if a Dockerfile exists (note it: it makes a container target cheaper once the target is known) |

## 8. Kubernetes

1. Hard constraint forbids it ("不要 K8s", "只有一台 VM") -> **Not Recommended**. If the
   repository already uses Kubernetes -> also §1.1 (Migration Required, Gate 4).
2. Hard constraint requires it -> **Required**; list the signals below anyway. If the
   repository deploys elsewhere -> §1.1.
3. Existing manifests / K8s deploy job -> **Required**.
4. Otherwise weigh signals. Only signals about the **runtime environment and
   requirements** count; the repository's own shape alone does not.

| For (CONFIRMED) | Against (CONFIRMED) |
|---|---|
| A cluster the team already runs (user statement, kubeconfig use in CI, manifests in sibling repos the user names) | No cluster exists and none is planned (user statement) |
| Several replicas / HA required | The app will run on a single VM / host (user statement or existing setup) |
| Autoscaling required | User states low traffic and no HA requirement |
| Several services needing service discovery | Library / CLI (nothing runs) |
| CronJob sharing the API's image | |
| Several environments needing identical deployment shape | |

- Cluster available and no CONFIRMED "Against" -> **Recommended**.
- Any CONFIRMED "Against" -> **Not Recommended** (no cluster: creating one is
  infrastructure, out of scope - say so even if HA is needed).
- No CONFIRMED signal about cluster, hosts, traffic or HA -> **Unknown**. A single-
  service repository with no deployment information is Unknown, not Not Recommended.

Which Kubernetes resources to generate and their operational values:
`targets/kubernetes.md`.

## 9. Operational values

Values that decide capacity, networking or placement - ports, replicas, resource
requests / limits, autoscaling bounds, namespaces, hosts, URLs, schedules - come
**only** from evidence:

```
1. Existing deployment files (manifests, compose, unit files, CI variables)
2. Application configuration and code (stack reference lists the sources)
3. User statement
```

- Framework or platform conventions are not evidence. "ASP.NET Core usually listens
  on 8080", "HA means 2 replicas", "Services use port 80" are guesses.
- A value with no evidence is `Unknown` in the Assessment, with the reason
  (e.g. `Replicas: Unknown - HA is required, minimum replica count is not defined`).
- Generation with a required value still `Unknown`:
  - If it can be supplied per environment at deploy time, emit a **fail-closed
    placeholder**: a named variable the deploy job substitutes and checks
    (`: "${REPLICAS:?REPLICAS must be set}"`), listed under Manual setup as "must
    decide". Never a plausible-looking literal.
  - If it cannot (it shapes the file itself, e.g. the port the app listens on, which
    probes and the Service depend on) -> **Gate 7**.
- Generic, non-capacity defaults are allowed when stated as `INFERRED` in the
  Assessment: rollout strategy (`maxSurge: 1`, `maxUnavailable: 0`), probe timing,
  history limits, restart policies. They are tunable, not environment facts.
