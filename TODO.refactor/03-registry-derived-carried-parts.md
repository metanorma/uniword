# 03 — carried_part_paths derived from the registry (kill the last mirror)

Status: PENDING
Priority: P1
Depends on: 01 (registry v2), 02 (all part families model-driven)
Absorbs: none (new)

## Context

The R32 dangling-relationship sweep
(`Reconciler::ReferentialIntegrity#reconcile_relationship_targets`)
computes the set of parts the save path will emit via a hand-written
mirror of the serializer: `carried_word_parts`,
`carried_docprops_parts`, `custom_xml_item_paths`, `document_part_paths`
(`media_chart_paths`, `header_footer_paths`). This is precisely the
duplication item 08 was created to eliminate; it was accepted as
temporary with a note to move it to the registry.

## Goal

- The "will this part be emitted?" question is answered by the
  PartRegistry + part collections: single-instance parts via their
  model presence (the registry entry's package attribute), collection
  parts by asking the (now model-driven) collections.
- Delete the hand-written `carried_*`/`media_chart_paths`/
  `header_footer_paths` mirror methods; R32 (and any future consumer)
  asks one authority.
- Content-type coverage (the 02 gate's OPC-005) and any future
  "what will be emitted" consumer share the same answer.

## Design constraints

- Same forbidden-construct and autoload rules.
- The answer must stay exactly correct for every current case
  (single parts, numbered families, customXml items, theme media,
  notes rels) — referential_integrity and round-trip suites prove it.

## Acceptance

- `carried_part_paths` (and helpers) gone from
  `referential_integrity.rb`; the sweep queries the registry.
- `bundle exec rspec spec/uniword/docx/ spec/integration/
  round_trip_validation_spec.rb spec/integration/repair_spec.rb`
  green.
- Registry spec: emitted-part enumeration for a representative package.
