# Lutaml-Model Issue: attribute_form_default :qualified Not Working

## Problem Description

When using `attribute_form_default :qualified` in an XmlNamespace definition, attributes are not being serialized with namespace prefixes, even though this is the expected behavior for OOXML (Office Open XML) documents.

## Expected Behavior

According to the OOXML specification (ISO 29500), attributes in the WordProcessingML namespace should be prefixed with `w:`. For example:

```xml
<w:spacing w:val="20"/>
<w:border w:color="FF0000" w:val="single" w:sz="4"/>
```

## Actual Behavior

Currently, lutaml-model serializes attributes without namespace prefixes:

```xml
<w:spacing val="20"/>
<w:border color="FF0000" val="single" sz="4"/>
```

## Minimal Reproduction Case

```ruby
require 'lutaml/model'

# Define namespace with attribute_form_default :qualified
class WordProcessingML < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix_default 'w'
  element_form_default :qualified
  attribute_form_default :qualified  # <-- This should make attributes use w: prefix
end

# Define a simple OOXML element
class CharacterSpacing < Lutaml::Model::Serializable
  xml do
    element 'spacing'
    namespace WordProcessingML
    map_attribute 'val', to: :val
  end

  attribute :val, :integer
end

# Test serialization
spacing = CharacterSpacing.new(val: 20)
puts spacing.to_xml(prefix: true)
```

### Current Output (INCORRECT)
```xml
<w:spacing val="20"/>
```

### Expected Output (CORRECT)
```xml
<w:spacing w:val="20"/>
```

## Real-World Impact

This issue affects OOXML document generation. When Microsoft Word or other OOXML-compliant applications read documents with unprefixed attributes, they may reject them or parse them incorrectly.

### Example from Real OOXML Document

Here's what a real Word document contains:

```xml
<w:spacing w:after="100" w:before="0"/>
<w:tab w:leader="none" w:pos="560" w:val="left"/>
<w:top w:color="00000A" w:space="0" w:sz="4" w:val="single"/>
```

All attributes have the `w:` prefix because they're in the WordProcessingML namespace.

## API Expectation

The `attribute_form_default :qualified` configuration should work similarly to `element_form_default :qualified`, automatically adding the namespace prefix to all attributes in that namespace.

## Workaround Attempted

We tried manually specifying the prefix in map_attribute:
```ruby
map_attribute 'val', to: :val, prefix: 'w'  # Does not work
```

This doesn't work because attributes can only have a prefix if they're explicitly in a namespace, and there's no direct way to assign the namespace to an attribute.

## Proposed Solution

Lutaml-model should respect the `attribute_form_default :qualified` setting and automatically prefix attributes with the namespace prefix when serializing to XML.

Alternatively, if this is intentionally unsupported, the documentation should clarify this and provide a recommended approach for handling namespaced attributes.

## Test Case

```ruby
require 'lutaml/model'
require 'nokogiri'

class WordProcessingML < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix_default 'w'
  element_form_default :qualified
  attribute_form_default :qualified
end

class CharacterSpacing < Lutaml::Model::Serializable
  xml do
    element 'spacing'
    namespace WordProcessingML
    map_attribute 'val', to: :val
  end

  attribute :val, :integer
end

spacing = CharacterSpacing.new(val: 20)
xml = spacing.to_xml(prefix: true)
doc = Nokogiri::XML(xml)

element = doc.at_xpath("//w:spacing", "w" => WordProcessingML.uri)
puts "Element found: #{!element.nil?}"
puts "Attribute with 'val': #{element['val']}"           # Currently works
puts "Attribute with 'w:val': #{element['w:val']}"       # Currently nil, should be "20"

# Expected: element['w:val'] should return "20"
# Actual: element['w:val'] returns nil
```

## Environment

- Lutaml-model version: 0.7.x
- Ruby version: 3.3.x
- Use case: OOXML (Office Open XML) document generation for Word/Excel/PowerPoint
