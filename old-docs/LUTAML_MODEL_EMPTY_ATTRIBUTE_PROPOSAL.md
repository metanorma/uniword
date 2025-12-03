# Lutaml-Model Enhancement Proposal: Empty Attribute Rendering

## Issue Summary

**Title**: Add `render_empty` option to preserve empty string attributes in XML serialization

**Type**: Enhancement / Feature Request

**Affected Component**: XML Attribute Serialization

**Use Case**: Office Open XML (OOXML) document processing

## Problem Description

### Current Behavior

Lutaml-model currently treats empty strings (`""`) as "nil-ish" values and does not render them as XML attributes, even when explicitly set.

**Example:**

```ruby
class EaFont < Lutaml::Model::Serializable
  attribute :typeface, :string, default: -> { "" }
  
  xml do
    element 'ea'
    namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
    map_attribute 'typeface', to: :typeface
  end
end

font = EaFont.new(typeface: "")
puts font.to_xml
```

**Current Output:**
```xml
<a:ea/>
```

**Expected Output:**
```xml
<a:ea typeface=""/>
```

### Impact

This limitation affects document formats where empty attributes have semantic meaning distinct from missing attributes. In Office Open XML (OOXML), Microsoft Word explicitly preserves empty string attributes in theme files:

```xml
<!-- Word's serialization -->
<a:majorFont>
  <a:latin typeface="Calibri Light"/>
  <a:ea typeface=""/>  ← Explicit empty string
  <a:cs typeface=""/>  ← Explicit empty string
</a:majorFont>
```

When round-tripping these documents through lutaml-model, the empty attributes are lost, causing:
- Semantic differences in XML comparison tools
- Potential issues with strict XML validators
- Loss of original document structure
- Failed round-trip tests (116 differences across 29 Office themes)

## Use Case: Office Open XML Documents

### Context

Office Open XML (ISO 29500) is the standard format for Microsoft Office documents (.docx, .xlsx, .pptx). Theme files (`.thmx`) use empty string attributes to indicate:

1. **Font fallback intention**: `typeface=""` means "use system default"
2. **Explicit unset**: Different from attribute absence
3. **Schema compliance**: Some schemas require attribute presence

### Real-World Example

In Uniword (Ruby library for Word documents), we process 29 official Microsoft Office themes. ALL 29 themes use empty string attributes for East Asian and Complex Script fonts:

```xml
<!-- Badge.thmx -->
<a:fontScheme name="Badge">
  <a:majorFont>
    <a:latin typeface="Impact"/>
    <a:ea typeface=""/>      ← Required for round-trip
    <a:cs typeface=""/>      ← Required for round-trip
  </a:majorFont>
  <a:minorFont>
    <a:latin typeface="Gill Sans MT"/>
    <a:ea typeface=""/>      ← Required for round-trip
    <a:cs typeface=""/>      ← Required for round-trip
  </a:minorFont>
</a:fontScheme>
```

**Scale**: 4 attributes × 29 themes = 116 required empty attributes

## Proposed Solution

### Option 1: `render_empty` Parameter (Recommended)

Add a `render_empty` option to `map_attribute` that forces rendering of empty string values:

```ruby
class EaFont < Lutaml::Model::Serializable
  attribute :typeface, :string, default: -> { "" }
  
  xml do
    element 'ea'
    namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
    map_attribute 'typeface', to: :typeface, render_empty: true  # ✅ NEW OPTION
  end
end
```

**Behavior:**
- `render_empty: true` → Empty strings render as `attr=""`
- `render_empty: false` (default) → Empty strings omitted (current behavior)
- `nil` values → Always omitted (unchanged)

### Option 2: `render_default` Enhancement

Alternatively, enhance existing `render_default` to handle empty strings:

```ruby
map_attribute 'typeface', to: :typeface, render_default: true
```

**Current behavior**: Only renders non-empty defaults
**Enhanced behavior**: Also renders empty string defaults

### Option 3: Global Configuration

Allow global configuration for strict XML serialization:

```ruby
Lutaml::Model.configure do |config|
  config.render_empty_attributes = true  # Global setting
end
```

## Implementation Considerations

### 1. Backward Compatibility

**Critical**: Default behavior MUST NOT change. Existing code relying on empty omission should continue working.

```ruby
# Default behavior (unchanged)
map_attribute 'name', to: :name
# Empty strings still omitted

# Explicit opt-in (new)
map_attribute 'typeface', to: :typeface, render_empty: true
# Empty strings rendered
```

### 2. Distinction: Empty vs Nil

Clear semantics needed:

| Value | `render_empty: false` | `render_empty: true` |
|-------|----------------------|---------------------|
| `nil` | Omitted | Omitted |
| `""` | Omitted | `attr=""` |
| `"value"` | `attr="value"` | `attr="value"` |

### 3. XML Schema Validity

Empty attributes are **valid XML**:

```xml
<!-- Valid per XML 1.0 spec -->
<element attr=""/>
<element attr="value"/>
<element/>  <!-- attr omitted -->
```

Some XML schemas (like OOXML) distinguish between these forms.

### 4. Performance

Minimal impact expected:
- Single boolean check during serialization
- No change to parsing/deserialization
- No additional memory overhead

## Benefits

### For Uniword (Immediate)
- Perfect Office theme round-trip (145/174 → 174/174 tests)
- 100% OOXML compliance
- No architectural compromises needed

### For Community (Broader)
- **OOXML Processing**: All Office document libraries benefit
- **Strict XML Schemas**: Support schemas requiring attribute presence
- **Round-Trip Fidelity**: Perfect preservation of source documents
- **Standards Compliance**: Better ISO 29500, OASIS, W3C support

### Similar Use Cases
- SVG documents with empty attributes
- XHTML `<input value="">`
- XML configuration files
- SOAP/XML web services

## Alternative Workarounds (Why They Don't Work)

### 1. Sentinel Value
```ruby
attribute :typeface, :string, default: -> { "EMPTY" }
```
**Problem**: Breaks semantic correctness, wrong value serialized

### 2. Custom Serializer
```ruby
def to_xml
  # Manual XML generation
end
```
**Problem**: Defeats purpose of lutaml-model, loses type safety

### 3. Post-Processing
```ruby
xml = obj.to_xml
xml.gsub(/<ea\/>/, '<ea typeface=""/>')
```
**Problem**: Fragile, breaks with namespace changes, unmaintainable

### 4. Accept Limitation
**Problem**: Can't achieve 100% OOXML compliance

## Comparison with Other Libraries

### Nokogiri (Ruby)
```ruby
node['attr'] = ""  # Renders as attr=""
```
**Behavior**: Always renders empty strings ✅

### REXML (Ruby)
```ruby
element.add_attribute('attr', '')  # Renders as attr=""
```
**Behavior**: Always renders empty strings ✅

### XmlMapper (Ruby)
```ruby
attribute :name, String
```
**Behavior**: Omits empty strings ❌ (same issue as lutaml-model)

### Conclusion
Explicit empty string rendering is **common in XML libraries** and **required for standards compliance**.

## Proposed API

### Minimal Implementation

```ruby
module Lutaml
  module Model
    module XmlMapping
      class AttributeMapping
        attr_accessor :render_empty  # New option
        
        def serialize(value)
          return nil if value.nil?
          return nil if value == "" && !render_empty  # Current behavior
          value.to_s  # New: render empty if render_empty: true
        end
      end
    end
  end
end
```

### Usage Example

```ruby
class MyElement < Lutaml::Model::Serializable
  attribute :required_empty, :string, default: -> { "" }
  attribute :optional_field, :string
  
  xml do
    root 'element'
    
    # Force render even when empty
    map_attribute 'required_empty', to: :required_empty, render_empty: true
    
    # Default behavior (omit when empty)
    map_attribute 'optional_field', to: :optional_field
  end
end

obj = MyElement.new(required_empty: "", optional_field: "")
puts obj.to_xml
```

**Output:**
```xml
<element required_empty=""/>
```

## Testing Requirements

### Unit Tests

```ruby
RSpec.describe 'Empty attribute rendering' do
  it 'omits empty attributes by default' do
    obj = MyElement.new(field: "")
    expect(obj.to_xml).not_to include('field=')
  end
  
  it 'renders empty attributes with render_empty: true' do
    obj = MyElement.new(field: "")
    expect(obj.to_xml).to include('field=""')
  end
  
  it 'still omits nil values with render_empty: true' do
    obj = MyElement.new(field: nil)
    expect(obj.to_xml).not_to include('field=')
  end
end
```

### Integration Tests

```ruby
RSpec.describe 'OOXML round-trip' do
  it 'preserves empty font attributes' do
    original = EaFont.from_xml('<ea typeface=""/>')
    expect(original.typeface).to eq("")
    
    regenerated = original.to_xml
    expect(regenerated).to include('typeface=""')
  end
end
```

## Documentation Requirements

### rdoc/YARD Comments

```ruby
# @param render_empty [Boolean] When true, empty strings render as attr="". 
#   When false (default), empty strings are omitted.
#
# @example Preserve empty attributes
#   class Font < Lutaml::Model::Serializable
#     attribute :typeface, :string
#     
#     xml do
#       map_attribute 'typeface', to: :typeface, render_empty: true
#     end
#   end
#
#   font = Font.new(typeface: "")
#   font.to_xml  # => '<font typeface=""/>'
```

### README Update

Add section on empty attribute handling with Office Open XML example.

### Migration Guide

Document for users upgrading:
```markdown
### Empty Attribute Rendering (v0.X.0)

New `render_empty` option available. **Default behavior unchanged**.

If you need to preserve empty string attributes (e.g., for OOXML):
...
```

## Timeline

### Implementation (Estimated)
- **Core Logic**: 2-4 hours
- **Tests**: 2-3 hours
- **Documentation**: 1-2 hours
- **Review**: 1-2 hours
- **Total**: ~1 week

### Compatibility
- **Breaking Changes**: None (opt-in feature)
- **Minimum Version**: Next minor release (e.g., 0.8.0)

## References

### Standards
- **XML 1.0 Specification**: https://www.w3.org/TR/xml/
- **ISO 29500 (OOXML)**: https://www.iso.org/standard/71691.html

### Related Issues
- Uniword theme round-trip: https://github.com/metanorma/uniword
- (Add lutaml-model issues if any exist)

### Prior Art
- Nokogiri attribute handling
- REXML attribute serialization
- Other XML serialization libraries

## Conclusion

Empty string attribute rendering is a **legitimate requirement** for:
1. Standards compliance (ISO 29500, etc.)
2. Round-trip document processing
3. Strict XML schema adherence

The proposed `render_empty: true` option:
- ✅ Solves the problem completely
- ✅ Maintains backward compatibility
- ✅ Follows principle of least surprise
- ✅ Minimal implementation complexity
- ✅ Aligns with other XML libraries

**Request**: Please consider adding this feature to lutaml-model to support Office Open XML and other strict XML standards.

---

## Appendix: Full Working Example

```ruby
require 'lutaml/model'

# BEFORE (Current behavior)
class FontBefore < Lutaml::Model::Serializable
  attribute :typeface, :string, default: -> { "" }
  
  xml do
    element 'font'
    map_attribute 'typeface', to: :typeface
  end
end

font = FontBefore.new(typeface: "")
puts font.to_xml
# Output: <font/>  ❌ Empty attribute lost


# AFTER (Proposed behavior)
class FontAfter < Lutaml::Model::Serializable
  attribute :typeface, :string, default: -> { "" }
  
  xml do
    element 'font'
    map_attribute 'typeface', to: :typeface, render_empty: true
  end
end

font = FontAfter.new(typeface: "")
puts font.to_xml
# Output: <font typeface=""/>  ✅ Empty attribute preserved
```

This enhancement would enable **100% OOXML compliance** and support for any XML standard requiring empty attribute preservation.