# 10 — rId stability through round-trip; IdAllocator as single authority

Status: PENDING
Priority: P2 (structural)
Depends on: 09 (unified parts/wiring)
Absorbs: TODO/01-preserve-rids-through-roundtrip.md

## Context

`Docx::IdAllocator` rebuilds `document.xml.rels` from its `[target, type]`
registry; insertion order differs from the loaded file, so round-tripped
rIds shift (`rId8`→`rId9`). Three examples in
`spec/integration/docx_roundtrip_spec.rb` are permanently `skip`ped over
this (see TODO/01). Meanwhile the legacy path renumbers every rId
(`reconciler/package_structure.rb:155-243`), and
`PackageRelationships.next_available_rid`
(`lib/uniword/ooxml/relationships/package_relationships.rb:27-32`) plus
serializer-side `next_rid` allocate outside the allocator.

## Goal

1. `IdAllocator` is the single rId authority for ALL rels parts (document,
  package, settings, theme, etc.): `seed_from_rels` preserves existing rIds
  verbatim so a load→save round-trip is rId-stable; new allocations take
  the next free id without renumbering existing ones.
2. Remove the legacy renumbering path and all out-of-band allocation
  (`next_available_rid` scans, serializer `next_rid`) — route everything
  through the allocator. Grep must prove no other site assigns rIds.
3. Unskip and fix the 3 skipped `docx_roundtrip_spec.rb` examples.

## Acceptance

- A fixture with many relationships (styles, numbering, images, hyperlinks,
  headers/footers) round-trips with byte-identical rIds (spec).
- The 3 previously skipped examples pass unskipped.
- `bundle exec rspec spec/uniword/docx/ spec/integration/docx_roundtrip_spec.rb
  spec/integration/round_trip_validation_spec.rb` green.
- Absorbed TODO/01 marked completed; no forbidden constructs.
