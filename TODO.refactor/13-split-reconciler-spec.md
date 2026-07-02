# 13 — Split `reconciler_spec.rb` (1980 lines) into per-concern files

**Priority:** Medium (spec organization)
**Files:** Split `spec/uniword/docx/reconciler_spec.rb` into
`spec/uniword/docx/reconciler/` directory

## Problem

`reconciler_spec.rb` is 1980 lines with 12 top-level `describe` blocks
covering: footnotes, endnotes, profiles, content types, package rels,
document rels, referential integrity (4 sub-sections), numbering,
tables, value preservation, headers/footers, and clear_stored_namespace_plans.

This is a monolith. Slow to navigate, slow to run individually, hard
to see what's tested and what's not.

## Fix

Split into per-concern files under `spec/uniword/docx/reconciler/`:

```
spec/uniword/docx/reconciler/
├── footnotes_spec.rb
├── endnotes_spec.rb
├── settings_spec.rb
├── content_types_spec.rb
├── package_rels_spec.rb
├── document_rels_spec.rb
├── numbering_spec.rb
├── tables_spec.rb
├── headers_footers_spec.rb
├── note_references_spec.rb
├── style_references_spec.rb
├── hyperlink_references_spec.rb
├── clear_namespace_plans_spec.rb
└── value_preservation_spec.rb
```

Each file has its own `RSpec.describe Uniword::Docx::Reconciler do`
block with only the relevant `let`s and helpers.

### Verification

- All examples preserved (no test deleted, only moved)
- Each file runs independently: `rspec spec/uniword/docx/reconciler/footnotes_spec.rb`
- Combined example count matches the original 101

### Migration notes

- The shared `let(:settings_class) { ... }` etc. either move to a
  `spec/support/reconciler_helpers.rb` file or get duplicated in each
  spec file (preferred for clarity — small duplication beats hidden
  shared state).
- Keep the integration smoke-test in `reconciler_spec.rb` (one example
  that exercises the full reconcile pipeline end-to-end).
