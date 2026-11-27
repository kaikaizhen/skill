# UI Visibility & Port Checks (a page element that compiles but never shows)

Load when a change touches a **server-rendered page with client-side show / hide**:
porting a change onto a branch whose UI differs ("logic identical, UI follows the
base"), adding or moving a form field, restyling controls, or any page that has more
than one entry path (normal, special redirect, validation post-back).

A page can compile, pass its unit tests and still lose a field: nothing shows it, a
guarded call silently does nothing, or the base branch removed the mechanism the
field relied on. The user must not be the one who finds it. Run these checks
**before** the report, at a depth proportional to the page - one screen, not a
repository sweep.

## 0. Run this unasked - detection is part of the edit, not an answer to a question

Do not wait for the user to notice something odd. Whenever you finish editing or
porting such a page, **before the first report**, run the trunk comparison yourself:

1. Take the trunk's version of each touched page / script (`git show origin/<trunk>:path`).
2. Extract and diff the **inventories** of trunk vs current: element ids, handler /
   function names, CSS classes that gate visibility, model-state keys, validation
   messages, form field names, query / redirect parameters.
3. Every entry the trunk has and the current file lacks is a suspect. Trace each to
   one of: intentionally removed by the ticket, replaced by an equivalent (name it),
   or **lost** (broken port, removed mechanism, rename, silent no-op). Only `lost`
   is reported; the other two are dropped.
4. Run sections 1, 4 and 6 on what you touched.

This is a mandatory step of the implementation, like compiling. A reply that says
"done" without this comparison having been run is incomplete.

## 1. Visibility matrix - every element touched, every entry path

For each element added, moved, restyled or whose container changed, write one row:

```
Element            Initial render         Opened by (path:line)          Hidden by          Entry paths checked
#residentialCht li display:none (Razor)   goToRegistrationForm :1267     -                  normal ✔ / redirect ✔ / post-back ✔
```

- **Initial render**: the inline style, CSS rule or class state the first response
  carries - including a value the *server template* computes from a model field.
- **Opened by**: the exact code that makes it visible, at `path:line`. **No opener
  = `UNREACHABLE`**, reported as a finding, never "done".
- **Entry paths**: normal flow, each special entry (redirect / `ReturnUrl` / campaign
  flag), the page re-rendered after a validation error, and back-navigation. The
  re-rendered page is the usual loser: its server-computed state differs from the
  first load.
- One defect of this class found -> check **every sibling** controlled by the same
  mechanism before reporting; the second one is usually there.

## 2. The base removed or replaced a show / hide mechanism

When the branch you build on replaced how steps or fields are revealed (a CSS rule,
a marker class, a wrapper element, a JS loop), then for **every element that used
the old mechanism** find its new opener. Compare the base against the trunk it came
from: an element that had an opener there and has none here is an **inherited base
defect**. Report it in the first reply as `既有 / 來自基底分支`, with the one-line fix
and who owns it - do not wait to be asked, and do not silently absorb it into your
diff unless it is inside the approved scope.

## 3. "Controlled by a backend parameter" - trace the value to its setter

Server-rendered `display:` / `class` is frozen at render. Before accepting or
repeating "the backend controls it", find where the value is **set**: a model field
bound from a hidden input the client writes (the *client* decides), a controller /
service assignment (the server decides), or a query / redirect parameter. State which
one, with `path:line`. A flag nobody on the server ever sets is a client-driven flag
that only changes on a post-back.

## 4. Cross-file and cross-scope calls fail silently

- A function declared inside a ready-callback, IIFE or block is **not** a global. A
  call such as `if (typeof window.fn === 'function') window.fn()` from another file
  then does nothing and raises nothing. For every cross-file call, confirm the symbol
  is actually exposed where the caller looks (`window.fn = fn` at the definition), or
  that the caller fails loudly.
- Order of execution: the exposing code must have run before the caller. Name both
  `path:line`.
- A call placed before an existing step may break that step if it throws; place new
  calls **after** the established ones, or guard them so they cannot abort the rest.

## 5. Port fidelity - "logic identical, UI follows the base"

- Diff the **logic carriers** (validation, ranges, flags, bit values, branch
  conditions, server-side rules) separately from the **UI carriers** (markup, CSS
  classes, element ids). Port the first verbatim; adapt only the second.
- When the UI base stores the same data in different fields (e.g. one `yyyy/MM`
  value instead of separate year and month numbers), write the field mapping once,
  keep the rule identical, and state the swap so the user can accept or reject it.
- A range or rule must match **every other screen that reads or edits the same
  data** (registration vs profile edit, web vs app). A narrower or wider range on one
  side makes saved values vanish or fail on the other: grep the sibling screen once
  and state the comparison.

## 6. Scripted edits to view files - prove the page still parses

After any bulk rename or regex edit in a view or inline script: extract each inline
`<script>` block, replace server-side tags with placeholders, run `node --check`
(or the project's equivalent), then confirm every id and function name the script
references still exists in the markup. A renamed function declaration or a handler
that never binds is invisible to the compiler.

## 7. Visual parity with siblings

For a new or restyled control, compare its box (height, border, radius, vertical
alignment) with the neighbouring controls in the same form. Differences that exist
in the base are reported as inherited, one line each, in the same first reply; those
you introduce are fixed before reporting.

## 8. What the reply must say - only confirmed problems, no noise

Report **only what is established from the code**, and above all **regressions**:
something the trunk (`main`) does that this branch no longer does - a field that
used to show and does not, a rule that used to run and was dropped, an entry that
disappeared. For each one: what the trunk does (`path:line`), what the branch does
now (`path:line`), and the cause (the base removed the mechanism, a rename broke a
handler, a call is a silent no-op, ...).

Do **not** list: generic caveats ("not run in a browser", "not compiled"), guesses
that were not traced, open decisions the user already knows about, or every item you
looked at that turned out fine. A suspicion is traced to a confirmed finding first,
or dropped; the user's report must stay short enough that every line demands action.
When nothing is wrong, say so in one line - the visibility matrix stays in the
working file, not in the reply.
