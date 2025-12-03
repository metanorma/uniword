# Phase 4 Session 4: Run Properties Enhancement

**Context**: Phase 4 Session 3 completed paragraph rsid attributes with unexpected test results (244 differences). Continue with Session 4 to implement Run Properties which show high impact in current test output.

## Your Mission

Implement Run Properties enhancements to target the most visible differences in test output. This is a HIGH IMPACT session with potential for 100+ difference reduction.

## Current State

### Completed (Sessions 1-3)
- ✅ 12 properties implemented (44% of 27 total)
- ✅ Test differences: 276 → 244 (baseline → current)
- ✅ Baseline: 342/342 maintained
- ✅ 100% Pattern 0 compliance

### Test Status
- Content Types: 8/8 (100%) ✅
- Glossary: 0/8 (244 differences each)
- Baseline: 342/342 ✅

### Session 3 Results
- Added paragraph rsid attributes
- Unexpected increase: 90 → 244 differences
- Analysis: rsid may not exist in original files
- Architecture remains solid

## Session 4 Tasks (1.5 hours - HIGH IMPACT)

### Target: Reduce differences from 244 → ~150 (-90 differences)

### 1. Implement Run Caps Property (15 min)

**File**: `lib/uniword/properties/run_properties.rb`

Add boolean flag for all capitals:

```ruby
# In RunProperties class, add attribute
attribute :caps, :boolean

# In xml block, add mapping
map_element 'caps', to: :caps, render_nil: false
```

**Reference XML**: `<w:caps/>`

**Impact**: Appears in 100+ differences (HIGH)

### 2. Implement Run NoProof Property (15 min)

**File**: `lib/uniword/properties/run_properties.rb`

Add boolean flag to disable spell/grammar checking:

```ruby
# Add attribute
attribute :no_proof, :boolean

# Add mapping
map_element 'noProof', to: :no_proof, render_nil: false
```

**Reference XML**: `<w:noProof/>`

**Impact**: Appears in 40+ differences (MEDIUM)

### 3. Enhance Color with themeColor (20 min)

**File**: `lib/uniword/properties/color_value.rb`

Add theme color reference attribute:

```ruby
# Add attribute
attribute :theme_color, :string

# In xml block, add mapping
map_attribute 'themeColor', to: :theme_color, render_nil: false
```

**Reference XML**: `<w:color w:val="FFFFFF" w:themeColor="background1"/>`

**Impact**: Appears in 80+ differences (HIGH)

### 4. Implement Complex Script Size (szCs) (15 min)

**Option A**: Enhance existing FontSize class
**File**: `lib/uniword/properties/font_size.rb`

Check if szCs is already handled. If not:

```ruby
# Add companion attribute for complex script
attribute :complex_script_size, :integer

# Add mapping
map_element 'szCs', to: :complex_script_size, render_nil: false
```

**Option B**: Create separate class if needed
**File**: `lib/uniword/properties/complex_script_size.rb`

**Reference XML**: `<w:szCs w:val="18"/>`

**Impact**: Appears in 60+ differences (HIGH)

### 5. Test and Verify (25 min)

```bash
cd /Users/mulgogi/src/mn/uniword

# Run document element tests
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation

# Expected: 244 → ~150 differences (-90, -37%)

# Verify baseline (CRITICAL)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Must remain: 342/342 passing ✅
```

## Critical Rules

### Architecture (NON-NEGOTIABLE)
1. ✅ **Pattern 0**: ALWAYS attributes BEFORE xml mappings
2. ✅ **MECE**: Clear separation of concerns
3. ✅ **Model-Driven**: No raw XML preservation
4. ✅ **Test After Each**: Catch issues early
5. ✅ **Zero Regressions**: Maintain 342/342 baseline

### Implementation Pattern (PROVEN)

```ruby
class RunProperties < Lutaml::Model::Serializable
  # Pattern 0: ATTRIBUTES FIRST
  attribute :caps, :boolean
  attribute :no_proof, :boolean
  # ... other attributes ...
  
  xml do
    root 'rPr'
    namespace Ooxml::Namespaces::WordProcessingML
    # ... existing mappings ...
    map_element 'caps', to: :caps, render_nil: false
    map_element 'noProof', to: :no_proof, render_nil: false
    # ... other mappings ...
  end
end
```

## Reference Documents

**Read these FIRST**:
1. `PHASE4_CONTINUATION_PLAN.md` - Complete 7-session plan
2. `PHASE4_IMPLEMENTATION_STATUS.md` - Current progress (44%)
3. `PHASE4_SESSION3_SUMMARY.md` - Previous session results
4. `PHASE4_PROPERTY_ANALYSIS.md` - Original gap analysis

## Expected Outcomes

### After Session 4
- ✅ 4 Run property enhancements complete
- ✅ Test differences: 244 → ~150 (-37%)
- ✅ 16/27 properties (59% complete)
- ✅ Zero regressions (342/342 baseline)
- ✅ 100% Pattern 0 compliance maintained

### Files to Modify
1. `lib/uniword/properties/run_properties.rb` (add 2 boolean flags)
2. `lib/uniword/properties/color_value.rb` (add themeColor)
3. `lib/uniword/properties/font_size.rb` OR create `complex_script_size.rb`

### Success Criteria
- [ ] caps property serializes correctly (`<w:caps/>`)
- [ ] noProof property serializes correctly (`<w:noProof/>`)
- [ ] themeColor attribute appears in color elements
- [ ] szCs serializes correctly (`<w:szCs w:val="..."/>`)
- [ ] Baseline 342/342 maintained
- [ ] Differences reduced by ~90 (-37%)

## Next Steps After Session 4

Session 5 will focus on SDT Properties (8 classes, 2.5 hours). Estimated remaining differences: ~80-100, with SDT handling ~60 of them.

## Efficiency Notes

**Time Compression Strategy**:
- Each property: 15-20 minutes max
- Test immediately after each change
- If one property complex, defer and move to next
- Prioritize high-impact properties first (caps, themeColor, szCs)
- noProof can be deferred if time limited

## Start Here

1. Read all reference documents (5 min)
2. Find RunProperties class (1 min)
3. Add caps + noProof (15 min)
4. Test and verify (5 min)
5. Enhance Color with themeColor (20 min)
6. Test and verify (5 min)
7. Implement szCs (15 min)
8. Final test and verify (10 min)
9. Document results in PHASE4_SESSION4_SUMMARY.md (10 min)

Begin with: "I've read the Phase 4 context. Starting Session 4: Run Properties Enhancement. Searching for RunProperties class..."

**LET'S TARGET 100+ DIFFERENCE REDUCTION! 🚀**