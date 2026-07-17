# 13 — `IdAllocator` collapses rels that share a target and type

**Priority:** High (live data loss through the public `Package` API)
**Files:** `lib/uniword/docx/id_allocator.rb`,
`lib/uniword/docx/reconciler/package_structure.rb`

## Problem

`IdAllocator` stores one entry per `[target, type]`
(`id_allocator.rb:35`, `@rid_entries`). `seed_from_rels`
(`id_allocator.rb:89`) writes by that key, so when a document has several
rIds pointing at the same target+type, the last one wins and the rest are
lost. `all_rels` (`:118`) can only ever return the survivors, and
`reconcile_document_rels_from_allocator` (`package_structure.rb:116`)
builds `document.xml.rels` from exactly that list.

This is legal, common OOXML. Word writes one rel per hyperlink
*occurrence*, so repeated links to the same URL get distinct rIds.

## This is live, not theoretical

`Package.from_file` calls `populate_allocator` (`package.rb:105-111`) and
`to_zip_content` passes the allocator to the reconciler (`package.rb:470`),
so **the public `Package` API takes the allocator branch** and drops rels:

```
$ ruby -e 'pkg = Uniword::Docx::Package.from_file(ISO_690); pkg.to_zip_content'
on disk      : 356 rels
allocator    : true
after to_zip : 311 rels
LOST 45 rel(s)
[Uniword] WARN: Dangling hyperlink r:id=rId335 in body — builder failed to register hyperlink with allocator
[Uniword] WARN: Dangling hyperlink r:id=rId336 in body — builder failed to register hyperlink with allocator
```

Fixture: `spec/fixtures/uniword-private/fixtures/iso/ISO_690_2021-Word_document(en).docx`.
Collapsed examples — each set is one target, several legitimate rIds:

```
3x  rId42, rId23, rId24
      https://artinwords.de/albrecht-duerer-feldhase-1502/
2x  rId117, rId261
      https://www.gamespot.com/reviews/mario-kart-8-deluxe-review/1900-6416660/
2x  rId84, rId113
      http://verkkoarkisto.kansalliskirjasto.fi:8080/20060916080210/http://www.verkkosanomat.fi/
```

Note the warning blames "builder failed to register hyperlink" — it is
not the builder's fault. The rels were registered and then collapsed by
the `[target, type]` key. The message is misleading.

## What is NOT affected

`Uniword.load(path).save(path)` is fine: `DocumentFactory` never copies
`Package#allocator` onto the returned `DocumentRoot`, so that route takes
`reconcile_document_rels_legacy`, which preserves rIds and object identity
(TODO/01, fixed).

`Package.from_file(...).to_zip_content` is the loaded-document
reproduction above, but it is **not** the only allocator-backed route:
`DocumentBuilder.from_template` seeds one and passes it explicitly
(`document_builder.rb:83-84`), and any allocator-bearing `DocumentRoot`
copies it into the package (`package_defaults.rb:36`). The template
builder clears the body first, so the ISO dangling-hyperlink reproduction
does not carry over unchanged there.

Do **not** "fix" the divergence by copying the allocator onto the
`DocumentRoot` — that spreads this bug to every load→save and also trips
the provenance gates (see TODO/14). Two revisions of the TODO/01 fix were
rejected for exactly that.

## Fix

`@rid_entries` must hold several ids for one `[target, type]`: either key
by rId with a secondary target+type index for `rid_for`, or make the
value a list. `rid_for(target:, type:)` must define which id it returns
when several match (probably: first seeded).

## Also here: `seed_from_rels` crashes on an id-less rel

`seed_from_rels` (`id_allocator.rb:100`) does `r.id[/\ArId(\d+)\z/, 1]`,
so a relationship parsed without an `Id` raises `NoMethodError` before the
reconciler runs. `all_rels` (`:119`) would dereference the nil id too.
Present on `main`. Safe navigation alone is not enough — it would emit a
relationship with `Id=nil`. Allocate an id during seeding instead:

```ruby
def seed_from_rels(relationships)
  return unless relationships

  max_seeded_rid = relationships.filter_map do |rel|
    rel.id&.[](/\ArId(\d+)\z/, 1)&.to_i
  end.max || 0
  @rid_counter = [@rid_counter, max_seeded_rid].max

  relationships.each do |rel|
    id = rel.id
    unless id
      @rid_counter += 1
      id = "rId#{@rid_counter}"
    end

    key = [rel.target, rel.type.to_s]
    @rid_entries[key] = {
      id: id, type: rel.type.to_s,
      target: rel.target, target_mode: rel.target_mode,
    }
  end
end
```

`all_rels` then needs `rel[:id].to_s[/\d+/]&.to_i || 0`. Note this only
holds once the `[target, type]` key above is fixed — otherwise the newly
allocated id is collapsed away with the rest.

## Verification

- Seed an allocator from the ISO 690 rels; assert `all_rels.size == 356`
  and that `rId42`, `rId23`, `rId24` all survive.
- `Package.from_file(ISO_690).to_zip_content` emits 356 rels and logs no
  dangling-hyperlink warnings.
- `Package.from_file` on a package whose `document.xml.rels` has a
  `<Relationship>` without `Id` does not raise.
