# Sequence 2: docx-js TypeScript Test Conversion - Analysis

**Date:** 2025-10-26
**Status:** Analysis Complete, Ready for Conversion

---

## Overview

This document tracks the systematic conversion of docx-js TypeScript tests to Ruby RSpec tests for Uniword.

**Goal:** Import 200-300 core functional tests from docx-js to achieve comprehensive test coverage

**Current Status:** Sequence 1 Complete (44 docx gem tests, 90.9% passing)

---

## Priority 1: Core Functionality Tests

### Test File Inventory

#### Batch 1 (Files 1-5) - Document & Paragraph Core

| # | Source File | Target File | Est. Tests | Complexity |
|---|-------------|-------------|------------|-----------|
| 1 | `reference/docx-js/src/file/document/document.spec.ts` | `spec/compatibility/docx_js/core/document_spec.rb` | 1 | Low |
| 2 | `reference/docx-js/src/file/paragraph/paragraph.spec.ts` | `spec/compatibility/docx_js/core/paragraph_spec.rb` | ~50 | Medium |
| 3 | `reference/docx-js/src/file/paragraph/run/text-run.spec.ts` | `spec/compatibility/docx_js/core/run_spec.rb` | 2 | Low |
| 4 | `reference/docx-js/src/file/table/table.spec.ts` | `spec/compatibility/docx_js/core/table_spec.rb` | ~15 | Medium |
| 5 | `reference/docx-js/src/file/styles/style/paragraph-style.spec.ts` | `spec/compatibility/docx_js/core/paragraph_style_spec.rb` | ~80 | High |

**Batch 1 Total:** ~148 tests

#### Batch 2 (Files 6-10) - Properties & Formatting

| # | Source File | Target File | Est. Tests | Complexity |
|---|-------------|-------------|------------|-----------|
| 6 | `reference/docx-js/src/file/paragraph/run/run-fonts.spec.ts` | `spec/compatibility/docx_js/formatting/run_fonts_spec.rb` | ~10 | Low |
| 7 | `reference/docx-js/src/file/paragraph/run/underline.spec.ts` | `spec/compatibility/docx_js/formatting/underline_spec.rb` | ~8 | Low |
| 8 | `reference/docx-js/src/file/table/table-cell/table-cell.spec.ts` | `spec/compatibility/docx_js/core/table_cell_spec.rb` | ~12 | Medium |
| 9 | `reference/docx-js/src/file/table/table-row/table-row.spec.ts` | `spec/compatibility/docx_js/core/table_row_spec.rb` | ~10 | Low |
| 10 | `reference/docx-js/src/file/styles/style/character-style.spec.ts` | `spec/compatibility/docx_js/core/character_style_spec.rb` | ~40 | Medium |

**Batch 2 Total:** ~80 tests

#### Batch 3 (Files 11-15) - Advanced Features

| # | Source File | Target File | Est. Tests | Complexity |
|---|-------------|-------------|------------|-----------|
| 11 | `reference/docx-js/src/file/paragraph/run/image-run.spec.ts` | `spec/compatibility/docx_js/features/image_spec.rb` | ~8 | Medium |
| 12 | `reference/docx-js/src/file/document/body/section-properties/section-properties.spec.ts` | `spec/compatibility/docx_js/core/section_spec.rb` | ~15 | Medium |
| 13 | `reference/docx-js/src/file/table/table-properties/table-borders.spec.ts` | `spec/compatibility/docx_js/core/table_borders_spec.rb` | ~20 | Medium |
| 14 | `reference/docx-js/src/file/table/table-properties/table-properties.spec.ts` | `spec/compatibility/docx_js/core/table_properties_spec.rb` | ~15 | Medium |
| 15 | `reference/docx-js/src/file/paragraph/frame/frame-properties.spec.ts` | `spec/compatibility/docx_js/features/frame_spec.rb` | ~12 | High |

**Batch 3 Total:** ~70 tests

---

## Conversion Strategy

### Test Conversion Patterns

#### TypeScript → Ruby Mapping

**TypeScript Pattern:**
```typescript
it("should create empty document", () => {
  const doc = new Document();
  expect(doc).toBeDefined();
});
```

**Ruby Pattern:**
```ruby
it 'creates empty document' do
  doc = Uniword::Document.new
  expect(doc).not_to be_nil
  expect(doc.paragraphs).to be_empty
end
```

#### Common Conversions

| TypeScript | Ruby |
|-----------|------|
| `new Document()` | `Uniword::Document.new` |
| `new Paragraph("text")` | `Uniword::Paragraph.new.add_text("text")` |
| `new TextRun("text")` | `Uniword::Run.new.add_text("text")` |
| `new Table({rows: [...]})` | `Uniword::Table.new(rows: [...])` |
| `expect(x).toBeDefined()` | `expect(x).not_to be_nil` |
| `expect(x).to.deep.equal(y)` | `expect(x).to eq(y)` |

### API Adaptation Strategy

Where docx-js and Uniword APIs differ:

1. **Constructor Options**
   - TS: `new Paragraph({ text: "hello", alignment: AlignmentType.CENTER })`
   - Ruby: `Uniword::Paragraph.new.add_text("hello").align(:center)`

2. **Method Chaining**
   - TS: Uses constructor options
   - Ruby: Prefer method chaining for fluent API

3. **Enums**
   - TS: `AlignmentType.CENTER`
   - Ruby: `:center` (symbols)

4. **XML Output Testing**
   - TS: Tests against formatted JSON tree
   - Ruby: Test against object properties and serialization

---

## Test Organization

### Directory Structure

```
spec/compatibility/docx_js/
├── core/
│   ├── document_spec.rb
│   ├── paragraph_spec.rb
│   ├── run_spec.rb
│   ├── table_spec.rb
│   ├── table_cell_spec.rb
│   ├── table_row_spec.rb
│   ├── paragraph_style_spec.rb
│   ├── character_style_spec.rb
│   └── section_spec.rb
├── formatting/
│   ├── run_fonts_spec.rb
│   ├── underline_spec.rb
│   └── ...
└── features/
    ├── image_spec.rb
    ├── frame_spec.rb
    └── ...
```

---

## Test Focus Areas

### Batch 1 Coverage

**Document Tests:**
- ✓ Document creation
- ✓ XML namespace verification

**Paragraph Tests:**
- ✓ Heading levels (1-6, Title)
- ✓ Alignment (left, center, right, justified, distribute, start, end)
- ✓ Tab stops (left, right, center, with leaders)
- ✓ Contextual spacing
- ✓ Thematic breaks
- ✓ Paragraph borders
- ✓ Page breaks
- ✓ Bullet lists
- ✓ Numbered lists
- ✓ Bookmarks
- ✓ Styles
- ✓ Indentation
- ✓ Spacing
- ✓ Keep lines/next
- ✓ Bidirectional text
- ✓ Line number suppression
- ✓ Outline levels
- ✓ Shading
- ✓ Frames
- ✓ External hyperlinks

**Run Tests:**
- ✓ Text creation
- ✓ Empty text
- ✓ Footnote references

**Table Tests:**
- ✓ Basic table structure
- ✓ Cell spanning (colspan/rowspan)
- ✓ Table layout (fixed/auto)
- ✓ Table alignment
- ✓ Table width (percentage/DXA)
- ✓ Floating tables
- ✓ Cell margins

**Style Tests:**
- ✓ Style ID and name
- ✓ Based on styles
- ✓ Quick format
- ✓ Next style
- ✓ Paragraph indentation
- ✓ Paragraph spacing
- ✓ Alignment styles
- ✓ Character spacing
- ✓ Font sizes
- ✓ Small caps / All caps
- ✓ Strike / Double strike
- ✓ Sub/superscript
- ✓ Font families
- ✓ Bold / Italics
- ✓ Highlighting
- ✓ Shading patterns
- ✓ Underline styles
- ✓ Emphasis marks
- ✓ Text color
- ✓ Linked styles

---

## Success Metrics

### Batch 1 Targets

- [ ] 148 tests converted
- [ ] 80%+ pass rate (118+ passing)
- [ ] Zero regressions in existing tests
- [ ] API gaps documented
- [ ] Missing features identified

### Overall Sequence 2 Targets

- [ ] 200-300 tests converted total
- [ ] 85%+ overall pass rate
- [ ] Core features validated
- [ ] Ready for missing feature implementation

---

## Known API Gaps (To Address)

Based on initial test review, these features may need implementation or adaptation:

1. **Paragraph Borders** - Need verification if fully supported
2. **Positional Tabs** - Not yet implemented
3. **Text Frames** - Not yet implemented
4. **Advanced Shading Patterns** - May need extension
5. **External Hyperlinks** - Not yet implemented
6. **Complex Script Support** - May need verification

---

## Next Steps

1. ✅ Analysis complete
2. ⏭️ Begin Batch 1 conversion (Files 1-5)
3. ⏭️ Run tests, document pass rate
4. ⏭️ Fix critical API gaps
5. ⏭️ Proceed to Batch 2

---

**Last Updated:** 2025-10-26
**Status:** READY FOR CONVERSION - START BATCH 1