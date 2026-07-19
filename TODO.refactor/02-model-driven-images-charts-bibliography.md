# 02 — Finish model-driven parts: images, charts, bibliography

Status: DONE
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

## Completion notes

### Model objects

- `Docx::ImagePart` (new, `lib/uniword/docx/image_part.rb`): binary
  Part subclass — `data` (aliases `content`), `target`,
  `content_type` (per-file, carried explicitly; the registry `:image`
  definition contributes only the rel type), `r_id`, `source_path`
  (the legacy `:path` hash key = on-disk source path). Hash-style
  reads kept: `part[:data]`, `part[:target]`, `part[:content_type]`,
  `part[:path]` (source path; `part.path` stays the package path).
- `Docx::Part.from_hash` (new class-method hook on `Part`,
  overridden by `ImagePart`): `PartCollection#[]=` now normalizes raw
  hash assignments polymorphically instead of hardcoding
  `{ content:/xml:, target: }` keys. `ChartPart`/`Part` inherit the
  default; `ImagePart.from_hash` maps `{ data:, target:,
  content_type:, path: }`.
- `Docx::PartCollection` gained `has_key?` (alias of `key?`) — RSpec's
  `have_key` matcher and legacy Hash callers need it.

### Collection shapes

- `DocumentRoot#image_parts`: was `attr_accessor` raw Hash
  (`r_id => { data:, target:, content_type:, path: }`); now a lazy
  `Docx::PartCollection.new(:r_id, Docx::ImagePart)` with a
  `replace_all` writer — same shape as `chart_parts`/`embeddings`.
  `image_parts = nil` clears (was: set nil). All reads (`[]`, `each`,
  `each_value`, `keys`, `size`, `empty?`, `[]=`, `delete`, `key?`)
  unchanged.
- `chart_parts`: single home is `DocumentRoot#chart_parts`
  (PartCollection of `ChartPart`, from item 09); Package reaches it
  via `document`.
- `bibliography_sources`: single home stays
  `DocumentRoot#bibliography_sources` (`Bibliography::Sources` model,
  unchanged).

### Removed

- `Package#chart_parts` and `Package#bibliography_sources`
  attr_accessors (write-only copies shuttled by
  `copy_document_parts_to_package`).
- `:chart` and `:bibliography` registry entries no longer carry
  `package_attribute`/`document_attribute`/`copy_to_document`
  metadata — both copy loops (`copied_to_package`,
  `copied_to_document`) now skip them. Only `:ole_object`
  (package-owned embeddings) still round-trips through the
  document→package copy.
- `PackageStructure#document_rel_defs` reads sources only from
  `package.document` (was `package.bibliography_sources || document`).

### Consumers updated to model objects

- Writers: `PartLoader::ImageLoader` and `ChartLoader` build
  `ImagePart`/`ChartPart`; `Builder::ImageBuilder.register_image` and
  `Builder::ChartBuilder#register_chart_part` build the parts directly
  (rIds still allocated via `IdAllocator`; the `||= {}` priming is
  gone — collections are lazy).
- Readers: `PackageSerialization#inject_image_parts`/
  `#inject_chart_parts` (`part.target`/`part.data`/`part.xml`),
  `Images::ImageManager` (list/extract/remove),
  `Transformation::MhtmlMetadataBuilder` (filelist + MHTML image
  parts), `Transformation::MhtmlElementRenderer#resolve_image_target`
  (now `@image_parts[embed_id]&.target`),
  `Reconciler::PackageStructure#register_auxiliary_part_rels`,
  `Reconciler::ReferentialIntegrity#media_chart_paths`.

### API compatibility

- `document.image_parts` hash-style reads all keep working; legacy
  raw-hash assignment is normalized into `ImagePart` (specs in
  `image_manager_spec`, `reconciler_spec`,
  `reconciler/referential_integrity_spec` unchanged and green).
- `Package#chart_parts` / `Package#bibliography_sources` are gone —
  nothing in lib/ or spec/ read them (both were write-only).
- New spec: `spec/uniword/docx/image_part_spec.rb` (mirrors
  `lib/uniword/docx/image_part.rb`).
- `spec/uniword/ooxml/part_registry_spec.rb`: two examples updated —
  `:chart`/`:bibliography` left the document→package copy list (only
  `:ole_object` remains asymmetric).

### Verification

- `bundle exec rspec spec/uniword/docx/ spec/uniword/builder/
  spec/uniword/images/ spec/uniword/ooxml/` — 1133 examples, 0
  failures.
- `bundle exec rspec spec/integration/docx_roundtrip_spec.rb
  spec/integration/chart_roundtrip_spec.rb
  spec/integration/repair_spec.rb` — 44 examples, 0 failures (18
  pendings are pre-existing: private-submodule fixtures unavailable).
- `bundle exec rspec spec/lint/` — 32 examples, 0 failures;
  `bundle exec exe/uniword help` OK; `spec/transformation/` +
  `spec/uniword/mhtml/` (MHTML readers touched) — 332 examples, 0
  failures.
- RuboCop: no new offenses in any touched file (new files clean).

### Leftovers for item 03

- `ReferentialIntegrity#media_chart_paths`/`carried_part_paths` still
  hand-assemble the carried-parts set from individual collections
  (now model objects, but the sweep itself is item 03's rewrite).
- `PackageSerialization#inject_image_parts` still derives per-extension
  Default content types from part data at save time; moving that into
  a registry-derived pass belongs with item 03's carried-set work.
