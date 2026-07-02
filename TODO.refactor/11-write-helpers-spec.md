# 11 — Write `spec/uniword/docx/reconciler/helpers_spec.rb`

**Priority:** High (spec gap)
**Files:** New `spec/uniword/docx/reconciler/helpers_spec.rb`

## Problem

`lib/uniword/docx/reconciler/helpers.rb` (264 lines) is the shared
utility module mixed into every other reconciler module. It has zero
direct tests — only exercised through integration tests in
`reconciler_spec.rb` (1980 lines, hard to navigate).

## Required coverage

### ID generation
- `generate_rsid` returns uppercase hex string of expected length
- `generate_hex_id(name, length)` returns correct length
- `hex_derive(name, length)` is deterministic

### Traversal (after fix 06)
- `walk_body` yields paragraphs in element_order
- `walk_body` yields tables in element_order
- `walk_body` falls back to arrays when element_order is nil
- `walk_body_paragraphs` filters out tables
- `walk_table_paragraphs` recurses into rows/cells

### Run utilities (delegating to RunUtils)
- `empty_run?(run)` returns false for runs with break/tab/text/drawings
- `empty_run?(run)` returns true for runs with nothing
- `strip_empty_runs(paragraph)` removes empty runs and records R-fix
- `strip_empty_runs_from_notes(entries)` iterates all entries

### element_order manipulation
- `ensure_element_in_order(model, tag, after:)` inserts after specified tag
- `ensure_element_in_order(model, tag, before:)` inserts before specified tag
- `ensure_element_in_order(model, tag)` appends when no anchor
- Returns early if tag already in order

### `document_fingerprint`
- Returns same fingerprint for same document
- Returns different fingerprint for different documents
- Memoized across calls

## Approach

Build a `Reconciler` instance with a real Package + DocumentRoot.
Call public helpers via the reconciler instance. No doubles.
