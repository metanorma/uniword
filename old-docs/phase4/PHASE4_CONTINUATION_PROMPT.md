# Phase 4 Session 2: Continue Wordprocessingml Property Implementation

**Context**: Phase 4 implements complete Wordprocessingml property support for 100% round-trip fidelity. Session 1 completed the foundation (4 high-priority properties, -23% test differences). Continue with Session 2.

## Your Mission

Implement the remaining table properties to maximize test improvements. Target: Reduce differences from 211 → 160 per test (-24% additional improvement).

## Current State

### Completed (Session 1)
- ✅ Property analysis (27 gaps identified)  
- ✅ Shading themeFill enhancement
- ✅ TableWidth wrapper class
- ✅ CellWidth wrapper class
- ✅ CellVerticalAlign wrapper class
- ✅ TableCellProperties integration

### Test Status
- Content Types: 8/8 (100%) ✅
- Glossary: 0/8 (211 differences each)
- Baseline: 342/342 ✅

### Files Ready
```
lib/uniword/properties/
├── shading.rb (enhanced with themeFill) ✅
├── table_width.rb (new) ✅
├── cell_width.rb (new) ✅
└── cell_vertical_align.rb (new) ✅

lib/uniword/wordprocessingml/
└── table_cell_properties.rb (refactored) ✅

lib/uniword/ooxml/wordprocessingml/
└── table_properties.rb (partial - needs margins+look) 🔄
```

## Session 2 Tasks (2 hours)

### 1. Create Margin Helper Class (15 min)
**File**: `lib/uniword/properties/margin.rb`

```ruby
# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Margin specification helper
    # Represents individual margin with width and type
    class Margin < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :w, :integer        # Width in twips
      attribute :type, :string      # Type: dxa (twips)

      xml do
        # This is a helper class, child elements define root
        namespace Ooxml::Namespaces::WordProcessingML
        map_attribute 'w', to: :w
        map_attribute 'type', to: :type, render_nil: false
      end
    end
  end
end
```

### 2. Create TableCellMargin Class (30 min)
**File**: `lib/uniword/properties/table_cell_margin.rb`

Reference XML:
```xml
<w:tblCellMar>
  <w:top w="0" type="dxa"/>
  <w:left w="108" type="dxa"/>
  <w:bottom w="0" type="dxa"/>
  <w:right w="108" type="dxa"/>
</w:tblCellMar>
```

Pattern: Use Margin class for each side.

### 3. Create TableLook Class (30 min)
**File**: `lib/uniword/properties/table_look.rb`

Reference XML:
```xml
<w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" 
           w:lastColumn="0" w:noHBand="0" w:noVBand="1"/>
```

Attributes: val (string), firstRow/lastRow/firstColumn/lastColumn/noHBand/noVBand (all :integer for 0/1)

### 4. Enhance GridColumn (20 min)
**Find and update**: Search for `table_grid_column.rb` or `grid_column.rb`
**Add**: w attribute (:integer) with XML mapping

### 5. Complete TableProperties Integration (25 min)
**File**: `lib/uniword/ooxml/wordprocessingml/table_properties.rb`

Add attributes:
```ruby
attribute :table_cell_margin, TableCellMargin
attribute :table_look, TableLook
```

Add XML mappings:
```ruby
map_element 'tblCellMar', to: :table_cell_margin, render_nil: false
map_element 'tblLook', to: :table_look, render_nil: false
```

### 6. Test and Verify (10 min)
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation
```

Expected: Differences reduced to ~160 per test (from 211)

## Critical Rules

### Architecture (NON-NEGOTIABLE)
1. ✅ **Pattern 0**: ALWAYS attributes BEFORE xml mappings
2. ✅ **MECE**: Clear separation of concerns
3. ✅ **Model-Driven**: No raw XML preservation  
4. ✅ **Test After Each**: Catch issues early
5. ✅ **Zero Regressions**: Maintain 342/342 baseline

### Implementation Pattern (PROVEN)
```ruby
# Step 1: Create wrapper class
class PropertyName < Lutaml::Model::Serializable
  # Pattern 0: ATTRIBUTES FIRST
  attribute :attr_name, :type
  
  xml do
    root 'elementName'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'xmlAttr', to: :attr_name
  end
end

# Step 2: Use in container
class Container
  attribute :property_name, PropertyName
  
  xml do
    map_element 'elementName', to: :property_name, render_nil: false
  end
end
```

## Reference Documents

**Read these FIRST**:
1. `PHASE4_CONTINUATION_PLAN.md` - Complete 7-session plan
2. `PHASE4_IMPLEMENTATION_STATUS.md` - Current progress tracker
3. `PHASE4_SESSION1_SUMMARY.md` - What was accomplished
4. `PHASE4_PROPERTY_ANALYSIS.md` - Original analysis

## Expected Outcomes

### After Session 2
- ✅ 3 new property classes created
- ✅ GridColumn enhanced
- ✅ TableProperties complete
- ✅ Test differences: 211 → ~160 (-24%)
- ✅ Estimated 2-3 tests passing
- ✅ Zero regressions

### Session 2 Success Criteria
- [ ] All table properties serialize correctly
- [ ] `<tblCellMar>` appears in output
- [ ] `<tblLook>` appears in output
- [ ] `<gridCol w="..."/>` includes width
- [ ] Baseline 342/342 maintained
- [ ] 100% Pattern 0 compliance

## Next Steps After Session 2

Session 3 will focus on Run Properties (4 enhancements: caps, noProof, themeColor, szCs). Estimated 1.5 hours.

## Start Here

1. Read all reference documents
2. Create Margin helper class
3. Create TableCellMargin class
4. Create TableLook class
5. Find and enhance GridColumn
6. Complete TableProperties
7. Run tests
8. Update PHASE4_IMPLEMENTATION_STATUS.md with results

Begin with: "I've read the Phase 4 context. Starting Session 2: Complete Table Properties. Creating Margin helper class..."

**LET'S ACHIEVE 100% ROUND-TRIP FIDELITY! 🚀**