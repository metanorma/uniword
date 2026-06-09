# 005: Split Reconciler into focused modules

## Status: DONE

## Problem
Reconciler is 1600+ lines, ~60 private methods. Violates SRP.
Mixes note reconciliation, table repair, theme repair, settings population,
content types, relationships, ID generation, element_order manipulation,
and default value factories in one class.

## Solution
Extract into mixin modules under `lib/uniword/docx/reconciler/`:

- `helpers.rb` — ID generation (generate_rsid, hex_derive, document_fingerprint),
  traversal (walk_body_paragraphs, walk_table_paragraphs),
  element_order (ensure_element_in_order, insert_element_order),
  run utilities (empty_run?, strip_empty_runs, strip_empty_runs_from_notes),
  YAML loading
- `notes.rb` — footnote/endnote reconciliation (reconcile_notes, finalize_notes,
  ensure_separators, reorder/renumber, separator builders)
- `referential_integrity.rb` — cross-part ID consistency
  (reconcile_referential_integrity, reconcile_note_body_references,
  reconcile_sect_pr_references, collect_valid_header_footer_rids)
- `tables.rb` — table structure reconciliation
- `theme.rb` — theme creation and repair
- `parts.rb` — profile-dependent parts (settings, fonts, styles, numbering,
  web settings, app/core properties, document body)
- `package_structure.rb` — content types, relationships
- `body.rb` — section properties, headers/footers

Main reconciler.rb becomes thin orchestrator composing modules.

## Files
- `lib/uniword/docx/reconciler.rb` — thin orchestrator
- `lib/uniword/docx/reconciler/helpers.rb` — NEW
- `lib/uniword/docx/reconciler/notes.rb` — NEW
- `lib/uniword/docx/reconciler/referential_integrity.rb` — NEW
- `lib/uniword/docx/reconciler/tables.rb` — NEW
- `lib/uniword/docx/reconciler/theme.rb` — NEW
- `lib/uniword/docx/reconciler/parts.rb` — NEW
- `lib/uniword/docx/reconciler/package_structure.rb` — NEW
- `lib/uniword/docx/reconciler/body.rb` — NEW
