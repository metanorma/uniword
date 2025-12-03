# Lutaml-Model Nested Serialization: Implementation Guide

## Overview

This document provides a technical implementation roadmap for adding nested object serialization to lutaml-model.

## Current Architecture

### Serialization Flow

```
Model.to_xml
  → Xml::Transform.serialize
    → Xml::Adapter.build_element
      → For each attribute:
        → Get value from model
        → Serialize value (PROBLEM: only handles primitives)
```

### Key Classes

1. **`Lutaml::Model::Serializable`** - Base class for all models
2. **`Lutaml::Model::Xml::Transform`** - XML serialization logic
3. **`Lutaml::Model::Xml::Mapping`** - Element/attribute mappings
4. **`Lutaml::Model::Xml::Adapter::*`** - XML builder adapters (Nokogiri, Ox, Oga)

## Problem Location

The issue is in how mapped elements are serialized. Currently:

```ruby
# Pseudocode of current logic
def serialize_element(element_name, value)
  if value.nil?
    return nil if render_nil == false
  end

  # PROBLEM: Only primitive serialization
  builder.element(element_name) do
    builder.text(value.to_s)
  end
end
```

## Proposed Solution

### Phase 1: Detection

Add logic to detect if a value is a nested Serializable:

```ruby
def serialize_element(element_name, value, mapping)
  return nil if value.nil? && !mapping.render_nil?

  # NEW: Check if nested serializable
  if value.is_a?(Lutaml::Model::Serializable)
    serialize_nested_object(element_name, value, mapping)
  elsif value.is_a?(Array)
    serialize_collection(element_name, value, mapping)
  else
    serialize_primitive(element_name, value, mapping)
  end
end
```

### Phase 2: Nested Serialization

```ruby
def serialize_nested_object(element_name, object, mapping)
  # Get the nested object's XML mapping
  nested_mapping = object.class.xml_mapping

  # OPTION A: Inline the nested object's elements
  if mapping.inline?
    # Don't create wrapper element, just serialize children
    serialize_nested_children(object, nested_mapping)
  else
    # OPTION B: Create wrapper element with nested content
    builder.element(element_name, namespace: mapping.namespace) do
      # Serialize all attributes of the nested object
      nested_mapping.attributes.each do |attr_mapping|
        attr_value = object.send(attr_mapping.to)
        serialize_attribute(attr_mapping.name, attr_value, attr_mapping)
      end

      # Serialize all elements of the nested object
      nested_mapping.elements.each do |elem_mapping|
        elem_value = object.send(elem_mapping.to)
        serialize_element(elem_mapping.name, elem_value, elem_mapping)
      end
    end
  end
end
```

### Phase 3: Collection Handling

```ruby
def serialize_collection(element_name, array, mapping)
  array.each do |item|
    if item.is_a?(Lutaml::Model::Serializable)
      serialize_nested_object(element_name, item, mapping)
    else
      serialize_primitive(element_name, item, mapping)
    end
  end
end
```

## Mapping Options

### New `map_element` Options

```ruby
class RunProperties < Lutaml::Model::Serializable
  xml do
    map_element 'spacing', to: :character_spacing,
                delegate: true,        # Enable nested serialization
                inline: false,         # Create wrapper element (default)
                render_nil: false,     # Don't render if nil (default: true)
                render_empty: false    # Don't render if empty collection
  end

  attribute :character_spacing, CharacterSpacing
end
```

### Implementation in `Xml::MappingRule`

```ruby
class MappingRule
  attr_reader :delegate, :inline, :render_nil, :render_empty

  def initialize(name, to:, delegate: false, inline: false,
                 render_nil: true, render_empty: true)
    @name = name
    @to = to
    @delegate = delegate
    @inline = inline
    @render_nil = render_nil
    @render_empty = render_empty
  end

  def should_serialize?(value)
    return false if value.nil? && !render_nil
    return false if value.respond_to?(:empty?) && value.empty? && !render_empty
    true
  end
end
```

## Namespace Handling

### Problem: Namespace Propagation

When serializing nested objects, ensure the correct namespace is used:

```ruby
def serialize_nested_object(element_name, object, mapping)
  # Determine namespace for the element
  element_ns = mapping.namespace || object.class.xml_mapping.namespace

  builder.element(element_name, namespace: element_ns) do
    # Use the NESTED object's namespace for its children
    nested_ns = object.class.xml_mapping.namespace

    # ... serialize with nested_ns ...
  end
end
```

### Example

```ruby
class RunProperties < Lutaml::Model::Serializable
  xml do
    element 'rPr'
    namespace WordProcessingML  # w: namespace
    map_element 'spacing', to: :character_spacing, delegate: true
  end
end

class CharacterSpacing < Lutaml::Model::Serializable
  xml do
    element 'spacing'
    namespace WordProcessingML  # Also w: namespace
    map_attribute 'val', to: :val
  end
end

# Should produce:
# <w:rPr xmlns:w="...">
#   <w:spacing w:val="20"/>
# </w:rPr>
```

## Edge Cases

### 1. Circular References

**Problem**: A → B → A causes infinite recursion

**Solution**: Track serialization depth or visited objects

```ruby
def serialize_element(element_name, value, mapping, context = {})
  depth = context[:depth] || 0

  if depth > MAX_NESTING_DEPTH
    raise SerializationError, "Maximum nesting depth exceeded"
  end

  if value.is_a?(Lutaml::Model::Serializable)
    object_id = value.object_id
    if context[:visited]&.include?(object_id)
      raise SerializationError, "Circular reference detected"
    end

    new_context = context.merge(
      depth: depth + 1,
      visited: (context[:visited] || Set.new).add(object_id)
    )

    serialize_nested_object(element_name, value, mapping, new_context)
  end
end
```

### 2. Mixed Content

**Problem**: Element with both text and nested elements

```xml
<w:p>
  Some text
  <w:pPr>...</w:pPr>
  More text
</w:p>
```

**Solution**: Use existing `mixed_content` flag

```ruby
def serialize_mixed_content(object)
  if object.class.xml_mapping.mixed_content?
    # Serialize in document order
    object.ordered_content.each do |item|
      if item.is_a?(String)
        builder.text(item)
      elsif item.is_a?(Lutaml::Model::Serializable)
        serialize_nested_object(item.class.element_name, item, ...)
      end
    end
  end
end
```

### 3. Attribute vs Element Objects

**Problem**: Some nested objects should serialize as attributes, not elements

```xml
<!-- Element style -->
<w:rPr>
  <w:spacing w:val="20"/>
</w:rPr>

<!-- Attribute style (NOT supported, but show how to handle) -->
<w:rPr spacing="20"/>
```

**Solution**: Keep separate - attributes are always primitives

## Testing Strategy

### Unit Tests

```ruby
describe "Nested Object Serialization" do
  it "serializes single-level nested objects" do
    parent = Parent.new(child: Child.new(value: "test"))
    xml = parent.to_xml

    expect(xml).to include("<child>")
    expect(xml).to include("<value>test</value>")
  end

  it "serializes multi-level nested objects" do
    parent = Parent.new(
      child: Child.new(
        grandchild: GrandChild.new(value: "deep")
      )
    )
    xml = parent.to_xml

    expect(xml).to include("<child>")
    expect(xml).to include("<grandchild>")
    expect(xml).to include("<value>deep</value>")
  end

  it "serializes collections of nested objects" do
    parent = Parent.new(
      children: [
        Child.new(value: "one"),
        Child.new(value: "two")
      ]
    )
    xml = parent.to_xml

    expect(xml.scan(/<child>/).count).to eq(2)
  end

  it "respects render_nil: false for nested objects" do
    parent = Parent.new(child: nil)
    xml = parent.to_xml

    expect(xml).not_to include("<child")
  end

  it "propagates namespaces correctly" do
    parent = Parent.new(child: Child.new(value: "test"))
    xml = parent.to_xml
    doc = Nokogiri::XML(xml)

    child_elem = doc.at_xpath("//p:child", "p" => PARENT_NS)
    expect(child_elem).not_to be_nil
    expect(child_elem.namespace.href).to eq(PARENT_NS)
  end
end
```

### Integration Tests

Test with real OOXML structures from Uniword:

```ruby
it "serializes RunProperties with CharacterSpacing" do
  run = Run.new(text: "Test")
  run.character_spacing = 20

  xml = run.to_xml
  doc = Nokogiri::XML(xml)

  spacing = doc.at_xpath("//w:spacing", "w" => WORDML_NS)
  expect(spacing).not_to be_nil
  expect(spacing["w:val"]).to eq("20")
end

it "serializes ParagraphProperties with Borders" do
  para = Paragraph.new
  para.set_borders(top: "000000", bottom: "FF0000")

  xml = para.to_xml
  doc = Nokogiri::XML(xml)

  borders = doc.at_xpath("//w:pBdr", "w" => WORDML_NS)
  expect(borders).not_to be_nil

  top = borders.at_xpath("w:top", "w" => WORDML_NS)
  expect(top["w:color"]).to eq("000000")
end
```

## Performance Considerations

### 1. Caching

Cache the nested object's XML mapping to avoid repeated lookups:

```ruby
def nested_mapping(object)
  @nested_mappings ||= {}
  @nested_mappings[object.class] ||= object.class.xml_mapping
end
```

### 2. Lazy Serialization

Only serialize nested objects if they have content:

```ruby
def has_content?(object)
  return false if object.nil?
  return false if object.respond_to?(:empty?) && object.empty?

  # For Serializable objects, check if any attributes have values
  if object.is_a?(Lutaml::Model::Serializable)
    object.class.attributes.any? do |attr|
      value = object.send(attr.name)
      !value.nil? && (!value.respond_to?(:empty?) || !value.empty?)
    end
  else
    true
  end
end
```

### 3. Builder Optimization

Reuse the same XML builder instead of creating new ones:

```ruby
def serialize_nested_object(element_name, object, mapping, builder)
  # Reuse existing builder, don't create new one
  builder.element(element_name) do
    # ... serialize into same builder ...
  end
end
```

## Backward Compatibility

### Migration Path

1. **Phase 1**: Add opt-in flag (v0.8.0)
   ```ruby
   class MyModel < Lutaml::Model::Serializable
     xml do
       element 'root'
       auto_serialize_nested true  # Opt-in
     end
   end
   ```

2. **Phase 2**: Make delegate explicit (v0.9.0)
   ```ruby
   map_element 'child', to: :child_obj, delegate: true
   ```

3. **Phase 3**: Enable by default (v1.0.0)
   - Auto-detect Serializable objects
   - Deprecate manual delegation

### Deprecation Warnings

```ruby
if mapping.delegate? && !value.is_a?(Lutaml::Model::Serializable)
  warn "[DEPRECATION] delegate: true used with non-Serializable value"
end
```

## Documentation Updates

### API Documentation

Add to `Lutaml::Model::Serializable` docs:

```ruby
# Nested Object Serialization
#
# When an attribute is itself a Serializable object, it will be
# automatically serialized as a nested element:
#
# @example
#   class Address < Lutaml::Model::Serializable
#     attribute :street, :string
#     attribute :city, :string
#   end
#
#   class Person < Lutaml::Model::Serializable
#     attribute :name, :string
#     attribute :address, Address
#   end
#
#   person = Person.new(
#     name: "John",
#     address: Address.new(street: "123 Main St", city: "NYC")
#   )
#
#   person.to_xml
#   # <person>
#   #   <name>John</name>
#   #   <address>
#   #     <street>123 Main St</street>
#   #     <city>NYC</city>
#   #   </address>
#   # </person>
```

### Migration Guide

Document in `CHANGELOG.md` and `UPGRADING.md`:

```markdown
## v0.8.0

### New Features

- **Nested Object Serialization**: Serializable objects as attributes
  now automatically serialize as nested XML elements.

### Breaking Changes

None (opt-in via `auto_serialize_nested` flag)

### Migration

If you have nested Serializable objects, enable automatic serialization:

```ruby
xml do
  auto_serialize_nested true
end
```
```

## Timeline

- **Research & Design**: 1 week
- **Implementation**: 2-3 weeks
- **Testing**: 1 week
- **Documentation**: 1 week
- **Total**: 5-6 weeks

## Success Criteria

1. ✅ All 22 Uniword enhanced properties tests pass
2. ✅ No performance regression (< 5% slower)
3. ✅ 100% backward compatible with opt-in
4. ✅ Comprehensive test coverage (> 95%)
5. ✅ Complete documentation with examples
6. ✅ Support for all XML adapters (Nokogiri, Ox, Oga)

## References

- Uniword test file: `spec/uniword/enhanced_properties_xml_spec.rb`
- Current lutaml-model: https://github.com/lutaml/lutaml-model
- OOXML Spec: ISO/IEC 29500