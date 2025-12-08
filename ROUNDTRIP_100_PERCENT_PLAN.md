# Uniword 100% Round-Trip Achievement Plan

**Goal**: Achieve 274/274 tests passing (100% round-trip fidelity)
**Current**: 266/274 (97.1%)
**Gap**: 8 glossary tests failing
**Estimated Time**: 4-6 hours (compressed)
**Created**: December 8, 2024

---

## Executive Summary

Uniword has achieved **97.1% round-trip fidelity** (266/274 tests):
- ✅ **StyleSets**: 100% (168/168 tests, 24 files)
- ✅ **Themes**: 100% (174/174 tests, 29 files)
- 🟡 **Document Elements**: 50% (8/16 tests)
  - Content Types: 100% (8/8)
  - Glossary XML: 0% (0/8)

**Target**: Fix 8 remaining glossary test failures to achieve 100%

---

## Current Test Status

### Passing (266/274) ✅

| Category | Files | Tests | Status |
|----------|-------|-------|--------|
| StyleSets (style-sets) | 12 | 84 | ✅ 100% |
| StyleSets (quick-styles) | 12 | 84 | ✅ 100% |
| Themes | 29 | 174 | ✅ 100% |
| Document Elements (Content Types) | 8 | 8 | ✅ 100% |
| **TOTAL PASSING** | **61** | **266** | **97.1%** |

### Failing (8/274) ❌

| File | Differences | Primary Issue | Impact |
|------|------------|---------------|--------|
| Bibliographies.dotx | 12 | Empty `<rPr>` elements | Low |
| Cover Pages.dotx | 24 | Empty `<rPr>` elements | Medium |
| Equations.dotx | 1 | Namespace prefix only | Minimal |
| Footers.dotx | 191 | Empty `<rPr>` + VML | High |
| Headers.dotx | 227 | Empty `<rPr>` + VML | High |
| Table of Contents.dotx | 18 | Empty `<rPr>` elements | Low |
| Tables.dotx | 125 | Empty `<rPr>` elements | Medium |
| Watermarks.dotx | 150 | VML content missing | High |

**Total Differences**: ~748 (but many are duplicates/cascading)

---

## Root Cause Analysis

### Issue 1: Empty RunProperties Elements 🔴 CRITICAL

**Problem**: `<rPr>` elements serialize as empty instead of with child elements

**Location**:
- Math elements (MathRun → word_properties)
- Regular paragraphs (Run → properties)

**Impact**: ~80% of failures (~600 differences)

**Root Cause**:
```xml
<!-- WRONG (current) -->
<w:r>
  <w:rPr/>  <!-- Empty! -->
  <w:t>text</w:t>
</w:r>

<!-- CORRECT (expected) -->
<w:r>
  <w:rPr>
    <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
    <w:sz w:val="22"/>
  </w:rPr>
  <w:t>text</w:t>
</w:r>
```

**Hypothesis**: RunProperties child elements not serializing or not being mapped
- FontFamily (`<w:rFonts>`) missing
- FontSize (`<w:sz>`) missing
- Other properties potentially affected

### Issue 2: VML Content Missing 🟡 HIGH

**Problem**: VML Group/Shape content not preserved in AlternateContent → Fallback

**Location**:
- Watermarks.dotx (150 differences)
- Footers/Headers with graphics

**Impact**: ~15% of failures (~150 differences)

**Root Cause**:
```xml
<!-- WRONG (current) -->
<mc:Fallback>
  <w:pict/>  <!-- Empty! -->
</mc:Fallback>

<!-- CORRECT (expected) -->
<mc:Fallback>
  <w:pict>
    <v:group>
      <v:shape>...</v:shape>
    </v:group>
  </w:pict>
</mc:Fallback>
```

**Hypothesis**: Pict class using wildcard (:string content) instead of proper VML classes

### Issue 3: Namespace Prefix 🟢 COSMETIC

**Problem**: `Ignorable` vs `mc:Ignorable` attribute on GlossaryDocument

**Location**: Equations.dotx only

**Impact**: 1 difference (cosmetic - semantically equivalent)

**Root Cause**: Namespace prefix not being preserved by lutaml-model

**Priority**: LOW (may be lutaml-model limitation)

---

## Implementation Strategy

### Phase A: Fix RunProperties Serialization (CRITICAL)

**Duration**: 1.5-2 hours
**Priority**: 🔴 HIGHEST
**Target**: 270-272/274 tests (+4-6)

#### Tasks

**A1: Investigate RunProperties (30 min)**

1. Check why `<rPr>` serializes empty
2. Verify FontFamily (rFonts) element mapping
3. Check if attributes vs elements issue
4. Review MathRunProperties vs RunProperties

**Files to Check**:
- `lib/uniword/wordprocessingml/run_properties.rb`
- `lib/uniword/math/math_run_properties.rb`
- `lib/uniword/properties/run_fonts.rb`
- `lib/uniword/properties/font_size.rb`

**A2: Fix RunProperties Class (45 min)**

1. Ensure `fonts` attribute properly mapped
2. Add missing element mappings if needed
3. Verify render_nil settings
4. Test serialization

**Expected Fix**:
```ruby
# lib/uniword/wordprocessingml/run_properties.rb
class RunProperties < Lutaml::Model::Serializable
  attribute :fonts, Properties::RunFonts  # ✅ Already exists
  attribute :size, Properties::FontSize    # ✅ Already exists

  xml do
    element 'rPr'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content  # ✅ Already set

    # Ensure proper mapping
    map_element 'rFonts', to: :fonts, render_nil: false  # ✅ Check this
    map_element 'sz', to: :size, render_nil: false       # ✅ Check this
  end
end
```

**A3: Fix Math Integration (30 min)**

1. Verify MathRun → word_properties serialization
2. Check namespace handling in Math context
3. Test with Equations.dotx

**Verification**:
```bash
# Extract and compare rPr elements
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Equations.dotx"
```

**Success Criteria**:
- [ ] `<rPr>` elements have child elements
- [ ] FontFamily (`<rFonts>`) serializes
- [ ] FontSize (`<sz>`) serializes
- [ ] Equations.dotx passes (may be only namespace prefix issue left)
- [ ] +4-6 tests passing

### Phase B: Implement VML Content (HIGH)

**Duration**: 2-3 hours
**Priority**: 🟡 HIGH
**Target**: 273-274/274 tests (+2-4)

#### Tasks

**B1: Analyze VML Structure (30 min)**

1. Extract VML from Watermarks.dotx glossary
2. Identify Group/Shape/TextBox patterns
3. Document VML element hierarchy

**Command**:
```bash
# Extract glossary XML
unzip -p "references/word-resources/document-elements/Watermarks.dotx" \
  word/glossary/document.xml > /tmp/watermarks_glossary.xml

# Find VML content
grep -A 20 "<v:group" /tmp/watermarks_glossary.xml
```

**B2: Implement VML Classes (90 min)**

Create minimal VML support:

**1. vml/group.rb** (20 min):
```ruby
module Uniword
  module Vml
    class Group < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :coordsize, :string
      attribute :shapes, Shape, collection: true, default: -> { [] }

      xml do
        root 'group'
        namespace Uniword::Ooxml::Namespaces::VML

        map_attribute 'id', to: :id
        map_attribute 'style', to: :style
        map_attribute 'coordsize', to: :coordsize
        map_element 'shape', to: :shapes
      end
    end
  end
end
```

**2. vml/shape.rb** (30 min):
```ruby
module Uniword
  module Vml
    class Shape < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :type, :string
      attribute :style, :string
      attribute :fillcolor, :string
      attribute :stroked, :string
      # ... other VML shape attributes

      xml do
        root 'shape'
        namespace Uniword::Ooxml::Namespaces::VML

        map_attribute 'id', to: :id
        map_attribute 'type', to: :type
        map_attribute 'style', to: :style
        map_attribute 'fillcolor', to: :fillcolor
        map_attribute 'stroked', to: :stroked
      end
    end
  end
end
```

**3. Update Pict class** (40 min):
```ruby
# lib/uniword/wordprocessingml/pict.rb
class Pict < Lutaml::Model::Serializable
  # BEFORE (wildcard):
  # attribute :content, :string  # ❌ WRONG

  # AFTER (proper VML):
  attribute :groups, Uniword::Vml::Group, collection: true, default: -> { [] }  # ✅ CORRECT
  attribute :shapes, Uniword::Vml::Shape, collection: true, default: -> { [] }  # ✅ CORRECT

  xml do
    root 'pict'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content

    map_element 'group', to: :groups,
                namespace: Uniword::Ooxml::Namespaces::VML,
                render_nil: false
    map_element 'shape', to: :shapes,
                namespace: Uniword::Ooxml::Namespaces::VML,
                render_nil: false
  end
end
```

**B3: Test VML Round-Trip (30 min)**

1. Run Watermarks.dotx test
2. Verify Footers/Headers with VML
3. Check for regressions

**Success Criteria**:
- [ ] VML Group/Shape content preserved
- [ ] Watermarks.dotx passes
- [ ] Footers/Headers VML works
- [ ] +2-4 tests passing

### Phase C: Final Cleanup & Documentation (OPTIONAL)

**Duration**: 30-60 min
**Priority**: 🟢 LOW
**Target**: 274/274 tests (if namespace fix possible)

#### Tasks

**C1: Namespace Prefix Fix (20 min)**

Investigate if lutaml-model supports prefix preservation:

```ruby
# Try different approaches
xml do
  root 'glossaryDocument'
  namespace Uniword::Ooxml::Namespaces::WordProcessingML

  # Option 1: Explicit prefix
  map_attribute 'Ignorable', to: :ignorable,
                namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility,
                prefix: 'mc'  # Try this

  # Option 2: Accept as limitation (semantically equivalent)
end
```

**C2: Final Verification (10 min)**

```bash
# Run full test suite
bundle exec rspec spec/uniword/ --format documentation | grep -A 5 "failures"
```

**Success Criteria**:
- [ ] 274/274 tests passing OR
- [ ] 273/274 (if namespace prefix unfixable - still 99.6%)

---

## Compressed Timeline

| Phase | Duration | Tests | Cumulative | Priority |
|-------|----------|-------|------------|----------|
| **Current** | - | 266/274 | 97.1% | - |
| A: RunProperties | 1.5-2h | +4-6 | 270-272/274 (98.5-99.3%) | 🔴 CRITICAL |
| B: VML Content | 2-3h | +2-4 | 273-274/274 (99.6-100%) | 🟡 HIGH |
| C: Cleanup | 0.5-1h | +0-1 | 274/274 (100%) | 🟢 LOW |
| **TOTAL** | **4-6h** | **+8** | **274/274 (100%)** | |

---

## Architecture Principles

All work MUST follow established patterns:

1. ✅ **Pattern 0**: Attributes BEFORE xml mappings (critical!)
2. ✅ **Model-Driven**: No wildcards, proper classes for all content
3. ✅ **MECE**: Clear separation of concerns
4. ✅ **Single Responsibility**: One class, one purpose
5. ✅ **Open/Closed**: Extensible through proper inheritance

---

## Risk Mitigation

### Risk 1: RunProperties Fix More Complex Than Expected

**Likelihood**: Medium
**Impact**: High (blocks most progress)

**Mitigation**:
- Focus on FontFamily first (most common in failures)
- Implement subset if needed (fonts + size minimum)
- Document any workarounds

**Fallback**:
- Mark complex RunProperties as Phase 6
- Still achieve 270/274 (98.5%)

### Risk 2: VML Implementation Too Large

**Likelihood**: Low (minimal VML needed)
**Impact**: Medium

**Mitigation**:
- Implement only Group + Shape (core VML)
- Skip advanced VML features
- Use targeted approach (Watermarks first)

**Fallback**:
- Partial VML support
- Achieve 272/274 (99.3%)

### Risk 3: Namespace Prefix Unfixable

**Likelihood**: High (may be lutaml-model limitation)
**Impact**: Minimal (1 test, cosmetic only)

**Mitigation**:
- Accept as known limitation
- Document in release notes
- Semantically equivalent XML

**Outcome**: 273/274 (99.6%) - acceptable

---

## Success Criteria

### Must Have (274/274 Goal)
- [ ] All 8 glossary tests pass round-trip
- [ ] RunProperties serialize with child elements
- [ ] VML content preserved
- [ ] Zero baseline regressions (266 tests still pass)
- [ ] 100% Pattern 0 compliance
- [ ] 100% model-driven architecture

### Nice to Have
- [ ] Namespace prefix preserved (273/274 acceptable if not)
- [ ] Comprehensive VML support (minimal is acceptable)
- [ ] Documentation complete

### Must NOT Have
- ❌ Wildcards or `:string` content for structured data
- ❌ Hardcoded XML generation
- ❌ Breaking changes to existing API
- ❌ Test regressions

---

## Next Steps

### Immediate: Phase A (RunProperties Fix)

**File**: `ROUNDTRIP_PHASE_A_PROMPT.md`
**Duration**: 1.5-2 hours
**Goal**: Fix empty `<rPr>` elements

### After Phase A: Phase B (VML)

**File**: `ROUNDTRIP_PHASE_B_PROMPT.md`
**Duration**: 2-3 hours
**Goal**: Implement VML content preservation

### Final: Documentation

**Tasks**:
1. Update `UNIWORD_ROUNDTRIP_STATUS.md` with 100% status
2. Update `README.adoc` with achievement
3. Create release notes for v1.1.0
4. Move temporary docs to old-docs/

---

## Dependencies

### Required (Already Available) ✅
- lutaml-model ~> 0.7
- All Wordprocessingml infrastructure
- All Math classes
- All SDT properties (Phase 4 complete)

### Not Required
- No new gems
- No schema changes
- No breaking changes

---

## Deliverables

### Code
- [ ] RunProperties fix (lib/uniword/wordprocessingml/run_properties.rb)
- [ ] VML classes (lib/uniword/vml/group.rb, shape.rb)
- [ ] Pict update (lib/uniword/wordprocessingml/pict.rb)
- [ ] Autoload additions (lib/uniword/vml.rb)

### Tests
- [ ] 274/274 round-trip tests passing
- [ ] No baseline regressions
- [ ] RSpec output documented

### Documentation
- [ ] UNIWORD_ROUNDTRIP_STATUS.md updated
- [ ] Release notes created
- [ ] README.adoc updated
- [ ] Architecture docs updated

---

## Conclusion

**Achievable Goal**: 274/274 tests (100%) in 4-6 hours

**Minimal Goal**: 273/274 tests (99.6%) if namespace prefix unfixable

**Current Status**: 266/274 (97.1%) - excellent foundation

**Next Action**: Execute Phase A (RunProperties fix)

**Expected Impact**: +4-6 tests in first 2 hours, +2-4 in next 3 hours

🎯 **100% Round-Trip Fidelity is Within Reach!**