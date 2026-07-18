# 08 — Ooxml::PartRegistry (single part↔content-type↔rel-type mapping)

Status: PENDING
Priority: P2 (structural)
Depends on: 02/03 (write gate & reconciler changes must land first)
Absorbs: TODO/09-extract-ooxml-constants.md, TODO/10-dry-content-type-mapping.md

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
