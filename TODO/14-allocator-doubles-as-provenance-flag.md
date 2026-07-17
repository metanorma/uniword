# 14 — `allocator` doubles as a "builder authored this" provenance flag

**Priority:** Medium (design smell; caused two rejected fixes)
**Files:** `lib/uniword/docx/reconciler.rb`,
`lib/uniword/docx/reconciler/{tables,notes,body,referential_integrity}.rb`,
`lib/uniword/docx/package_serialization.rb`

## Problem

`allocator` is named and documented as an ID allocator, but its
*presence* is used throughout the reconciler and serializer as a
provenance flag meaning "a builder authored this content, so its IDs and
rels are already correct — skip the repair."

Confirmed gates:

- `tables.rb:18` — `if allocator` → cell-order-only instead of full table
  repair
- `notes.rb:95` — `unless allocator` → skips note renumbering/backfill
- `body.rb:179` — `next if allocator` → skips paragraph/rsid backfill
- `body.rb:53` — header/footer backfill
- `referential_integrity.rb:18` — `if allocator` → builder-only validation
  instead of dangling-reference repair
- `package_serialization.rb:194, 221` — `return if allocator`; and
  `:320, :349, :375` — `next if allocator`. Together these skip
  relationship creation.

## Why this is a trap

The two facts — "IDs were seeded from a template" and "a builder authored
this content" — are not the same, but one nil check tests both. Setting
`allocator` on a loaded document is the natural-looking fix for rId
preservation, and it silently disables six repair passes at once. This
was attempted twice while fixing TODO/01 and rejected both times; the
reviews found orphaned parts, dropped image rels, and lost paraId/rsid
backfill, none of which any fixture caught.

`document_root.rb:120` even advertises the field as "Central ID allocator
— preserves IDs across build/save cycle", which is exactly the reading
that leads to the trap.

## Fix

Separate the two concepts. Either:

1. an explicit `builder_authored: true` (or a `Provenance` value object)
   set by the builders, with every `if allocator` gate rewritten to test
   *that* — leaving `allocator` free to mean only "where ids come from";
   or
2. push each decision to the object that owns it, so the reconciler asks
   "does this need repair?" rather than "did a builder make this?"

Option 1 is the smaller change and unblocks TODO/13.

## Verification

With provenance separated, setting an allocator on a loaded document must
leave table repair, note renumbering, paragraph backfill, and
dangling-reference repair all still running.
