# 04 — General frozen element_order solution (one mechanism, not per-model patches)

Status: PENDING
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
