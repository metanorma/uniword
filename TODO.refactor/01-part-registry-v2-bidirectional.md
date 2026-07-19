# 01 — PartRegistry v2: bidirectional, loader-aware part definitions

Status: PENDING
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
