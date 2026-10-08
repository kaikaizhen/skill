# Explanation Standard

How any human-facing output is written: a Mode C answer, a Mode B onboarding
summary, and the prose of a Mode A report. Load when writing an explanation for a
reader, not when deciding what is true (that is the gates and the evidence rules).

```
Default assumption: the reader is seeing this system, this codebase and this
domain vocabulary for the FIRST time.
```

The goal is not to deliver a conclusion. It is to leave the reader able to retrace
the behaviour themselves:

```
what the term means -> where the data comes from -> who produces it
-> what triggers it -> which layer handles it -> what it does -> what it affects
```

---

## 1. Explain every term on first use

No English word, abbreviation, project name, class, method or field is used before
it is explained. For a project-specific name, keep four things apart:

```
the program name          the literal translation
its role in THIS system   whether the business meaning is confirmed
```

Weak: *"ranking is handled by the search engine."*

Better: *"`<Flag>` is this project's name for results that must appear before the
ordinary ones - a pinned or promoted entry. It is the program's own label, not a
general English term."*

If the business meaning is not evidenced, say exactly that instead of inventing it:
*"From the query it behaves as a pinned/promoted entry, because the request filters
on `<field>` and places those rows first. Whether the business calls it `<name>` is
not confirmed from the repository."*

## 2. Translating the word is not explaining it

Give the role in *this* system, not a dictionary gloss:

| Term | Not enough | What the reader needs |
|---|---|---|
| Repository | "a store" | the layer that talks to an external data source - builds the request, calls the API or database, returns the response to the service |
| Controller | "a controller" | the first layer an HTTP request reaches: takes parameters, calls the service, turns the result into an HTTP response |
| Service | "business logic" | where the business flow lives - which data to fetch, how to combine it; not HTTP handling |
| DTO | "an object" | Data Transfer Object - the shape of data passed between layers or returned by an API |
| DSL | "a language" | Domain-Specific Language - here, the search engine's JSON query syntax (`bool`, `must`, `must_not`, `term`) |

The same applies to a project's own method and component names: one line of role on
first mention. *"`<Method>` wraps the external call and converts a timeout or HTTP
error into a safe empty result"* - never the bare method name.

## 3. A field or value needs its provenance

For any unfamiliar field, answer four things:

```
who produces it     where it lives      who reads it      how it is used
```

Weak: *"`<field>` decides whether it is promoted."*

Better: *"`<field>` is a field on each document in the search index. **Produced by**
the indexing pipeline when the record was written - not computed by the controller
at request time. **Obtained** because the service asks for it in the request's
`fields` list, so the engine returns it with each hit. **Used** by `<Component>` to
decide whether the row carries the promoted attribute."*

State what it is **not**, when a reader would plausibly assume otherwise.

## 4. Every action names its actor

Forbidden as a complete explanation - each hides the actor:

```
"自己設定" · "自己處理" · "系統自己判斷" · "自動處理" · "原本就有"
"預設會處理" · "內部處理" · "it just handles it" · "the system does it"
```

They are allowed only when the actor is named in the same breath.

Weak: *"the bucket is decided automatically."*

Better: *"`<CallerService>` puts the visitor identifier in the `<Header>` request
header. When the request reaches `<ExternalService>`, **`<ExternalService>`'s own
server side** decides which bucket it belongs to. We can confirm the split happens
there; without that service's documentation we cannot claim *how* it decides."*

## 5. Who, where, when, why - as an ordered chain

An important behaviour is explained as numbered steps, each with its actor, so cause
and effect are visible:

```
1 <Caller> builds the first query
2 <Caller> calls <Engine>
3 <Engine> returns the matching rows
4 <Caller> extracts their ids from the response
5 <Caller> adds those ids to the second query's exclusion list
6 <Engine>, on the second call, no longer returns them
7 <Caller> concatenates the two result sets
```

Then name the ownership conclusion: *"so the exclusion list is built by `<Caller>`
from its own first result, not produced by `<Engine>`."*

## 6. Keep responsibility boundaries visible

Attribute each step to its layer, never to "the system":

```
client / frontend -> controller -> service -> query builder -> repository
-> external API / search engine / database / cache / message queue
-> repository -> service (mapping) -> controller -> response
```

"The system handles it" collapses the exact boundary the reader is trying to find.

## 7. Comparing old and new: expand both sides

Never *"the new version moved it to the server side."* Write both flows step by step,
then say what actually changed:

```
Old:  <Caller> builds query A -> <Engine> -> <Caller> extracts ids
      -> <Caller> excludes them from query B -> <Engine> -> <Caller> merges
New:  <Caller> sends one query -> <Engine> applies that handling internally
      -> <Engine> returns results -> <Caller> maps the response
```

Then the honest conclusion: *"what the new version removes is the client-side
compensation that existed because the old engine did not do this itself - not the
ordinary search conditions."*

## 8. A program name is not a business name

Names like `Top`, `Recommend`, `Ads`, `Boost`, `Rank`, `Score`, `Bucket` may not be
mapped onto business vocabulary without evidence. Report it in layers:

```
program name -> observed behaviour (with the code evidence)
-> whether the business name is confirmed
```

Only once evidence exists: *"in this project `<name>` is `<business term>`."`

## 9. Explaining an API or a header

Cover: who sends it · to whom · why · who acts on it · what comes back.

Weak: *"sending the identifier enables the split."*

Better: *"it is an HTTP request header. **Sent by** `<Caller>` when calling
`<ExternalService>`. **Purpose**: let that service recognise the same visitor across
requests and use it as input to its own routing. **Decided by** `<ExternalService>`,
not `<Caller>`. **Returned**: the response carries the results; it does not
necessarily expose how the decision was made."*

## 10. A derived number needs its origin

Weak: *"the offset is 10."*

Better: *"the offset is what `<Caller>` recorded as the number of extra rows the main
search returned beyond its page size - page size 30, 40 returned, so 10 extra are
treated as promoted and the offset becomes 10. On a page with no extras it is 0."*

If the origin is not fully confirmed, say so rather than presenting it as settled.

## 11. Define a formula's variables before the formula

Never drop `from = (page - 1) * n - offset` on the reader. First each variable - what
it is and who sets it - then the formula, then a worked example, then the edge case:

```
page    the page the reader is viewing
n       how many rows this step takes per page
offset  extra rows the previous step already consumed
from    the starting position sent to the engine

page 2, offset 10  ->  (2 - 1) * 3 - 10 = -7
```

Then state what the receiving system actually does with a negative value - per
version if the versions differ - or mark it `UNKNOWN`.

## 12. Separate confirmed, inferred and unknown

Every load-bearing statement is labelled. The five statuses and their definitions are
`memory-system.md` §5 - do not restate them here; just use them, and never present an
inference as a fact:

```
CONFIRMED  the request requires the identifier header
CONFIRMED  both variants use the same endpoint
INFERRED   the split probably uses a stable hash
UNKNOWN    the actual algorithm and the ratio
```

## 13. Localise a fault before naming a culprit

Never *"the new API is broken."* Walk the layers and say where the difference first
appears:

```
is the query the client builds identical?
-> is the request actually sent identical?
-> is the variant / routing the same?
-> does the engine honour every condition sent?
-> is the response already different?
-> does client-side mapping re-sort or filter afterwards?
```

The answer names the first layer where the two runs diverge.

## 14. The no-chasing test

Before delivering, check whether the reader could still reasonably ask:

```
where did this value come from?   who set it?   what triggers it?
is this the client or the server?   what does this name mean here?
```

If any of those remain, the explanation is incomplete - answer them in advance.

## 15. Order of an answer

```
1 answer the question directly
2 explain the terms and names it depends on
3 where the data comes from
4 which layer handles it
5 what triggers it
6 the full flow, step by step with actors
7 why the present result happens
8 old vs new, if both exist
9 confirmed / inferred / unknown
10 recommendation, last
```

Do not open with a wall of unexplained vocabulary. Concise is fine; vague is not -
never drop a causal link to save space. For a first-time reader *"where does this
come from"* matters more than *"what is it called"*.
