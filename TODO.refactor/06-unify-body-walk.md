# 06 — Unify three `walk_body*` variants

**Priority:** High (architecture / MECE)
**Files:** `lib/uniword/docx/reconciler/helpers.rb`,
`lib/uniword/docx/reconciler/referential_integrity.rb`

## Problem

There are **three subtly different traversals** of the same document body:

| File:line | Method | Behavior |
|---|---|---|
| `helpers.rb:46` | `walk_body_paragraphs(body)` | Yields each paragraph (incl. table cells), in `element_order` if present |
| `referential_integrity.rb:402` | `walk_all_paragraphs(&block)` | Yields body paragraphs and table paragraphs |
| `referential_integrity.rb:410` | `walk_body_tables(body, &block)` | Yields tables (not paragraphs inside them) |

Two implementations of the same conceptual operation, with subtly
different semantics (one respects `element_order`, the other doesn't;
one yields tables, the other doesn't). Bugs hide in the gaps.

## Root cause

`referential_integrity.rb` was written before `helpers.rb` was
extracted. The duplication wasn't noticed during the DRY refactor.

## Fix

Unify on **one** `walk_body` in `helpers.rb` that takes a block and
yields both paragraphs and tables. Callers that only want paragraphs
filter by type:

```ruby
def walk_body(body)
  return enum_for(:walk_body, body) unless block_given?

  if body.element_order && !body.element_order.empty?
    p_idx = 0
    tbl_idx = 0
    body.element_order.each do |entry|
      case entry.name
      when "p"
        yield body.paragraphs[p_idx] if body.paragraphs[p_idx]
        p_idx += 1
      when "tbl"
        yield body.tables[tbl_idx] if body.tables[tbl_idx]
        tbl_idx += 1
      end
    end
  else
    body.paragraphs.each { |p| yield p }
    body.tables&.each { |tbl| yield tbl }
  end
end

def walk_body_paragraphs(body, &block)
  walk_body(body) { |node| yield node if node.is_a?(Wordprocessingml::Paragraph) }
end
```

For table-cell paragraphs, `walk_table_paragraphs` already exists in
helpers.rb:68 — keep it.

Remove `walk_all_paragraphs` and `walk_body_tables` from
`referential_integrity.rb`; refactor callers.

### Verification

Existing specs should pass unchanged. Add helpers_spec coverage for:
- walk_body yields paragraphs in element_order
- walk_body yields tables in element_order
- walk_body falls back to arrays when element_order is nil
- walk_body_paragraphs filters out tables
