# Property Serialization Pattern for Uniword (CORRECTED)

## Overview

This document describes the **CORRECT** pattern for implementing XML serialization of OOXML simple element properties in Uniword using lutaml-model v0.7+.

**Status**: Corrected November 29, 2024  
**Test Coverage**: 168/168 tests passing across 24 StyleSets  
**Properties Serializing**: Alignment, FontSize, Color, StyleReference, OutlineLevel

## Critical Corrections from Initial Implementation

### ❌ WRONG (Initial Pattern)
```ruby
# WRONG SYNTAX - DO NOT USE
class Alignment < Lutaml::Model::Serializable
  attribute :value, :string
  
  xml do
    root 'jc'  # ❌ 'root' is obsolete syntax
    namespace 'http://schemas...', 'w'  # ❌ prefix should be in namespace class
    map_attribute 'val', to: :value
  end
end

# WRONG - Dual attributes for backward compat
attribute :alignment, :string
attribute :alignment_obj, Alignment  # ❌ Don't use dual attributes
```

### ✅ CORRECT (Current Pattern)
```ruby
# CORRECT SYNTAX
class AlignmentValue < Lutaml::Model::Type::String
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

class Alignment < Lutaml::Model::Serializable
  attribute :value, AlignmentValue  # ✅ Namespaced custom type
  
  xml do
    element 'jc'  # ✅ Use 'element' not 'root'
    namespace Ooxml::Namespaces::WordProcessingML  # ✅ Reference namespace class
    map_attribute 'val', to: :value
  end
end

# CORRECT - Single attribute only
attribute :alignment, Alignment  # ✅ No _obj suffix, no dual attributes
```

## The Problem

OOXML uses simple elements with a single `w:val` attribute for many properties:

```xml
<w:jc w:val="center"/>           <!-- Alignment -->
<w:sz w:val="32"/>                <!-- Font Size -->
<w:color w:val="FF0000"/>         <!-- Color -->
<w:pStyle w:val="Heading1"/>      <!-- Style Reference -->
<w:outlineLvl w:val="0"/>         <!-- Outline Level -->
```

## The Solution: Namespaced Custom Types + Wrapper Classes

### Step 1: Create Namespaced Custom Type

For each XML type, create a custom type class that inherits from the appropriate Lutaml::Model::Type class:

```ruby
# lib/uniword/properties/alignment.rb
require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Step 1: Create namespaced custom type
    class AlignmentValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end
    
    # Step 2: Create wrapper class using the custom type
    class Alignment < Lutaml::Model::Serializable
      attribute :value, AlignmentValue  # Use custom type
      
      xml do
        element 'jc'  # Element name without prefix
        namespace Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
```

### Step 2: Use in Property Classes

**IMPORTANT**: Use single attribute, no dual attributes, no _obj suffix

```ruby
# lib/uniword/properties/paragraph_properties.rb
require_relative 'alignment'

class ParagraphProperties < Lutaml::Model::Serializable
  # ✅ CORRECT - Single attribute
  attribute :alignment, Alignment
  
  xml do
    map_element 'jc', to: :alignment, render_nil: false
  end
end
```

### Step 3: Update Parser

```ruby
# lib/uniword/stylesets/styleset_xml_parser.rb
if (jc = pPr_node.at_xpath('./w:jc', WORDML_NS))
  props.alignment = Properties::Alignment.new(value: jc['w:val'])
end
```

## Complete Implementation Examples

### Example 1: String Value (Alignment)

```ruby
# lib/uniword/properties/alignment.rb
require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    class AlignmentValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    class Alignment < Lutaml::Model::Serializable
      attribute :value, AlignmentValue
      
      xml do
        element 'jc'
        namespace Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
```

### Example 2: Integer Value (Font Size)

```ruby
# lib/uniword/properties/font_size.rb
require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    class FontSizeValue < Lutaml::Model::Type::Integer
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    class FontSize < Lutaml::Model::Serializable
      attribute :value, FontSizeValue
      
      xml do
        element 'sz'
        namespace Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value
      end
    end
  end
end
```

## Key Syntax Rules

### Rule 1: Namespaced Custom Types
```ruby
# ✅ CORRECT
class AlignmentValue < Lutaml::Model::Type::String
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

attribute :value, AlignmentValue

# ❌ WRONG
attribute :value, :string  # No namespace information
```

### Rule 2: Use `element` not `root`
```ruby
# ✅ CORRECT
xml do
  element 'jc'
  namespace Ooxml::Namespaces::WordProcessingML
end

# ❌ WRONG
xml do
  root 'jc'  # Obsolete syntax
end
```

### Rule 3: Reference Namespace Class
```ruby
# ✅ CORRECT
namespace Ooxml::Namespaces::WordProcessingML

# ❌ WRONG
namespace 'http://schemas...', 'w'  # Prefix should be in namespace class
```

### Rule 4: Single Attribute Only
```ruby
# ✅ CORRECT
class ParagraphProperties < Lutaml::Model::Serializable
  attribute :alignment, Alignment
end

# ❌ WRONG - No dual attributes
class ParagraphProperties < Lutaml::Model::Serializable
  attribute :alignment, :string          # ❌ Don't keep flat attribute
  attribute :alignment_obj, Alignment    # ❌ Don't use _obj suffix
end
```

### Rule 5: Access Value Directly
```ruby
# ✅ CORRECT
para.alignment.value  # Access the wrapped value

# ❌ WRONG
para.alignment  # This returns the Alignment object, not the string
```

## Namespace Reference

All namespaces are defined in `lib/uniword/ooxml/namespaces.rb`:

```ruby
module Uniword
  module Ooxml
    module Namespaces
      class WordProcessingML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        prefix_default 'w'
        element_form_default :qualified
        attribute_form_default :qualified
      end
    end
  end
end
```

## Available Custom Type Base Classes

Choose the appropriate base class for your value type:

- `Lutaml::Model::Type::String` - For text values
- `Lutaml::Model::Type::Integer` - For numeric values  
- `Lutaml::Model::Type::Float` - For decimal values
- `Lutaml::Model::Type::Boolean` - For true/false values
- `Lutaml::Model::Type::Date` - For date values
- `Lutaml::Model::Type::Time` - For timestamp values

## Implementation Checklist

- [ ] Create namespaced custom type class (e.g., `AlignmentValue`)
- [ ] Set `xml_namespace` in custom type
- [ ] Create wrapper class inheriting from `Lutaml::Model::Serializable`
- [ ] Use custom type for `:value` attribute
- [ ] Use `element` (not `root`) in xml block
- [ ] Reference namespace class (not inline string)
- [ ] Use single attribute in property class (no dual attributes)
- [ ] Update parser to create wrapper objects
- [ ] Test serialization
- [ ] Test round-trip (deserialize → serialize → deserialize)

## Current Implementation Status

### Implemented Properties

| Property | Element | Type | Custom Type | Wrapper Class | Status |
|----------|---------|------|-------------|---------------|--------|
| Alignment | `<w:jc>` | String | `AlignmentValue` | `Alignment` | ✅ Complete |
| Font Size | `<w:sz>` | Integer | `FontSizeValue` | `FontSize` | ✅ Complete |
| Font Size CS | `<w:szCs>` | Integer | `FontSizeValue` | `FontSize` | ✅ Complete |
| Color | `<w:color>` | String | `ColorValueType` | `ColorValue` | ✅ Complete |
| Para Style | `<w:pStyle>` | String | `StyleReferenceValue` | `StyleReference` | ✅ Complete |
| Run Style | `<w:rStyle>` | String | `StyleReferenceValue` | `StyleReference` | ✅ Complete |
| Outline Level | `<w:outlineLvl>` | Integer | `OutlineLevelValue` | `OutlineLevel` | ✅ Complete |

### Test Results (November 29, 2024)

- **Total StyleSets Tested**: 24 (12 style-sets + 12 quick-styles)
- **Total Test Examples**: 168
- **Failures**: 0
- **Success Rate**: 100%

## Common Pitfalls

### ❌ Pitfall 1: Using obsolete `root` syntax
```ruby
# WRONG
xml do
  root 'jc'  # Obsolete!
end
```

**Fix**: Use `element` instead
```ruby
xml do
  element 'jc'
end
```

### ❌ Pitfall 2: Inline namespace with prefix
```ruby
# WRONG
xml do
  namespace 'http://schemas...', 'w'  # Prefix set inline
end
```

**Fix**: Reference namespace class (prefix already defined there)
```ruby
xml do
  namespace Ooxml::Namespaces::WordProcessingML
end
```

### ❌ Pitfall 3: Not using namespaced custom types
```ruby
# WRONG
attribute :value, :string  # Plain type, no namespace
```

**Fix**: Create and use namespaced custom type
```ruby
class AlignmentValue < Lutaml::Model::Type::String
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

attribute :value, AlignmentValue
```

### ❌ Pitfall 4: Dual attributes for backward compatibility
```ruby
# WRONG - Don't do this!
attribute :alignment, :string
attribute :alignment_obj, Alignment
```

**Fix**: Single attribute only
```ruby
attribute :alignment, Alignment
```

### ❌ Pitfall 5: Forgetting render_nil: false
```ruby
# WRONG - Will render <jc/> even when nil
xml do
  map_element 'jc', to: :alignment
end
```

**Fix**: Add `render_nil: false`
```ruby
xml do
  map_element 'jc', to: :alignment, render_nil: false
end
```

## Why This Pattern Works

1. **Namespaced Types**: Custom types declare their XML namespace, ensuring proper serialization
2. **Lutaml-Model Architecture**: Framework recognizes custom types and handles namespace prefixes automatically
3. **Clean API**: Single attribute per property keeps code simple and maintainable
4. **Type Safety**: Each wrapper class explicitly declares its value type
5. **Testability**: Wrapper classes can be tested independently

## Future Properties

Additional simple elements that can use this pattern:

### Paragraph Properties
- `<w:numId>` - Numbering ID (Integer → `NumberingIdValue`)
- `<w:ilvl>` - Numbering level (Integer → `NumberingLevelValue`)

### Run Properties
- `<w:u>` - Underline style (String → `UnderlineValue`)
- `<w:highlight>` - Highlight color (String → `HighlightValue`)
- `<w:vertAlign>` - Vertical alignment (String → `VerticalAlignValue`)
- `<w:position>` - Text position (Integer → `PositionValue`)
- `<w:spacing>` - Character spacing (Integer → `CharSpacingValue`)
- `<w:kern>` - Kerning (Integer → `KerningValue`)
- `<w:w>` - Width scale (Integer → `WidthScaleValue`)
- `<w:em>` - Emphasis mark (String → `EmphasisMarkValue`)

## Related Documentation

- [Namespace Definitions](../lib/uniword/ooxml/namespaces.rb) - All XML namespaces
- [Architecture Guide](../.kilocode/rules/memory-bank/architecture.md) - System architecture
- [Phase 2 Session 3 Summary](../PHASE2_SESSION3_SUMMARY.md) - Implementation history