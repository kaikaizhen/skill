# Existing Data Strategy First

Part of **Gate 7** (`consistency-gate.md` §1), not a separate gate and not a separate
workflow. Loaded when the requirement touches how data is **identified, updated,
deleted, copied or restructured** - the usual case being "this identifier column is
going away, what replaces it".

**Core principle: find out how the existing projects already solve the same business
problem, then decide whether a new mechanism is needed at all.** Where an existing
data strategy can be reused safely, reuse it; design a new identity only when the
existing ones genuinely cannot meet the requirement.

Depth follows the tier (`risk-tiers.md`): **L1** looks at the target feature and its
direct dependencies only · **L2** checks whether the relevant modules already have a
solution · **L3** compares across the repositories that genuinely share this data or
contract. **"Check project consistency" never means "scan every repository in the
company"** - only the repositories and functions actually affected by this change.

## 1. Establish each project's real data strategy


When the requirement touches how data is **identified, updated, deleted, copied or
restructured**, establish what each affected repository already does for the *same
business function* - **before** designing any new mechanism. Removing `rowguid` is
not a cue to invent a composite GUID, a hash, an index or a new identity column; it
is a cue to go and read how the live projects already save that data.

Tell these strategies apart, and keep **read**, **write** and **externally exposed**
identity separate - one function often uses different ones:

```
a database primary key identifying one row      a rowguid / other GUID
a business composite key                        an order or index mapping
delete the whole set, then insert it again      some other existing mechanism
```

Two cautions that invert the usual conclusion:

- **A column existing does not mean the function depends on it.** It may be declared,
  projected by `select *`, and never read.
- **A repository having a batch-update method does not mean every single-row feature
  can be removed.** The batch method is a write strategy; a single-row edit may be a
  live product capability with its own consumers.

Record the result as a cross-repository comparison - **only for the repositories and
functions actually affected**, filled from code, never guessed:

| Repository | 功能／API | 目前處理方式 | 是否依賴原識別碼 | 是否有替代的既有處理方式 | 證據 |
|---|---|---|---|---|---|

Then judge whether what exists is already enough. Preferred order - a design
preference, not an unbreakable sequence:

```
1  reuse an existing data-handling flow that already satisfies the requirement
2  extend that existing flow to cover this requirement
3  use an identity mechanism the project already has, whose meaning is correct
4  only then adjust the data contract or add a new identity mechanism
```

A new mechanism is considered only when the options above cannot meet the requirement
or would carry higher risk.

## 2. Whole-Collection Replacement - evaluate it first

If an affected project already does *"delete every detail row of this parent, then
insert the complete set again"*, that flow is a **first-class candidate**:

```
today      find one row by rowguid -> single UPDATE / DELETE
existing   read the whole set -> change it -> DELETE the old set -> INSERT the new set
```

If the requirement can be met with that existing batch capability, prefer it over
adding a GUID, hash or index. Confirm all eight first:

1. can it really achieve the same business behaviour?
2. does the user need an immediate single-row update?
3. does another table reference the individual detail rows?
4. does rebuilding the set affect audit, history or data integrity?
5. do the DELETE and INSERT need one transaction?
6. can concurrent updates overwrite each other?
7. does it change an external API contract?
8. is there a case where batch update cannot be used?

**Delete-all-then-insert is a write strategy, not a single-row identity strategy.**
Where a feature must map an external result back to one specific detail row, a
suitable temporary or durable identity is still required - and **an index may not
replace an identifier until the mapping has been verified** (§4).

## 3. Do not add an identity mechanism that is not needed

Warn **before** proposing any of these:

- a batch-update flow already exists, yet a GUID generator is added beside it;
- the API field name is kept while the identifier now holds a value of different
  meaning;
- there was no durable single-row identity requirement, yet an identity column is
  added;
- a suitable business identity already exists, yet a hash is built instead;
- an index replaces an identifier without frontend and backend ordering being
  confirmed identical;
- several similar-looking identity mechanisms with different purposes are added to
  preserve an old interface.

Before any new identity mechanism, answer one question in writing:
**why can the existing data strategy not meet this requirement?** Without a concrete
answer, the new mechanism may not be the recommended option.

