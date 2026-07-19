# 02 — Finish model-driven parts: images, charts, bibliography

Status: PENDING
Priority: P0
Depends on: 01 (registry v2 gives them a home)
Absorbs: item 09 leftovers (image_parts raw hash, chart_parts /
bibliography_sources write-only copies)

## Context

Item 09 introduced `Docx::Part`/`PartCollection` for header/footer,
charts (partial), customXml, embeddings — but left:
- `DocumentRoot#image_parts`: raw `r_id => {data:, target:,
  content_type:}` hash (`document_root.rb:101`, written by
  `builder/image_builder.rb:64` and `Package.from_zip_content`).
- `Package#chart_parts` / `#bibliography_sources`: write-only copies
  shuttled between Package and DocumentRoot via
  `copy_document_parts_to_package` (`package_defaults.rb:67-69`) —
  state that lives in two places for no reason.
- `Package#embeddings` became a PartCollection in 09; images are the
  last binary part family still hash-based.

## Goal

- `Docx::ImagePart` (binary Part: data, target, content_type, r_id)
  replacing the raw hash; `document.image_parts` keeps hash-read
  compatibility (key/value reads and `[]=` assignment normalize to
  ImagePart, like item 09's collections).
- Charts: `Package#chart_parts` removed; the DocumentRoot collection
  is the single home (Package reaches it via `document`).
- Bibliography: single home on the document (`Bibliography::Sources`
  is already a model); drop the Package-level copy and its
  copy-list entries.
- All builders/extractors/serializers/reconcilers use the model
  objects; no raw hashes remain for part families.

## Design constraints

- Same forbidden-construct and autoload rules as item 01.
- Public API compatibility: `image_parts` reads (`[]`, `each`,
  `each_value`, `keys`, `size`, `empty?`) keep working — grep spec/
  and lib/ before changing shapes.
- rId authority stays with IdAllocator (item 10): image part rIds
  come from the allocator, not hash keys.

## Acceptance

- No `attr_accessor :image_parts` raw hash remains; `chart_parts` /
  `bibliography_sources` exist in exactly one place.
- `bundle exec rspec spec/uniword/docx/ spec/uniword/builder/
  spec/uniword/images/ spec/integration/docx_roundtrip_spec.rb
  spec/integration/chart_roundtrip_spec.rb` green.
- New model objects have their own spec files mirroring lib/.
