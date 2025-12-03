# Document Generation Fix Tracker

## Overview

This document tracks the systematic fixing of all 13 XML file differences between the generated [`demo_formal_integral.docx`](examples/demo_formal_integral.docx) and the reference [`demo_formal_integral_proper.docx`](examples/demo_formal_integral_proper.docx).

**Goal:** Achieve semantic equivalence for all files as verified by Canon comparison tool.

**Verification Command:**
```bash
ruby test_verify_demo_formal_integral.rb
```

## Current Status

**Last Verification:** 2025-11-13T17:20:19+08:00

| Status | Count |
|--------|-------|
| ✓ Equivalent | 0/13 |
| ⚠ Different | 13/13 |
| ❌ Missing | 0/13 |

---

## File Comparison Matrix

| # | File | Status | Current Size | Reference Size | Priority | Notes |
|---|------|--------|--------------|----------------|----------|-------|
| 1 | [`word/document.xml`](examples/demo_current/word/document.xml) | ⚠ Different | 17,986 bytes | 106,545 bytes | **HIGH** | Main content - large size difference |
| 2 | [`word/styles.xml`](examples/demo_current/word/styles.xml) | ⚠ Different | 15,105 bytes | 45,273 bytes | **HIGH** | Style definitions missing |
| 3 | [`word/theme/theme1.xml`](examples/demo_current/word/theme/theme1.xml) | ⚠ Different | 1,540 bytes | 7,315 bytes | **HIGH** | Theme data incomplete |
| 4 | [`word/fontTable.xml`](examples/demo_current/word/fontTable.xml) | ⚠ Different | 657 bytes | 2,412 bytes | MEDIUM | Font definitions missing |
| 5 | [`word/settings.xml`](examples/demo_current/word/settings.xml) | ⚠ Different | 252 bytes | 3,626 bytes | MEDIUM | Document settings missing |
| 6 | [`word/webSettings.xml`](examples/demo_current/word/webSettings.xml) | ⚠ Different | 185 bytes | 1,069 bytes | LOW | Web settings minimal |
| 7 | [`word/numbering.xml`](examples/demo_current/word/numbering.xml) | ⚠ Different | 125 bytes | 3,225 bytes | MEDIUM | Numbering definitions missing |
| 8 | [`[Content_Types].xml`](examples/demo_current/[Content_Types].xml) | ⚠ Different | 1,624 bytes | 1,497 bytes | MEDIUM | Content type declarations |
| 9 | [`_rels/.rels`](examples/demo_current/_rels/.rels) | ⚠ Different | 880 bytes | 590 bytes | MEDIUM | Package relationships |
| 10 | [`word/_rels/document.xml.rels`](examples/demo_current/word/_rels/document.xml.rels) | ⚠ Different | 1,088 bytes | 950 bytes | MEDIUM | Document relationships |
| 11 | [`word/theme/_rels/theme1.xml.rels`](examples/demo_current/word/theme/_rels/theme1.xml.rels) | ⚠ Different | 125 bytes | 293 bytes | LOW | Theme relationships |
| 12 | [`docProps/app.xml`](examples/demo_current/docProps/app.xml) | ⚠ Different | 682 bytes | 719 bytes | LOW | Application properties |
| 13 | [`docProps/core.xml`](examples/demo_current/docProps/core.xml) | ⚠ Different | 666 bytes | 747 bytes | LOW | Core properties/metadata |

---

## Detailed Analysis & Fixes

### 1. word/document.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 88,559 bytes smaller (16.9% of reference size)

**Suspected Issues:**
- Missing content elements
- Incomplete paragraph/run structures
- Missing section properties
- Possible missing headers/footers

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare document structure
3. [ ] Identify missing elements
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 2. word/styles.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 30,168 bytes smaller (33.4% of reference size)

**Suspected Issues:**
- Missing style definitions
- Incomplete styleset application
- Missing default styles

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare style count
3. [ ] Identify missing style types
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 3. word/theme/theme1.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 5,775 bytes smaller (21.1% of reference size)

**Suspected Issues:**
- Incomplete theme serialization
- Missing color scheme elements
- Missing font scheme elements
- Missing format scheme elements

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare theme structure
3. [ ] Identify missing theme components
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 4. word/fontTable.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 1,755 bytes smaller (27.2% of reference size)

**Suspected Issues:**
- Missing font definitions
- Incomplete font embedding data

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare font entries
3. [ ] Identify missing fonts
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 5. word/settings.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 3,374 bytes smaller (6.9% of reference size)

**Suspected Issues:**
- Missing document settings
- Missing compatibility settings
- Missing view settings

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare setting elements
3. [ ] Identify missing settings
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 6. word/webSettings.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 884 bytes smaller (17.3% of reference size)

**Suspected Issues:**
- Missing web-specific settings
- Incomplete encoding declarations

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare web setting elements
3. [ ] Identify missing settings
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 7. word/numbering.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 3,100 bytes smaller (3.9% of reference size)

**Suspected Issues:**
- Missing numbering definitions
- Missing abstract numbering
- Missing numbering instances

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare numbering structures
3. [ ] Identify missing definitions
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 8. [Content_Types].xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 127 bytes LARGER (108.5% of reference size)

**Suspected Issues:**
- Extra content type declarations
- Incorrect override declarations
- Possible format differences only

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare content type entries
3. [ ] Identify extra/missing types
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 9. _rels/.rels

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 290 bytes LARGER (149.2% of reference size)

**Suspected Issues:**
- Extra relationship declarations
- Incorrect relationship targets
- Different relationship ordering

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare relationship entries
3. [ ] Identify extra/missing relationships
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 10. word/_rels/document.xml.rels

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 138 bytes LARGER (114.5% of reference size)

**Suspected Issues:**
- Extra document relationships
- Incorrect relationship IDs
- Different relationship ordering

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare relationship entries
3. [ ] Identify extra/missing relationships
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 11. word/theme/_rels/theme1.xml.rels

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 168 bytes smaller (42.7% of reference size)

**Suspected Issues:**
- Missing theme relationships
- Missing image relationships for theme

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare relationship entries
3. [ ] Identify missing relationships
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 12. docProps/app.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 37 bytes smaller (94.9% of reference size)

**Suspected Issues:**
- Minor metadata differences
- Possibly just Word version stamps

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare property values
3. [ ] Identify semantic vs metadata differences
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

### 13. docProps/core.xml

**Status:** ⚠ Pending Analysis

**Size Difference:** Current is 81 bytes smaller (89.2% of reference size)

**Suspected Issues:**
- Minor metadata differences
- Possibly timestamps or creator information

**Analysis Steps:**
1. [ ] Read both files
2. [ ] Compare property values
3. [ ] Identify semantic vs metadata differences
4. [ ] Document root cause

**Fix Implementation:**
- [ ] Location: TBD
- [ ] Changes: TBD
- [ ] Test: Re-run verification

---

## Fix Strategy

### Phase 1: Core Content Files (Priority: HIGH)
1. **word/document.xml** - Main document content structure
2. **word/styles.xml** - Style definitions and formatting
3. **word/theme/theme1.xml** - Theme colors, fonts, effects

### Phase 2: Supporting Files (Priority: MEDIUM)
4. **word/fontTable.xml** - Font declarations
5. **word/settings.xml** - Document settings
6. **word/numbering.xml** - List numbering definitions
7. **[Content_Types].xml** - OOXML content types
8. **_rels/.rels** - Package-level relationships
9. **word/_rels/document.xml.rels** - Document relationships

### Phase 3: Auxiliary Files (Priority: LOW)
10. **word/webSettings.xml** - Web-specific settings
11. **word/theme/_rels/theme1.xml.rels** - Theme relationships
12. **docProps/app.xml** - Application properties
13. **docProps/core.xml** - Core document metadata

---

## Verification Process

After each fix:

1. **Run verification script:**
   ```bash
   ruby test_verify_demo_formal_integral.rb
   ```

2. **Update this tracker:**
   - Change file status to ✓ Equivalent if Canon confirms
   - Document the fix if successful
   - Note any remaining issues if not resolved

3. **Commit changes:**
   ```bash
   git add -A
   git commit -m "fix(generation): resolve {file} differences"
   ```

---

## Notes

- **Canon Match Profile:** `spec_friendly` - ignores formatting/whitespace differences
- **Focus:** Structural and semantic differences only
- **Approach:** Fix one file at a time, verify immediately
- **Documentation:** Update this tracker after each fix

---

## Investigation Commands

```bash
# Extract current generated document
cd examples && unzip -qo demo_formal_integral.docx -d demo_current

# Extract reference document
cd examples && unzip -qo demo_formal_integral_proper.docx -d demo_reference

# Compare specific files with diff
diff examples/demo_current/word/document.xml examples/demo_reference/word/document.xml

# Compare with xmllint formatting
xmllint --format examples/demo_current/word/document.xml > /tmp/current.xml
xmllint --format examples/demo_reference/word/document.xml > /tmp/reference.xml
diff /tmp/current.xml /tmp/reference.xml

# Use Canon for semantic comparison
ruby -rcanon/comparison -e "puts Canon::Comparison.equivalent?(File.read('examples/demo_current/word/document.xml'), File.read('examples/demo_reference/word/document.xml'), match_profile: :spec_friendly)"
```

---

## Progress Log

### 2025-11-13T17:20:19+08:00 - Initial Assessment
- Created tracking document
- Ran initial verification: 13/13 files different
- Identified size discrepancies and priorities
- Established fix strategy in 3 phases

---

**Next Action:** Begin Phase 1 - Analyze word/document.xml differences