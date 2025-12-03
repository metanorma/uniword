# Phase 4 Session 3: Paragraph rsid Attributes Implementation

**Context**: Phase 4 Session 2 achieved 67% cumulative reduction in test differences (276 → 90). Continue with Session 3 to implement paragraph rsid attributes for further improvement.

## Your Mission

Implement paragraph rsid attributes to enable document revision tracking. Target: Reduce differences from 90 → ~70 per test.

## Current State

### Completed (Sessions 1-2)
- ✅ 11 properties implemented (41% of 27 total)
- ✅ Test differences: 276 → 90 (-67%)
- ✅ Baseline: 342/342 maintained
- ✅ 100% Pattern 0 compliance

### Test Status
- Content Types: 8/8 (100%) ✅
- Glossary: 0/8 (90 differences each)
- Baseline: 342/342 ✅

### Session 2 Achievements
- TableCellMargin + Margin classes
- TableLook conditional formatting
- GridCol width attribute fix
- TableProperties complete

## Session 3 Tasks (30 minutes)

### 1. Find Paragraph Class (5 min)
**Location**: `lib/uniword/wordprocessingml/paragraph.rb` or similar

Search for the Paragraph class that represents the `<w:p>` element.

### 2. Add rsid Attributes (10 min)
Add three revision tracking attributes to Paragraph class:

```ruby
# Pattern 0: ATTRIBUTES FIRST
attribute :rsid_r, :string       # Revision ID for paragraph creation
attribute :rsid_r_default, :string  # Default revision ID
attribute :rsid_p, :string       # Revision ID for properties
```

**Reference XML**:
```xml
<w:p w:rsidR="00B10ACF" w:rsidRDefault="00B10ACF" w:rsidP="00FE3863">
```

### 3. Add XML Mappings (10 min)
In the xml block, add attribute mappings:

```ruby
xml do
  # ... existing mappings ...
  map_attribute 'rsidR', to: :rsid_r, render_nil: false
  map_attribute 'rsidRDefault', to: :rsid_r_default, render_nil: false
  map_attribute 'rsidP', to: :rsid_p, render_nil: false
end
```

### 4. Run Tests and Verify (5 min)
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation

# Expected: 90 → ~70 differences (-20 to -25)
```

## Critical Rules

### Architecture (NON-NEGOTIABLE)
1. ✅ **Pattern 0**: ALWAYS attributes BEFORE xml mappings
2. ✅ **MECE**: Clear separation of concerns
3. ✅ **Simple Addition**: This is attribute-only, no new classes
4. ✅ **Test After**: Catch issues early
5. ✅ **Zero Regressions**: Maintain 342/342 baseline

### Implementation Pattern (PROVEN)
```ruby
class Paragraph < Lutaml::Model::Serializable
  # Pattern 0: ATTRIBUTES FIRST
  attribute :rsid_r, :string
  attribute :rsid_r_default, :string
  attribute :rsid_p, :string
  
  xml do
    root 'p'
    namespace Ooxml::Namespaces::WordProcessingML
    # ... existing mappings ...
    map_attribute 'rsidR', to: :rsid_r, render_nil: false
    map_attribute 'rsidRDefault', to: :rsid_r_default, render_nil: false
    map_attribute 'rsidP', to: :rsid_p, render_nil: false
  end
end
```

## Reference Documents

**Read these FIRST**:
1. `PHASE4_CONTINUATION_PLAN.md` - Complete 7-session plan
2. `PHASE4_IMPLEMENTATION_STATUS.md` - Current progress tracker
3. `PHASE4_SESSION2_SUMMARY.md` - Previous session results
4. `PHASE4_PROPERTY_ANALYSIS.md` - Original gap analysis

## Expected Outcomes

### After Session 3
- ✅ 3 rsid attributes added to Paragraph class
- ✅ Test differences: 90 → ~70 (-22%)
- ✅ Estimated 2-3 tests may start passing
- ✅ Zero regressions (342/342 baseline)
- ✅ 100% Pattern 0 compliance maintained

### Session 3 Success Criteria
- [ ] All 3 rsid attributes serialize correctly
- [ ] `<w:p rsidR="..." rsidRDefault="..." rsidP="...">` appears in output
- [ ] Baseline 342/342 maintained
- [ ] Differences reduced by ~20

## Next Steps After Session 3

Session 4 will focus on Run Properties (4 enhancements: caps, noProof, themeColor, szCs). Estimated 1.5 hours.

## Start Here

1. Read all reference documents
2. Find Paragraph class
3. Add 3 rsid attributes (Pattern 0!)
4. Add 3 XML attribute mappings
5. Run tests
6. Document results in PHASE4_SESSION3_SUMMARY.md

Begin with: "I've read the Phase 4 context. Starting Session 3: Paragraph rsid Attributes. Searching for Paragraph class..."

**LET'S ACHIEVE 75% CUMULATIVE REDUCTION! 🚀**