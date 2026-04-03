# TODO: lutaml-model Namespace Handling Proposal

## Status: PENDING - Awaiting lutaml-model Team Review

## Problem Statement

When parsing XML documents with elements in multiple namespaces (like OOXML Core Properties),
elements with namespace prefixes are not being correctly deserialized to their attributes.

### Example

```xml
<cp:coreProperties
  xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:title>Round Trip Test</dc:title>
</cp:coreProperties>
```

The `dc:title` element is not being mapped to the `title` attribute.

### Current Architecture

```ruby
# Uniword uses Type classes that extend Lutaml::Model::Type::String
class DcTitleType < Lutaml::Model::Type::String
  # Cannot declare namespace - Type::String is not a Serializable model
end

# CoreProperties tries to use namespace_scope for serialization
class CoreProperties < Lutaml::Model::Serializable
  attribute :title, Types::DcTitleType

  xml do
    element 'coreProperties'
    namespace Namespaces::CoreProperties

    # This only affects serialization (hoisting), not parsing
    namespace_scope [
      { namespace: Namespaces::DublinCore, declare: :always }
    ]

    # No way to specify that 'title' should match 'dc:title' from DublinCore namespace
    map_element 'title', to: :title
  end
end
```

## Root Cause

1. `namespace_scope` only affects **serialization** (hoisting namespace declarations to root)
2. `map_element` cannot specify a target namespace for **deserialization**
3. Type::Value classes (like Type::String subclasses) cannot declare their XML namespace

## Proposed Solutions

### Option A: Allow `map_element` to specify namespace for parsing (RECOMMENDED)

Add a `parse_namespace` parameter to `map_element`:

```ruby
xml do
  map_element 'title', to: :title,
             parse_namespace: Namespaces::DublinCore
end
```

This would:
- During parsing: Match `<dc:title>` (where dc is bound to DublinCore namespace)
- During serialization: Use the model class's declared namespace

### Option B: Allow Type::Value classes to declare namespace

```ruby
class DcTitleType < Lutaml::Model::Type::String
  xml_namespace Namespaces::DublinCore, prefix: 'dc'
end
```

This would require:
- Adding `xml_namespace` class method to `Type::Value`
- Updating XML parser to check attribute type for namespace

### Option C: Explicit namespace mapping with prefix

Allow namespace to be specified with a prefix hint:

```ruby
xml do
  map_element 'dc:title', to: :title,
             namespaces: {
               'dc' => Namespaces::DublinCore
             }
end
```

## Impact Analysis

### Affected OOXML Classes

All classes with mixed-namespace child elements:

1. **CoreProperties** - dc:title, dc:creator, dcterms:created, etc.
2. **AppProperties** - Similar pattern
3. **Any class using namespace_scope** - Currently only affects serialization

### Current Workaround

None - tests are skipped/pending for this functionality.

## Recommendation

**Option A** is recommended because:
1. Most explicit and clear
2. Doesn't change Type::Value semantics
3. Backward compatible
4. Allows per-element namespace control

## Test Case

```ruby
# spec/lutaml/xml/multi_namespace_parsing_spec.rb
RSpec.describe 'Multi-namespace XML parsing' do
  let(:xml) do
    <<~XML
      <root xmlns:ns1="http://example.org/ns1" xmlns:ns2="http://example.org/ns2">
        <ns1:element>Value from ns1</ns1:element>
        <ns2:element>Value from ns2</ns2:element>
      </root>
    XML
  end

  class Ns1Type < Lutaml::Model::Type::String; end
  class Ns2Type < Lutaml::Model::Type::String; end

  class MultiNsDoc < Lutaml::Model::Serializable
    attribute :ns1_element, Ns1Type
    attribute :ns2_element, Ns2Type

    xml do
      element 'root'
      namespace 'http://example.org/root'

      map_element 'element', to: :ns1_element,
                 parse_namespace: 'http://example.org/ns1'
      map_element 'element', to: :ns2_element,
                 parse_namespace: 'http://example.org/ns2'
    end
  end

  it 'parses elements from different namespaces with same local name' do
    doc = MultiNsDoc.from_xml(xml)
    expect(doc.ns1_element).to eq('Value from ns1')
    expect(doc.ns2_element).to eq('Value from ns2')
  end
end
```

## Questions for lutaml-model Team

1. Is `parse_namespace` the right parameter name?
2. Should this also affect serialization, or only parsing?
3. How should this interact with `namespace_scope`?
4. Should we support both URI and XmlNamespace class as values?

## Timeline

- **Needed by**: 2026-03-20
- **Blocking**: 33+ spec failures in Uniword related to XML round-trip fidelity
