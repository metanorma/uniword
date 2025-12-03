# Lutaml-Model Feature Request: Nested Object Serialization

## Problem Statement

When a `Lutaml::Model::Serializable` class has attributes that are themselves `Serializable` objects, those nested objects are not being serialized to XML. Instead, empty elements are generated.

## Current Behavior (BROKEN)

### Example Code

```ruby
# Nested serializable class
class CharacterSpacing < Lutaml::Model::Serializable
  xml do
    element 'spacing'
    namespace Namespaces::WordProcessingML
    map_attribute 'val', to: :val
  end

  attribute :val, :integer

  def initialize(val = nil)
    @val = val
  end
end

# Parent serializable class
class RunProperties < Lutaml::Model::Serializable
  xml do
    element 'rPr'
    namespace Namespaces::WordProcessingML
    map_element 'spacing', to: :character_spacing
  end

  attribute :character_spacing, CharacterSpacing
end

# Usage
props = RunProperties.new
props.character_spacing = CharacterSpacing.new(20)
puts props.to_xml
```

### Actual Output (WRONG)

```xml
<w:rPr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>
```

### Expected Output (CORRECT)

```xml
<w:rPr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:spacing w:val="20"/>
</w:rPr>
```

## Root Cause Analysis

The `CharacterSpacing` object exists and has the correct value (`@val=20`), but when the parent `RunProperties` is serialized, lutaml-model does NOT recursively call `to_xml` on the nested `CharacterSpacing` object.

### Debug Evidence

```ruby
# Object inspection shows correct structure:
props.character_spacing
#=> #<CharacterSpacing:0x... @val=20>

props.character_spacing.to_xml
#=> "<w:spacing xmlns:w=\"...\" w:val=\"20\"/>"  # Nested object CAN serialize itself

props.to_xml
#=> "<w:rPr xmlns:w=\"...\"/>"  # But parent ignores it!
```

## Proposed Solution

### Option 1: Automatic Recursive Serialization (Preferred)

When serializing an attribute:
1. Check if the attribute value is a `Lutaml::Model::Serializable` instance
2. If yes, call `to_xml` on that object and embed the result
3. If no, serialize as primitive value

### Option 2: Explicit Delegation Syntax

Add a mapping option to explicitly delegate serialization:

```ruby
class RunProperties < Lutaml::Model::Serializable
  xml do
    element 'rPr'
    map_element 'spacing', to: :character_spacing, delegate: true
  end

  attribute :character_spacing, CharacterSpacing
end
```

### Option 3: Render Options

Add options to control nested serialization:

```ruby
class RunProperties < Lutaml::Model::Serializable
  xml do
    element 'rPr'
    map_element 'spacing', to: :character_spacing,
                render_nested: true,   # Serialize nested objects
                render_nil: false      # Don't render if nil
  end

  attribute :character_spacing, CharacterSpacing
end
```

## Real-World Use Case

This issue blocks the Uniword gem from serializing OOXML (Office Open XML) documents. OOXML has deeply nested structures:

```
Document
  └─ Body
      └─ Paragraph
          ├─ ParagraphProperties
          │   ├─ ParagraphBorders
          │   │   ├─ TopBorder
          │   │   ├─ BottomBorder
          │   │   └─ ...
          │   ├─ ParagraphShading
          │   └─ TabStops
          │       └─ TabStop[]
          └─ Run[]
              ├─ RunProperties
              │   ├─ CharacterSpacing
              │   ├─ Kerning
              │   ├─ Position
              │   └─ ...
              └─ TextElement
```

WITHOUT nested serialization, we cannot use lutaml-model for this (which defeats the purpose of using lutaml-model).

## Compatibility Considerations

### Backward Compatibility

Option 1 (automatic) might break existing code if:
- Users are manually serializing nested objects
- Nested objects unintentionally serialize

**Mitigation**: Add a flag to enable/disable automatic nested serialization:

```ruby
class MyModel < Lutaml::Model::Serializable
  xml do
    element 'root'
    auto_serialize_nested true  # Default: false for backward compat
  end
end
```

### Forward Compatibility

Option 2 or 3 (explicit syntax) is safer but requires more boilerplate.

**Recommendation**: Implement both:
- Option 1 with opt-in flag (for new projects)
- Option 3 attribute-level options (for fine-grained control)

## Implementation Sketch

### In `Lutaml::Model::Xml::Transform` (or similar):

```ruby
def serialize_element(element_name, value, mapping)
  if value.is_a?(Lutaml::Model::Serializable) && should_delegate?(mapping)
    # Nested serialization
    nested_xml = value.to_xml
    # Extract inner content and embed it
    return embed_nested_xml(nested_xml, element_name)
  end

  # Existing primitive serialization
  serialize_primitive(element_name, value, mapping)
end

def should_delegate?(mapping)
  # Check if mapping has delegate: true option
  # OR if auto_serialize_nested is enabled
  mapping.options[:delegate] || auto_serialize_nested?
end
```

## Testing Requirements

### Test Cases Needed

1. **Single-level nesting**
   ```ruby
   Parent { Child { value } } → XML with nested elements
   ```

2. **Multi-level nesting**
   ```ruby
   Parent { Child { GrandChild { value } } } → Deep XML hierarchy
   ```

3. **Collections of nested objects**
   ```ruby
   Parent { children: [Child, Child, Child] } → Multiple nested elements
   ```

4. **Nil handling**
   ```ruby
   Parent { child: nil } → No child element if render_nil: false
   ```

5. **Namespace propagation**
   ```ruby
   Parent (ns: w) { Child (ns: w) } → Both use same namespace
   ```

6. **Attribute vs Element nesting**
   ```ruby
   Parent { Child with attributes } → Nested element with attributes
   ```

## Expected Timeline

- **Critical**: This blocks OOXML document generation in production
- **Impact**: Affects any deeply-nested XML structure (common in standards)
- **Workaround**: None without defeating lutaml-model's purpose

## References

- Uniword gem: https://github.com/metanorma/uniword
- ISO 29500 (OOXML spec): https://www.iso.org/standard/71691.html
- Current lutaml-model version: 0.7.7
- Issue manifests in: `spec/uniword/enhanced_properties_xml_spec.rb`

## Contact

For questions or clarification, please contact the Uniword maintainers or open an issue at https://github.com/metanorma/uniword/issues.

---

**Priority**: HIGH
**Type**: Feature Request / Bug Fix
**Component**: XML Serialization
**Affects**: v0.7.7 and likely earlier versions