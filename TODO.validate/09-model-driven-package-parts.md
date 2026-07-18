# 09 — Model-driven package parts, unified header/footer path

Status: PENDING
Priority: P2 (structural)
Depends on: 08 (PartRegistry)
Absorbs: TODO/06-fix-header-footer-dual-path.md,
TODO/07-dry-header-footer-wiring.md, TODO/08-model-driven-header-footer-parts.md

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
