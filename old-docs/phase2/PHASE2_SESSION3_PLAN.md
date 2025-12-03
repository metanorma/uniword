# Phase 2 Session 3: Property Serialization Implementation

**Status**: Ready to Start  
**Prerequisites**: Session 2 Complete (24/24 StyleSets serialize without errors)  
**Target**: 90% Phase 2 completion  
**Estimated Duration**: 3-4 hours

## Mission

Implement proper XML serialization for simple element properties using the correct lutaml-model pattern, achieving property preservation in round-trip operations.

## Current State (Post-Session 2)

### What Works ✅
- All 24 StyleSets load without errors
- All 24 StyleSets serialize without "Attribute not found" errors
- Complex objects serialize perfectly: Spacing, Indentation, RunFonts
- Boolean elements have render_default: false

### What Doesn't Serialize Yet ❌
- ParagraphProperties: style, alignment, outline_level, shading (4 properties)
- RunProperties: style, size, size_cs, underline, color, highlight, vertical_align, position, spacing, kerning, w_scale, emphasis_mark, language props, shading (14 properties)
- TableProperties: ALL properties (style, width, alignment, layout, borders, etc.)

### Root Cause
Lutaml-model doesn't support the patterns we tried:
- ❌ `delegate: :val` doesn't work
- ❌ Intermediate `content` attributes cause errors
- ✅ Need to find correct pattern for `<elem w:val="value"/>` structure

## Session 3 Goals

### Primary Goal
Find and implement the correct lutaml-model pattern for simple elements with single attributes.

### Success Criteria
1. At least alignment and font size serialize correctly
2. 5+ StyleSets achieve >80% property preservation in round-trip
3. Document the correct pattern for future use
4. No new serialization errors introduced

## Investigation Phase (30 min)

### Task 1: Research Lutaml-Model Documentation
Check lutaml-model README and examples for:
- How to map elements with single attributes
- Any special syntax for `w:val` style attributes
- Examples of XML attribute delegation

**Action**: Read `/Users/mulgogi/src/lutaml/lutaml-model/README.adoc`

### Task 2: Test Simple Patterns
Create test file to validate different approaches:

```ruby
# test_serialization_patterns.rb
require './lib/uniword/properties/paragraph_properties'

# Test 1: Direct attribute mapping
class TestClass1 < Lutaml::Model::Serializable
  attribute :my_value, :string
  
  xml do
    root 'testElem'
    namespace 'http://test', 'w'
    map_attribute 'val', to: :my_value
  end
end

# Test 2: Wrapper element
class TestClass2 < Lutaml::Model::Serializable
  attribute :alignment, :string
  
  xml do
    root 'jc'
    namespace 'http://test', 'w'
    map_attribute 'val', to: :alignment
  end
end

# Test both
obj1 = TestClass1.new(my_value: "test")
puts obj1.to_xml

obj2 = TestClass2.new(alignment: "center")
puts obj2.to_xml
```

### Task 3: Analyze Working Examples
Study how Spacing and Indentation work (they succeed):

```ruby
# lib/uniword/properties/spacing.rb
attribute :before, :integer
attribute :after, :integer

xml do
  root 'spacing'
  namespace '...', 'w'
  map_attribute 'before', to: :before
  map_attribute 'after', to: :after
end
```

**Key Insight**: These map attributes of the ROOT element, not nested elements.

## Implementation Phase (2-3 hours)

### Strategy A: Wrapper Classes (Recommended)

Create wrapper classes for simple elements, similar to Spacing/Indentation.

#### Step 1: Create Simple Element Wrappers

**Create**: `lib/uniword/properties/style_reference.rb`
```ruby
class StyleReference < Lutaml::Model::Serializable
  attribute :value, :string
  
  xml do
    root 'pStyle'  # or 'rStyle' for run properties
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
    map_attribute 'val', to: :value
  end
end
```

**Create**: `lib/uniword/properties/alignment.rb`
```ruby
class Alignment < Lutaml::Model::Serializable
  attribute :value, :string
  
  xml do
    root 'jc'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
    map_attribute 'val', to: :value
  end
end
```

**Create**: `lib/uniword/properties/font_size.rb`
```ruby
class FontSize < Lutaml::Model::Serializable
  attribute :value, :integer
  
  xml do
    root 'sz'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
    map_attribute 'val', to: :value
  end
end
```

#### Step 2: Update Property Classes

**Update**: `lib/uniword/properties/paragraph_properties.rb`
```ruby
require_relative 'style_reference'
require_relative 'alignment'

class ParagraphProperties < Lutaml::Model::Serializable
  # Add wrapper attributes
  attribute :style_ref, StyleReference
  attribute :alignment_obj, Alignment
  
  # Keep flat attributes for compatibility
  attribute :style, :string
  attribute :alignment, :string
  
  xml do
    # Map wrapper objects
    map_element 'pStyle', to: :style_ref, render_nil: false
    map_element 'jc', to: :alignment_obj, render_nil: false
  end
  
  # Convenience methods
  def style
    @style || style_ref&.value
  end
  
  def alignment
    @alignment || alignment_obj&.value
  end
end
```

#### Step 3: Update Parser

**Update**: `lib/uniword/stylesets/styleset_xml_parser.rb`
```ruby
# Style reference
if (pStyle = pPr_node.at_xpath('./w:pStyle', WORDML_NS))
  props.style_ref = Properties::StyleReference.new(value: pStyle['w:val'])
  props.style = pStyle['w:val']  # Flat compatibility
end

# Alignment
if (jc = pPr_node.at_xpath('./w:jc', WORDML_NS))
  props.alignment_obj = Properties::Alignment.new(value: jc['w:val'])
  props.alignment = jc['w:val']  # Flat compatibility
end
```

#### Step 4: Test Serialization

```bash
bundle exec ruby -e "
require './lib/uniword/styleset'
styleset = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
heading1 = styleset.styles.find { |s| s.id == 'Heading1' }
xml = heading1.to_xml
puts xml[0..1000]
reparsed = Uniword::Style.from_xml(xml)
puts 'Alignment preserved: ' + (reparsed.paragraph_properties.alignment == 'left').to_s
"
```

### Strategy B: Custom Serialization (Fallback)

If wrapper classes don't work, implement custom serialization methods.

**Pattern**: Override `to_xml` to manually build XML for simple elements.

```ruby
class ParagraphProperties < Lutaml::Model::Serializable
  def to_xml_custom(builder)
    # Build pStyle element
    if style
      builder['w'].pStyle('w:val' => style)
    end
    
    # Build jc element
    if alignment
      builder['w'].jc('w:val' => alignment)
    end
    
    # Complex objects use normal serialization
    spacing.to_xml_custom(builder) if spacing
  end
end
```

## Testing Phase (30 min)

### Test 1: Single StyleSet Deep Dive
Test Distinctive.dotx thoroughly:

```ruby
# spec/uniword/distinctive_deep_spec.rb
RSpec.describe 'Distinctive StyleSet Deep Dive' do
  let(:styleset) { Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx') }
  let(:heading1) { styleset.styles.find { |s| s.id == 'Heading1' } }
  
  it 'preserves alignment in round-trip' do
    original = heading1.paragraph_properties.alignment
    xml = heading1.to_xml
    reparsed = Uniword::Style.from_xml(xml)
    expect(reparsed.paragraph_properties.alignment).to eq(original)
  end
  
  it 'preserves font size in round-trip' do
    original = heading1.run_properties.size
    xml = heading1.to_xml
    reparsed = Uniword::Style.from_xml(xml)
    expect(reparsed.run_properties.size).to eq(original)
  end
end
```

### Test 2: Property Coverage Analysis

```bash
bundle exec ruby -e "
require './lib/uniword/styleset'
['Distinctive', 'Elegant', 'Formal'].each do |name|
  styleset = Uniword::StyleSet.from_dotx(\"references/word-package/style-sets/#{name}.dotx\")
  heading1 = styleset.styles.find { |s| s.id == 'Heading1' }
  
  original = {
    alignment: heading1.paragraph_properties.alignment,
    size: heading1.run_properties.size,
    bold: heading1.run_properties.bold
  }
  
  xml = heading1.to_xml
  reparsed = Uniword::Style.from_xml(xml)
  
  preserved = {
    alignment: reparsed.paragraph_properties.alignment == original[:alignment],
    size: reparsed.run_properties.size == original[:size],
    bold: reparsed.run_properties.bold == original[:bold]
  }
  
  puts \"#{name}: alignment=#{preserved[:alignment]}, size=#{preserved[:size]}, bold=#{preserved[:bold]}\"
end
"
```

### Test 3: Full RSpec Suite

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb --format documentation
```

**Target**: < 20 failures (down from 28)

## Documentation Phase (30 min)

### Update Memory Bank
File: `.kilocode/rules/memory-bank/context.md`

Update with Session 3 progress and new patterns discovered.

### Create Pattern Documentation
File: `docs/PROPERTY_SERIALIZATION_PATTERN.md`

Document the correct pattern for future property additions:

```markdown
# Property Serialization Pattern

## Simple Elements with Single Attribute

For XML elements like `<w:jc w:val="center"/>`:

### Step 1: Create Wrapper Class
[pattern documented...]

### Step 2: Add to Property Class
[pattern documented...]

### Step 3: Update Parser
[pattern documented...]
```

## Rollback Plan

If Session 3 implementations cause regressions:

### Revert Strategy
1. Keep RunFonts class (it works)
2. Revert property class changes
3. Keep parser changes (they don't break anything)
4. Document findings for future attempt

### Acceptable Outcomes
- **Best**: 5+ StyleSets with >80% property preservation
- **Good**: Alignment and font size serialize correctly for all 24
- **Acceptable**: Document why approach doesn't work, plan alternative

## Success Metrics

### Primary
- [ ] Alignment serializes correctly (24/24 StyleSets)
- [ ] Font size serializes correctly (24/24 StyleSets)
- [ ] No new serialization errors

### Secondary
- [ ] Color serializes correctly
- [ ] Style references serialize correctly
- [ ] 5+ StyleSets >80% property preservation

### Documentation
- [ ] Pattern documented for future use
- [ ] Memory bank updated
- [ ] Session 3 summary created

## Timeline

**Total Estimated Time**: 3-4 hours

- Investigation: 30 min
- Implementation: 2-3 hours
  - Wrapper classes: 1 hour
  - Parser updates: 30 min
  - Testing and fixes: 1-1.5 hours
- Testing: 30 min
- Documentation: 30 min

## Files to Modify

### New Files (5-10)
- `lib/uniword/properties/style_reference.rb`
- `lib/uniword/properties/alignment.rb`
- `lib/uniword/properties/font_size.rb`
- `lib/uniword/properties/color_value.rb`
- `lib/uniword/properties/underline_value.rb`
- `spec/uniword/distinctive_deep_spec.rb`
- `docs/PROPERTY_SERIALIZATION_PATTERN.md`

### Modified Files (3)
- `lib/uniword/properties/paragraph_properties.rb`
- `lib/uniword/properties/run_properties.rb`
- `lib/uniword/stylesets/styleset_xml_parser.rb`

## Risk Assessment

### High Risk
- Incorrect pattern could break all 24 StyleSets (reverted Session 2 progress)
- **Mitigation**: Test each change incrementally, keep Session 2 state in git

### Medium Risk
- Wrapper classes add complexity but don't achieve round-trip
- **Mitigation**: Have fallback to custom serialization

### Low Risk
- Some properties may not work with discovered pattern
- **Mitigation**: Document limitations, defer to Session 4

## Next Session Preview (Session 4)

If Session 3 succeeds:
- Implement remaining properties (table, shading, language)
- Achieve 100% property coverage
- Complete Phase 2

If Session 3 partially succeeds:
- Focus on most critical properties
- Implement custom serialization for holdouts
- Document limitations

## References

- Session 2 Summary: `PHASE2_SESSION2_SUMMARY.md`
- Implementation Status: `PHASE2_IMPLEMENTATION_STATUS.md`
- Lutaml-Model: `/Users/mulgogi/src/lutaml/lutaml-model/README.adoc`
- Memory Bank: `.kilocode/rules/memory-bank/`