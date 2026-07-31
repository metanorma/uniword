# 01 — Mail merge

**Status:** PLANNED
**Priority:** High for marketing/ops teams
**Depends on:** Template::Template (already exists)

## Why

Word's entire Mailings tab. Letters, envelopes, labels, directory
listings from CSV/YAML data. Fortune-500 workflow. Template engine
exists but field-level record iteration does not.

## Scope

- Data sources: CSV, YAML, JSON
- Output modes: one-document-per-record (letters), single-document
  with all records (directory), envelopes, labels
- Field markers: `{{field_name}}` syntax (Liquid-style)
- Conditional blocks: `{{#if field}}...{{/if}}`
- Loops: `{{#each items}}...{{/each}}`

## CLI

```
uniword mail-merge letters --template letter.docx --data recipients.csv --output-dir out/
uniword mail-merge directory --template entry.docx --data people.yml --output catalog.docx
uniword mail-merge envelopes --template envelope.docx --data addr.csv --output-dir out/
uniword mail-merge labels --template avery5160.docx --data addr.csv --output labels.docx
```

## Ruby API

```ruby
merge = Uniword::MailMerge::Engine.new(
  template: "letter.docx",
  data: "recipients.csv",
  mode: :letters,
)
merge.run(output_dir: "out/")
```

## Architecture

```
Uniword::MailMerge
  ├── Engine             # orchestrator
  ├── DataSource         # abstract
  │   ├── CsvSource
  │   ├── YamlSource
  │   ├── JsonSource
  │   └── ActiveRecordSource  # optional, lazy-loaded
  ├── Template           # extends existing Template::Template
  ├── Renderer           # render one record
  └── OutputStrategy     # abstract
      ├── PerRecordOutput   # letters
      ├── ConcatenatedOutput # directory
      ├── EnvelopeOutput
      └── LabelSheetOutput  # label grids
```

## Out of scope

- Database connectors beyond CSV/YAML/JSON
- Email sending (callers do that)
- Real-time merge (no live data sources)
