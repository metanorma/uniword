# RunProperties Boolean Wrapper Pattern

## Overview

OOXML boolean formatting elements (like `<w:b/>` for bold, `<w:i/>` for italic) are **not** simple Ruby booleans. They are XML elements with:

- Optional `w:val` attribute that can be `true`, `false`, `1`, `0`, or omitted entirely
- Specific namespace requirements (`w:` prefix for WordProcessingML)
- Mixed content support (text and attributes)
- Element ordering constraints within parent `<w:rPr>` elements

Uniword uses **wrapper classes** to properly model these elements, ensuring type safety, correct serialization, and perfect round-trip fidelity.

## Pattern 0: Attributes Before XML (THE CRITICAL RULE)

**🚨 THIS IS THE MOST IMPORTANT RULE IN UNIWORD:**

In all lutaml-model classes, **attributes MUST be declared BEFORE xml mappings**.

### Why This Matters

Lutaml-model builds its internal schema sequentially:

1. Reads `attribute` declarations to build the model schema
2. Then processes `xml do...end` block to map attributes to XML elements
3. Uses the schema  for serialization and deserialization

If you declare xml mappings first, lutaml-model processes the mappings before it knows the attributes exist, resulting in:

- **Serialization failure**: Produces empty XML like `<rPr/>` with no children
- **Deserialization failure**: Silently drops elements it can't map
- **No error messages**: Fails silently, making debugging extremely difficult

### The Correct Pattern

```ruby
class Bold < Lutaml::Model::Serializable
  # ✅ STEP 1: Declare attributes FIRST
  attribute :value, :boolean, default: -> { true }

  # ✅ STEP 2: Map to XML SECOND
  xml do
    element 'b'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value, render_nil: false, render_default: false
  end
end
```

### The Incorrect Pattern (DO NOT DO THIS)

```ruby
class Bold < Lutaml::Model::Serializable
  # ❌ WRONG: XML mappings before attributes
  xml do
    element 'b'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end

  # ❌ TOO LATE: Framework already processed xml block
  attribute :value, :boolean, default: -> { true }
end
```

**Result**: This class will NOT serialize the `value` attribute. The XML will be empty or missing entirely.

## Wrapper Class Template

Use this template to create new boolean wrapper classes:

```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # {PropertyName} - {Description}
    #
    # Represents the OOXML <w:{elementName}/> element.
    # Maps to w:{elementName} in WordProcessingML namespace.
    #
    # @example Create {propertyName} property
    #   {propertyName} = {PropertyName}.new(value: true)
    #
    # @example Serialize to XML
    #   {propertyName}.to_xml
    #   # => "<w:{elementName}/>"
    class {PropertyName} < Lutaml::Model::Serializable
      # STEP 1: Declare attribute FIRST
      attribute :value, :boolean, default: -> { true }

      # STEP 2: Map to XML SECOND
      xml do
        element '{elementName}'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end
  end
end
```

### Template Variables

Replace these placeholders:

- `{PropertyName}` - Ruby class name (PascalCase, e.g., `Bold`, `Italic`, `SmallCaps`)
- `{propertyName}` - Ruby variable name (snake_case, e.g., `bold`, `italic`, `small_caps`)
- `{elementName}` - XML element name (camelCase, e.g., `b`, `i`, `smallCaps`)
- `{Description}` - Human-readable description (e.g., "Bold text formatting")

## Step-by-Step Guide: Adding a New Boolean Property

### Example: Adding `Emboss` Property

Let's walk through adding support for `<w:emboss/>` (embossed text effect).

#### Step 1: Create the Wrapper Class

Create `lib/uniword/properties/emboss.rb`:

```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Emboss - Embossed text effect
    #
    # Represents the OOXML <w:emboss/> element.
    # Maps to w:emboss in WordProcessingML namespace.
    #
    # @example Create emboss property
    #   emboss = Emboss.new(value: true)
    #
    # @example Serialize to XML
    #   emboss.to_xml
    #   # => "<w:emboss/>"
    class Emboss < Lutaml::Model::Serializable
      # CRITICAL: Attribute BEFORE xml block
      attribute :value, :boolean, default: -> { true }

      xml do
        element 'emboss'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false, render_default: false
      end
    end
  end
end
```

#### Step 2: Add to RunProperties

Modify `lib/uniword/wordprocessingml/run_properties.rb`:

```ruby
class RunProperties < Lutaml::Model::Serializable
  # ... existing attributes ...

  # Add emboss attribute (alphabetically sorted)
  attribute :emboss, Uniword::Properties::Emboss

  # ... existing xml block ...
  xml do
    # ... existing mappings ...

    # Add emboss mapping (in order with other boolean properties)
    map_element 'emboss', to: :emboss
  end
end
```

#### Step 3: Add Autoload

Add to `lib/uniword/properties.rb`:

```ruby
module Uniword
  module Properties
    # ... existing autoloads ...
    autoload :Emboss, 'uniword/properties/emboss'
  end
end
```

#### Step 4: Test the Implementation

Create `spec/uniword/properties/emboss_spec.rb`:

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Properties::Emboss do
  describe '#to_xml' do
    it 'serializes to correct XML element' do
      emboss = described_class.new(value: true)
      xml = emboss.to_xml

      expect(xml).to include('<w:emboss')
      expect(xml).to include('xmlns:w=')
    end

    it 'omits val attribute when true (default)' do
      emboss = described_class.new(value: true)
      xml = emboss.to_xml

      # Default value should not appear in XML
      expect(xml).not_to include('val=')
    end
  end

  describe '.from_xml' do
    it 'deserializes from XML element' do
      xml = '<w:emboss xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'
      emboss = described_class.from_xml(xml)

      expect(emboss.value).to be true
    end
  end
end
```

#### Step 5: Verify Integration

Test in a document:

```ruby
require 'uniword'

doc = Uniword::Document.new
para = doc.add_paragraph("Embossed text")
run = para.runs.first

# Set emboss property
run.properties.emboss = Uniword::Properties::Emboss.new(value: true)

# Save and verify
doc.save('test.docx')

# Reload and check
doc2 = Uniword::Document.open('test.docx')
emboss = doc2.body.paragraphs.first.runs.first.properties.emboss
puts emboss.value  # => true
```

## Common Pitfalls

### Pitfall 1: xml Block Before attributes

**❌ WRONG:**
```ruby
class Bold < Lutaml::Model::Serializable
  xml do
    element 'b'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
  end
  attribute :value, :boolean  # Too late!
end
```

**RESULT**: Serialization produces `<rPr/>` with no `<b/>` element. Silent failure.

### Pitfall 2: Using Primitive Boolean Instead of Wrapper

**❌ WRONG:**
```ruby
run.properties.bold = true  # Primitive boolean
```

**✅ CORRECT:**
```ruby
run.properties.bold = Uniword::Properties::Bold.new(value: true)
```

### Pitfall 3: Incorrect Namespace

**❌ WRONG:**
```ruby
xml do
  element 'b'
  namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'  # String
end
```

**✅ CORRECT:**
```ruby
xml do
  element 'b'
  namespace Uniword::Ooxml::Namespaces::WordProcessingML  # Class reference
end
```

### Pitfall 4: Missing render_nil and render_default

**❌ WRONG:**
```ruby
map_attribute 'val', to: :value  # Will render default values
```

**✅ CORRECT:**
```ruby
map_attribute 'val', to: :value, render_nil: false, render_default: false
```

**WHY**: OOXML convention is to omit `w:val` attribute when value is true (default). Including it creates unnecessarily verbose XML.

### Pitfall 5: Forgetting to Add to RunProperties

Creating the wrapper class is not enough - you must:

1. Add `attribute` declaration to RunProperties
2. Add `map_element` to RunProperties xml block
3. Add autoload to properties module

All three steps are required for the property to work.

## Examples from Uniword Codebase

### Simple Boolean: Bold

```ruby
# lib/uniword/properties/bold.rb
class Bold < Lutaml::Model::Serializable
  attribute :value, :boolean, default: -> { true }

  xml do
    element 'b'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value, render_nil: false, render_default: false
  end
end
```

### Complex Script Variant: BoldCs

```ruby
# lib/uniword/properties/bold_cs.rb
class BoldCs < Lutaml::Model::Serializable
  attribute :value, :boolean, default: -> { true }

  xml do
    element 'bCs'  # Note: camelCase for complex script
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value, render_nil: false, render_default: false
  end
end
```

### Usage in RunProperties

```ruby
# lib/uniword/wordprocessingml/run_properties.rb
class RunProperties < Lutaml::Model::Serializable
  # Boolean formatting
  attribute :bold, Bold
  attribute :bold_cs, BoldCs
  attribute :italic, Italic
  attribute :italic_cs, ItalicCs
  attribute :strike, Strike
  attribute :double_strike, DoubleStrike
  attribute :small_caps, SmallCaps
  attribute :caps, Caps
  attribute :hidden, Hidden
  attribute :no_proof, NoProof

  xml do
    root 'rPr'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content  # Allow mixed text and elements

    # Map boolean elements
    map_element 'b', to: :bold
    map_element 'bCs', to: :bold_cs
    map_element 'i', to: :italic
    map_element 'iCs', to: :italic_cs
    map_element 'strike', to: :strike
    map_element 'dstrike', to: :double_strike
    map_element 'smallCaps', to: :small_caps
    map_element 'caps', to: :caps
    map_element 'vanish', to: :hidden
    map_element 'noProof', to: :no_proof
  end
end
```

## Testing Strategy

### Unit Tests

Test each wrapper class independently:

```ruby
RSpec.describe Uniword::Properties::Bold do
  it 'serializes to XML' do
    bold = described_class.new(value: true)
    xml = bold.to_xml
    expect(xml).to include('<w:b')
  end

  it 'deserializes from XML' do
    xml = '<w:b xmlns:w="..."/>'
    bold = described_class.from_xml(xml)
    expect(bold.value).to be true
  end
end
```

### Integration Tests

Test in document context:

```ruby
RSpec.describe 'RunProperties boolean properties' do
  it 'round-trips bold correctly' do
    doc = Uniword::Document.new
    para = doc.add_paragraph("Bold text")
    para.runs.first.properties.bold = Uniword::Properties::Bold.new(value: true)

    xml = doc.to_xml
    doc2 = Uniword::Document.from_xml(xml)

    expect(doc2.body.paragraphs.first.runs.first.properties.bold.value).to be true
  end
end
```

### Round-Trip Tests

Test with real .dotx files:

```ruby
RSpec.describe 'StyleSet round-trip' do
  it 'preserves bold property' do
    original_path = 'references/style-sets/Distinctive.dotx'
    styleset = Uniword::StyleSet.from_dotx(original_path)

    # Find style with bold
    style = styleset.styles.find {|s| s.run_properties&.bold }
    expect(style.run_properties.bold.value).to be true

    # Serialize and reload
    doc = Uniword::Document.new
    styleset.apply_to(doc)
    xml = doc.to_xml
    doc2 = Uniword::Document.from_xml(xml)

    # Verify bold preserved
    # ... assertions ...
  end
end
```

## Related Documentation

- [README.adoc](../README.adoc) - Boolean properties section
- [architecture.md](../.kilocode/rules/memory-bank/architecture.md) - Pattern 0 explanation
- [lutaml-model docs](https://github.com/lutaml/lutaml-model) - Framework documentation

## History

- **December 2, 2024**: RunProperties boolean fix implemented
  - 10 wrapper classes created (Bold, Italic, Strike, etc.)
  - Fixed empty `<rPr/>` serialization issue
  - Achieved 100% Pattern 0 compliance
  - Zero regressions (84/84 StyleSet tests maintained)

## Credits

Implemented as part of Phase 4 property completeness work. The pattern follows lutaml-model best practices and ensures perfect OOXML round-trip fidelity.