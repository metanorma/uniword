# 08 — Ooxml::PartRegistry (single part↔content-type↔rel-type mapping)

Status: DONE
Priority: P2 (structural)
Depends on: 02/03 (write gate & reconciler changes must land first)
Absorbs: TODO/09-extract-ooxml-constants.md, TODO/10-dry-content-type-mapping.md

## Completion notes

### Design

- `Uniword::Ooxml::PartDefinition` (`lib/uniword/ooxml/part_definition.rb`)
  — plain Ruby value class (keyword init + readers; not
  Lutaml::Model::Serializable, it is not XML). Fields: `key`, `path`,
  `path_pattern` (for instance-numbered parts, `format`-style
  placeholders like `word/header%<counter>d.xml`), `target`,
  `target_pattern`, `content_type`, `rel_type`, `extension`,
  `required`, `kind` (:override/:default/:none), `rels_scope`
  (:package/:document), `standard` (member of the comprehensive
  [Content_Types].xml set). Derived: `part_name`, `part_name_for`,
  `path_for`, `target_for`, `override?`, `default?`, `required?`,
  `standard?`, `package_rel?`, value `==`.
- `Uniword::Ooxml::PartRegistry` (`lib/uniword/ooxml/part_registry.rb`)
  — module with `register` (replace-in-place by key, else append),
  `unregister`, `all`, `find_by_key`, `find_by_path` (fixed and
  pattern paths, leading slash tolerated), `find_by_content_type`,
  `override_for`, `default_for`, `standard_defaults`,
  `standard_overrides`, `package_rel_types`. 25 built-in
  registrations cover every part kind the library writes: jpeg/png/
  gif/rels/xml Defaults; document, numbering, styles, settings,
  webSettings, fontTable, theme, core, app (the :standard set, in
  historic `ContentTypes.generate` order); footnotes, endnotes,
  bibliography, header, footer, custom properties, chart, image,
  oleObject, customXml item/itemProps, hyperlink, thmx theme.
  Autoloaded from `lib/uniword/ooxml.rb` alongside `PartDefinition`.
- Open/closed: new part kinds `PartRegistry.register(...)`; consumers
  read the registry only.

### Consumers refactored (all derive from the registry)

- `Uniword::ContentTypes.generate` / `.generate_for_theme`
  (`lib/uniword/content_types.rb`) — maps `standard_defaults` /
  `standard_overrides` (registration order = historic literal order)
  and the :rels/:xml/:thmx_theme keys.
- `PackageDefaults.minimal_content_types` / `.minimal_package_rels` /
  `.minimal_document_rels` (`lib/uniword/docx/package_defaults.rb`)
  — ordered key lists (emission/rId order is consumer data); every
  literal from the registry. Signatures and returned content
  unchanged.
- `Reconciler::PackageStructure`
  (`lib/uniword/docx/reconciler/package_structure.rb`) —
  `PACKAGE_LEVEL_REL_TYPES` derived via `package_rel_types`;
  package rels, document rels (defs are `[PartDefinition, obj]`
  pairs), and content-type overrides all derive rel types, targets,
  part names, and content types from the registry. The `base` URI
  interpolation is gone.
- The 12 `inject_*` methods
  (`lib/uniword/docx/package_serialization.rb`) — `ensure_content_type`
  now takes a `PartDefinition`; numbered parts use
  `part_name_for`/`target_for`; every content type / rel type looked
  up by key.
- Beyond the 4 required consumers (absorbed TODO/09):
  `IdAllocator::*_REL_TYPE` constants, `Reconciler::Body`
  HEADER/FOOTER_REL_TYPE, `ImageBuilder::IMAGE_REL_TYPE`,
  `ChartBuilder::CHART_REL_TYPE`/`CHART_CONTENT_TYPE`,
  `BibliographyBuilder::CHART_REL_TYPE`, `Hyperlink::REL_TYPE`,
  `ReferentialIntegrity#promote_literal_hyperlink`,
  `Package.extract_header_footer_parts` content types,
  `Relationships::ImageRelationship`, and
  `PackageRelationships.generate_package_rels` all derive from the
  registry.

### Justified literal exceptions (with reasons)

- `PackageStructure::UNSUPPORTED_REL_TYPES` — stylesWithEffects is a
  Microsoft extension URI uniword never writes; it is a filter for
  foreign input, not a part mapping.
- Read-path fragment matchers (`package.rb` chart/header/footer/
  officeDocument `include?` predicates, `referential_integrity.rb`
  header/footer fragments) — tolerant substring predicates over
  foreign input, not emission mappings.
- `ChartBuilder` `xmlns:r` declaration and
  `PackageIntegrityChecker`/`validation/*` namespace URIs — XML
  namespace identifiers and independent validators, not part
  mappings (namespaces are owned by `Ooxml::Namespaces`).
- Per-image content types and `header_footer_parts` rel/content types
  come from the source document model (dynamic data, not literals).

Grep proof: no part-mapping literals remain in consumers —
`grep -nE "application/vnd|officeDocument/2006/relationships|
package/2006/relationships"` over the four consumers, IdAllocator,
Body, builders, Hyperlink, and ReferentialIntegrity yields only the
three exception sites above; the literals exist solely in
`lib/uniword/ooxml/part_registry.rb`.

### Byte-identity proof

- `spec/fixtures/docx_gem/basic.docx` round-trip save before vs after:
  `diff -r` of unzipped packages shows zero differences except
  `docProps/core.xml` `dcterms:modified` (save timestamp).
- Builder-path save (DocumentBuilder + chart) before vs after: zero
  differences except the same timestamp and per-process random
  `w14:paraId`/`w:rsidR` (confirmed pre-existing: two consecutive
  runs of identical code differ the same way).
- `ContentTypes.generate` XML dump matches the historic literal
  output exactly (defaults jpeg/png/gif/rels/xml; overrides in the
  historic order). `generate_package_rels` matches the historic
  rId3/rId2/rId1 order and URIs exactly.

### Verification

- `spec/uniword/ooxml/ spec/uniword/docx/ spec/uniword/builder/` —
  1016 examples, 0 failures.
- `spec/integration/docx_roundtrip_spec.rb
  spec/integration/round_trip_validation_spec.rb` — 61 examples,
  0 failures, 5 pending (same as pre-change baseline).
- `spec/lint/` — 32 examples, 0 failures.
- `bundle exec exe/uniword help` — loads cleanly.
- Registry specs: `spec/uniword/ooxml/part_registry_spec.rb` +
  `part_definition_spec.rb` — 41 examples covering lookup by key, by
  path (fixed, leading-slash, numbered pattern), by content type,
  override/default lookup, standard-set order pinning, package-level
  rel types, and custom registration (add, replace-in-place,
  rejection of non-PartDefinition).
- Forbidden constructs: `grep -rnE "public_send|\.send\(|respond_to\?|
  instance_variable_(set|get)|require_relative" lib/` → 0 hits.
- RuboCop: both new lib files clean; no touched file has more
  offenses than at HEAD (several have fewer); spec files carry only
  the RSpec metric-cop offenses tolerated repo-wide.

## Context


The part↔content-type↔rel-type↔path mapping is duplicated in 4+ places:
`Uniword::ContentTypes.generate` (`lib/uniword/content_types.rb:20-55`),
`PackageDefaults.minimal_*` (`lib/uniword/docx/package_defaults.rb:47-138`),
`Reconciler::PackageStructure` (`lib/uniword/docx/reconciler/package_structure.rb:24-47,284-318`),
and 12 `inject_*` methods (`lib/uniword/docx/package_serialization.rb:40-54,196-460`).
Relationship XML is likewise built in 3 places. Literals are strewn across
~10 files. Adding a part kind means editing all of them.

## Goal

Single declarative `Uniword::Ooxml::PartRegistry`:

- A `PartDefinition` value class (proper model object, not a raw hash):
  key, path pattern, content type, relationship type URI, extension,
  required/optional, default-vs-override.
- Built-in registrations for every part kind the library writes: document,
  styles, settings, fontTable, numbering, theme, header, footer, footnotes,
  endnotes, comments, core props, app props, webSettings, images, charts,
  bibliography, customXml, embeddings, glossary, etc. (audit the inject_*
  methods for the complete list).
- Open/closed: new part kinds are added by registering an entry, never by
  editing `ContentTypes`/`PackageDefaults`/`PackageStructure`/`inject_*`.
- Refactor those 4 consumers to DERIVE from the registry. After the
  refactor, content-type and rel-type literals exist only inside the
  registry (document any justified exception).

## Acceptance

- Byte-identical output for representative saves (round-trip and builder
  specs prove it); `bundle exec rspec spec/uniword/docx/ spec/uniword/ooxml/
  spec/integration/docx_roundtrip_spec.rb` green.
- Grep proves the duplication is gone; registry specs cover lookup by key,
  by path, by content type, and custom registration.
- Absorbed TODO/09 and TODO/10 are marked completed in their files.
- Autoload `PartRegistry`/`PartDefinition` in the immediate parent
  namespace file (create `lib/uniword/ooxml.rb` if missing); no forbidden
  constructs.
