# 04 — captions + cross-references + TOC of figures

**Status:** PLANNED (next session)
**Priority:** High for tech/science writing
**Depends on:** nothing (but complements existing TOC)

## Why

The tech/science writing trifecta. ISO, IEEE, ACM, and every
technical publisher requires auto-numbered figures, tables, and
equations with cross-references. Without these, uniword can't be the
last tool in a technical-publishing pipeline.

## Three features, one PR (they interlock)

### 4a. Captions

Auto-numbered figure/table/equation captions.

#### OOXML

A caption is a paragraph containing:
- A run with the label ("Figure", "Table", "Equation")
- A run with the separator (": ", "-", ". ")
- A `SEQ` field with the sequence name (e.g., "Figure")
- A run with the caption text

The SEQ field auto-increments on every render. Word maintains the
counter in the document's `settings.xml` `<w:seq/>` cache (optional;
uniword can compute on render).

#### Ruby API

```ruby
builder.add_caption("Figure", text: "Pipeline overview")
# Produces: "Figure 1: Pipeline overview"

builder.add_caption("Figure", text: "Data flow", separator: " - ")
# Produces: "Figure 2 - Data flow"

builder.add_caption("Table", text: "Results")
# Produces: "Table 1: Results"
```

Counter state is held on the builder; reset to 1 at start.

#### CLI

```
uniword caption add FILE "Figure" --text "..." [--separator ": "]
uniword caption number FILE      # show current counts per label
```

### 4b. Cross-references

Reference a previously-marked target (bookmark or caption).

#### OOXML

A cross-reference is a `REF` field targeting a bookmark. For
captions, the bookmark wraps the caption paragraph.

```xml
<w:fldSimple w:instr=" REF _Fig1 \h ">
  <w:r><w:t>Figure 1</w:t></w:r>
</w:fldSimple>
```

#### Ruby API

```ruby
builder.add_caption("Figure", text: "Pipeline",
                    bookmark: "_Fig1")  # auto-creates bookmark
# ... later ...
builder.add_paragraph("See ")
builder.add_cross_reference("_Fig1", type: :caption)
# Produces: "See Figure 1"
```

#### CLI

```
uniword cross-ref add FILE TARGET_BOOKMARK [--type caption|heading|table|figure]
```

### 4c. TOC of figures

Variant of existing TOC. Uses `\c "Figure"` switch instead of `\o`.

#### Ruby API

```ruby
doc.insert_toc_figures(label: "Figure")  # produces "Figure 1, Figure 2, ..."
```

#### CLI

```
uniword toc insert-figures FILE [--label Figure]
```

## Architecture

```
Uniword::Caption
  ├── Counter          # label => count, persisted on document
  ├── CaptionStyle     # name + numbering format
  └── CaptionBuilder   # build the caption paragraph

Uniword::CrossReference
  ├── Resolver         # bookmark -> display text
  └── FieldBuilder     # build REF fldSimple

Uniword::Toc::FigureVariant   # subclass of existing TOC with \c switch
```

## Verification

- Spec: `spec/uniword/caption/counter_spec.rb`
- Spec: `spec/uniword/caption/builder_spec.rb`
- Spec: `spec/uniword/cross_reference/resolver_spec.rb`
- Integration: `spec/integration/captions_integration_spec.rb`
  (end-to-end: build doc with captions, save, reload, verify SEQ
  fields and bookmarks round-trip)
- CLI: `spec/uniword/cli/caption_cli_spec.rb`,
  `spec/uniword/cli/cross_reference_cli_spec.rb`

## Round-trip

Captions and cross-refs must survive load → save. The reconciler
should leave SEQ and REF fields untouched. Add a regression spec
against the ISO DIS Simple template (which uses captions).

## Out of scope

- Equation auto-numbering with chapter-prefix ("(3.1)" style) — defer
  to Tier 2.
- List of Tables / List of Equations (variants of TOC-figures) — same
  pattern, easy follow-up.
- Bookmark range resolution (cross-ref to a paragraph range vs single
  point) — Tier 2.
