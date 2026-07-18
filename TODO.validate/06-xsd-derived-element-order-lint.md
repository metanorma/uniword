# 06 — XSD-derived element-order lint

Status: DONE
Priority: P1
Absorbs: none (new)

## Context

Fresh-built models serialize in `map_element` declaration order; drift from
the XSD `xsd:sequence` order has caused real Word "unreadable content"
dialogs (commit 98f1342a fixed `RunProperties` kern/sz, `Style`
qFormat/semiHidden, `TableProperties` tblStyle). Today only regex-based
specs guard the specific orderings that already broke
(`spec/uniword/word_compatibility_spec.rb`). The authoritative schemas are
bundled: `data/schemas/iso/wml.xsd` etc.

## Goal

Spec-only lint (no lib API): `spec/lint/element_order_spec.rb` that parses
`data/schemas/iso/wml.xsd` with Nokogiri, extracts `xsd:sequence` child
order for a curated set of order-sensitive complexTypes — start with
CT_RPr, CT_PPr, CT_TblPr/CT_TblPrBase, CT_Settings, CT_Style, CT_SectPr,
CT_Tbl, CT_Tr, CT_Tc, CT_R, CT_P — and compares it against each
corresponding model class's `map_element` declaration order (via
lutaml-model's mapping metadata if accessible, else source analysis).
Gracefully skip sequence positions that are `xsd:choice`/`xsd:any`/extension
points, and document how each is handled.

Fix any real drift found by reordering `map_element` lines (no other
changes to those models).

## Acceptance

- Lint spec green; a spec comment demonstrates it would have caught the
  historical 98f1342a drift (e.g. asserts the CT_RPr order it enforces
  matches the fixed order).
- Any drift found is fixed and mentioned in completion notes.
- `bundle exec rspec spec/lint/` green; deterministic, offline.

## Completion notes

Implemented 2026-07-18.

### What was built

- `spec/lint/element_order_spec.rb` — spec-only lint (no lib API). An
  `ElementOrder` module in the spec file provides three small classes:
  - `Schema` parses `data/schemas/iso/wml.xsd` with Nokogiri and flattens a
    complexType's content model into ordered positions: `xsd:sequence`/
    `xsd:element` become singleton positions (element `ref`s contribute
    their local name, e.g. `m:mathPr` -> `mathPr`), `xsd:group` refs are
    resolved and inlined, `xsd:complexContent`/`xsd:extension` base types
    are walked first (so CT_TblPr yields CT_TblPrBase + `tblPrChange`, and
    CT_TcPr walks CT_TcPrInner -> CT_TcPrBase), `xsd:choice` members share
    one unordered position, and `xsd:any` is skipped. Each handling rule
    is documented in the module comment.
  - `ModelMappingOrder` reads the model's declared `map_element` order
    from lutaml-model's public mapping metadata
    (`klass.mappings[:xml].elements.map(&:name)`, declaration order in
    0.8.17) — no source parsing needed.
  - `OrderComparison` asserts the schema-covered subset of the model's
    elements has non-decreasing ranks (subsequence check; elements absent
    from the transitional schema, e.g. W14/W15/MC extensions, are skipped).
- Special case, documented in the spec: `EG_RPrBase` is an unbounded
  `xsd:choice` in the transitional schema, but Word (and the strict ECMA
  schema) enforce its member order for `w:rPr` children — exactly the
  order commit 98f1342a restored. It is listed in
  `ORDERED_CHOICE_GROUPS` and treated as ordered positions.
- 98f1342a regression anchors: examples assert the extracted CT_RPr order
  has `kern` before `sz` and `rStyle` first, CT_Style has `semiHidden`/
  `unhideWhenUsed` before `qFormat`, and CT_TblPr has `tblStyle` first —
  so the lint would have caught the historical drift. The current
  RunProperties/Style/TableProperties orders pass (98f1342a verified).
- complexTypes checked: CT_RPr, CT_PPr, CT_TblPr, CT_TblPrBase, CT_TcPr
  (extension beyond the curated list, cheap and order-sensitive),
  CT_Settings, CT_Style, CT_SectPr, CT_Tbl, CT_Row (the ISO schema's name
  for ECMA CT_Tr), CT_Tc, CT_R, CT_P.

### Drift found and fixed (map_element reorder only, no other model changes)

- `lib/uniword/wordprocessingml/paragraph_properties.rb` (CT_PPr):
  extensive drift — `jc` was 2nd (schema: after `ind`/`contextualSpacing`),
  `numPr`/keep options/`suppressLineNumbers`/`pBdr`/`shd`/`tabs`/`bidi`/
  `autoSpaceDE/DN`/`adjustRightInd` all misplaced. Reordered to
  CT_PPrBase sequence order.
- `lib/uniword/wordprocessingml/settings.rb` (CT_Settings): `proofState`
  was after `attachedTemplate`; `hdrShapeDefaults` was after
  `doNotIncludeSubdocsInStats` (schema: before `footnotePr`);
  `schemaLibrary` was after `decimalSymbol`/`listSeparator` (schema:
  before `shapeDefaults`). Reordered.
- `lib/uniword/wordprocessingml/section_properties.rb` (CT_SectPr):
  `footnotePr` was after `docGrid` (schema: first, after hdr/ftr
  references); `titlePg` was after `docGrid` (schema: before). Reordered.
- `lib/uniword/wordprocessingml/table_cell_properties.rb` (CT_TcPr):
  `cnfStyle` was 8th (schema: first), `gridSpan`/`vMerge` after
  `vAlign`, `textDirection` last. Reordered to CT_TcPrBase sequence order.
- Clean (no drift): RunProperties, Style, TableProperties, Table,
  TableRow, TableCell, Run, Paragraph.

### Verification

- `bundle exec rspec spec/lint/element_order_spec.rb
  spec/uniword/wordprocessingml/` — 651 examples, 0 failures
  (12 pending pre-existing in `styleset_roundtrip_spec.rb`, identical on
  the unmodified tree).
- `bundle exec rspec spec/uniword/word_compatibility_spec.rb
  spec/uniword/builder/` — 541 examples, 0 failures.
- `bundle exec rubocop` on all touched files: new spec is clean; lib
  files carry only pre-existing offenses (31, identical count to HEAD via
  `rubocop --stdin` comparison), no new offenses introduced.
- Not run: `spec/integration/` (~12 min) and the memory-unsafe full
  suite, per repo guidance.
