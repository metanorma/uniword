# 023: DRY header/footer wiring logic (body.rb vs package_serialization.rb)

## Status: COMPLETED via TODO.validate/09

The duplication is gone the way this note predicted: after the dual-path
unification (TODO 012) only one path exists. The serializer-side wiring
(`inject_headers`/`inject_footers` + `wire_header_reference`/
`wire_footer_reference`, with its divergent `next_rid` strategy) was
deleted; the reconciler's `wire_header_footer_parts` (via `IdAllocator`
on the builder path, `find_or_create_rel` on the legacy path, and a
single `wire_sect_pr_reference`) is the one remaining implementation.

## Problem

Header/footer rId wiring is implemented in two places with slightly different
behavior:

### Reconciler (body.rb:97-162)
- `wire_builder_headers_footers` — wires builder-path headers/footers
- `wire_parts_to_rels` — creates rels with `find_or_create_rel`
- `wire_sect_pr_reference` — updates sectPr references
- Called during reconciliation (Group 1)

### Serialization (package_serialization.rb:297-442)
- `inject_headers` / `inject_footers` — adds content types + rels
- `wire_header_reference` / `wire_footer_reference` — updates sectPr refs
- Called during serialization (inject phase)

Both do the same thing: for each header/footer type, create a relationship,
and wire it into sectPr. The reconciler uses `find_or_create_rel` (idempotent),
the serializer uses `next_rid` (always new). This means:

1. The reconciler wires correct rIds during reconciliation
2. The serializer may add DUPLICATE rels during serialization (it checks
   `rels.relationships.any? { |r| r.target == target }` but only skips if
   the reconciler already added the exact target)

The TODO 009 fix made the reconciler wire rIds first, and the serializer
checks before adding. But the sectPr wiring logic is duplicated:
`wire_sect_pr_reference` (body.rb) vs `wire_header_reference`/`wire_footer_reference` (serialization.rb).

## Fix

Extract a shared `HeaderFooterWiring` module with a single
`wire_reference(sect_pr, kind, type, r_id)` method. Both the reconciler
and serializer call this shared method.

Long-term (after TODO 012 dual-path unification), only one path will exist
and this duplication will be eliminated naturally.

## Files
- `lib/uniword/docx/reconciler/body.rb` (lines 97-162)
- `lib/uniword/docx/package_serialization.rb` (lines 297-442)
