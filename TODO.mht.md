# TODO.mht.md — MHT/DOCX Transformation Work

## Overview

MHT (MHTML) ↔ DOCX transformation work. Full fidelity round-trip conversion.

**Test Status**: 3186 examples, 0 failures, 65 pending (2026-04-04)

---

## Completed Work

### MHTML Edge Cases (DONE 2026-04-04)

| Issue | Fix |
|-------|-----|
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
|-------|-----|
| Empty table cells returning nil | Added `create_empty_cell` method |
| CSS class → OOXML style mapping | Map MsoHeading1-6, MsoToc1-9, MsoTitle, etc. |
| Table cell paragraph styles | Proper style mapping for cell content |

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

## Remaining Work

### MHT → DOCX

#### 1. SDT Attribute Preservation
MHT contains `w:Sdt` elements with attributes that need preservation:

```
w:Sdt ShowingPlcHdr="t" Temporary="t" DocPart="UUID" Text="t" ID="-1771543088"
```

| Attribute | Description | Status |
|----------|-------------|--------|
| ShowingPlcHdr | Placeholder display | DONE (parsing) |
| Temporary | Temporary SDT | DONE (parsing) |
| DocPart | Document part UUID | DONE (parsing) |
| Text | Text-only flag | DONE (parsing) |
| ID | Numeric ID | DONE (parsing) |

**Implementation**: Parse `<w:Sdt ...>` wrapper elements from MHT HTML, extract attributes, and apply to OOXML SDT properties.

**Known Issue**: SDT attributes are parsed and stored in OOXML model, but `build_sdt_attrs` in ooxml_to_mhtml_converter.rb does not serialize them back to MHT format. Round-trip loses SDT attributes.

#### 2. Hyperlink URL Resolution
External hyperlinks need relationship ID → URL resolution:

| Issue | Status |
|-------|--------|
| External URL resolution | MISSING |
| Internal anchor links (#_Toc) | MISSING |
| TOC field codes preservation | MISSING |

#### 3. TOC Field Codes
Conditional comments contain TOC field codes that need parsing:

```
<!--[if !supportLists]-->
<!--[if gte mso 9]>
...
<![endif]-->
```

#### 4. Metadata Fields
Complete metadata fields extraction:

| Field | Status |
|-------|--------|
| o:Revision | MISSING |
| o:TotalTime | MISSING |
| o:Pages | MISSING |
| o:Words | MISSING |
| o:Characters | MISSING |

---

### DOCX → MHT

#### 1. VML Behavior Styles
Conditional VML styles in `<!--[if !mso]>` tags.

#### 2. CustomDocumentProperties
`o:CustomDocumentProperties` with AssetID and other custom fields.

#### 3. Image Parts
Image parts in MIME structure with base64 encoding.

#### 4. Theme Parts
Binary theme parts:
- `themedata.thmx` (base64)
- `colorschememapping.xml`

#### 5. Header/Footer Parts
Header and footer as separate MIME parts.

#### 6. Filelist.xml
Complete `filelist.xml` generation tracking all parts.

---

## Implementation Phases

### Phase 1: Style Mapping ✓
- [x] MsoHeading1-6
- [x] MsoToc1-9
- [x] MsoTitle, MsoTitle2, MsoSubtitle
- [x] SectionTitle, MsoBibliography, MsoNoSpacing
- [x] MsoQuote, MsoHeader, MsoFooter, MsoListBullet, etc.

### Phase 2: SDT Enhancement
- [ ] Parse SDT attributes from MHT HTML
- [ ] Preserve attributes in OOXML SDT elements
- [ ] Handle SDT content from mixed_content

### Phase 3: Hyperlink Resolution
- [ ] External URL from relationships
- [ ] Internal anchor links
- [ ] TOC field code parsing

### Phase 4: DOCX → MHT Completeness
- [ ] VML behavior styles
- [ ] CustomDocumentProperties
- [ ] Image parts (base64)
- [ ] Theme/colorschememapping parts
- [ ] Header/footer MIME parts
- [ ] filelist.xml

### Phase 5: Round-Trip Tests
- [x] MHT edge cases (all passing)
- [x] Content matching (136 tests passing)
- [ ] Full round-trip fidelity spec

---

## Test Suite Breakdown

| Test File | Status |
|------------|--------|
| spec/integration/mhtml_edge_cases_spec.rb | 35 examples, 0 failures |
| spec/transformation/mht_docx_content_matching_spec.rb | 29 examples passing |
| spec/integration/format_conversion_spec.rb | 17 examples, 0 failures |
| spec/integration/mhtml_compatibility_spec.rb | 32 examples, 0 failures |

**Total MHT-related**: 136+ transformation tests passing

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
