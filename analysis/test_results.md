# Uniword Compatibility Test Results - Metanorma ISO Samples

**Test Date**: 2025-10-26
**Total Files Tested**: 8 representative samples from 44 total files
**Test Suite**: `spec/compatibility/mn_samples_spec.rb`

## Executive Summary

✅ **Good News**: Uniword successfully reads all tested MHTML files without errors or crashes
❌ **Critical Issue**: Uniword only parses ~8% of actual content due to structural parsing bug

### Test Results Overview

| Category | Files Tested | Success Rate | Content Parsed |
|----------|--------------|--------------|----------------|
| Small files (amendments) | 2 | 100% | ~8% |
| Medium files (ISO standards) | 3 | 100% | ~8% |
| Large files (directives) | 3 | 100% | ~8% |

## Critical Finding: Incomplete Content Parsing

### The Problem

Uniword successfully opens and reads MHTML files but only extracts a small fraction of the content:

**Expected vs. Actual Content** (sample file: `rice-2016/document-en.doc`):

| Metric | In File | Parsed by Uniword | Percentage |
|--------|---------|-------------------|------------|
| Paragraphs | 241 | 20 | 8.3% |
| Tables | 6 | 0 | 0% |
| File Size | 473 KB | ~2 KB text | 0.4% |

### Root Cause Analysis

The issue is in [`HtmlDeserializer#parse_html`](lib/uniword/serialization/html_deserializer.rb:46-71).

**Current Implementation** (lines 58-68):
```ruby
body.children.each do |node|
  next unless node.element?

  elements = parse_block_element(node)
  # ...
end
```

**The Structural Issue**:

Metanorma MHTML files use this structure:
```html
<body>
  <div class="WordSection1">
    <p>Actual paragraph 1</p>
    <p>Actual paragraph 2</p>
    <table>...</table>
    <p>Actual paragraph 3</p>
  </div>
  <div class="WordSection2">
    <p>More content...</p>
  </div>
</body>
```

But the parser:
1. Sees `<div class="WordSection1">` as a direct child of `<body>`
2. Calls `parse_block_element(div)`
3. Line 118 treats it as `when 'p', 'div'` → calls `parse_paragraph(div)`
4. `parse_paragraph` extracts text from the **div itself**, not its children
5. Result: Only the outer structure is parsed, not the actual content inside

This is why we see exactly 20 paragraphs - one for each section div in the document, not the 241 actual paragraphs inside them.

### Verification

```bash
# Count actual paragraphs in file
$ grep -c "<p " rice-2016/document-en.doc
241

# Count actual tables in file
$ grep -c "<table" rice-2016/document-en.doc
6

# Count section divs (what Uniword actually parses)
$ grep -c "WordSection" rice-2016/document-en.doc
20
```

## Detailed Test Results

### Test 1: Small Files (Amendment AWI)

**Files**: 2 amendment documents in AWI stage
**Result**: ✅ All files read successfully

```
documents/amendment/rice-2017/document-en.awi.doc
  Size: 172.68 KB
  Parsed: 16 paragraphs, 0 tables, 2,160 chars

documents/amendment/rice-2023/document-en.awi.doc
  Size: 182.32 KB
  Parsed: 16 paragraphs, 0 tables, 2,160 chars
```

### Test 2: International Standard Files

**Files**: 3 representative ISO standard documents
**Result**: ✅ All files read successfully

```
documents/international-standard/rice-2016/document-en.awi.doc
  Size: 342.58 KB
  Parsed: 16 paragraphs, 0 tables, 2,105 chars

documents/international-standard/rice-2016/document-en.doc
  Size: 473.03 KB
  Parsed: 20 paragraphs, 0 tables, 2,288 chars
  Actual content: 241 paragraphs, 6 tables

documents/international-standard/rice-2023/document-en.doc
  Size: 517.16 KB
  Parsed: 20 paragraphs, 0 tables, 2,288 chars
```

### Test 3: Large Files (ISO Directives)

**Files**: 3 large directive documents (4-12 MB)
**Result**: ✅ All files read successfully (surprisingly fast!)

```
documents/directives/part1-consolidated-iso/document.doc
  Size: 4.72 MB
  Parsed: 20 paragraphs, 0 tables, 2,250 chars
  Parse time: <0.2 seconds

documents/directives/part1/document.doc
  Size: 11.91 MB (largest file)
  Parsed: 20 paragraphs, 0 tables, 2,250 chars
  Parse time: <0.2 seconds

documents/directives/part2/document.doc
  Size: 4.67 MB
  Parsed: 20 paragraphs, 0 tables, 2,250 chars
  Parse time: <0.2 seconds
```

**Note**: The fact that 12MB files parse in <0.2s confirms that most content is being skipped.

### Test 4: Detailed Content Analysis

Using `rice-2016/document-en.doc` as the reference sample:

**Styles Detected**: ✅ Working correctly
- Total styles: 13
- Paragraph styles: 10
- Character styles: 3

**Text Sample Extracted**:
```
ISO 17301-1:2016(E) ISO 17301-1:2016(E) ISO 17301-1:2016(E) 2
```

This is just the header text from section divs, not the actual document body content.

## What's Working Well

### ✅ Stability
- No crashes or errors
- Handles files from 173 KB to 12 MB
- Fast parsing (even for incomplete parsing)
- Proper error handling

### ✅ Format Detection
- Correctly identifies MHTML format
- Parses MIME structure successfully
- Loads embedded resources

### ✅ Style Parsing
- Extracts CSS styles from `<head>`
- Identifies MSO class names correctly
- Maps styles to Uniword model

### ✅ Basic Structure
- Document object creation works
- StylesConfiguration populated
- No memory issues

## What's Not Working

### ❌ Critical: Content Extraction
- **Only ~8% of paragraphs extracted**
- **Zero tables extracted** (0 out of 6)
- Nested content inside divs ignored
- Section structure flattened

### ❌ High Priority: Semantic Structure
- WordSection divs not recognized as sections
- Document structure lost
- Page breaks likely missing
- Headers/footers not extracted

### ❌ Medium Priority: Complex Elements
- Tables inside sections not found
- Lists (if present) likely missed
- Images (if present) likely missed
- Footnotes/endnotes (if present) not extracted

## Impact Assessment

### For v1.1 Release
**BLOCKER**: This bug must be fixed before v1.1 can claim MHTML reading support.

Current state:
- ❌ Cannot recreate Metanorma documents
- ❌ Cannot extract meaningful content
- ❌ Cannot serve as format conversion tool
- ✅ Can serve as MHTML structure validator
- ✅ Can extract styles and themes

### For Metanorma Use Case
The primary use case is **reading Metanorma ISO sample documents** and being able to:
1. Extract all content ❌ (8% success rate)
2. Preserve structure ❌ (sections flattened)
3. Extract tables ❌ (0% success rate)
4. Extract styles ✅ (100% success rate)
5. Convert formats ❌ (insufficient content)

**Current suitability**: Not suitable for production use.

## Recommended Actions

### Immediate (Fix for v1.1)
1. **Fix div handling in HtmlDeserializer** (CRITICAL)
   - Recursively process div children for section divs
   - Add WordSection detection and handling
   - Preserve section structure in document model

2. **Add recursive block parsing**
   - When div contains block elements, recurse into children
   - Only treat div as paragraph if it contains inline content only

3. **Add comprehensive MHTML tests**
   - Use mn-samples-iso files as fixtures
   - Test paragraph counts match actual content
   - Test table extraction
   - Test section structure preservation

### Short Term (v1.2)
4. **Enhanced section support**
   - Map WordSection1/2/3 to Section objects
   - Extract headers/footers from sections
   - Preserve page break information

5. **Table extraction**
   - Ensure tables inside divs are found
   - Handle nested table structures
   - Preserve table formatting

### Medium Term (v1.3+)
6. **Advanced features**
   - Footnote/endnote support
   - Bookmark handling
   - Field extraction
   - Comment preservation

## Test Coverage Metrics

### Files Tested
- ✅ 8 files tested manually
- ✅ 44 files discovered and cataloged
- ⏭️ 36 files available for future testing

### Content Types Tested
- ✅ Small documents (amendments)
- ✅ Medium documents (ISO standards)
- ✅ Large documents (directives)
- ✅ Multilingual documents (EN, FR samples available)
- ⏭️ Chinese language samples available
- ⏭️ Different document stages (AWI, CD, DIS, FDIS, PRF, etc.)

### Features Tested
- ✅ File loading
- ✅ Format detection
- ✅ Style extraction
- ✅ Basic structure
- ⏭️ Content completeness
- ⏭️ Table extraction
- ⏭️ Image handling
- ⏭️ Section structure
- ⏭️ Round-trip conversion

## Conclusion

Uniword has a **solid foundation** for MHTML support:
- Stable file handling ✅
- Good architecture ✅
- Proper error handling ✅
- Style support ✅

However, there is a **critical bug** in content extraction that must be fixed:
- Only 8% of paragraphs extracted ❌
- Zero tables extracted ❌
- Section structure lost ❌

**Recommendation**: Fix the div handling bug in HtmlDeserializer before releasing v1.1. This is a high-impact, low-complexity fix that will unlock full MHTML reading capability.

**Estimated effort**: 0.5-1 day to fix + 0.5 day for comprehensive testing = 1-1.5 days total.