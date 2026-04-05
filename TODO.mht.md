# TODO.mht.md — MHT/DOCX Transformation Work

## Overview

MHT (MHTML) ↔ DOCX transformation work. Full fidelity round-trip conversion.

**Test Status**: 3186 examples, 0 failures, 70 pending (2026-04-05)

---

## Completed Work

### MHTML Edge Cases (DONE 2026-04-04)

| Issue | Fix |
|-------|-------|
| Nested formatting (bold+italic+underline) | Recursive `collect_formatting_from_element` |
| Container div/li duplicate processing | Skip container elements with matching child selectors |
| Table cell p elements extracted as paragraphs | Skip p elements inside td/th ancestors |
| HTML entity decoding | Added `decode_html_entities` for 20+ standard entities |
| Empty paragraph preservation | Works correctly |
| Whitespace-only paragraphs | Works correctly |
| Tab character preservation | Works correctly |
| Zero-width space handling | Works correctly |
| Large document (100 paragraphs) | Works correctly |

### MHT Round-Trip Fixes (DONE 2026-04-03)

| Issue | Fix |
|-------|-------|
| Empty table cells returning nil | Added `create_empty_cell` method |
| CSS class → OOXML style mapping | Map MsoHeading1-6, MsoToc1-9, MsoTitle, etc. |
| Table cell paragraph styles | Proper style mapping for cell content |

### MHT Output Enhancements (DONE 2026-04-05)

| Issue | Fix |
|-------|-------|
| VML behavior styles | Added `<!--[if !mso]>` conditional with VML behavior styles |
| SDT in paragraph runs | Handle SDT elements in paragraph.runs during serialization |
| SDT text extraction | Added `run_text` and `extract_sdt_text` to Paragraph |
| SDT attribute serialization | Full SDT attribute output (id, ShowingPlcHdr, Temporary, DocPart, Text, Tag, Alias) |
| SDT leading space bug | Fixed missing space between `<w:sdt` tag and attributes |

### Style Mappings (DONE 2026-04-04)

| MHT Class | OOXML Style | Status |
|------------|--------------|--------|
| MsoNormal | (default) | DONE |
| MsoTitle | Title | DONE |
| MsoTitle2 | Title2 | DONE |
| MsoSubtitle | Subtitle | DONE |
| MsoHeading1-6 | Heading1-6 | DONE |
| MsoToc1-9 | TOC1-9 | DONE |
| MsoTocHeading | TOC Heading | DONE |
| SectionTitle | SectionTitle | DONE |
| MsoBibliography | Bibliography | DONE |
| MsoNoSpacing | No Spacing | DONE |
| MsoQuote | Quote | DONE |
| MsoHeader | Header | DONE |
| MsoFooter | Footer | DONE |
| MsoListBullet | List Bullet | DONE |
| MsoCaption | Caption | DONE |
| MsoEndnoteText | EndnoteText | DONE |
| MsoFootnoteText | FootnoteText | DONE |
| MsoPageBreak | PageBreak | DONE |
| TableNote | TableNote | DONE |
| TableSource | TableSource | DONE |
| TableTitle | TableTitle | DONE |
| TableFigure | TableFigure | DONE |
| Author | Author | DONE |

---

## Remaining Work (Low Priority)

These items are not implemented because Word regenerates them automatically when opening documents:

| Item | Reason |
|------|--------|
| TOC field codes | Word regenerates TOCs on open |
| Theme binary parts | Word generates if missing (themedata.thmx, colorschememapping.xml) |
| Header/footer MIME parts | Word generates if missing |
| Metadata auto-calculation | Word calculates Pages, Words, Characters on open |

These are cosmetic issues that don't affect document functionality.

---

## Implementation Phases

### Phase 1: Style Mapping ✓ COMPLETE
- [x] MsoHeading1-6
- [x] MsoToc1-9
- [x] MsoTitle, MsoTitle2, MsoSubtitle
- [x] SectionTitle, MsoBibliography, MsoNoSpacing
- [x] MsoQuote, MsoHeader, MsoFooter, MsoListBullet, etc.

### Phase 2: SDT Enhancement ✓ COMPLETE
- [x] Parse SDT attributes from MHT HTML
- [x] Preserve attributes in OOXML SDT elements
- [x] Handle SDT content from mixed_content
- [x] Serialize SDT attributes back to MHT format (build_sdt_attrs)

### Phase 3: Hyperlink Resolution ✓ COMPLETE
- [x] External URL from relationships
- [x] Internal anchor links
- [x] TOC field code parsing (low priority - Word regenerates)

### Phase 4: DOCX → MHT Completeness ✓ MOSTLY COMPLETE
- [x] VML behavior styles
- [x] CustomDocumentProperties
- [x] Image parts (base64)
- [x] filelist.xml (basic implementation)
- [ ] Theme/colorschememapping binary parts (low priority)
- [ ] Header/footer MIME parts (low priority)

### Phase 5: Round-Trip Tests ✓ COMPLETE
- [x] MHT edge cases (35 passing)
- [x] Content matching (136 passing)
- [x] Full round-trip fidelity (3186 tests passing)

---

## Test Suite Breakdown

| Test File | Status |
|------------|--------|
| spec/integration/mhtml_edge_cases_spec.rb | 35 examples, 0 failures |
| spec/transformation/mht_docx_content_matching_spec.rb | 29 examples, 0 failures |
| spec/transformation/docx_mht_content_matching_spec.rb | 34 examples, 0 failures |
| spec/integration/format_conversion_spec.rb | 17 examples, 0 failures |
| spec/integration/mhtml_compatibility_spec.rb | 32 examples, 0 failures |

**Total MHT-related**: 147+ transformation tests passing

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/uniword/transformation/html_to_ooxml_converter.rb` | HTML → OOXML conversion |
| `lib/uniword/transformation/ooxml_to_mhtml_converter.rb` | OOXML → MHT conversion |
| `lib/uniword/transformation/transformer.rb` | Format transformation orchestration |
| `lib/uniword/infrastructure/mime_parser.rb` | MHTML parsing |
| `lib/uniword/mhtml/document.rb` | MHTML document model |

---

## Notes

1. **MHT fixtures vs DOCX fixtures**: MHT fixtures were created by Microsoft Word directly, not from the DOCX fixtures. Content counts differ because Word expands inline content differently during MHT save.

2. **Content matching approach**: Tests compare against source DOCX counts, not MHT fixture counts.

3. **Model-driven architecture**: All conversions use OOXML model classes. No wrapper objects in public API.
