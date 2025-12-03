# Phase 5 Session A: Fix RunProperties Serialization - START HERE

**Goal**: Fix RunProperties serialization to eliminate empty `<rPr>` elements
**Duration**: 1.5-2 hours (estimated)
**Status**: Ready to begin
**Expected Outcome**: 270-272/274 tests (from 266/274)

## 🎯 Session A Objective

**PRIMARY GOAL**: Fix RunProperties serialization in Math and WordprocessingML contexts so that FontFamily (`<rFonts>`) and other child elements serialize properly instead of producing empty `<rPr>` tags.

## 📊 Starting Point

### Current Test Results
- **Total**: 266/274 (97.1%)
- **Failing**: 8 glossary tests
- **Primary Issue**: Empty `<rPr>` elements (~80% of failures)

### Example Failure Pattern
```xml
<!-- Expected -->
<r>
  <rPr>
    <rFonts ascii="Cambria Math" hAnsi="Cambria Math"/>
  </rPr>
  <t>x</t>
</r>

<!-- Actual (WRONG) -->
<r>
  <rPr/>  <!-- EMPTY! -->
  <t>x</t>
</r>
```

## 📋 Investigation Strategy

### Step 1: Analyze Failure Pattern (30 min)

Run one of the simpler failing tests to see exact differences:

```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Bibliographies.dotx" \
  --format documentation
```

Look for:
1. How many `<rPr>` elements are empty?
2. Are they in Math contexts (`<m:r>`) or regular contexts (`<w:r>`)?
3. What child elements are missing (rFonts, sz, color)?

### Step 2: Check MathRunProperties Class Structure (15 min)

The MathRunProperties class is at `lib/uniword/math/math_run_properties.rb`.

Current structure (from Session 3 analysis):
```ruby
class MathRunProperties < Lutaml::Model::Serializable
  attribute :lit, :string
  attribute :nor, :string
  attribute :scr, :string
  attribute :sty, :string
  attribute :brk, MathBreak
  attribute :aln, :string

  xml do
    element 'rPr'
    namespace Uniword::Ooxml::Namespaces::MathML
    mixed_content

    map_attribute 'val', to: :lit    # WRONG! Multiple val attributes
    map_attribute 'val', to: :nor
    map_attribute 'val', to: :scr
    map_attribute 'val', to: :sty
    map_element 'brk', to: :brk, render_nil: false
    map_attribute 'val', to: :aln
  end
end
```

**Issues to Check**:
- Missing FontFamily mapping?
- Multiple `val` attributes mapped (WRONG!)
- Should it contain WordprocessingML RunProperties?

### Step 3: Check Math context RunProperties (15 min)

In Math elements, `<m:r>` can contain `<w:rPr>` (WordprocessingML namespace).

Check if MathRun properly maps this:
```ruby
# lib/uniword/math/math_run.rb
class MathRun < Lutaml::Model::Serializable
  attribute :properties, MathRunProperties  # Math properties
  attribute :text, :string

  # Missing: attribute :run_properties, Uniword::Ooxml::WordProcessingML::RunProperties
end
```

## 🔧 Implementation Tasks

### Task 1: Fix MathRun to Support WordprocessingML RunProperties (45 min)

**File**: `lib/uniword/math/math_run.rb`

**Current**:
```ruby
class MathRun < Lutaml::Model::Serializable
  attribute :properties, MathRunProperties
  attribute :text, :string

  xml do
    element 'r'
    namespace Uniword::Ooxml::Namespaces::MathML
    mixed_content

    map_element 'rPr', to: :properties, render_nil: false
    map_element 't', to: :text, render_nil: false
  end
end
```

**Expected Fix**:
```ruby
class MathRun < Lutaml::Model::Serializable
  # Pattern 0: Attributes BEFORE xml
  attribute :math_properties, MathRunProperties
  attribute :run_properties, Uniword::Ooxml::WordProcessingML::RunProperties
  attribute :text, :string

  xml do
    element 'r'
    namespace Uniword::Ooxml::Namespaces::MathML
    mixed_content

    map_element 'rPr', to: :math_properties,
                namespace: Uniword::Ooxml::Namespaces::MathML,
                render_nil: false
    map_element 'rPr', to: :run_properties,
                namespace: Uniword::Ooxml::Namespaces::WordProcessingML,
                render_nil: false
    map_element 't', to: :text, render_nil: false
  end
end
```

**Key Points**:
- MathRun can have BOTH `<m:rPr>` (Math properties) AND `<w:rPr>` (Word properties)
- Need distinct attribute names (`math_properties` vs `run_properties`)
- Need distinct namespace mappings

### Task 2: Fix MathRunProperties Attribute Mappings (30 min)

**File**: `lib/uniword/math/math_run_properties.rb`

The current multiple `val` attribute mappings are WRONG. Each Math property should be its own element.

**Analysis Needed**:
Check original XML to see actual structure:
```bash
unzip -q -o "references/word-resources/document-elements/Equations.dotx" -d /tmp/eq_check
grep -A 5 "<m:rPr>" /tmp/eq_check/word/glossary/document.xml | head -20
```

**Expected Structure** (based on OOXML spec):
```ruby
class MathRunProperties < Lutaml::Model::Serializable
  # Pattern 0: Attributes BEFORE xml
  attribute :lit, :string          # Literal (text mode)
  attribute :nor, :string          # Normal (no special formatting)
  attribute :scr, :string          # Script level
  attribute :sty, :string          # Style
  attribute :brk, MathBreak        # Math break
  attribute :aln, :string          # Alignment

  xml do
    element 'rPr'
    namespace Uniword::Ooxml::Namespaces::MathML
    mixed_content

    map_element 'lit', to: :lit, render_nil: false
    map_element 'nor', to: :nor, render_nil: false
    map_element 'scr', to: :scr, render_nil: false
    map_element 'sty', to: :sty, render_nil: false
    map_element 'brk', to: :brk, render_nil: false
    map_element 'aln', to: :aln, render_nil: false
  end
end
```

### Task 3: Test and Verify (30 min)

After fixes, run tests:

```bash
# Test simplest case first
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Equations.dotx"

# Test other Math-heavy files
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Bibliographies.dotx"

# Run all tests to check for regressions
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
  spec/uniword/theme_roundtrip_spec.rb \
  --format documentation
```

**Expected Results**:
- Equations.dotx: 1 → 0 differences (should pass!)
- Bibliographies.dotx: 12 → 0-2 differences
- Table of Contents.dotx: 18 → 0-2 differences
- **Total**: 270-272/274 (98-99%)

## ✅ Success Criteria

### Must Achieve
- [ ] No empty `<rPr>` elements in output
- [ ] FontFamily (`<rFonts>`) serializes properly
- [ ] Math context RunProperties work
- [ ] Zero baseline regressions (266 minimum maintained)
- [ ] 270-272/274 tests passing

### Architecture Quality
- [ ] Pattern 0 compliance (attributes before xml)
- [ ] Model-driven (no wildcards)
- [ ] Proper namespace handling
- [ ] Clear separation (Math vs WordprocessingML properties)

## 🎯 Execution Checklist

### Pre-Session
- [x] Session 3 complete ✅
- [x] Baseline established (266/274) ✅
- [x] Plan reviewed ✅
- [x] Ready to start ✅

### During Session
- [ ] Run failure analysis
- [ ] Fix MathRun class
- [ ] Fix MathRunProperties class
- [ ] Test incrementally
- [ ] Verify zero regressions
- [ ] Document findings

### Post-Session
- [ ] Create PHASE5_SESSIONA_COMPLETE.md
- [ ] Update PHASE5_IMPLEMENTATION_STATUS.md
- [ ] Prepare Session B prompt (if needed)
- [ ] Update memory bank

## 📝 Important Reminders

### Critical Patterns

1. **Pattern 0**: Attributes MUST come before xml mappings
2. **Namespace Clarity**: Use explicit namespace for each element
3. **Dual Properties**: MathRun can have both Math AND Word properties
4. **Test After Each**: Maintain baseline throughout

### Common Pitfalls

- ❌ Mapping multiple attributes to same element name
- ❌ Forgetting namespace on cross-namespace elements
- ❌ Using `attribute :properties` when need distinct names
- ❌ Not testing after each fix

## 🚀 Quick Start Commands

```bash
cd /Users/mulgogi/src/mn/uniword

# Analyze failure
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Bibliographies.dotx" \
  --format documentation 2>&1 | less

# Check MathRun structure
cat lib/uniword/math/math_run.rb

# Check MathRunProperties structure  
cat lib/uniword/math/math_run_properties.rb

# After fixes, test
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Equations.dotx"
```

## 🎉 Expected Outcome

**Before Session A**: 266/274 (97.1%)
**After MathRun Fix**: 268-270/274 (98%)
**After MathRunProperties Fix**: 270-272/274 (98-99%)

**Ready for Session B**: VML Content Implementation

---

## 🚀 Ready to Begin!

**Time Budget**: 1.5-2 hours
**Complexity**: Medium (clear patterns established)
**Confidence**: HIGH (Math infrastructure complete)

**Start with**:
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb \
  --example "Bibliographies.dotx" \
  --format documentation
```

Analyze the empty `<rPr>` elements, identify the pattern, and implement the fixes!

**Good luck! Let's get to 270-272 tests!** 💪

---

**Reference Documents**:
- `PHASE5_CONTINUATION_PLAN.md` - Overall plan
- `PHASE5_IMPLEMENTATION_STATUS.md` - Current status
- `PHASE5_SESSION3_COMPLETE.md` - Session 3 summary
- `.kilocode/rules/memory-bank/context.md` - Project context

**Next Step**: Run test analysis and start implementing!