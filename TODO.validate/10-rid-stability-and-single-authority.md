# 10 — rId stability through round-trip; IdAllocator as single authority

Status: DONE
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

## Completion notes

### Design

`Docx::IdAllocator` is the single rId authority. rId namespaces are
per-rels-part, so the allocator scopes its registry/counters
(`:document` for `word/_rels/document.xml.rels`, `:package` for
`_rels/.rels`): `alloc_rid`/`register_rid`/`next_free_rid`/`rid_for`/
`seed_from_rels` all take a scope. `seed_from_rels` preserves loaded
rIds verbatim; only a genuine collision (allocation before seeding, or
duplicate ids in the source) yields a fresh counter allocation for the
seeded pair — uniqueness wins over preservation there. Non-document/
package rels parts (settings, theme, footnotes, endnotes, customXml)
carry no allocations at all: they pass through verbatim on load→save.

Save path: `Package#prepare_allocator` (in `to_zip_content`, before the
Reconciler) guarantees an allocator and seeds it from the package's
current package_rels (scope `:package`) and document_rels. The
Reconciler keeps a lazy fallback (`IdAllocator.populate_from_package`)
for direct use outside `to_zip_content`.

Reconciler document rels assembly is preserve-first
(`Reconciler::PackageStructure#assemble_document_rels`): existing rels
keep position and rId; genuinely new rels (missing standard parts,
builder-registered images/hyperlinks/charts/headers/footers, OLE
embeddings) are appended with allocated ids. Package rels are
preserve-first too. No renumbering, no reference remapping anywhere.

rId authority vs. repair mode are now decoupled: `Reconciler#builder_managed?`
(explicit `builder_managed:` flag from `Package#to_zip_content`, derived
from allocator presence otherwise) selects light-touch vs full
normalization (paraId backfill, table normalization, note renumbering,
semiHidden) — the role `allocator`-presence used to play. Loaded
documents (`Uniword.load → save`) keep full normalization with preserved
rIds; builder/from_template/from_file documents keep light-touch.

### Removed allocation sites (grep proof)

- `PackageStructure#reconcile_document_rels_legacy`,
  `register_legacy_image_relationships`, `update_sect_pr_rid_references`,
  `update_blip_embed_references`, `update_drawing_blip`,
  `update_hyperlink_rid_references` — deleted (was
  `reconciler/package_structure.rb:155-265`).
- `Ooxml::Relationships::PackageRelationships.next_available_rid` —
  deleted; `grep -rn next_available_rid lib/ spec/` → 0 hits.
- Serializer `next_rid` (`docx/package_serialization.rb:186-191`) and the
  rel-writing branches in `ensure_content_type`, `inject_image_parts`,
  `inject_chart_parts`, `inject_embeddings` — deleted; rels are owned by
  the Reconciler; content-type injection only.
- `Reconciler::Body#find_or_create_rel` (used `next_available_rid`) —
  deleted; header/footer wiring always allocates via the allocator.
- `ReferentialIntegrity#derive_unique_rid` — deleted;
  `ensure_rid_uniqueness` is now a safety net that renames pathological
  duplicates via `allocator.next_free_rid` + `register_rid` (no wholesale
  renumbering). `promote_literal_hyperlink` allocates via
  `allocator.alloc_rid` (target-deduped).
- `ChartBuilder`'s literal `"rIdChartN"` ids — now allocated via
  `root.allocator` (chart rIds are numeric `rIdN`); `ImageBuilder`'s
  `"rId#{image_parts.size + 1}"` fallback — now ensures and uses
  `root.allocator`.
- `DocumentBuilder` always carries an allocator (explicit, model's, or
  one populated from the model's rels), so build-time allocations and
  the save path share one registry.

Remaining rId literal sites in lib/ are fixed constants, not allocation:
`PackageRelationships.generate_package_rels` (rId1-3 historical DOTX
layout), `PackageDefaults.build_minimal_rels` (seeded into the allocator
at save), and the allocator's own `"rId#{counter}"`.

### Other changes

- `Package.extract_image_parts` keys loaded image parts by their actual
  document-rel rId (looked up by target), fixing `r:embed` resolution in
  MHTML conversion and ImageManager; unreferenced media (theme-only
  images) gets a synthetic non-colliding key and no longer gains a
  spurious document-level rel (previously added by
  `register_legacy_image_relationships`).
- `Docx::PartCollection` gained `each_key`/`each_value`.
- Same image file added twice now dedups to one part + one rel (both
  drawings reference the shared rId) — replaces silently dangling
  duplicate-key behavior.

### Byte-stability evidence

`spec/integration/docx_roundtrip_spec.rb` gained an
"rId stability through round-trip" group (3 examples):

- `demo_formal_integral_proper.docx` round-trips with every `.rels` part
  byte-identical in Relationship content (ordered Id/Type/Target/
  TargetMode sequences equal). Raw bytes differ only by uniword's uniform
  trailing CRLF line ending (+2 bytes/part, serializer convention, all
  parts, pre-existing).
- `word-template-apa-style-paper.docx` (12+ document rels: styles,
  numbering, headers, image, notes, theme…): every output rel exists
  verbatim in the input and every carried part's rel survives. The only
  loss is `glossary/document.xml` (unmodeled glossary sub-document;
  R32 strips its rel — pre-existing coverage gap, not an rId issue).
- Body `r:id`/`r:embed` references keep their original values.

The 3 previously skipped examples now pass unskipped:
"maintains XML file structure" (APA template) and both ISO examples
("preserves text content", "maintains XML structure" × 2 fixtures).

### Generated artifacts

`examples/generated/` and `spec/examples/generated/` churn was reverted.
One REAL recurring diff to know: builder-created chart rels are now
numeric (`rId1…`, allocated at build time) instead of `rIdChartN`, and
standard-part rIds follow build-order allocation (e.g. charts rId1-3,
styles rId4 in chart_gallery.docx). Body references always match (the
write-time gate enforces it).

### Verification

- `bundle exec rspec spec/uniword/docx/ spec/uniword/builder/
  spec/uniword/ooxml/` — 1016 examples, 0 failures.
- `bundle exec rspec spec/integration/docx_roundtrip_spec.rb` — 15
  examples, 0 failures (incl. the 3 unskipped; ISO fixtures present).
- `spec/integration/round_trip_validation_spec.rb` — 46/0;
  `repair_spec.rb` + `header_footer_unified_path_spec.rb` — 29/0;
  broader integration sweep (8 files) — 870/0; transformation/images/
  headers_footers — 46/0; chart_roundtrip — 8/0.
- `spec/lint/` 32/0; `bundle exec exe/uniword help` OK.
- Forbidden constructs (`public_send`, `.send(`, `__send__`,
  `respond_to?`, `instance_variable_get/set`, `require_relative`):
  0 hits in lib/.
- RuboCop: every touched lib file has same-or-fewer offenses vs HEAD.

### Leftovers

- Glossary sub-documents (`word/glossary/*`) are not modeled; their rels
  are stripped by R32 on save (pre-existing coverage gap, surfaced by the
  new strict spec).
- Saved parts carry a trailing CRLF (serializer convention); `.rels`
  content is byte-identical before that line ending.
- `seed_from_rels` seeds all loaded rels, including ones R32 will strip
  (e.g. removed header parts); new allocations then start above the
  stripped ids — harmless (ids are opaque, uniqueness holds).

