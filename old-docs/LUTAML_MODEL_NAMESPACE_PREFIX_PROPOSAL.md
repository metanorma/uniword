# Lutaml-Model Namespace Prefix Declaration Bug - Proposal

**Date**: November 27, 2024  
**Project**: Uniword (using lutaml-model v0.7+)  
**Issue**: Namespace prefixes used in child element attributes are not declared in root element

---

## Problem Statement

When lutaml-model serializes XML with namespace prefixes on attributes, it does not emit the required namespace prefix binding (xmlns:prefix="uri") in the XML output. This causes deserialization to fail because parsers cannot resolve the prefixed attributes.

## Reproducible Test Case

```ruby
require 'lutaml/model'

# Define namespace
class WordProcessingML < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix_default 'w'
  attribute_form_default :qualified
end

# Parent class uses namespace
class Document < Lutaml::Model::Serializable
  attribute :body, Body
  
  xml do
    root 'document'
    namespace WordProcessingML
    map_element 'body', to: :body
  end
end

# Child class with prefixed attributes
class Border < Lutaml::Model::Serializable
  attribute :color, :string
  
  xml do
    element 'top'
    namespace WordProcessingML
    map_attribute 'color', to: :color
  end
end

# Create and serialize
doc = Document.new
doc.body = Body.new
# ... add borders etc

xml = doc.to_xml
puts xml
```

### Current Output (BROKEN)

```xml
<document xmlns="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <body>
    <pBdr>
      <top w:color="FF0000"/>
                  <!-- ↑ Prefix 'w' used but NOT declared! -->
    </pBdr>
  </body>
</document>
```

### Expected Output (CORRECT)

```xml
<document xmlns="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
          xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <body>
    <pBdr>
      <top w:color="FF0000"/>
           <!-- ↑ Now valid because w: is declared -->
    </pBdr>
  </body>
</document>
```

OR (as real Word documents do):

```xml
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:pBdr>
      <w:top w:color="FF0000"/>
    </w:pBdr>
  </w:body>
</w:document>
```

## Impact

This bug affects **any** lutaml-model class hierarchy where:
1. Parent uses default namespace
2. Child attributes use prefixed form
3. Namespace declares `attribute_form_default :qualified`

In Uniword, this breaks deserialization for:
- Paragraph borders (11 attributes not loading)
- Paragraph shading (9 attributes not loading)
- Tab stops (3 attributes not loading)
- Character spacing, kerning, position (9 wrapper classes broken)
- Emphasis marks, language settings (6 more affected)

**Total**: 15+ classes, 35+ attributes affected

## Root Cause Analysis

When lutaml-model serializes:
1. It correctly determines attributes need the `w:` prefix (from `attribute_form_default :qualified`)
2. It emits `w:color="FF0000"` in child elements
3. **BUT** it doesn't track which prefixes are used and emit their xmlns declarations in the root

The framework needs to:
1. Track all namespace prefixes used during serialization
2. Emit xmlns:prefix declarations in the root element
3. OR use the prefix for ALL elements and attributes consistently

## Proposed Solution

### Option 1: Auto-collect and declare used prefixes (PREFERRED)

During serialization, collect all namespace prefixes actually used, then emit their declarations in root:

```ruby
class XmlSerializer
  def serialize(object)
    @used_prefixes = Set.new
    xml = build_xml(object)  # Tracks prefixes during build
    
    # Add xmlns declarations for all used prefixes
    @used_prefixes.each do |prefix, uri|
      xml.root.add_namespace_definition(prefix, uri)
    end
    
    xml
  end
end
```

### Option 2: Explicit prefix declaration in model

Allow models to explicitly declare which prefixes they need:

```ruby
class Document < Lutaml::Model::Serializable
  xml do
    root 'document'
    namespace WordProcessingML
    namespace WordProcessingML, prefix: 'w'  # Explicit prefix binding
    map_element 'body', to: :body
  end
end
```

### Option 3: Use prefix everywhere consistently

If a namespace has `prefix_default 'w'`, use it for **all** elements and attributes:

```xml
<w:document xmlns:w="...">
  <w:body>
    <w:pBdr>
      <w:top w:color="..."/>
    </w:pBdr>
  </w:body>
</w:document>
```

## Testing Strategy

Add to lutaml-model test suite:

```ruby
RSpec.describe "Namespace prefix declarations" do
  it "declares prefixes used in child attributes" do
    doc = Document.new
    doc.body.borders.top.color = "FF0000"
    
    xml = doc.to_xml
    
    # Must have xmlns:w declaration
    expect(xml).to include('xmlns:w="http://schemas...')
    
    # Round-trip must work
    loaded = Document.from_xml(xml)
    expect(loaded.body.borders.top.color).to eq("FF0000")
  end
end
```

## Workaround (Temporary)

Until fixed in lutaml-model, Uniword can post-process XML:

```ruby
class Document
  def to_xml(*args)
    xml = super
    
    # Add missing namespace declarations
    doc = Nokogiri::XML(xml)
    root = doc.root
    
    unless root['xmlns:w']
      root.add_namespace_definition('w', WordProcessingML.uri)
    end
    
    doc.to_xml
  end
end
```

## Related Issues

- Uniword issue #XXX: Enhanced properties deserialization
- Similar issues may exist for:
  - DrawingML (wp:, a: prefixes)
  - MathML (m: prefix)
  - Relationships (r: prefix)

## References

- **OOXML Spec**: ISO/IEC 29500-1:2016
- **XML Namespaces**: https://www.w3.org/TR/xml-names/
- **Uniword Test Case**: `spec/uniword/enhanced_properties_roundtrip_spec.rb`

## Request

Please prioritize this fix as it blocks critical functionality in production systems. The bug affects any OOXML-compliant application using lutaml-model for XML serialization.

---

**Uniword Contact**: [maintainer email]  
**Lutaml-Model Version**: 0.7.x  
**Ruby Version**: 2.7+