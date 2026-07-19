# 03 — carried_part_paths derived from the registry (kill the last mirror)

Status: DONE
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

## Completion notes

Completed 2026-07-19.

### Design

- `PartDefinition#emitted_paths(package)`: single-instance kinds emit
  their fixed `path` when the backing model is present
  (`attribute_source` reads the package attribute, else the document
  attribute through the package's document); collection families
  (`collection?` — no fixed path) enumerate their stored parts.
- `Docx::Part#package_paths` (`[path]`) and
  `Docx::CustomXmlItem#package_paths` (`[path, props_path]`) — each
  part object answers its own emitted paths, so no path-string
  building remains anywhere downstream.
- `PartRegistry.emitted_paths(package)` — the single authority:
  `all.flat_map(&:emitted_paths).to_set`.
- Registry metadata completed for the family definitions: `:header`,
  `:footer` → `document_attribute: :header_footer_parts`; `:chart` →
  `:chart_parts`; `:image` → `:image_parts`; `:bibliography` →
  `:bibliography_sources` (`:ole_object` already had `:embeddings`).

### Removed

`carried_word_parts`, `core_word_pairs`, `note_word_pairs`,
`carried_docprops_parts`, `custom_xml_item_paths`,
`document_part_paths`, `media_chart_paths`, `embedding_paths`,
`header_footer_paths` — the hand-written serializer mirror in
`Reconciler::ReferentialIntegrity`. `carried_part_paths` is now a
two-line delegation. The R32 sweep and the dangling-image check are
unchanged consumers.

### Verification

- `spec/uniword/docx/` + `spec/uniword/ooxml/`: 565 examples, 0
  failures (behavior-equivalence of the derivation).
- New `.emitted_paths` registry examples (5): single-instance
  presence/absence, image family, customXml item + itemProps,
  header/footer store.
- RuboCop: zero new offenses in every touched file
  (part_registry/part_definition/part/custom_xml_item clean;
  referential_integrity unchanged at 34).
