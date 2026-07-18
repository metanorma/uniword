# 09 — Model-driven package parts, unified header/footer path

Status: DONE
Priority: P2 (structural)
Depends on: 08 (PartRegistry)
Absorbs: TODO/06-fix-header-footer-dual-path.md,
TODO/07-dry-header-footer-wiring.md, TODO/08-model-driven-header-footer-parts.md

## Completion notes

### Design

- `Docx::Part` (`lib/uniword/docx/part.rb`) — value object for one
  package-held part: `definition` (an `Ooxml::PartDefinition` from the
  08 registry, supplying `content_type`/`rel_type` defaults), `r_id`,
  `target`, `content` (model object or raw String), plus verbatim
  `rel_type`/`content_type` overrides for loaded packages and
  `part[:key]` hash-style read compatibility. Subclasses:
  `ChartPart` (`:xml` key alias), `HeaderFooterPart` (adds `type`,
  `kind`, `loaded?` flag, content delegation, `serializable_content`
  which converts legacy `Uniword::Header`/`Uniword::Footer` models to
  their Wordprocessingml counterparts at emit time).
  `CustomXmlItem` stands alone (index/xml_content/props_xml/rels_xml +
  `[]` compat). Bibliography needed no wrapper: `bibliography_sources`
  was already a `Bibliography::Sources` Serializable, not a raw hash.
- Keyed `Docx::PartCollection` backs `chart_parts` (key: rId) and
  `embeddings` (key: target); assignment normalizes legacy hashes and
  raw binaries into Part objects, so every former call site keeps
  working unchanged.
- Unified header/footer store: `DocumentRoot#header_footer_parts` is
  now a `Docx::HeaderFooterPartCollection` (ordered
  `HeaderFooterPart` list). `document.headers`/`document.footers`
  return memoized `Docx::HeaderFooterView`s over that single store.
  The views preserve BOTH historic shapes: Hash-style by sectPr type
  (`headers["default"] = model`, `each_value`, `key?`, `delete` —
  content access) and Array-style over parts (`<<`, `each`, `map`,
  `find`, `reject` — part access with `.type` and content
  delegation), so the Builder, `HeadersFooters::Manager`,
  `Watermark::Manager`, link validation and document statistics all
  share one store. Upsert semantics: assigning an existing type
  replaces that part's content in place (keeping target and rId);
  new types get the next free numbered target (`header3.xml` after
  `header1`/`header2`) — collisions are impossible by construction.
- Load path (`Package.extract_header_footer_parts`) builds
  `HeaderFooterPart`s with original rId/target/rel_type verbatim,
  flagged `loaded`, and derives each part's sectPr `type` from every
  section's references (body-level and paragraph-level sectPr).
- ONE wiring implementation: the Reconciler
  (`Reconciler::Body#wire_header_footer_parts`) wires fresh
  (non-loaded) parts via `IdAllocator#alloc_rid` /
  `find_or_create_rel` and writes the sectPr reference. Loaded parts
  keep the rels and references they arrived with (legacy renumbering
  still remaps them as before). Deleted from the serializer:
  `inject_headers`, `inject_footers`, `inject_header_footer_parts`,
  `wire_header_reference`, `wire_footer_reference`,
  `serialize_headers`, `serialize_footers` (the divergent `next_rid`
  rel strategy and duplicate overrides). The serializer now only
  ensures one content-type override per part and emits one part file
  per store entry, headers before footers (historic order).
- Reconciler consumers updated to the store:
  `ReferentialIntegrity#collect_valid_header_footer_rids` and
  `#header_footer_paths`, `PackageStructure#header_footer_target_present?`
  (now an exact store-target match instead of the fragile
  count-by-number heuristic), `Helpers#walk_all_paragraphs`,
  `Reconciler#clear_stored_namespace_plans`, `Body` mc:Ignorable
  (fresh parts only, as before) and rsid/paraId backfill (historic
  `hdr:N`/`ftr:N`/`hfp:N` seed scheme preserved).

### Migration per part kind

- header/footer: hashes → `HeaderFooterPart`s in the unified store;
  dual storage eliminated (see above).
- charts: `document.chart_parts` values `{xml:, target:}` →
  `ChartPart`s in a `PartCollection`; extraction, builder, injector
  and referential-integrity call sites unchanged via `[]` compat.
- embeddings: `Package#embeddings` / `DocumentRoot#embeddings`
  `target => binary` → `target => Part` in a `PartCollection`;
  serializer emits `part.content`.
- customXml: item hashes → `CustomXmlItem` objects; Package writer
  normalizes legacy hash arrays (spec API preserved).
- bibliography: already model-driven (`Sources`); untouched.

### Dual-path unification proof

Before (reproduced on `spec/fixtures/docx_gem/basic.docx` — 2 headers
+ 2 footers loaded, then Builder adds a `first` header): the new
header was silently dropped, its sectPr reference pointed at the even
header's part (two refs sharing rId9), and no `header3.xml` was
emitted. After: output carries 5 parts, 5 rels (unique ids and
targets), 5 content-type overrides (unique), every sectPr reference
resolving to a rel of the matching kind, and the builder content in
`word/header3.xml` — the write gate passes. Locked in by the new
acceptance spec `spec/integration/header_footer_unified_path_spec.rb`
(add-new-type and replace-existing-type scenarios, view API, second
round-trip stability).

Byte-comparison of round-trips (both `Uniword.load`+save legacy path
and `Package.from_file`+save allocator path) against pre-refactor
output for header-bearing fixtures (basic.docx, APA/MLA paper
templates): identical except `dcterms:modified` timestamps and one
real fix — the APA legacy-path output previously contained a
spurious duplicate relationship (`rId12` and `rId10` both targeting
`header2.xml`, re-added by the deleted serializer-side injector when
the original rId got renumbered); it now emits exactly one rel per
part. That duplicate was the TODO/06 bug firing on a pure round-trip.

### Verification results

- `spec/uniword/docx/` + `spec/uniword/ooxml/`: 486 examples, 0 failures
- `spec/uniword/builder/` + `spec/uniword/docx/`: 813 examples, 0 failures
- `spec/integration/docx_roundtrip_spec.rb`, `repair_spec.rb`,
  `round_trip_validation_spec.rb` (+ docx/ooxml re-run): 565 examples,
  0 failures (23 pendings are absent html2doc fixtures, pre-existing)
- acceptance spec: 11 examples, 0 failures
- `spec/lint/`: 32 examples, 0 failures; `exe/uniword help` OK
- forbidden constructs (`public_send`, `.send(`, `__send__`,
  `respond_to?`, `instance_variable_get/set`, `require_relative`):
  zero hits in lib/
- rubocop: no new offenses on any touched lib file (reconciler.rb,
  body.rb, package_structure.rb improved; new files clean)

### API compatibility notes

- `document.headers`/`footers` now return live views (never nil);
  `||= {}` / `||= []` idioms short-circuit onto the view. Hash-style,
  Array-style and bulk assignment (nil/Hash/Array) all work;
  `header_footer_parts=` still accepts legacy part-hash arrays.
- Previously the CLI `headers add-header`/`watermark` path crashed on
  save (Array-shaped `headers` met `each_key`) and `headers list`
  showed nothing for loaded documents (it only read the builder
  hash); both now work through the unified store.
- `document_statistics` word counts now include loaded
  headers/footers (previously only the builder hash was counted).

### Leftovers for item 10 (rId stability)

- The legacy (no-allocator) save path still renumbers every rId
  sequentially; part `r_id`s on loaded parts can go stale after
  renumbering (harmless today: nothing reads them downstream, but
  item 10 should make the allocator the single authority).
- Multi-section documents with several paragraph-level sectPrs:
  part `type` is derived from all sections, but view upserts are
  keyed by (kind, type) only, so two sections sharing a type map to
  the first part; builder-created refs wire into the body-level
  sectPr only.
- `image_parts` is still a raw hash keyed by rId (out of this item's
  scope; migrate to `PartCollection` with images next).
- `Package#chart_parts` / `Package#bibliography_sources` remain
  write-only convenience copies (never read on the package).

## Context

`header_footer_parts`, `chart_parts`, `bibliography_sources`,
`custom_xml_items`, `embeddings` are plain `attr_accessor` hashes
(`lib/uniword/docx/package.rb:86-99`, `lib/uniword/wordprocessingml/document_root.rb:103`)
bypassing the model layer. Headers/footers have TWO storage paths —
builder `document.headers`/`footers` hashes vs round-trip
`header_footer_parts` array — producing duplicate rels, overwritten sectPr
rIds, and duplicate content-type overrides when both exist (TODO/06).
Wiring is implemented twice with different semantics: reconciler
`find_or_create_rel` (idempotent, `reconciler/body.rb:88-163`) vs
serializer `next_rid` + `wire_header_reference`
(`package_serialization.rb:315-460`) (TODO/07).

## Goal

1. Proper part model objects (lutaml-model Serializables or `Docx::Part`
   value objects holding path + model + rels) for every package-held part
   kind, replacing raw hashes — serialization, equality, and cloning then
   come from the model layer.
2. ONE header/footer storage path: loaded files and the Builder populate
   the same collection; the Builder keeps its convenience API but writes
   into the unified store. Preserve the public API surface
   (`document.headers`, `footers`, `header_footer_parts`) as delegators so
   existing callers don't break.
3. ONE wiring implementation (reconciler side, via `IdAllocator` +
   `Ooxml::PartRegistry` from 08); delete the duplicate serializer-side
   wiring and its divergent rId strategy.

## Acceptance

- Regression spec: load a DOCX with headers+footers, add a header via the
  Builder, save → exactly one rel set, no duplicate content-type overrides,
  no dangling sectPr r:ids (assert via the 02 gate passing and by parsing
  the output).
- `spec/integration/docx_roundtrip_spec.rb`, `repair_spec.rb` (header/footer
  cases), `spec/uniword/docx/`, `spec/uniword/builder/` green.
- Absorbed TODO/06, 07, 08 marked completed; no forbidden constructs;
  autoload rules for new files.
