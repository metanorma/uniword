# 15 — `ensure_rid_uniqueness` renames rels without moving their references

**Priority:** Low (reachable only from malformed input)
**Files:** `lib/uniword/docx/reconciler/referential_integrity.rb`

## Problem

`ensure_rid_uniqueness` (`referential_integrity.rb:359-386`) deduplicates
relationship ids by renaming the later of two rels sharing an id:

```ruby
duplicates.each do |rel|
  old_id = rel.id
  rel.id = derive_unique_rid(rels, old_id)
  record_fix(..., "Deduplicated rId #{old_id} → #{rel.id}")
end
```

It never updates the document references naming `old_id`. The output has
unique ids, but a `hyperlink/@r:id`, `blip/@r:embed`, or
`headerReference/@r:id` still pointing at `old_id` now resolves to
whichever rel *kept* the id — silently the wrong part.

## What still reaches it

`reconcile_document_rels_legacy` dedups the ids it emits
(`package_structure.rb`, `reassign_colliding_rids`) and remaps the
affected references per reference kind. But it only iterates
`non_standard` rels, so **two standard parts sharing an id** (e.g.
`styles.xml` and `settings.xml` both `rId1` in a hand-edited template)
are not deduped there and still arrive here — where they are renamed with
no reference update.

## Related gap in the same module

The sibling passes are inconsistent about repair:

- `reconcile_hyperlink_references` (`:308`) **removes** dangling
  hyperlinks (`reject!` at `:317`).
- `reconcile_image_references` (`:279`) only **counts** them
  (`dangling += 1`) and records a fix message; the dangling `r:embed`
  survives into the output.

Worth deciding deliberately whether a dangling image reference should be
removed, repaired, or left — right now it is merely reported.

## Fix

When `ensure_rid_uniqueness` renames a rel, remap references of the
matching kind, mirroring `reassign_colliding_rids`' type-directed
approach — a hyperlink reference follows the hyperlink rel, never the
header rel that kept the id. `update_sect_pr_rid_references` /
`update_blip_embed_references` / `update_hyperlink_rid_references` and the
`reference_kind` classifier live in `PackageStructure`; if both passes
need them they belong in a shared module.

Note the inherent ambiguity: if two rels of the *same* kind share an id, a
reference naming it is genuinely undecidable. Type-directing resolves the
common cases; document the rest.

## Verification

Two standard parts sharing an rId is **not** a useful reproduction:
`styles.xml`/`settings.xml` carry no `r:id` reference from `document.xml`,
so nothing observable breaks.

Use the allocator branch instead — an image rel and a hyperlink rel with
the same id, plus a hyperlink referencing it. Today the hyperlink ends up
resolving to the image. Assert it resolves to the hyperlink target.

## Related: the reference walkers are incomplete

Both remapping passes miss real reference sites. These gaps predate the
TODO/01 fix — `main` had the same helpers — and matter here because any
complete dedup has to remap through them:

- `update_blip_embed_references` (`package_structure.rb`) visits only
  top-level body paragraphs, so an image inside a **table cell** is never
  remapped. Use `walk_body_paragraphs` (`helpers.rb:46`), as the
  hyperlink walker already does.
- `update_sect_pr_rid_references` visits only the body's final `sectPr`,
  not paragraph-level section breaks
  (`paragraph_properties.rb:80`).
- `reference_kind` classifies header **and** footer as one `:sect_pr`
  kind, and the mapping is keyed by old id — so a header and footer
  sharing an id both follow the same reassignment and one resolves to the
  wrong part. Verified identical on `main`, so this is inherited, not new.
- Chart references (`chart/chart_reference.rb`, `<c:chart r:id>`) have no
  remapper, and `reference_kind` returns `nil` for them.
- Switching the image walker to `walk_body_paragraphs` (`helpers.rb:46`)
  would cover direct table cells but is still not a complete document
  walker: it omits body structured-document-tag content
  (`structured_document_tag/content.rb:12`) and nested tables in
  `TableCell#tables` (`table_cell.rb:14`), because `walk_table_paragraphs`
  (`helpers.rb:92`) visits only `cell.paragraphs`.
- `update_drawing_blip` remaps only `Blip#embed`; the model also
  serializes `Blip#link` (`<a:blip r:link>`, `blip.rb:13`), another image
  relationship reference.
- Legacy VML pictures live in `Run#pictures`; their `Vml::Imagedata#r_id`
  and `#r_href` (`vml/imagedata.rb:15`) are never walked.
- `GraphicData#diagram` / `Chart::DiagramReference#id` has no remapper,
  same as `GraphicData#chart`.
