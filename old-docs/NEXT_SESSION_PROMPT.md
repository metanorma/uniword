# Next Session: Complete Enhanced Properties Implementation

## Session Goal
Complete the remaining 18/22 failing enhanced properties tests to reach 100% pass rate.

## Current State ✅
- **FIXED**: Nested serialization now works! Custom `to_xml()` override was removed from Element class.
- **WORKING**: Run properties with wrapper classes (CharacterSpacing, Kerning, Position, etc.)
- **PASSING**: 4/22 tests (outline, shadow, emboss, imprint)
- **FAILING**: 18/22 tests (implementation incomplete, not lutaml-model issues)

## Critical Rules (MUST FOLLOW)

### 🚨 NEVER OVERRIDE LUTAML-MODEL METHODS 🚨
1. ❌ **NEVER** override `to_xml()` or `from_xml()`
2. ❌ **NEVER** override `initialize()` in lutaml-model classes
3. ❌ **NEVER** create custom getters that return different types than the attribute
4. ✅ **ALWAYS** let lutaml-model handle serialization automatically
5. ✅ **ALWAYS** use wrapper classes for OOXML elements with `w:val` attributes

## Implementation Checklist

### Step 1: Add Missing Run Methods (30 min)

**File**: `lib/uniword/run.rb`

Add the `set_shading()` method:
```ruby
def set_shading(fill: nil, color: nil, pattern: nil)
  ensure_properties
  shading = Properties::RunShading.new(
    fill: fill,
    color: color,
    shading_type: pattern || 'clear'
  )
  @properties.shading = shading
  self
end
```

**Test**: `spec/uniword/enhanced_properties_xml_spec.rb` - Run shading tests

### Step 2: Fix Border Attributes (1 hour)

**Problem**: Border class doesn't properly serialize attributes with `w:` prefix

**File**: `lib/uniword/properties/border.rb`

Current (WRONG):
```ruby
xml do
  map_attribute 'val', to: :style
  map_attribute 'color', to: :color
  map_attribute 'sz', to: :size
end
```

Should be (CORRECT):
```ruby
xml do
  map_attribute 'val', to: :style
  map_attribute 'color', to: :color
  map_attribute 'sz', to: :size
  map_attribute 'space', to: :space
  map_attribute 'shadow', to: :shadow
  map_attribute 'frame', to: :frame
end
```

**Note**: Check if `prefix: 'w'` is needed based on namespace configuration.

**Test**: Border serialization tests should show `w:color`, `w:val`, etc.

### Step 3: Create TabStop Wrapper Classes (1 hour)

**File**: `lib/uniword/properties/tab_stops.rb` (NEW FILE)

Create these classes:
```ruby
class TabStop < Lutaml::Model::Serializable
  xml do
    element 'tab'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :alignment
    map_attribute 'pos', to: :position
    map_attribute 'leader', to: :leader
  end

  attribute :alignment, :string  # 'left', 'center', 'right', 'decimal', 'bar'
  attribute :position, :integer  # Position in twips
  attribute :leader, :string     # 'none', 'dot', 'hyphen', 'underscore', 'middleDot'
end

class TabStopCollection < Lutaml::Model::Serializable
  xml do
    element 'tabs'
    namespace Ooxml::Namespaces::WordProcessingML
    map_element 'tab', to: :tabs
  end

  attribute :tabs, TabStop, collection: true, default: -> { [] }

  def add_tab(position, alignment, leader = 'none')
    @tabs << TabStop.new(
      position: position,
      alignment: alignment,
      leader: leader
    )
  end
end
```

**Update**: `lib/uniword/properties/paragraph_properties.rb`
- Change `attribute :tab_stops` type from current to `TabStopCollection`

**Update**: `lib/uniword/paragraph.rb`
- Update `add_tab_stop` method to use new TabStopCollection

**Test**: Tab stops serialization tests

### Step 4: Verify All Wrapper Classes Work (30 min)

Test each wrapper class individually:
1. CharacterSpacing ✅ (already working)
2. TextExpansion
3. Kerning
4. Position
5. EmphasisMark
6. Language
7. TabStop (new)

Run: `bundle exec rspec spec/uniword/enhanced_properties_xml_spec.rb`

### Step 5: Final Validation (30 min)

1. Run all 22 tests: `bundle exec rspec spec/uniword/enhanced_properties_xml_spec.rb`
2. Verify round-trip: Load XML → Model → XML should be identical
3. Performance check: Should complete in < 500ms
4. Update memory bank with final status

## Files to Modify

1. ✏️ `lib/uniword/run.rb` - Add set_shading method
2. ✏️ `lib/uniword/properties/border.rb` - Fix attribute mappings
3. ✏️ `lib/uniword/properties/tab_stops.rb` - **NEW FILE**
4. ✏️ `lib/uniword/properties/paragraph_properties.rb` - Use TabStopCollection
5. ✏️ `lib/uniword/paragraph.rb` - Update add_tab_stop method

## Expected Test Results

After completion:
- ✅ 22/22 tests passing (100%)
- ✅ All border attributes serialize correctly
- ✅ All tab stops serialize correctly
- ✅ All character spacing/kerning/position serialize correctly
- ✅ All shading serialize correctly

## Debugging Strategy

If tests still fail:

1. **Test individual serialization**:
   ```ruby
   obj = WrapperClass.new(val: value)
   puts obj.to_xml
   # Should show: <element val="value"/>
   ```

2. **Test parent serialization**:
   ```ruby
   props = Properties.new
   props.attribute = WrapperClass.new(val: value)
   puts props.to_xml
   # Should show nested element
   ```

3. **Check for custom getters/setters**:
   - Ensure NO custom methods return different types
   - Use `@attribute` directly, or use lutaml-model's automatic getters

4. **Verify namespace configuration**:
   - All wrapper classes must declare `namespace Ooxml::Namespaces::WordProcessingML`
   - Check element names match OOXML spec

## Success Criteria

- [ ] All 22 enhanced properties tests pass
- [ ] No custom `to_xml()` or `from_xml()` overrides anywhere
- [ ] All wrapper classes follow the same pattern
- [ ] Round-trip preservation works
- [ ] Performance < 500ms for complex documents
- [ ] Memory bank updated with completion status

## Estimated Time: 3-4 hours

## Reference Files

- Test file: `spec/uniword/enhanced_properties_xml_spec.rb`
- Wrapper classes: `lib/uniword/properties/simple_val_properties.rb`
- Run properties: `lib/uniword/properties/run_properties.rb`
- Paragraph properties: `lib/uniword/properties/paragraph_properties.rb`
- Memory bank: `.kilocode/rules/memory-bank/context.md`

## Key Insight from This Session

The nested serialization issue was NOT a lutaml-model limitation - it was our custom code interfering with lutaml-model's automatic functionality. Once we removed the custom `to_xml()` override and custom getters, everything worked perfectly.

**Lesson**: Trust lutaml-model's built-in capabilities. Don't fight the framework.
