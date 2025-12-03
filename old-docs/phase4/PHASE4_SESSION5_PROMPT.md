# Phase 4 Session 5: SDT Properties Implementation

**Context**: Phase 4 Session 4 completed Run Properties with exceptional results (244→121 differences, -50%). Continue with Session 5 to implement SDT (Structured Document Tag) Properties which account for ~40% of remaining differences.

## Your Mission

Implement complete SDT Properties infrastructure to target the largest remaining source of differences. This is a HIGH IMPACT session with potential for 40-50 difference reduction.

## Current State

### Completed (Sessions 1-4)
- ✅ 14 properties implemented (52% of 27 total)
- ✅ Test differences: 276 → 121 (baseline → current, -56%)
- ✅ Baseline: 342/342 maintained
- ✅ 100% Pattern 0 compliance

### Test Status
- Content Types: 8/8 (100%) ✅
- Glossary: 0/8 (121 differences each)
- Baseline: 342/342 ✅

### Session 4 Results (SUCCESS!)
- Added noProof + themeColor properties
- Discovered caps/szCs already implemented
- Achieved 50% reduction: 244 → 121 differences
- Time: 20 minutes (87% faster than estimated)

## Session 5 Tasks (2.5 hours - HIGH IMPACT)

### Target: Reduce differences from 121 → ~70 (-40 to -50 differences, -35% to -40%)

### 1. Create SDT Directory Structure (5 min)

```bash
mkdir -p lib/uniword/sdt
```

### 2. Implement Simple SDT Properties (1 hour)

#### A. SDT Id (15 min)
**File**: `lib/uniword/sdt/id.rb`

```ruby
module Uniword
  module Sdt
    class Id < Lutaml::Model::Serializable
      attribute :value, :integer
      
      xml do
        element 'id'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
```

**Reference XML**: `<w:id w:val="-578829839"/>`

#### B. SDT Alias (15 min)
**File**: `lib/uniword/sdt/alias.rb`

```ruby
module Uniword
  module Sdt
    class Alias < Lutaml::Model::Serializable
      attribute :value, :string
      
      xml do
        element 'alias'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
```

**Reference XML**: `<w:alias w:val="Title"/>`

#### C. SDT Tag (15 min)
**File**: `lib/uniword/sdt/tag.rb`

```ruby
module Uniword
  module Sdt
    class Tag < Lutaml::Model::Serializable
      attribute :value, :string
      
      xml do
        element 'tag'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end
  end
end
```

**Reference XML**: `<w:tag w:val=""/>`

#### D. SDT Text (10 min)
**File**: `lib/uniword/sdt/text.rb`

```ruby
module Uniword
  module Sdt
    class Text < Lutaml::Model::Serializable
      xml do
        element 'text'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
```

**Reference XML**: `<w:text/>`

#### E. SDT ShowingPlaceholderHeader (5 min)
**File**: `lib/uniword/sdt/showing_placeholder_header.rb`

```ruby
module Uniword
  module Sdt
    class ShowingPlaceholderHeader < Lutaml::Model::Serializable
      xml do
        element 'showingPlcHdr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
```

**Reference XML**: `<w:showingPlcHdr/>`

### 3. Implement Complex SDT Properties (1 hour)

#### F. SDT Appearance (20 min)
**File**: `lib/uniword/sdt/appearance.rb`

```ruby
module Uniword
  module Sdt
    class Appearance < Lutaml::Model::Serializable
      attribute :value, :string  # "hidden" | "tags" | "boundingBox"
      
      xml do
        element 'appearance'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
```

**Reference XML**: `<w:appearance w:val="hidden"/>`

#### G. SDT Placeholder (20 min)
**File**: `lib/uniword/sdt/placeholder.rb`

```ruby
module Uniword
  module Sdt
    class DocPartReference < Lutaml::Model::Serializable
      attribute :value, :string
      
      xml do
        element 'docPart'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
    
    class Placeholder < Lutaml::Model::Serializable
      attribute :doc_part, DocPartReference
      
      xml do
        element 'placeholder'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_element 'docPart', to: :doc_part
      end
    end
  end
end
```

**Reference XML**: 
```xml
<w:placeholder>
  <w:docPart w:val="{F765B1B1-...}"/>
</w:placeholder>
```

#### H. SDT DataBinding (20 min)
**File**: `lib/uniword/sdt/data_binding.rb`

```ruby
module Uniword
  module Sdt
    class DataBinding < Lutaml::Model::Serializable
      attribute :xpath, :string
      attribute :store_item_id, :string
      attribute :prefix_mappings, :string
      
      xml do
        element 'dataBinding'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'xpath', to: :xpath, render_nil: false
        map_attribute 'storeItemID', to: :store_item_id, render_nil: false
        map_attribute 'prefixMappings', to: :prefix_mappings, render_nil: false
      end
    end
  end
end
```

**Reference XML**: 
```xml
<w:dataBinding w:xpath="/root/element" 
               w:storeItemID="{GUID}" 
               w:prefixMappings="xmlns:ns='http://example.com'"/>
```

### 4. Create SDT Properties Container (30 min)

**File**: `lib/uniword/structured_document_tag_properties.rb`

```ruby
require_relative 'sdt/id'
require_relative 'sdt/alias'
require_relative 'sdt/tag'
require_relative 'sdt/text'
require_relative 'sdt/showing_placeholder_header'
require_relative 'sdt/appearance'
require_relative 'sdt/placeholder'
require_relative 'sdt/data_binding'

module Uniword
  class StructuredDocumentTagProperties < Lutaml::Model::Serializable
    # Pattern 0: ATTRIBUTES FIRST
    attribute :id, Sdt::Id
    attribute :alias_name, Sdt::Alias
    attribute :tag, Sdt::Tag
    attribute :text, Sdt::Text
    attribute :showing_placeholder_header, Sdt::ShowingPlaceholderHeader
    attribute :appearance, Sdt::Appearance
    attribute :placeholder, Sdt::Placeholder
    attribute :data_binding, Sdt::DataBinding
    
    xml do
      element 'sdtPr'
      namespace Uniword::Ooxml::Namespaces::WordProcessingML
      mixed_content
      
      map_element 'id', to: :id, render_nil: false
      map_element 'alias', to: :alias_name, render_nil: false
      map_element 'tag', to: :tag, render_nil: false
      map_element 'text', to: :text, render_nil: false
      map_element 'showingPlcHdr', to: :showing_placeholder_header, render_nil: false
      map_element 'appearance', to: :appearance, render_nil: false
      map_element 'placeholder', to: :placeholder, render_nil: false
      map_element 'dataBinding', to: :data_binding, render_nil: false
    end
  end
end
```

### 5. Integrate into StructuredDocumentTag (if needed)

Check if `lib/uniword/structured_document_tag.rb` exists. If it does, ensure it uses the new properties class:

```ruby
attribute :properties, StructuredDocumentTagProperties
```

### 6. Test and Verify (30 min)

```bash
cd /Users/mulgogi/src/mn/uniword

# Run document element tests
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation

# Expected: 121 → 70-80 differences (-35% to -40%)

# Verify baseline (CRITICAL)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Must remain: 342/342 passing ✅
```

## Critical Rules

### Architecture (NON-NEGOTIABLE)
1. ✅ **Pattern 0**: ALWAYS attributes BEFORE xml mappings
2. ✅ **MECE**: Clear separation of concerns (one file per SDT property)
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

# Pattern for complex element
class ComplexProperty < Lutaml::Model::Serializable
  attribute :child, ChildClass  # Pattern 0: ATTRIBUTE FIRST
  
  xml do
    element 'elementName'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_element 'childElement', to: :child
  end
end
```

## Reference Documents

**Read these FIRST**:
1. [`PHASE4_CONTINUATION_PLAN.md`](PHASE4_CONTINUATION_PLAN.md) - Complete 7-session plan
2. [`PHASE4_IMPLEMENTATION_STATUS.md`](PHASE4_IMPLEMENTATION_STATUS.md) - Current progress (52%)
3. [`PHASE4_SESSION4_SUMMARY.md`](PHASE4_SESSION4_SUMMARY.md) - Previous session results
4. [`PHASE4_PROPERTY_ANALYSIS.md`](PHASE4_PROPERTY_ANALYSIS.md) - Original gap analysis

## Expected Outcomes

### After Session 5
- ✅ 8 SDT property classes complete
- ✅ Test differences: 121 → 70-80 (-35% to -40%)
- ✅ 22/27 properties (81% complete)
- ✅ Zero regressions (342/342 baseline)
- ✅ 100% Pattern 0 compliance maintained

### Files to Create (9 files)
1. `lib/uniword/sdt/id.rb`
2. `lib/uniword/sdt/alias.rb`
3. `lib/uniword/sdt/tag.rb`
4. `lib/uniword/sdt/text.rb`
5. `lib/uniword/sdt/showing_placeholder_header.rb`
6. `lib/uniword/sdt/appearance.rb`
7. `lib/uniword/sdt/placeholder.rb` (includes DocPartReference)
8. `lib/uniword/sdt/data_binding.rb`
9. `lib/uniword/structured_document_tag_properties.rb`

### Success Criteria
- [ ] All 8 SDT properties serialize correctly
- [ ] StructuredDocumentTagProperties integrates all 8 properties
- [ ] Baseline 342/342 maintained
- [ ] Differences reduced by 40-50 (~35-40%)
- [ ] 100% Pattern 0 compliance

## Next Steps After Session 5

Session 6 will focus on remaining properties:
- Table conditional formatting (cnfStyle, vMerge)
- Table row rsid attributes
- Investigation of AlternateContent issues

Estimated remaining differences: 70-80, with next session targeting ~30-40 reduction.

## Efficiency Notes

**Time Compression Strategy**:
- Simple properties first (id, alias, tag, text, showing_plc_hdr): 1 hour
- Complex properties next (appearance, placeholder, data_binding): 1 hour
- Integration and testing: 30 minutes
- Each property: 10-20 minutes max
- Test immediately if any issues arise

## Module Organization

All SDT properties go in `Uniword::Sdt` module:
```ruby
module Uniword
  module Sdt
    class Id < Lutaml::Model::Serializable
      # ...
    end
  end
end
```

Parent properties use full namespace:
```ruby
module Uniword
  class StructuredDocumentTagProperties < Lutaml::Model::Serializable
    attribute :id, Sdt::Id
    # ...
  end
end
```

## Start Here

1. Read all reference documents (5 min)
2. Create `lib/uniword/sdt/` directory (1 min)
3. Implement simple properties (id, alias, tag, text, showing_plc_hdr - 1 hour)
4. Test simple properties (5 min)
5. Implement complex properties (appearance, placeholder, data_binding - 1 hour)
6. Test complex properties (5 min)
7. Create StructuredDocumentTagProperties container (20 min)
8. Integration testing (10 min)
9. Final verification and baseline check (10 min)
10. Document results in PHASE4_SESSION5_SUMMARY.md (10 min)

Begin with: "I've read the Phase 4 context. Starting Session 5: SDT Properties Implementation. Creating sdt directory structure..."

**LET'S TARGET 40-50 DIFFERENCE REDUCTION! 🚀**