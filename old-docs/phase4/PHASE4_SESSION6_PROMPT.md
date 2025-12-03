# Phase 4 Session 6: Final Property Gaps and 100% Round-Trip

**Context**: Phase 4 Session 5 achieved exceptional results (121→13 differences, -89%). With only 13 differences remaining per test, Session 6 targets **100% round-trip fidelity** by implementing final missing properties.

## Your Mission

Complete the remaining property gaps to achieve 16/16 tests passing with zero differences. This is the **FINAL SESSION** before documentation and completion.

## Current State

### Completed (Sessions 1-5)
- ✅ 22 properties implemented (81% of 27 total)
- ✅ Test differences: 276 → 13 (-95% total reduction!)
- ✅ Baseline: 342/342 maintained
- ✅ 100% Pattern 0 compliance

### Test Status
- Content Types: 8/8 (100%) ✅
- Glossary: 0/8 (13 differences each)
- Baseline: 342/342 ✅

### Session 5 Results (EXCEPTIONAL!)
- Implemented 8 SDT properties
- Created complete SDT infrastructure (12 files)
- Achieved 89% reduction: 121 → 13 differences
- Time: 50 minutes (67% faster than estimated)

## Session 6 Tasks (1-1.5 hours - TARGET: 100%)

### Target: Reduce differences from 13 → 0 (-100%)

### 1. Analyze Remaining 13 Differences (10 min)

Run detailed diff analysis to identify exact missing properties:

```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb[1:1:1:1] --format documentation > analysis/session6_diff_analysis.txt 2>&1
```

Review the diff output and categorize remaining issues:
- Missing SDT properties
- Element ordering issues
- Other property gaps

### 2. Implement Missing SDT Properties (30-45 min)

Based on diff analysis, likely needed:

#### A. SDT Temporary Flag (10 min)
**File**: `lib/uniword/sdt/temporary.rb`

```ruby
module Uniword
  module Sdt
    # Temporary flag for Structured Document Tag (empty element)
    # Reference XML: <w:temporary/>
    class Temporary < Lutaml::Model::Serializable
      xml do
        element 'temporary'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
```

**Integration**: Add to `StructuredDocumentTagProperties`:
```ruby
attribute :temporary, Sdt::Temporary
map_element 'temporary', to: :temporary, render_nil: false
```

#### B. SDT DocPartObj Element (20 min)
**File**: `lib/uniword/sdt/doc_part_obj.rb`

```ruby
module Uniword
  module Sdt
    class DocPartGallery < Lutaml::Model::Serializable
      attribute :value, :string
      
      xml do
        element 'docPartGallery'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end
    
    class DocPartCategory < Lutaml::Model::Serializable
      attribute :value, :string
      
      xml do
        element 'docPartCategory'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end
    
    class DocPartObj < Lutaml::Model::Serializable
      attribute :doc_part_gallery, DocPartGallery
      attribute :doc_part_category, DocPartCategory
      
      xml do
        element 'docPartObj'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        
        map_element 'docPartGallery', to: :doc_part_gallery, render_nil: false
        map_element 'docPartCategory', to: :doc_part_category, render_nil: false
      end
    end
  end
end
```

**Reference XML**:
```xml
<w:docPartObj>
  <w:docPartGallery w:val="placeholder"/>
  <w:docPartCategory w:val="General"/>
</w:docPartObj>
```

**Integration**: Add to `StructuredDocumentTagProperties`:
```ruby
require_relative 'sdt/doc_part_obj'

attribute :doc_part_obj, Sdt::DocPartObj
map_element 'docPartObj', to: :doc_part_obj, render_nil: false
```

#### C. Any Other Discovered Properties (15 min)

Review diff output for additional missing properties and implement as needed.

### 3. Address Element Ordering Issues (15 min)

If diff shows element position differences:

1. Check if `ordered: true` is needed in xml mappings
2. Verify element order in StructuredDocumentTagProperties
3. Ensure proper serialization order

### 4. Test and Verify (20 min)

```bash
cd /Users/mulgogi/src/mn/uniword

# Run document element tests
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation

# Expected: 16/16 passing ✅ (or very close)

# Verify baseline (CRITICAL)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Must remain: 342/342 passing ✅
```

### 5. Final Analysis (10 min)

If any differences remain:
- Document why they exist
- Determine if they're acceptable (e.g., non-semantic differences)
- Plan Session 7 if needed

## Critical Rules

### Architecture (NON-NEGOTIABLE)
1. ✅ **Pattern 0**: ALWAYS attributes BEFORE xml mappings
2. ✅ **MECE**: Clear separation of concerns
3. ✅ **Model-Driven**: No raw XML preservation
4. ✅ **Namespace**: Use `Uniword::Ooxml::Namespaces::WordProcessingML`
5. ✅ **Test After Each**: Catch issues early
6. ✅ **Zero Regressions**: Maintain 342/342 baseline

### Implementation Pattern (PROVEN)

```ruby
# Pattern for simple value element
class PropertyName < Lutaml::Model::Serializable
  attribute :value, :type  # Pattern 0: ATTRIBUTE FIRST
  
  xml do
    element 'elementName'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# Pattern for empty element (flag)
class FlagProperty < Lutaml::Model::Serializable
  xml do
    element 'elementName'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
  end
end

# Pattern for complex element with children
class ComplexProperty < Lutaml::Model::Serializable
  attribute :child, ChildClass  # Pattern 0: ATTRIBUTE FIRST
  
  xml do
    element 'elementName'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content  # If has nested elements
    map_element 'childElement', to: :child
  end
end
```

## Reference Documents

**Read these FIRST**:
1. [`PHASE4_SESSION5_SUMMARY.md`](PHASE4_SESSION5_SUMMARY.md) - Previous session (89% reduction!)
2. [`PHASE4_IMPLEMENTATION_STATUS.md`](PHASE4_IMPLEMENTATION_STATUS.md) - Current progress (81%)
3. [`PHASE4_CONTINUATION_PLAN.md`](PHASE4_CONTINUATION_PLAN.md) - Overall plan

## Expected Outcomes

### After Session 6
- ✅ 2-3 additional SDT properties complete
- ✅ Test differences: 13 → 0-3 (-75% to -100%)
- ✅ 24-25/27 properties (89-93% complete)
- ✅ Zero regressions (342/342 baseline)
- ✅ Potential: 16/16 tests passing (100%)

### Files to Create (2-3 files)
1. `lib/uniword/sdt/temporary.rb`
2. `lib/uniword/sdt/doc_part_obj.rb` (includes DocPartGallery, DocPartCategory)
3. Any additional discovered properties

### Files to Modify (1 file)
1. `lib/uniword/structured_document_tag_properties.rb` (add 2-3 properties)

### Success Criteria
- [ ] All discovered missing properties implemented
- [ ] Differences reduced to 0-3 per test
- [ ] Baseline 342/342 maintained
- [ ] 100% Pattern 0 compliance
- [ ] Potential: 16/16 tests passing

## Next Steps After Session 6

**If 16/16 tests passing**:
- Proceed to Session 7: Documentation & Final Polish (30 min)
- Update README.adoc with Phase 4 achievements
- Update memory bank
- Archive temporary docs to old-docs/

**If 3-5 differences remain**:
- Document why (may be acceptable non-semantic differences)
- Decide if worth addressing or declare victory at 95%+
- Proceed to Session 7: Documentation

**If >5 differences remain**:
- Brief Session 7 for final properties (30-60 min)
- Then Session 8: Documentation

## Efficiency Notes

**Time Compression Strategy**:
- Analyze first (don't code blindly)
- Implement only what diff shows is missing
- Use proven Pattern 0 template (5-10 min per property)
- Test immediately after each property
- Don't over-engineer

## Start Here

1. Read PHASE4_SESSION5_SUMMARY.md (5 min)
2. Run diff analysis on one failing test (5 min)
3. Identify exact missing properties from XML diff (5 min)
4. Implement missing properties one at a time (10-15 min each)
5. Test after each property (2 min)
6. Verify baseline after all changes (5 min)
7. Document results in PHASE4_SESSION6_SUMMARY.md (10 min)

Begin with: "I've read the Phase 4 Session 5 summary. Starting Session 6: Final Property Gaps. Analyzing remaining 13 differences..."

**LET'S ACHIEVE 100% ROUND-TRIP FIDELITY! 🎯**