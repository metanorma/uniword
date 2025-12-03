# Phase 5 Continuation Plan: Achieving 100% Round-Trip (274/274)

**Goal**: Fix remaining 8 glossary test failures to achieve 274/274 tests (100%)
**Current**: 266/274 (97.1%)
**Target**: 274/274 (100%)
**Estimated Time**: 4-6 hours (compressed timeline)

## Current Status

### Passing Tests ✅
- StyleSets: 168/168 (100%)
- Themes: 174/174 (100%)  
- Document Elements Content Types: 8/8 (100%)
- **Total Passing**: 266/274 (97.1%)

### Failing Tests ❌
1. Bibliographies.dotx - 12 differences
2. Cover Pages.dotx - 24 differences
3. Equations.dotx - 1 difference (cosmetic: `mc:Ignorable` vs `Ignorable`)
4. Footers.dotx - 191 differences
5. Headers.dotx - 227 differences
6. Table of Contents.dotx - 18 differences
7. Tables.dotx - 125 differences
8. Watermarks.dotx - 150 differences

## Root Cause Analysis

### Issue 1: Empty RunProperties Elements (PRIMARY)
**Symptom**: `<rPr>` elements serialize as empty instead of with child elements
**Location**: Inside Math elements and regular paragraphs
**Impact**: ~80% of failures
**Root Cause**: MathRunProperties or RunProperties not serializing FontFamily elements

### Issue 2: VML Graphics Content (SECONDARY)
**Symptom**: VML Group/Shape content missing from Fallback elements
**Location**: AlternateContent → Fallback → Pict → VML
**Impact**: ~15% of failures (Watermarks especially)
**Root Cause**: Pict class may be using wildcard for VML content

### Issue 3: Namespace

 Prefix (COSMETIC)
**Symptom**: `Ignorable` vs `mc:Ignorable` attribute
**Location**: GlossaryDocument root element
**Impact**: 1 failure (Equations.dotx only remaining issue)
**Root Cause**: Namespace prefix not being preserved

## Implementation Plan

### Session A: Fix RunProperties Serialization (1.5-2 hours)
**Priority**: CRITICAL (fixes ~80% of failures)

**Tasks**:
1. Investigate MathRunProperties serialization (30 min)
   - Check why `<rPr>` empty in Math contexts
   - Verify FontFamily (rFonts) element mapping
   
2. Fix MathRunProperties class (45 min)
   - Ensure proper FontFamily mapping
   - Test with Equations.dotx
   
3. Fix WordprocessingML RunProperties in Math (30 min)
   - Verify cross-namespace RunProperties work
   - Test integration

**Expected Outcome**: 270-272/274 tests passing

### Session B: Implement VML Content (2-3 hours)
**Priority**: HIGH (fixes remaining failures)

**Tasks**:
1. Analyze VML structure (30 min)
   - Extract VML from Watermarks.dotx
   - Identify Group/Shape patterns
   
2. Implement VML classes (90 min)
   - Create vml/group.rb
   - Create vml/shape.rb  
   - Create vml/textbox.rb (if needed)
   - Integrate with Pict class
   
3. Test VML round-trip (30 min)
   - Run Watermarks test
   - Verify other VML-heavy files

**Expected Outcome**: 273-274/274 tests passing

### Session C: Final Cleanup (30-60 min)
**Priority**: MEDIUM (cosmetic fixes)

**Tasks**:
1. Fix namespace prefix preservation (20 min)
   - Investigate lutaml-model prefix handling
   - May be lutaml-model limitation
   
2. Final test run (10 min)
   - Verify 274/274
   - Check for any edge cases

**Expected Outcome**: 274/274 tests passing ✅

## Compressed Timeline

**Total Estimated**: 4-6 hours
**Recommended Approach**: Sequential sessions (A → B → C)

| Session | Duration | Target | Cumulative |
|---------|----------|--------|------------|
| A: RunProperties | 1.5-2h | +4-6 tests | 270-272/274 |
| B: VML Content | 2-3h | +2-4 tests | 273-274/274 |
| C: Cleanup | 0.5-1h | +0-1 tests | 274/274 ✅ |

## Success Criteria

- [ ] All 274 tests passing
- [ ] Zero baseline regressions
- [ ] 100% Pattern 0 compliance
- [ ] 100% model-driven (no wildcards)
- [ ] Comprehensive documentation

## Risk Mitigation

### Risk 1: RunProperties Fix Complex
**Mitigation**: Focus on FontFamily first (most common issue)
**Fallback**: Implement subset of RunProperties if time critical

### Risk 2: VML Implementation Large
**Mitigation**: Implement minimal VML (Group, Shape only)
**Fallback**: Mark VML as Phase 6 if time runs out

### Risk 3: Namespace Prefix Unfixable
**Mitigation**: Accept as lutaml-model limitation (semantically equivalent)
**Impact**: 273/274 instead of 274/274 (still 99.6%)

## Dependencies

- None (all infrastructure complete from Session 3)
- lutaml-model ~> 0.7 (already installed)
- All Math classes implemented ✅

## Architecture Principles

Following established patterns:
1. ✅ Attributes BEFORE xml mappings (Pattern 0)
2. ✅ Model-driven (no wildcards)
3. ✅ MECE (clear separation of concerns)
4. ✅ One responsibility per class
5. ✅ Open/closed principle

## Next Steps

**Immediate**: Start Session A (Fix RunProperties)
**File**: Use PHASE5_SESSIONA_PROMPT.md for detailed instructions