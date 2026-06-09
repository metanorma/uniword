# 008: Cross-part ID referential integrity — full coverage achieved

## Status: DONE

## Summary

All 12 cross-part ID reference types now have reconciler coverage.

## Coverage (12/12)

| # | Source → Target | Status |
|---|-----------------|--------|
| 1 | body → footnotes.xml (fnRef/@w:id) | ✅ removes dangling |
| 2 | body → endnotes.xml (enRef/@w:id) | ✅ removes dangling |
| 3 | sectPr → document.xml.rels (hdrFtrRef/@r:id) | ✅ removes dangling |
| 4 | body → styles.xml (pStyle/@val) | ✅ removes dangling |
| 5 | body → numbering.xml (numPr/numId/@val) | ✅ removes dangling |
| 6 | body → images (blip/@r:embed) | ✅ warns only |
| 7 | body → hyperlinks (hyperlink/@r:id) | ✅ removes dangling |
| 8 | styles.xml self-refs (basedOn/@val, link/@val) | ✅ removes dangling |
| 9 | numbering.xml (abstractNumId) | ✅ logs warning |
| 10 | paraId uniqueness | ✅ deduplicates |
| 11 | rId uniqueness | ✅ deduplicates |
| 12 | body → styles.xml (rStyle, tblStyle) | ✅ removes dangling |

## Spec coverage

83 reconciler specs (all passing):
- 7 footnote/endnote specs
- 7 referential integrity (notes + sectPr) specs
- 3 style reference specs (pStyle)
- 3 style inheritance specs (basedOn, link)
- 3 run/table style specs (rStyle, tblStyle)
- 3 numbering body reference specs
- 3 hyperlink reference specs
- 1 paraId uniqueness spec
- 1 rId uniqueness spec
- Plus 53 existing specs for other modules

## Remaining architectural work

Tracked in separate TODOs:
- **009**: Header/footer rId wiring order
- **010**: Eliminate public_send in part-copy
- **011**: Deduplicate next_rid helper
- **012**: Fix header/footer dual-path ambiguity
- **013**: DRY package part injection
- **014**: Model-driven header_footer_parts
- **015**: Clear namespace plans missing HFP
- **016**: Image reference repair

## Files
- `lib/uniword/docx/reconciler/referential_integrity.rb`
- `spec/uniword/docx/reconciler_spec.rb`
