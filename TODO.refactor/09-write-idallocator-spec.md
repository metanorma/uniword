# 09 — Write `spec/uniword/docx/id_allocator_spec.rb`

**Priority:** High (spec gap — branch centerpiece has zero unit tests)
**Files:** New `spec/uniword/docx/id_allocator_spec.rb`

## Problem

`IdAllocator` is the centerpiece of this branch (deterministic ID
generation). It has 127 lines of logic and **zero unit tests**. Only
exercised indirectly through reconciler integration tests.

## Required coverage

### `alloc_rid`
- Returns new rId for fresh target+type
- Returns same rId for repeated target+type (idempotent)
- Increments counter across calls
- Accepts `target_mode:` argument

### `alloc_footnote_id` / `alloc_endnote_id`
- Returns 1, 2, 3, ... across calls
- Independent counters (footnote doesn't affect endnote)

### `alloc_bookmark_id` / `alloc_comment_id`
- Returns "1", "2", ... across calls
- Independent counters

### `alloc_para_id` / `alloc_rsid`
- Determinism: same call sequence → same output across runs
- **Independence (after fix 01):** interleaving para_id and rsid calls
  produces the same output as calling them in isolation
- Format: 12 hex chars uppercase (after fix 02)

### `seed_from_rels`
- Seeds entries from real Relationship objects
- Updates `@rid_counter` to max existing rId number
- Handles nil relationships argument
- Handles relationships with non-numeric rId suffix (e.g., "rIdChart1")

### `seed_from_notes`
- Seeds footnote counter from existing footnote IDs > 0
- Seeds endnote counter independently
- Handles nil entries
- Skips separator entries (id <= 0)

### `all_rels`
- Returns sorted list of relationship entries
- Sorts by numeric component of rId

### `rid_for`
- Returns rId for registered target+type
- Returns nil for unregistered target+type

### `populate_from_package` (after fix 07)
- Convenience class method combining all seed_from_* calls
- Handles nil fields on package

## Approach

Use real `Uniword::Docx::Package`, `Uniword::Ooxml::Relationships::Relationship`,
and `Uniword::Wordprocessingml::Footnotes` objects — never doubles.
