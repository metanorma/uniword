# 04 — Extract FixCodes constants module

**Priority:** High (architecture)
**Files:** New `lib/uniword/docx/reconciler/fix_codes.rb`, all
`lib/uniword/docx/reconciler/*.rb` files

## Problem

Rule codes R1–R16 appear as bare string literals at 46 `record_fix`
call sites across 7 reconciler files. Worse, codes are overloaded —
**R10 alone is used for 11 semantically different purposes**:

| File:line | Meaning |
|---|---|
| `helpers.rb:130` | Stripped empty runs |
| `notes.rb:53` | Created missing note definitions |
| `parts.rb:132` | Added style defaults |
| `parts.rb:454` | Added semiHidden to DefaultParagraphFont |
| `tables.rb:91` | Reconciled table structure |
| `tables.rb:127` | Moved tcPr before p in cell |
| `referential_integrity.rb:121` | Removed dangling note refs |
| `referential_integrity.rb:226` | Removed dangling style refs |
| `referential_integrity.rb:255` | Stripped dangling basedOn/link |
| `referential_integrity.rb:314` | Removed dangling numbering refs |
| `referential_integrity.rb:343` | Removed dangling hyperlink refs |

A consumer reading the audit log cannot distinguish a table structural
fix from a stripped hyperlink — both say "R10".

## Root cause

No central catalog of fix codes. Each developer picked the next free
letter and reused existing codes when "good enough".

## Fix

Create `lib/uniword/docx/reconciler/fix_codes.rb` as a module of
frozen string constants, one per semantic fix. Replace every
`record_fix("R10", ...)` with `record_fix(FixCodes::TABLE_STRUCTURE, ...)`.

```ruby
module Uniword
  module Docx
    class Reconciler
      module FixCodes
        # Settings
        SETTINGS_MC_IGNORABLE = "R1"
        DOC_ID_GENERATED = "R2"
        # ... etc, one constant per semantic fix
        TABLE_STRUCTURE = "R10a"
        TABLE_CELL_TCPR_ORDER = "R10b"
        # ...
      end
    end
  end
end
```

Then `include FixCodes` in Reconciler (or refer as `FixCodes::CONST`).

### Migration

Existing audit logs will see new code names. Update any consumer that
pattern-matches on specific codes (likely none today, since the codes
are unstructured).

### Verification

Spec: assert every `record_fix` call site uses a FixCodes constant (grep
the codebase for `record_fix("` to confirm zero literal-string codes).
