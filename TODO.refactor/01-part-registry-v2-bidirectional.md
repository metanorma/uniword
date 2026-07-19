# 01 — PartRegistry v2: bidirectional, loader-aware part definitions

Status: DONE
Priority: P0 (foundation for 02/03/04/06/08)
Absorbs: none (new)

## Context

Item 08's `Ooxml::PartRegistry` unified *emission* knowledge
(part ↔ content-type ↔ rel-type mapping) but only for the save path.
The load path knows nothing of it: `Package.from_zip_content`
(`lib/uniword/docx/package.rb`) hand-parses ~20 parts procedurally
(53 `zip_content[...]` accesses), and the document↔package copy lists
(`DocumentFactory.copy_package_parts_to_document`,
`PackageDefaults.copy_document_parts_to_package`) duplicate the same
part knowledge a third and fourth time. Adding a part kind still means
editing several places; a part can silently exist in only one direction
(the settings/footnotes rels bug was exactly this).

## Goal

Extend `Ooxml::PartDefinition` into the single, complete description of
a package part:

- `loader`: how to build the part from zip content (model class +
  parse rule: XML model, binary, rels part, optional pattern)
- `document_attribute` / `package_attribute`: where the part lives on
  `Wordprocessingml::DocumentRoot` and `Docx::Package`
- Built-in registrations completed to cover every part the library
  READS (currently it covers what the library writes).

Then derive from it:

1. `Package.from_zip_content` loads parts by iterating registry
   entries (patterns for numbered families: headers/footers, charts,
   media, customXml, embeddings, glossary) instead of the hand-written
   sequence. Special-case extraction logic (header/footer part
   objects, image rel wiring, theme media) moves behind the
   definition or a named strategy object — open/closed.
2. `DocumentFactory.copy_package_parts_to_document` and
   `PackageDefaults.copy_document_parts_to_package` become one
   registry-driven loop each — a part can no longer exist in only one
   direction.

## Design constraints

- No forbidden constructs (`public_send`/`.send(`/`__send__`,
  `respond_to?`, `instance_variable_set/get`, `require_relative`,
  in-library `require "uniword/..."`). Autoload new files in the
  immediate parent namespace file.
- `PartDefinition` stays a value object; behavior beyond data lives in
  named strategy classes, one per part kind, registered by key
  (open/closed — new kinds add a class + registration, never edit the
  loop).
- Preserve exact load semantics: every part that loads today must load
  identically (round-trip suites prove it).

## Acceptance

- `grep -c 'zip_content\[' lib/uniword/docx/package.rb` drops from 53
  to registry-driven single digits (exceptions documented).
- The two copy lists contain no per-part lines.
- `bundle exec rspec spec/uniword/docx/ spec/uniword/builder/
  spec/uniword/ooxml/ spec/integration/docx_roundtrip_spec.rb
  spec/integration/round_trip_validation_spec.rb` green.
- Registry specs cover loader metadata and both copy directions.

## Completion notes

Implemented 2026-07-19.

### Definition schema (PartDefinition, lib/uniword/ooxml/part_definition.rb)

New value-object fields (all optional, keyword args):

- `loader` — PartLoader strategy key (`:xml_model`, `:custom_xml`,
  `:header_footer`, `:chart`, `:image`, `:embedding`, `:theme_media`);
  nil means "not loaded from ZIP content".
- `loader_model` — model class with `.from_xml` for parsing loaders.
- `path_resolution` — dynamic path rule: `:office_document` (main
  document path from the package officeDocument rel) or
  `:office_document_rels` (sidecar rels of the resolved document).
- `load_priority` — load ordering weight (lower first; registration
  order breaks ties via explicit index — Ruby's sort_by is NOT
  stable, that bug bit once).
- `document_attribute` / `package_attribute` — reader/writer names on
  Wordprocessingml::DocumentRoot and Docx::Package for the copy loops.
- `copy_to_document` (default true) — false for parts the loader
  places directly (chart, ole_object/embeddings, bibliography).
- `to_package_guard` — document predicate guarding the
  document→package copy (`:numbering_configuration_loaded?` — its
  getter lazily creates, so the guard must run before reading).
- `to_package_type` — value class constraint for the
  document→package copy (CommentsPart for comments).
- New methods: `match_path?` (fixed path or pattern match, used by
  both find_by_path and the loader), `pattern_prefix`, `loadable?`,
  `copy_to_document?`. Pattern-regex building moved here from
  PartRegistry (single implementation).

### Registrations added (read-side, all kind :none — emission untouched)

`:content_types`, `:package_rels`, `:document_rels`,
`:settings_rels`, `:theme_rels`, `:footnotes_rels`,
`:endnotes_rels`, `:theme_media`. Existing registrations gained
loader/copy metadata in place (order preserved; ContentTypes.generate
output unchanged). 36 built-ins total.

### Strategy classes (lib/uniword/docx/part_loader/ — registered by key)

`PartLoader` (lib/uniword/docx/part_loader.rb) holds the strategy
registry (`register_loader`/`loader_for`, open/closed) and the load
loop: iterate `PartRegistry.loadable` (priority order) →
`loader_for(definition.loader).load(context, definition)`.
`LoadContext` carries zip_content/package/zip_path plus lazily
resolved main-document paths and `matching_paths(definition)`.
Strategies: `XmlModelLoader` (16 parts: content types, all rels,
docProps, document, styles/numbering/settings/fontTable/webSettings,
theme, notes, comments), `CustomXmlLoader`, `HeaderFooterLoader`
(shared by :header/:footer; carries the sectPr reference-type mapping
moved out of Package), `ChartLoader`, `ImageLoader` (rId wiring,
synthetic keys, binary re-extraction, extension→content-type map),
`EmbeddingLoader`, `ThemeMediaLoader` (only when a theme part
loaded).

### The two derived loops

- `DocumentFactory.copy_package_parts_to_document`: iterates
  `PartRegistry.copied_to_document` (both attributes present +
  copy_to_document?), nil-skips, dispatches via `method(...).call`
  (no public_send — repo constraint).
- `PackageDefaults.copy_document_parts_to_package`: iterates
  `copied_to_package` (both attributes present), honors
  `to_package_guard`/`to_package_type` via private helpers; the
  `allocator` copy stays as an explicit line (not a part).

### Verification

- `spec/uniword/ooxml/` + `spec/uniword/docx/`: 542 examples, 0
  failures (includes new loader-metadata, match_path?, .loadable
  ordering, and copied_to_* specs).
- `spec/uniword/builder/`: 551 examples, 0 failures.
- `spec/integration/docx_roundtrip_spec.rb`, `repair_spec.rb`,
  `header_footer_unified_path_spec.rb`, `round_trip_validation_spec.rb`:
  green (0 failures; 18 pending = pre-existing missing-fixture skips).
- `spec/lint/`: 32 examples, 0 failures; `exe/uniword help` OK.
- `grep -c 'zip_content\[' lib/uniword/docx/package.rb` → 0 (was 53;
  remaining accesses live in the strategy classes by design).
- Forbidden-construct grep over lib/: 0. RuboCop: no new offenses in
  any touched file (package_defaults 12→0, document_factory 19→9;
  new files clean).
- Byte-identity spot-check: builder-generated resume.docx
  document.xml identical between HEAD code and this change.

### Leftover notes for items 02/03

- Images still load into the raw `document.image_parts` hash
  (`r_id => { data:, target:, content_type: }`) — item 02 converts
  the shape; `ImageLoader` is the single place to change.
- `chart_parts` still receives `{ xml:, target: }` hashes (wrapped by
  PartCollection#[]=); item 02 may pass ChartPart objects directly.
- Package→document copy deliberately excludes embeddings/bibliography
  (`copy_to_document: false`): embeddings load onto
  `package.embeddings` while `document.embeddings` stays empty after
  load — a pre-existing asymmetry item 03 should reconcile (loaded
  embeddings do not flow DocumentFactory→document→save today).
- `Package.find_main_document_path` / `find_document_rels_path` /
  `extract_*` class methods were removed (moved into strategies);
  no external callers existed.
