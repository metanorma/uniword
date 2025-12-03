# Phase 2 Session 3: Property Serialization - Continuation Prompt

**Context**: Uniword StyleSet Round-Trip implementation  
**Current Status**: Session 2 Complete (60%), Session 3 Ready  
**Your Mission**: Implement XML serialization for simple element properties

## Background

You are continuing Phase 2 of Uniword StyleSet Round-Trip implementation. Session 2 achieved:
- ✅ 24/24 StyleSets serialize without "Attribute not found" errors
- ✅ Complex objects work perfectly (Spacing, Indentation, RunFonts)
- ⏳ Simple elements don't serialize yet (alignment, font size, color, etc.)

## Your Goal

Implement proper XML serialization for simple element properties to achieve property preservation in round-trip operations.

**Success Criteria**:
1. Alignment and font size serialize correctly (24/24 StyleSets)
2. 5+ StyleSets achieve >80% property preservation in round-trip
3. No new serialization errors introduced
4. Document the correct pattern for future use

## Current State

### What Works ✅
```ruby
# Complex objects serialize perfectly
spacing = Spacing.new(before: 300, after: 40)
# Produces: <w:spacing w:before="300" w:after="40"/>

fonts = RunFonts.new(ascii: "Arial", h_ansi: "Arial")
# Produces: <w:rFonts w:ascii="Arial" w:hAnsi="Arial"/>
```

### What Doesn't Work Yet ❌
```ruby
# Simple elements with single attributes don't serialize
paragraph_props.alignment = "center"
# Should produce: <w:jc w:val="center"/>
# Currently produces: nothing

run_props.size = 32
# Should produce: <w:sz w:val="32"/>
# Currently produces: nothing
```

### Why It Doesn't Work
The XML mappings in properties files are commented out because previous attempts failed:
- ❌ `delegate: :val` syntax doesn't work
- ❌ Intermediate `content` attributes cause errors  
- ❌ Direct mapping to attributes doesn't work

## Your Implementation Strategy

### Step 1: Research Lutaml-Model Pattern (30 min)

**Action**: Find the correct pattern for simple elements with single attributes.

**Resources**:
- Lutaml-model README: `/Users/mulgogi/src/lutaml/lutaml-model/README.adoc`
- Working examples: [`lib/uniword/properties/spacing.rb`](lib/uniword/properties/spacing.rb:1), [`lib/uniword/properties/run_fonts.rb`](lib/uniword/properties/run_fonts.rb:1)

**Test Approach**: Create a test file to validate different patterns:
```ruby
# test_serialization_patterns.rb
require './lib/uniword/properties/paragraph_properties'

# Try different approaches and see what serializes correctly
class TestAlignment < Lutaml::Model::Serializable
  attribute :value, :string
  
  xml do
    root 'jc'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
    map_attribute 'val', to: :value
  end
end

obj = TestAlignment.new(value: "center")
puts obj.to_xml
# Expected: <w:jc w:val="center" xmlns:w="..."/>
```

### Step 2: Implement Wrapper Classes (1-2 hours)

**Based on what you discover**, create wrapper classes for simple elements:

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

**Then update property classes**:
```ruby
# lib/uniword/properties/paragraph_properties.rb
require_relative 'alignment'

class ParagraphProperties < Lutaml::Model::Serializable
  # Add wrapper attribute
  attribute :alignment_obj, Alignment
  
  # Keep flat attribute for compatibility
  attribute :alignment, :string
  
  xml do
    map_element 'jc', to: :alignment_obj, render_nil: false
  end
  
  # Convenience method
  def alignment
    @alignment || alignment_obj&.value
  end
  
  def alignment=(val)
    @alignment = val
    @alignment_obj = Alignment.new(value: val) if val
  end
end
```

### Step 3: Update Parser (30 min)

**Update**: [`lib/uniword/stylesets/styleset_xml_parser.rb`](lib/uniword/stylesets/styleset_xml_parser.rb:1)

```ruby
# Alignment
if (jc = pPr_node.at_xpath('./w:jc', WORDML_NS))
  props.alignment_obj = Properties::Alignment.new(value: jc['w:val'])
  props.alignment = jc['w:val']  # Flat compatibility
end

# Font size
if (sz = rPr_node.at_xpath('./w:sz', WORDML_NS))
  props.size_obj = Properties::FontSize.new(value: sz['w:val']&.to_i)
  props.size = sz['w:val']&.to_i  # Flat compatibility
end
```

### Step 4: Test Round-Trip (30 min)

**Test serialization**:
```bash
bundle exec ruby -e "
require './lib/uniword/styleset'
styleset = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
heading1 = styleset.styles.find { |s| s.id == 'Heading1' }

puts 'Original alignment: ' + heading1.paragraph_properties.alignment.to_s
puts 'Original size: ' + heading1.run_properties.size.to_s

xml = heading1.to_xml
puts 'XML contains jc: ' + xml.include?('<jc').to_s
puts 'XML contains sz: ' + xml.include?('<sz').to_s

reparsed = Uniword::Style.from_xml(xml)
puts 'Reparsed alignment: ' + reparsed.paragraph_properties.alignment.to_s
puts 'Reparsed size: ' + reparsed.run_properties.size.to_s
"
```

**Run tests**:
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb --format documentation
```

**Target**: < 20 failures (currently 28 failures related to alignment/size)

### Step 5: Document Pattern (30 min)

**Create**: `docs/PROPERTY_SERIALIZATION_PATTERN.md`

Document the pattern you discovered for future property additions:
```markdown
# Property Serialization Pattern

## Simple Elements with Single Attribute

For XML elements like `<w:jc w:val="center"/>`:

### Pattern Discovered
[Document what works...]

### Implementation Steps
1. Create wrapper class
2. Add to property class  
3. Update parser
4. Test serialization

### Example
[Working code example...]
```

## Files to Modify

### New Files (5-10 expected)
- `lib/uniword/properties/alignment.rb`
- `lib/uniword/properties/font_size.rb`
- `lib/uniword/properties/color_value.rb`
- `lib/uniword/properties/style_reference.rb`
- `lib/uniword/properties/underline_value.rb`
- `docs/PROPERTY_SERIALIZATION_PATTERN.md`
- `spec/uniword/distinctive_deep_spec.rb`
- `PHASE2_SESSION3_SUMMARY.md`

### Modified Files (3)
- `lib/uniword/properties/paragraph_properties.rb`
- `lib/uniword/properties/run_properties.rb`
- `lib/uniword/stylesets/styleset_xml_parser.rb`

## Testing Strategy

### Test 1: Single StyleSet Deep Dive
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

### Test 2: Coverage Analysis
Test top 5 StyleSets for property preservation:
- Distinctive
- Elegant  
- Formal
- Modern
- Traditional

**Target**: Each should preserve >80% of properties

## Fallback Plan

If wrapper classes don't work, implement custom serialization:

```ruby
class ParagraphProperties
  def to_xml_with_simple_elements(builder)
    # Use nokogiri directly
    if alignment
      builder['w'].jc('w:val' => alignment)
    end
    
    # Complex objects use normal serialization
    spacing&.to_xml(builder) if spacing
  end
end
```

## Success Metrics

### Primary (Must Achieve)
- [ ] Alignment serializes correctly (24/24 StyleSets)
- [ ] Font size serializes correctly (24/24 StyleSets)
- [ ] No new serialization errors

### Secondary (Nice to Have)
- [ ] Color serializes correctly
- [ ] Style references serialize correctly
- [ ] 5+ StyleSets >80% property preservation

### Documentation (Required)
- [ ] Pattern documented in `docs/PROPERTY_SERIALIZATION_PATTERN.md`
- [ ] Memory bank updated with Session 3 progress
- [ ] Session 3 summary created

## Timeline

**Total Time**: 3-4 hours

- Investigation: 30 min
- Implementation: 2-3 hours
- Testing: 30 min
- Documentation: 30 min

## References

**Current Session Documents**:
- [`PHASE2_SESSION3_PLAN.md`](PHASE2_SESSION3_PLAN.md:1) - Detailed 452-line plan
- [`PHASE2_IMPLEMENTATION_STATUS.md`](PHASE2_IMPLEMENTATION_STATUS.md:1) - Progress tracker
- [`PHASE2_SESSION2_COMPLETE.md`](PHASE2_SESSION2_COMPLETE.md:1) - Session 2 summary

**Memory Bank**:
- [`.kilocode/rules/memory-bank/context.md`](.kilocode/rules/memory-bank/context.md:1) - Current state
- [`.kilocode/rules/memory-bank/architecture.md`](.kilocode/rules/memory-bank/architecture.md:1) - System architecture
- [`.kilocode/rules/memory-bank/tech.md`](.kilocode/rules/memory-bank/tech.md:1) - Technical details

**Working Code Examples**:
- [`lib/uniword/properties/spacing.rb`](lib/uniword/properties/spacing.rb:1) - Complex object (works)
- [`lib/uniword/properties/run_fonts.rb`](lib/uniword/properties/run_fonts.rb:1) - Complex object (works)
- [`lib/uniword/properties/paragraph_properties.rb`](lib/uniword/properties/paragraph_properties.rb:1) - Property class
- [`lib/uniword/stylesets/styleset_xml_parser.rb`](lib/uniword/stylesets/styleset_xml_parser.rb:1) - Parser

**Lutaml-Model Documentation**:
- `/Users/mulgogi/src/lutaml/lutaml-model/README.adoc`

## Starting Commands

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify Session 2 state
bundle exec ruby -e "
require './lib/uniword/styleset'
errors = 0
Dir.glob('references/word-package/{style-sets,quick-styles}/*.dotx').each do |f|
  s = Uniword::StyleSet.from_dotx(f)
  s.styles.each { |st| st.to_xml }
rescue => e
  errors += 1
end
puts \"Serialization errors: #{errors}/24\"
"

# Read detailed plan
cat PHASE2_SESSION3_PLAN.md

# Start implementation
# [Begin Step 1: Research...]
```

## Important Notes

1. **Pattern 0 is Critical**: Always declare attributes BEFORE xml mappings in lutaml-model classes
2. **Test Incrementally**: Test each wrapper class individually before integrating
3. **Preserve Compatibility**: Keep flat attributes for backward compatibility
4. **No Hacks**: Find the correct architectural solution, not workarounds
5. **Document Everything**: The pattern you discover is critical for future work

## Expected Outcome

By end of Session 3:
- ✅ 24/24 StyleSets serialize without errors (maintained from Session 2)
- ✅ Alignment property preserved in round-trip (24/24)
- ✅ Font size property preserved in round-trip (24/24)
- ✅ 5+ StyleSets achieve >80% property preservation
- ✅ Pattern documented for future properties
- ✅ Phase 2 at 90% completion

Good luck! 🚀