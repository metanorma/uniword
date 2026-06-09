# 007: Add missing specs

## Status: DONE

## Specs added

1. **reconcile_sect_pr_references** — removes dangling header/footer refs from sectPr
2. **collect_valid_header_footer_rids** — gathers valid rIds from document_rels
3. **reconcile_referential_integrity with broken refs** — body references footnote/endnote ID "99" → run removed
4. **reconcile_numbering durableId** — instances get deterministic durableId, existing values preserved, signed 32-bit range
5. **Table gridAfter** — row covering fewer columns than grid gets gridAfter, gridSpan accounted for
6. **Existing rsid/paraId preserved** — pre-existing values NOT overwritten (||= pattern)
7. **Notes: reorder by reference order** — footnotes reordered to match body reference order

## Additional fixes
- Removed last `public_send` in `reconcile_sect_pr_references`, replaced with explicit `[sect_pr.header_references, sect_pr.footer_references].each`

## Files
- `spec/uniword/docx/reconciler_spec.rb` (66 examples, 0 failures)
- `lib/uniword/docx/reconciler/referential_integrity.rb` (no more public_send)
