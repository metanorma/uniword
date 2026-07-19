# 04 — General frozen element_order solution (one mechanism, not per-model patches)

Status: DONE
Priority: P1
Absorbs: the piecemeal fixes in footnotes.rb, endnotes.rb,
toc_generator.rb

## Context

lutaml-model returns a frozen `element_order` array for parsed models.
Mutating it raises FrozenError. The class of bug has been patched
three times with local workarounds: `Footnotes#sync_element_order`,
`Endnotes#sync_element_order`, `TocGenerator#insert` (dup-then-mutate),
plus a fourth pattern in `Reconciler::Helpers#thaw_and_insert`. Each
new mutation site is a potential repeat — the fix must be one
mechanism, not a fifth workaround.

## Goal

- One canonical way to mutate `element_order` safely:
  a small `Lutaml`-level utility (e.g.
  `Uniword::Lutaml::ElementOrder` module) offering
  `mutable_order(model)` (returns a thawed/dup'd order, assigning it
  back once) plus `insert_in_order(model, name, after:/before:)` for
  schema-position-aware inserts (today's `ensure_element_in_order`
  semantics).
- Migrate all four existing sites to it (reconciler helpers,
  footnotes/endnotes sync, toc generator).
- A spec that parses each affected model from XML and exercises the
  mutation paths (parse → mutate → serialize), locking the class out.

## Design constraints

- Same forbidden-construct and autoload rules; the utility lives in
  one file under an appropriate namespace, autoloaded from its
  immediate parent.
- Do NOT monkey-patch lutaml-model classes; the utility wraps them.
- Keep the element-order lint (spec/lint/element_order_spec.rb) green —
  inserts must land in schema position.

## Acceptance

- One utility file owns frozen-order handling; the four migrated
  sites call it.
- New regression spec: parse → mutate → serialize for footnotes,
  endnotes, body (toc insert), settings (updateFields path).
- `bundle exec rspec spec/uniword/wordprocessingml/ spec/uniword/docx/
  spec/uniword/toc/ spec/lint/` green.

## Completion notes

Completed 2026-07-19.

### The mechanism

New `Uniword::Ooxml::ElementOrder` (lib/uniword/ooxml/element_order.rb,
autoloaded in lib/uniword/ooxml.rb) — the single element_order
mutation point:

- `mutable_order(model)` — thaw on demand (frozen parsed array → dup
  assigned back; mutable arrays returned as-is, so repeated mutations
  keep hitting the registered array).
- `append(model, entry)` — repeatable append.
- `insert_at(model, position, entry)` — positional insert for
  repeatable elements (toc SDT).
- `insert_once(model, name, after:/before:/position:)` — idempotent
  singleton insert with the existing anchor fallbacks (after → end,
  before → start).

No monkey-patching of lutaml-model classes.

### Namespace detour (recorded)

The utility first landed as `Uniword::Lutaml` — immediately reverted:
that name shadows the gem's top-level `Lutaml` inside `module Uniword`
and breaks every model (`Lutaml::Model` resolved to the nonexistent
`Uniword::Lutaml::Model`). It lives in `Uniword::Ooxml` (the
OOXML-serialization namespace it belongs to).

### Migrated sites

- `Reconciler::Helpers#ensure_element_in_order` and
  `#insert_element_order` — now thin delegators (reconciler call sites
  in parts.rb/tables.rb unchanged); `thaw_and_insert`/`thaw_and_append`
  deleted.
- `Footnotes#sync_element_order` / `Endnotes#sync_element_order` — use
  `mutable_order` (dup-per-call workaround gone).
- `TocGenerator#insert` — uses `insert_at` (frozen dup gone).

### Verification

- New `spec/uniword/ooxml/element_order_spec.rb` (12 examples):
  mutable_order thaw/register-back, insert_once anchor and fallback
  semantics, idempotence, insert_at, append, plus parse → mutate →
  serialize regressions for footnotes, endnotes, body TOC insert, and
  the settings updateFields path (insert lands after
  characterSpacingControl).
- `spec/uniword/ooxml/ spec/uniword/wordprocessingml/
  spec/uniword/docx/ spec/uniword/toc/ spec/lint/` — 1307 examples,
  0 failures.
- RuboCop: element_order.rb clean; helpers 33→29, toc_generator 10→9,
  foot/endnotes unchanged.
