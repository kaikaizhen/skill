# Organization Workspace

Copy this file to `PROFILE.md` and fill it in for your organization. `PROFILE.md`
itself is git-ignored - it is organization knowledge and must never be published.

Manifest and entry point for the organization this installation serves. Replacing
this folder is how the engine is pointed at a different organization.

**Keep this file small.** It answers only: who is this workspace for, where is its
knowledge, what state is it in, and where does routing start. Architecture,
repository lists, search design, DB schema, business rules, API documentation,
authentication flows and infrastructure knowledge all belong in `workspace/memory/`,
never here. It is not loaded on every task - routing that already knows the target
repository or knowledge unit should go straight there.

## Organization

```
Organization:   <organization name>
Namespaces:     <namespace or marker that identifies this organization's code,
                 e.g. Acme.*>
Knowledge Root: workspace/memory/
Onboarded:      <repositories onboarded so far - empty on a fresh install>
Initialization: new - run Mode B against the first repository to seed memory
```

## Memory Layers

| Layer | Holds | Path |
|---|---|---|
| `global/` | organization-level concepts true across repositories and domains | `workspace/memory/global/` |
| `shared/` | behaviour proven across more than one repository, per domain / infrastructure | `workspace/memory/shared/` |
| `repositories/<repo>/` | one repository's own implementation and conventions | `workspace/memory/repositories/` |
| open questions | `Blocking Now:` items awaiting evidence | `workspace/memory/unknowns.md` |
| corrected beliefs | guard rails against re-adopting a known-wrong understanding | `workspace/memory/corrections.md` |

Seed `unknowns.md` and `corrections.md` from `templates/unknowns.md` and
`templates/corrections.md` when you first need them. A repository folder is created
from `templates/memory/repositories/_REPO_TEMPLATE/` (or `_LOAD_TEST_TEMPLATE/` for a
caller/tooling repository); a `global/` or `shared/` unit from
`templates/memory/_LAYER_TEMPLATE.md`.

## Organization-Specific Procedures

Tooling and companion knowledge sources that exist only at this organization live in
`workspace/references/`, not in the engine's `references/`. List them here so routing
can find them:

| File | Load when |
|---|---|
| `workspace/references/<tool>.md` | <the trigger that should load it> |

## Domain Routing & Known Traps

Entry hints only - each line points at the file that authoritatively owns the
knowledge. Fill in as Mode B onboarding discovers them.

| Request | Start at | Trap to respect |
|---|---|---|
| <a recurring kind of question> | `workspace/memory/...` | <the misreading that costs time> |

## Boundary Rules

- Organization-specific knowledge belongs under this workspace. Reusable operating
  procedure belongs in the engine (`SKILL.md`, `references/`, `templates/`) and must
  never be stored here.
- **Current repository evidence overrides workspace memory**, always. Memory is
  navigation and historical knowledge, not current truth.
- Writing anything here goes through the admission gate in
  `references/memory-admission.md`; scope paths resolve to
  `workspace/memory/global/`, `workspace/memory/shared/` and
  `workspace/memory/repositories/`.
- An organization policy that is *not* universal (review counts, ticket-system
  approval, environment access rules) is organization knowledge and belongs in
  `workspace/memory/global/`, never promoted into an engine safety rule.
