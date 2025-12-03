# Property Serialization Pattern for Uniword

## Overview

This document describes the proven pattern for implementing XML serialization of OOXML simple element properties in Uniword using lutaml-model.

**Status**: Implemented in Phase 2 Session 3 (November 29, 2024)  
**Test Coverage**: 168/168 tests passing across 24 StyleSets  
**Properties Serializing**: Alignment, FontSize, Color, StyleReference, OutlineLevel

## The Problem

OOXML uses simple elements with a single `w:val` attribute for many properties:

```xml
<w:jc w:val="center"/>           <!-- Alignment -->
<w:sz w:val="32"/>                <!-- Font Size -->
<w:color w:val="FF0000"/>         <!-- Color -->
<w:pStyle w:val="Heading1"/>      <!-- Style Reference -->
<w:outlineLvl w:val="0"/>         <!-- Outline Level -->
```

Initial attempts to map these directly to attributes in Properties classes failed because lutaml-model couldn't serialize them properly without wrapper objects.

## The Solution: Wrapper Classes

Create a dedicated wrapper class for each simple element type that mirrors the XML structure.

### Pattern Structure

**For each simple element, create THREE components:**

1. **Wrapper Class** (e.g., `lib/uniword/properties/alignment.rb`)
2. **Property Class Integration** (e.g., in `paragraph_properties.rb`)
3. **Parser Updates** (in `styleset_xml_parser.rb`)

## Step-by-Step Implementation

### Step 1: Create Wrapper Class

Create a new file in `lib/uniword/properties/` following this exact pattern:

```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Brief description
    #
    # Represents <w:ELEMENT w:val="..."/> where value is...
    class WrapperClassName < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST (CRITICAL!)
      attribute :value, :string  # or :integer, :float, etc.
      
      xml do
        root 'elementName'  # without 'w:' prefix
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
        
        map_attribute 'val', to: :value
      end
    end
  end
end
```

**Key Rules:**
- ✅ **ALWAYS declare `attribute` BEFORE `xml do` block** (Pattern 0)
- ✅ Use `:value` as the attribute name for consistency
- ✅ Choose correct type: `:string`, `:integer`, `:float`, `:boolean`
- ✅ Root element name WITHOUT namespace prefix
- ✅ Use `map_attribute 'val'` NOT `map_element`

### Step 2: Integrate into Property Class

Update the relevant property class (ParagraphProperties, RunProperties, etc.):

```ruby
# At top of file, add require
require_relative 'wrapper_class_name'

class ParagraphProperties < Lutaml::Model::Serializable
  # ATTRIBUTES FIRST
  
  # Add wrapper object attribute
  attribute :property_obj, WrapperClassName
  
  # Keep flat attribute for backward compatibility
  attribute :property, :string
  
  # ... other attributes ...
  
  xml do
    # Map the wrapper object
    map_element 'elementName', to: :property_obj, render_nil: false
    
    # ... other mappings ...
  end
  
  # Add convenience methods for backward compatibility
  
  def property
    @property || @property_obj&.value
  end
  
  def property=(val)
    @property = val
    @property_obj = WrapperClassName.new(value: val) if val
  end
end
```

**Key Rules:**
- ✅ Both wrapper object AND flat attribute for compatibility
- ✅ Use `render_nil: false` to omit when nil
- ✅ Convenience methods delegate to wrapper object

### Step 3: Update Parser

Update the parser to create wrapper objects:

```ruby
def parse_paragraph_properties(pPr_node)
  require_relative '../properties/wrapper_class_name'
  
  props = Properties::ParagraphProperties.new
  
  # Create wrapper object from XML
  if (element = pPr_node.at_xpath('./w:elementName', WORDML_NS))
    val = element['w:val']  # or .to_i for integers
    props.property_obj = Properties::WrapperClassName.new(value: val)
    props.property = val  # Flat compatibility
  end
  
  # ... rest of parsing ...
  
  props
end
```

**Key Rules:**
- ✅ Create wrapper object with parsed value
- ✅ Also set flat attribute for compatibility
- ✅ Handle type conversion (e.g., `.to_i` for integers)

## Complete Examples

### Example 1: Alignment (String Value)

**Wrapper Class** (`lib/uniword/properties/alignment.rb`):
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

**Property Integration** (`lib/uniword/properties/paragraph_properties.rb`):
```ruby
require_relative 'alignment'

class ParagraphProperties < Lutaml::Model::Serializable
  attribute :alignment_obj, Alignment
  attribute :alignment, :string
  
  xml do
    map_element 'jc', to: :alignment_obj, render_nil: false
  end
  
  def alignment
    @alignment || @alignment_obj&.value
  end
  
  def alignment=(val)
    @alignment = val
    @alignment_obj = Alignment.new(value: val) if val
  end
end
```

**Parser Update** (`lib/uniword/stylesets/styleset_xml_parser.rb`):
```ruby
if (jc = pPr_node.at_xpath('./w:jc', WORDML_NS))
  props.alignment_obj = Properties::Alignment.new(value: jc['w:val'])
  props.alignment = jc['w:val']
end
```

### Example 2: Font Size (Integer Value)

**Wrapper Class** (`lib/uniword/properties/font_size.rb`):
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

**Property Integration** (`lib/uniword/properties/run_properties.rb`):
```ruby
require_relative 'font_size'

class RunProperties < Lutaml::Model::Serializable
  attribute :size_obj, FontSize
  attribute :size, :integer
  
  xml do
    map_element 'sz', to: :size_obj, render_nil: false
  end
  
  def size
    @size || @size_obj&.value
  end
  
  def size=(val)
    @size = val
    @size_obj = FontSize.new(value: val) if val
  end
end
```

**Parser Update**:
```ruby
if (sz = rPr_node.at_xpath('./w:sz', WORDML_NS))
  size_val = sz['w:val']&.to_i
  props.size_obj = Properties::FontSize.new(value: size_val)
  props.size = size_val
end
```

## Verification Checklist

After implementing a new simple element property:

- [ ] Wrapper class created with correct type
- [ ] `attribute` declared BEFORE `xml do` block
- [ ] Property class updated with wrapper object attribute
- [ ] Property class has flat attribute for compatibility
- [ ] Property class has convenience methods
- [ ] XML mapping uses `map_element` with `render_nil: false`
- [ ] Parser creates wrapper object from XML
- [ ] Parser sets both wrapper object and flat attribute
- [ ] Tests pass for serialization
- [ ] Tests pass for round-trip (deserialize → serialize → deserialize)

## Testing Strategy

### Quick Test

```ruby
# Create wrapper object
obj = Properties::Alignment.new(value: "center")

# Test serialization
xml = obj.to_xml
puts xml  # Should show: <jc val="center" xmlns:w="..."/>

# Test deserialization
reparsed = Properties::Alignment.from_xml(xml)
puts reparsed.value  # Should show: "center"
```

### Integration Test

```ruby
# Load a StyleSet
styleset = Uniword::StyleSet.from_dotx('path/to/stylesheet.dotx')

# Find a style with the property
style = styleset.styles.find { |s| s.paragraph_properties&.alignment }

# Get original value
original = style.paragraph_properties.alignment

# Serialize and reparse
xml = style.to_xml
reparsed = Uniword::Style.from_xml(xml)

# Verify preservation
reparsed.paragraph_properties.alignment == original  # Should be true
```

## Current Status

### Implemented Properties

| Property | Element | Type | Wrapper Class | Status |
|----------|---------|------|---------------|--------|
| Alignment | `<w:jc>` | String | `Alignment` | ✅ Complete |
| Font Size | `<w:sz>` | Integer | `FontSize` | ✅ Complete |
| Font Size CS | `<w:szCs>` | Integer | `FontSize` | ✅ Complete |
| Color | `<w:color>` | String | `ColorValue` | ✅ Complete |
| Para Style | `<w:pStyle>` | String | `StyleReference` | ✅ Complete |
| Run Style | `<w:rStyle>` | String | `StyleReference` | ✅ Complete |
| Outline Level | `<w:outlineLvl>` | Integer | `OutlineLevel` | ✅ Complete |

### Test Results (November 29, 2024)

- **Total StyleSets Tested**: 24 (12 style-sets + 12 quick-styles)
- **Total Test Examples**: 168
- **Failures**: 0
- **Success Rate**: 100%

**Properties Successfully Preserved in Round-Trip:**
- ✅ Alignment (24/24 StyleSets)
- ✅ Font Size (24/24 StyleSets)
- ✅ Spacing (24/24 StyleSets - complex object)
- ✅ Small Caps (24/24 StyleSets - boolean)

## Future Properties

Additional simple elements that can use this pattern:

### Paragraph Properties
- `<w:numId>` - Numbering ID (Integer)
- `<w:ilvl>` - Numbering level (Integer)

### Run Properties
- `<w:u>` - Underline style (String)
- `<w:highlight>` - Highlight color (String)
- `<w:vertAlign>` - Vertical alignment (String)
- `<w:position>` - Text position (Integer)
- `<w:spacing>` - Character spacing (Integer)
- `<w:kern>` - Kerning (Integer)
- `<w:w>` - Width scale (Integer)
- `<w:em>` - Emphasis mark (String)

### Table Properties
- `<w:tblLayout>` - Table layout (String)
- `<w:tblW>` - Table width (Integer + type attribute)

## Common Pitfalls

### ❌ Pitfall 1: Declaring attributes AFTER xml block
```ruby
# WRONG - Will NOT serialize!
xml do
  map_element 'jc', to: :alignment_obj
end
attribute :alignment_obj, Alignment  # Too late!
```

**Fix**: Always declare attributes BEFORE xml block (Pattern 0)

### ❌ Pitfall 2: Using map_element without wrapper class
```ruby
# WRONG - lutaml-model can't serialize this
attribute :alignment, :string
xml do
  map_element 'jc', to: :alignment  # Needs wrapper object!
end
```

**Fix**: Create a wrapper class and use it

### ❌ Pitfall 3: Forgetting render_nil: false
```ruby
# WRONG - Will render <jc/> even when nil
xml do
  map_element 'jc', to: :alignment_obj
end
```

**Fix**: Add `render_nil: false` to omit nil elements

### ❌ Pitfall 4: Not maintaining flat attributes
```ruby
# WRONG - Breaks backward compatibility
attribute :alignment_obj, Alignment
# Missing: attribute :alignment, :string
```

**Fix**: Always keep both wrapper object AND flat attribute

## Why This Pattern Works

1. **Lutaml-Model Architecture**: Lutaml-model serializes objects by calling their `to_xml` method. Simple attributes don't have this method, but wrapper classes do.

2. **Namespace Handling**: Wrapper classes properly declare namespaces and element names, ensuring correct XML structure.

3. **Type Safety**: Each wrapper class explicitly declares its value type, preventing serialization errors.

4. **Backward Compatibility**: Maintaining flat attributes ensures existing code continues to work.

5. **Testability**: Wrapper classes can be tested independently before integration.

## Maintenance Notes

- This pattern is proven stable with 100% test success rate
- Pattern established in Phase 2 Session 3 (November 29, 2024)
- All future simple element properties should follow this pattern
- Pattern documented in three locations:
  - This file (detailed guide)
  - Memory bank context.md (current status)
  - Memory bank tech.md (technical details)

## Related Documentation

- [Architecture Guide](../.kilocode/rules/memory-bank/architecture.md) - System architecture
- [Pattern 0 Documentation](../.kilocode/rules/memory-bank/tech.md#pattern-0) - Critical attribute ordering
- [Phase 2 Session 3 Summary](../PHASE2_SESSION3_SUMMARY.md) - Implementation details