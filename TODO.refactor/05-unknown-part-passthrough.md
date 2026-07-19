# 05 — Unknown-part passthrough (full round-trip fidelity for unmodelled parts)

Status: PENDING
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
