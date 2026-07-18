# 07 — CI XSD validation of generated output

Status: DONE
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

## Completion notes

Completed 2026-07-18.

### What was built

`spec/integration/xsd_output_validation_spec.rb` — first end-to-end XSD
validation of real library output. Corpus: 8 Builder documents
(paragraphs/runs, tables, styles, numbering, headers/footers, images,
footnotes, bookmarks+hyperlinks) + 23 fixture round-trips (14
schema-clean sources with hard assertions, 9 with inherited source
errors tracked as pendings). Every document is saved through the 02
write gate and verified via `VerifyOrchestrator` with
`xsd_validation: true`; each part covered by
`SchemaRegistry.primary_schema_for_part` is checked. Runtime ~29s.

Assertion policy: OPC parts ([Content_Types].xml, all .rels,
docProps/core+app) hard-fail on any XSD error; WordprocessingML parts
hard-fail on non-MCE errors (errors whose offending element/attribute
lives in an MCE extension namespace are classified and excluded — even
genuine Word output fails those, since the transitional XSDs do not
declare w14/w15 extension content on most complex types).

### Genuine bugs found and fixed

1. **SchemaRegistry coverage gaps** (`lib/uniword/validation/
   schema_registry.rb`): `word/webSettings.xml` was absent from
   WORDML_PARTS (it is a CT_WebSettings part in wml.xsd); docProps
   core/app/custom parts had no mapping. Added `DOCPROPS_SCHEMAS`
   (core → ecma/opc-coreProperties.xsd, app →
   iso/shared-documentPropertiesExtended.xsd, custom →
   iso/shared-documentPropertiesCustom.xsd).
2. **Offline core-properties validation**: ecma/opc-coreProperties.xsd
   imported the Dublin Core XSDs over the network (violating the
   offline constraint). Bundled `dc.xsd`, `dcterms.xsd`, `dcmitype.xsd`
   (DCMI, dublincore.org) and `xml.xsd` (W3C) into `data/schemas/ecma/`
   and patched the three importing files' `schemaLocation`s to relative
   paths. docProps/core.xml now validates offline (verified).
3. **Invalid `w:lvl` children** (`lib/uniword/wordprocessingml/
   level.rb`): `w:ind` and `w:tabs` were mapped as direct children of
   `w:lvl`; CT_Lvl allows neither — they belong to the level's `w:pPr`.
   Removed both mappings (and the unused Level-local `Tabs` class);
   `left_indent_value`/`hanging_indent_value` now read `pPr`.
   `numbering_definition.rb` factories (decimal/bullet/roman/letter)
   now build `pPr.indentation` (Properties::Indentation). Every
   Builder-generated list previously emitted schema-invalid
   numbering.xml.
   Leftover: `Wordprocessingml::Ind`/`Tab` classes are now unreferenced
   in lib (kept — public API surface; removal is item-11-style dead-code
   scope).
4. **`.rels` parts dropped on save** (surfaced by the full integration
   run: ISO 690 round-trip OPC-009 on footnotes.xml, APA template
   round-trip OPC-009 on settings.xml): `word/_rels/settings.xml.rels`
   was lost on the document-level save path
   (`copy_document_parts_to_package` didn't copy it) and
   `word/_rels/footnotes.xml.rels` / `endnotes.xml.rels` on both paths
   (never parsed or emitted). Fixed across `package.rb` (parse +
   `attr_accessor`), `package_serialization.rb` (emit), `document_root.rb`
   (round-trip accessors), `document_factory.rb` and
   `package_defaults.rb` (both copy directions); the R32 dangling-target
   sweep now covers note rels too. Regression spec:
   `spec/uniword/docx/note_rels_roundtrip_spec.rb`.
5. **Frozen `element_order` crash** (`footnotes.rb`, `endnotes.rb`):
   `sync_element_order` mutated the parser-frozen `element_order` array
   when the reconciler injected missing separator notes, raising
   FrozenError on save. Now dups before appending.

### Pendings (all 10, with owning item)

All point to TODO.validate/11 (validation-engine consolidation):
- 9 inherited-error fixture round-trips (01_single_word … 06_cjk_text,
  docx_gem tables/no_styles/substitution): the fixture's OWN content is
  schema-invalid (enumerated per fixture in
  INHERITED_ERROR_FIXTURES — e.g. missing required w:val on w:sz,
  w:tblInd/w:proofState order, w:sig missing usb/csb attributes, minimal
  w:pgMar) and round-trip fidelity preserves it; save-time content
  normalization is engine scope, not this item's.
- 1 full-validity-including-MCE example: XmlSchemaValidator does not
  strip mc:Ignorable/w14 extension content before validating (genuine
  Word output fails identically); MCE-aware preprocessing is engine
  work.

### Verification

- Corpus spec: 97 examples, 0 failures, 10 pending, ~29s.
- `spec/uniword/wordprocessingml/` + `spec/uniword/validation/` +
  `spec/lint/` — 824 examples, 0 failures (12 pre-existing pending).
- `spec/uniword/docx/` + `spec/uniword/builder/` — 810 examples,
  0 failures.
- Full `spec/integration/` — 1402 examples, 0 failures, 42 pending
  (10 this item's; 32 pre-existing), ~10 min.
- RuboCop: lib changes introduce no new offenses (counts identical to
  HEAD); the new spec file sits below the existing integration-spec
  offense range after autocorrect (26 vs 38–54 in siblings).

### Pre-existing blocker fixed en route

`spec/integration/libreoffice_spec.rb` ("can be validated by
LibreOffice") ran `soffice --headless --invisible --view <file>`
synchronously via `system` — a headless viewer never exits, so the whole
integration suite hung on machines with LibreOffice installed
(verified the `system(...)` call verbatim at HEAD). Replaced with a
detached process-group spawn + grace sleep + TERM, preserving the
example's intent (open, validate structure, close). `libreoffice_spec.rb`
now runs 26 examples green.
