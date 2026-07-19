# 05 — Unknown-part passthrough (full round-trip fidelity for unmodelled parts)

Status: DONE
Priority: P1
Depends on: 01 (registry load), 02 (model-driven parts)
Absorbs: none (new; resolves the R32 data-loss trade-off documented in
TODO.validate/02's completion notes)

## Context

Parts uniword does not model (e.g. `docProps/meta.xml`, glossary
documents, customXml outside the standard layout, VBA projects,
embedded packages) are dropped on load; R32 strips their relationships
on save (recorded, but data is lost). The 02/03 wave chose
strip-and-record because no preservation mechanism existed — items
01/02 of this queue now provide one.

## Goal

- Load: entries not claimed by any registry loader are preserved as
  raw `Docx::Part`s (path + bytes + content type from the source
  [Content_Types].xml + their relationship, if any).
- Save: raw parts are re-emitted byte-for-byte with their content
  types and relationships intact; R32 no longer strips rels whose
  targets are carried as raw parts (it still strips genuinely
  un-carried ones).
- The write-time gate (OPC-005/006/009) sees raw-carried parts as
  first-class, so round-trips of documents containing unmodelled
  parts pass cleanly.

## Design constraints

- Raw passthrough is a fallback only: any part the library models
  takes the model path (no double emission — the registry claims
  first, raw claims the remainder).
- Binary-safe: bytes never decoded as UTF-8 XML.
- Same forbidden-construct and autoload rules.

## Acceptance

- `spec/fixtures/docx_gem/no_styles.docx` round-trips with
  `docProps/meta.xml` preserved byte-identically (regression spec;
  today it is stripped).
- A document with an unmodelled binary part round-trips with the part
  and its rel intact; the gate passes.
- `bundle exec rspec spec/uniword/docx/ spec/integration/
  docx_roundtrip_spec.rb spec/integration/round_trip_validation_spec.rb`
  green.

## Completion notes

Completed 2026-07-19.

### Design

- `Docx::RawPart < Docx::Part` (new, `lib/uniword/docx/raw_part.rb`):
  carries the package-relative `path` verbatim (overrides `Part#path` —
  raw parts live anywhere, not only under `word/`), the raw byte
  stream as `content` (binary-safe, never parsed), the `content_type`
  the source `[Content_Types].xml` declared (Override first, then
  Default by extension), and the referencing relationship's
  `r_id`/`rel_type` as introspection metadata (emission never uses
  them — rels re-serialize from the loaded rels models).
- Storage: `Package#raw_parts` and `DocumentRoot#raw_parts`, both
  `PartCollection.new(:path, RawPart)` (PartCollection learned the
  `:path` key via a `KEY_ASSIGNERS` lookup).

### Claim mechanics (registry first, raw remainder)

- New registry entry `:raw_parts` (`kind: :none`, `loader: :raw`,
  `load_priority: 130`, both `package_attribute` and
  `document_attribute: :raw_parts`). Because it names both attributes,
  the registry-driven document↔package copies mirror raw parts for
  the `DocumentFactory.from_file` → `DocumentRoot#save` path with no
  new copy code, and `PartRegistry.emitted_paths` enumerates the
  stored raw parts like any collection family — no change to the
  emitted-paths authority itself.
- `Docx::PartLoader::RawPartLoader` runs last in the normal loader
  loop and claims only ZIP entries no `PartDefinition` matches
  (`PartRegistry.find_by_path` over every definition, loadable or
  not), additionally excluding the resolved main-document part and
  its rels sidecar at non-standard locations (`office365.docx`'s
  `word/document2.xml`, `weird_docx.docx`'s `word/document22.xml`)
  and `customXml/_rels/itemN.xml.rels` sidecars consumed by
  `CustomXmlLoader`.
- Bytes are re-read from the original ZIP when `zip_path` is
  available (same binary-safety treatment as images; the extracted
  hash force-encodes UTF-8, corrupting binaries), in one
  `Zip::File.open` pass.

### Emission and gate interplay

- `PackageSerialization#serialize_raw_parts` emits raw parts
  byte-for-byte at the end of serialization, guarded by
  `unless content.key?` — model emission always wins; double emission
  is impossible by construction.
- `#inject_raw_part_content_types` adds a content-type Override for a
  raw part only when the reconciled `[Content_Types].xml` covers it
  neither by Default (post-rebuild Defaults are rels+xml only, so
  e.g. a `bin` Default becomes an Override) nor by preserved
  non-standard Override.
- R32 (`reconcile_relationship_targets`) is untouched: raw parts
  appear in `PartRegistry.emitted_paths(package)` via the
  `:raw_parts` definition, so rels targeting them are kept; rels to
  genuinely un-carried parts are still stripped (existing
  `referential_integrity_spec.rb` expectations unchanged).
- The write-time gate (OPC-005/006/008/009/010) sees raw parts as
  ordinary emitted entries: content type ensured above, rel targets
  resolve (raw parts are in the content hash), XML raw parts are
  strict-parsed from their verbatim bytes.

### The no_styles.docx proof

`spec/fixtures/docx_gem/no_styles.docx` carries
`<Relationship Type=".../customXml" Target="../docProps/meta.xml"/>`
in `word/_rels/document.xml.rels`. Before: the part was dropped and
R32 stripped the rel. Now: `Package#raw_parts` carries
`docProps/meta.xml` (content type `application/xml` from the `xml`
Default, rId1 recorded), the round-trip preserves the part
byte-identically through both `Package.from_file`→`to_file` and
`DocumentFactory.from_file`→`DocumentRoot#save`, the rel survives
with no R32 fix, and the gate passes with zero issues.

### Verification

- New specs: `spec/uniword/docx/raw_part_spec.rb` (unit) and
  `spec/uniword/docx/package_raw_part_passthrough_spec.rb`
  (no_styles byte-identity, rel keep + no-R32, gate pass,
  document-level path, synthetic unmodelled-binary part
  byte-identity/rel/content-type/gate, no-unknown-parts packages
  unaffected, claim-order exclusions for basic/office365/saving_wps);
  one `.emitted_paths` raw-part example in
  `spec/uniword/ooxml/part_registry_spec.rb`; one dot-segment
  OPC-006 example in `spec/uniword/validation/opc_validator_spec.rb`.
- `bundle exec rspec spec/uniword/docx/ spec/uniword/ooxml/` — 610
  examples, 0 failures.
- `bundle exec rspec spec/uniword/builder/ spec/lint/` — 583
  examples, 0 failures.
- `bundle exec rspec spec/integration/docx_roundtrip_spec.rb
  spec/integration/round_trip_validation_spec.rb
  spec/integration/repair_spec.rb
  spec/integration/xsd_output_validation_spec.rb` — 182 examples, 0
  failures (28 pending, unchanged from baseline).
- Also green: `spec/uniword/document_spec.rb`,
  `document_factory_spec.rb`, `document_writer_spec.rb`,
  `spec/uniword/validation/` (244 examples), and
  `spec/uniword/wordprocessingml/` + `spec/transformation/` (858
  examples).
- `bundle exec exe/uniword help` — OK.
- RuboCop: zero new offenses in every touched file.
- Forbidden constructs (`public_send`, `.send(`, `__send__`,
  `respond_to?`, `instance_variable_*`, `require_relative`,
  in-library `require "uniword/..."`) — grep zero.

### Leftovers / notes

- `Validation::OpcValidator#resolve_target` now lexically normalizes
  `.`/`..` segments (same rule as the write-time gate and the
  reconciler): keeping `../docProps/meta.xml` exposed that the
  post-hoc validator resolved dot-segments literally and false-flagged
  OPC-006 on valid packages. Regression example added to
  `opc_validator_spec.rb`.
- `Package#raw_xml_parts` / `modified_part_paths` remain the unused
  accessors they were (TODO/08 tracks them); raw passthrough uses
  the new `raw_parts` collection instead.
- Raw XML parts with dangling `r:id` references and no sidecar rels
  would now fail the write-time gate (previously the part was
  silently dropped). This is the spec'd "gate treats raw parts as
  first-class" stance; no fixture in the suite exhibits it.
- The stylesWithEffects rel is still stripped by the reconciler's
  `UNSUPPORTED_REL_TYPES` rule (separate policy, unchanged); the
  `word/stylesWithEffects.xml` part itself now round-trips
  byte-identically as an orphan part.
- THMX/DOTX packages have their own `from_zip_content` and do not
  use `Docx::PartLoader`; raw passthrough does not apply there.
