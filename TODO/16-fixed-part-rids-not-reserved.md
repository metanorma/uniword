# 16 — A header/footer part's fixed rId can lose its relationship

**Priority:** Low (malformed input; no duplicate id, but a dangling ref)
**Files:** `lib/uniword/docx/package_serialization.rb`,
`lib/uniword/docx/reconciler/package_structure.rb`

## Problem

Serialization emits some relationships with ids taken from a part
collection rather than from `document.xml.rels`. Those ids cannot move.

`reconcile_document_rels` reserves the ones that would otherwise collide:
`fixed_part_rids` (`package_structure.rb`) collects
`document.image_parts` and `document.chart_parts` keys, stops a standard
part from preserving an id a fixed part owns, and lifts the allocation
maximum above them. Images and charts therefore no longer produce a
duplicate `Id`.

`header_footer_parts` is **not** covered. Its entries carry their own
`:r_id`, but a collision there does not duplicate an id — serialization
skips the relationship instead (`package_serialization.rb:375`), leaving
the `sectPr` reference pointing at whatever kept the id.

## Reproduction

Not yet reduced to a minimal script. The shape: a `header_footer_parts`
entry whose `:r_id` equals an id already held by another relationship in
`document.xml.rels`.

## Fix

Either include `header_footer_parts` `:r_id`s in `fixed_part_rids` — the
same treatment images and charts get — or, better, have those parts draw
their ids from the allocator instead of carrying their own, which is the
shape problem behind TODO/13 and TODO/14.

## Verification

A header/footer part whose fixed `:r_id` collides still gets its
relationship emitted, and the `sectPr` reference resolves to it.
