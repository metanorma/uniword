# 07 — CI XSD validation of generated output

Status: PENDING
Priority: P1
Depends on: 02 (write gate) — run after it lands
Absorbs: none (new)

## Context

40 XSDs are bundled (`data/schemas/{iso,microsoft,mce,ecma}/`);
`Validation::SchemaRegistry` + `XmlSchemaValidator` are complete but opt-in
(CLI `verify --xsd`) and have never been exercised end-to-end in specs —
`schema_registry_spec.rb` only unit-tests the part→schema mapping. No spec
XSD-validates anything the library writes.

## Goal

`spec/integration/xsd_output_validation_spec.rb`:

- Build a corpus: synthetic documents via the Builder exercising
  paragraphs, runs, tables, styles, numbering, headers/footers, images,
  footnotes, bookmarks, hyperlinks — plus a selection of `spec/fixtures`
  DOCX round-trips (load → save).
- Save each to `test_output/` and validate every XSD-coverable part (per
  `SchemaRegistry.primary_schema_for_part`) via `VerifyOrchestrator` with
  `xsd_validation: true`.
- Fail on XSD errors for OPC parts (`[Content_Types].xml`, all `.rels`,
  core/app properties). For WordprocessingML parts: attempt full validity;
  fix genuine library bugs it surfaces if tractable within this task; for
  systemic failures beyond scope, mark the specific example `pending` with
  a precise reason and a pointer to the owning TODO.validate item — every
  pending must be listed in the completion notes.

## Constraints

- Deterministic, offline, no mocks; reuse existing spec helpers
  (`temp_docx_path`, fixtures). Keep runtime bounded (< ~3 min) — schema
  compilation is cached by the registry.
- Spec-only change plus small bug fixes; do not refactor the validation
  engine (that is item 11).

## Acceptance

- Spec runs green in the integration suite; completion notes enumerate any
  pendings with root causes; genuine bugs fixed are listed.
