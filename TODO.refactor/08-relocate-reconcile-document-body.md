# 08 — Move `reconcile_document_body` from Parts to Body module

**Priority:** High (architecture / MECE)
**Files:** `lib/uniword/docx/reconciler/parts.rb`,
`lib/uniword/docx/reconciler/body.rb`,
`lib/uniword/docx/reconciler.rb`

## Problem

`parts.rb:262 reconcile_document_body` does paragraph-level backfill
and mc:Ignorable on the document body. But `body.rb` already owns
body-level reconciliation (`reconcile_section_properties`,
`reconcile_headers_footers`, paragraph backfill at line 55).

The "body" concern is split across two modules with no clean separation
criterion. Both modules call `strip_empty_runs` and
`backfill_paragraphs`.

## Root cause

Historical — `reconcile_document_body` was named "document_body" because
it operates on `package.document.body`, but conceptually it's body
reconciliation, which is Body module's responsibility.

## Fix

Move the entire method and its private helpers from `parts.rb` to
`body.rb`. Update the `reconcile` method in `reconciler.rb` if the call
order needs to change (probably stays in the same Group-2 support-parts
slot, since it requires profile context).

After the move:
- `body.rb` owns ALL body-level reconciliation: section properties,
  headers/footers, paragraph backfill, mc:Ignorable for the document
  part.
- `parts.rb` owns ONLY support-part reconciliation: theme, settings,
  font_table, styles, numbering, web_settings, app/core properties.

### Verification

No spec changes needed. Behavior unchanged. Verify the body_specs and
reconciler_specs pass.
