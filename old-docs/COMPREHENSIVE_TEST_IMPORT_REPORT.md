# Comprehensive Test Import Discovery Report

**Date**: 2025-10-26
**Mission**: Import ALL tests from reference libraries to prove Uniword supersedes them

---

## DISCOVERY SUMMARY

### Total Test Files Found: **186 files**

| Library | Test Files | Language | Status |
|---------|-----------|----------|--------|
| **docx gem** | 2 | Ruby | Ready to import |
| **docx-js** | 181 | TypeScript | Requires TS→Ruby conversion |
| **docxjs** | 2 | JavaScript | Requires JS→Ruby conversion |
| **html2doc** | 1 | Ruby | Ready to import |

---

## DETAILED BREAKDOWN

### 1. docx Gem (Ruby) - 2 Files

**Location**: `reference/docx/spec/`

**Files**:
1. [`reference/docx/spec/docx/document_spec.rb`](reference/docx/spec/docx/document_spec.rb) (708 lines)
   - Document reading/writing
   - Table operations
   - Formatting (bold, italic, underline, alignment)
   - Bookmarks and editing
   - Paragraph and run manipulation
   - Style management
   - HTML output
   - **~50 test cases**

2. [`reference/docx/spec/docx/elements/style_spec.rb`](reference/docx/spec/docx/elements/style_spec.rb) (181 lines)
   - Style attribute getters/setters
   - Style validation
   - XML serialization
   - **~60 test cases**

**Supporting Files**:
- [`reference/docx/spec/support/shared_examples.rb`](reference/docx/spec/support/shared_examples.rb) (68 lines)
  - Shared examples for reading and saving

**Estimated Test Count**: ~110 tests
**Complexity**: Medium (direct Ruby, API similar to Uniword)

---

### 2. docx-js (TypeScript) - 181 Files

**Location**: `reference/docx-js/src/`

**Sample Files** (showing structure):
```
reference/docx-js/src/index.spec.ts
reference/docx-js/src/file/paragraph/paragraph.spec.ts (982 lines, ~80 tests)
reference/docx-js/src/file/paragraph/run/run.spec.ts (760 lines, ~50 tests)
reference/docx-js/src/file/table/table.spec.ts
reference/docx-js/src/file/styles/...
reference/docx-js/src/file/numbering/...
reference/docx-js/src/file/drawing/...
... (177 more files)
```

**Test Categories**:
- **Paragraph**: ~15 files (headings, alignment, spacing, borders, bullets, numbering)
- **Run/Text**: ~10 files (formatting, fonts, colors, styles)
- **Table**: ~20 files (tables, rows, cells, borders)
- **Styles**: ~15 files (paragraph styles, character styles)
- **Numbering**: ~10 files (lists, numbering definitions)
- **Drawing/Images**: ~30 files (images, shapes, positioning)
- **Document**: ~10 files (sections, headers, footers)
- **Properties**: ~20 files (document properties, core properties)
- **Relationships**: ~5 files (relationships, hyperlinks)
- **Other**: ~46 files (borders, shading, formatting, utilities)

**Test Pattern** (TypeScript):
```typescript
describe("Paragraph", () => {
    it("should create valid JSON", () => {
        const paragraph = new Paragraph("");
        const tree = new Formatter().format(paragraph);
        expect(tree).to.deep.equal({ /* expected structure */ });
    });
});
```

**Conversion Needed** (TypeScript → Ruby):
```ruby
RSpec.describe 'Paragraph (docx-js)' do
  it 'creates valid structure' do
    paragraph = Uniword::Paragraph.new
    # Adapt to Uniword API
    expect(paragraph).to be_a(Uniword::Paragraph)
  end
end
```

**Estimated Test Count**: ~1,500-2,000 tests
**Complexity**: Very High (TypeScript conversion + API mapping + XML structure validation)

---

### 3. docxjs (JavaScript) - 2 Files

**Location**: `reference/docxjs/tests/`

**Files**:
1. [`reference/docxjs/tests/render-test/test.spec.js`](reference/docxjs/tests/render-test/test.spec.js)
   - Document rendering tests
   - HTML output validation
   - Multiple test documents (equation, footnote, line-spacing, numbering, revision, table, text)

2. [`reference/docxjs/tests/extended-props-test/extended-props.spec.js`](reference/docxjs/tests/extended-props-test/extended-props.spec.js)
   - Extended document properties parsing

**Estimated Test Count**: ~15 tests
**Complexity**: Medium (rendering-focused, may not all apply to Uniword)

---

### 4. html2doc (Ruby) - 1 File

**Location**: `reference/html2doc/spec/`

**File**:
1. [`reference/html2doc/spec/html2doc_spec.rb`](reference/html2doc/spec/html2doc_spec.rb) (1,072 lines)
   - HTML to DOCX conversion
   - MathML processing
   - Image handling and resizing
   - Footnote processing
   - List styling
   - Table handling
   - **~50 test cases**

**Estimated Test Count**: ~50 tests
**Complexity**: High (HTML import, not just DOCX creation - requires HtmlImporter implementation)

---

## TOTAL ESTIMATED TEST COUNT

| Library | Files | Estimated Tests | Complexity |
|---------|-------|----------------|------------|
| docx gem | 2 | 110 | Medium |
| docx-js | 181 | 1,500-2,000 | Very High |
| docxjs | 2 | 15 | Medium |
| html2doc | 1 | 50 | High |
| **TOTAL** | **186** | **~1,675-2,175** | **Very High** |

---

## CURRENT UNIWORD TEST STATUS

**Existing Tests**: 51 tests
**Passing**: 16 (31%)
**Failing**: 35 (69%)

**To Reach Goal**:
- Import: ~2,000 additional tests
- Target Pass Rate: 95%+
- Required Passes: ~1,950 tests
- Maximum Allowed Failures: ~100 tests

---

## REALISTIC ASSESSMENT

### Time Estimates

**Per-Test Conversion Time**:
- Ruby test import: ~2-5 minutes (read, adapt, test)
- TypeScript→Ruby conversion: ~5-10 minutes (convert syntax, adapt API, test)

**Total Estimated Time**:
- docx gem (110 tests × 3 min): ~5.5 hours
- docx-js (1,750 tests × 7 min): ~200 hours
- docxjs (15 tests × 5 min): ~1.25 hours
- html2doc (50 tests × 5 min): ~4 hours
- **Total**: ~210 hours (26 full working days)

### Challenges

1. **API Mapping Complexity**:
   - docx-js uses `new Paragraph({ alignment: AlignmentType.CENTER })`
   - Uniword uses `paragraph.properties.alignment = :center`
   - Each test requires understanding both APIs and mapping correctly

2. **Missing Features**:
   - Many docx-js features may not exist in Uniword yet
   - Would need to implement features OR skip tests
   - Each missing feature = hours of implementation

3. **Test Framework Differences**:
   - docx-js uses Vitest (TypeScript)
   - Uniword uses RSpec (Ruby)
   - Syntax conversion is mechanical but time-consuming

4. **XML Structure Validation**:
   - docx-js tests validate XML structure directly
   - Uniword tests would need to validate OOXML elements
   - Requires understanding OOXML schema deeply

---

## RECOMMENDED PHASED APPROACH

### Phase 1: Quick Wins (Days 1-2) ✓ FEASIBLE

**Import Ruby Tests**: docx gem + html2doc (160 tests)
- Direct Ruby-to-Ruby import
- Similar API concepts
- Can be done quickly

**Goal**: 160 additional tests, 70% pass rate

### Phase 2: High-Value TypeScript Tests (Days 3-7) ⚠️ CHALLENGING

**Import Core docx-js Tests** (300 tests):
- Paragraph tests (alignment, spacing, indentation)
- Run tests (bold, italic, formatting)
- Table tests (basic structure)
- Document tests (sections, properties)

**Goal**: 300 additional tests, 80% pass rate

### Phase 3: Feature Implementation (Days 8-14) ⚠️ VERY CHALLENGING

**Fix Failing Tests**:
- Implement missing convenience APIs
- Add property setters
- Implement missing features

**Goal**: Bring pass rate to 90%+

### Phase 4: Comprehensive Coverage (Days 15-26) 🔴 INFEASIBLE

**Import Remaining docx-js Tests** (1,450 tests):
- Advanced features
- Edge cases
- Complex scenarios

**Goal**: Full library supersession proof

---

## IMMEDIATE NEXT STEPS

### What We CAN Do Right Now (Achievable in 1-2 days):

1. **Import ALL docx gem tests** (2 files, ~110 tests)
   - Copy spec files to `spec/compatibility/docx_gem/`
   - Adapt to Uniword API
   - Fix API compatibility issues

2. **Import html2doc tests** (1 file, ~50 tests)
   - Copy spec file to `spec/compatibility/html2doc/`
   - Adapt HtmlImporter API
   - Implement missing HTML import features

3. **Import SAMPLE docx-js tests** (~50 core tests)
   - Choose most important: Paragraph, Run, Table basics
   - Convert TypeScript → Ruby
   - Validate core functionality

**Realistic Deliverable**: 210 tests imported, 150+ passing (71% pass rate)

### What Requires Long-Term Commitment:

1. **Full docx-js import** (181 files, 1,500+ tests)
   - Requires 20+ days of focused work
   - Needs systematic TS→Ruby conversion
   - Requires many Uniword features to be implemented

2. **95% pass rate across all tests**
   - Requires implementing missing features
   - Needs extensive API compatibility layer
   - Demands comprehensive testing infrastructure

---

## RECOMMENDATION

### For Immediate Proof of Concept:

**DO**: Import docx gem + html2doc + core docx-js samples
**Target**: 200-250 tests, 70%+ pass rate
**Time**: 1-2 days
**Outcome**: Demonstrates Uniword can handle real-world test cases from multiple libraries

### For Full Library Supersession:

**REQUIRES**: Multi-week dedicated effort
**Target**: 2,000+ tests, 95%+ pass rate
**Time**: 20-26 full working days
**Outcome**: Comprehensive proof that Uniword supersedes all three libraries

---

## PROPOSED IMMEDIATE ACTION PLAN

Let's start with **achievable goals** and build momentum:

### Step 1: Import docx gem tests (TODAY)
- Copy 2 spec files
- Adapt ~110 tests to Uniword API
- Fix compatibility issues
- **Target**: 80+ tests passing

### Step 2: Import html2doc tests (TODAY/TOMORROW)
- Copy 1 spec file
- Adapt ~50 tests to Uniword HtmlImporter
- Implement basic HTML import
- **Target**: 30+ tests passing

### Step 3: Import core docx-js tests (TOMORROW)
- Select 5-10 most important spec files
- Convert ~50 tests from TypeScript
- Focus on Paragraph, Run, Table basics
- **Target**: 30+ tests passing

### Deliverable After Steps 1-3:
- **Total Tests**: 210 (51 existing + 160 new)
- **Passing**: 140+ (67% pass rate)
- **Proof**: Uniword handles tests from 3 different libraries
- **Foundation**: Framework in place for continued import

---

## CONCLUSION

**Current Reality**:
- 186 test files discovered
- ~2,000 individual tests estimated
- Full import requires 20+ days of work

**Achievable Short-Term Goal**:
- Import ~200 tests in 1-2 days
- Demonstrate multi-library compatibility
- Achieve 65-70% pass rate

**Long-Term Vision**:
- Systematic import of all 2,000+ tests
- 95%+ pass rate
- Comprehensive supersession proof

**Recommendation**: Start with achievable goals (200 tests, 70% pass rate) and assess whether to continue with full import based on results and priorities.

---

## DECISION POINT

**Option A (Pragmatic)**: Import 200 tests from Ruby libraries + core TypeScript samples → Prove basic supersession → Move forward with v1.1.0

**Option B (Comprehensive)**: Commit to full 2,000+ test import → 20-day effort → Absolute proof of supersession → Delay v1.1.0 release

**Recommendation**: Option A, with Option B as long-term goal.