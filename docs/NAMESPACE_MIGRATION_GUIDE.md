# Namespace Migration Guide

**Purpose**: Migrate Uniword from placeholder-based namespace workaround to lutaml-model native namespace support

**Date**: 2025-11-13
**Status**: Implementation Guide
**Target**: Week 2 Days 1-3

---

## Background

### Current Approach (Placeholder-Based)

**Problem**: Nokogiri's XML Builder applies parent element's namespace to all children, breaking namespace preservation.

**Current Workaround** in [`lib/uniword/serialization/ooxml_serializer.rb`](../lib/uniword/serialization/ooxml_serializer.rb:167-206):

```ruby
# Insert placeholder comment
placeholder_id = "UNIWORD_PLACEHOLDER_#{rand(1000000)}"
xml.parent << xml.doc.create_comment(placeholder_id)

# Store raw XML
@raw_xml_placeholders ||= {}
@raw_xml_placeholders[placeholder_id] = raw_xml

# Later replace placeholders
xml_string.gsub!("<!--#{placeholder_id}-->", raw_xml)
```

**Issues:**
- Hacky workaround
- Not using lutaml-model's native capabilities
- Hard to maintain
- Doesn't leverage W3C XML C14N

### Target Approach (Native Namespaces)

**Solution**: Use lutaml-model's native namespace support via XML mapping blocks.

---

## Lutaml-Model Namespace API

### Pattern 1: Simple Namespace Declaration

```ruby
class Document < Lutaml::Model::Serializable
  xml do
    root 'document'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    # Child elements automatically get 'w' prefix
    map_element 'body', to: :body
  end
end
```

**Generates:**
```xml
<w:document xmlns:w="http://...">
  <w:body>...</w:body>
</w:document>
```

### Pattern 2: Multiple Namespaces

```ruby
class Drawing < Lutaml::Model::Serializable
  xml do
    root 'drawing'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    # Element from different namespace
    map_element 'inline', to: :inline,
      namespace: 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
      prefix: 'wp'
  end
end
```

**Generates:**
```xml
<w:drawing xmlns:w="http://...">
  <wp:inline xmlns:wp="http://...">...</wp:inline>
</w:drawing>
```

### Pattern 3: Namespace Inheritance

```ruby
class Paragraph < Lutaml::Model::Serializable
  xml do
    root 'p'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    map_element 'pPr', to: :properties  # Inherits 'w' namespace
    map_element 'r', to: :runs           # Inherits 'w' namespace
  end
end
```

---

## OOXML Namespace Registry

Created in [`lib/uniword/ooxml/namespaces.rb`](../lib/uniword/ooxml/namespaces.rb):

```ruby
module Uniword
  module Ooxml
    module Namespaces
      # WordProcessingML Main (w:)
      WORDPROCESSINGML = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

      # Office Math Markup Language (m:) - CRITICAL for ISO docs
      MATHML = 'http://schemas.openxmlformats.org/officeDocument/2006/math'

      # DrawingML WordProcessing Drawing (wp:)
      WORDPROCESSING_DRAWING = 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing'

      # DrawingML Main (a:)
      DRAWINGML = 'http://schemas.openxmlformats.org/drawingml/2006/main'

      # Relationships (r:)
      RELATIONSHIPS = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'

      # VML (v:) - Legacy
      VML = 'urn:schemas-microsoft-com:vml'

      # XML (xml:)
      XML = 'http://www.w3.org/XML/1998/namespace'
    end
  end
end
```

---

## Migration Strategy

### Phase 1: Core Elements (Completed in Week 1)

**Status**: ✅ Done

**Files migrated:**
- [`lib/uniword/style.rb`](../lib/uniword/style.rb:16-18)
- [`lib/uniword/properties/paragraph_properties.rb`](../lib/uniword/properties/paragraph_properties.rb:14-16)
- [`lib/uniword/properties/run_properties.rb`](../lib/uniword/properties/run_properties.rb:14-16)

**Pattern Used:**
```ruby
xml do
  root 'element-name'
  namespace 'http://schema-uri', 'prefix'
  # Mappings...
end
```

### Phase 2: Math Elements (Week 2 Day 2)

**Goal**: Fix `Failed to parse QName 'w:m:oMath'` error from ISO 8601 documents

**Files to create:**
```
lib/uniword/math/
  ├── math_element.rb    # Base class
  ├── o_math.rb          # m:oMath container
  ├── o_math_para.rb     # m:oMathPara
  ├── math_run.rb        # m:r
  └── math_text.rb       # m:t
```

**Implementation:**
```ruby
# lib/uniword/math/o_math.rb
module Uniword
  module Math
    class OMath < Element
      xml do
        root 'oMath'
        namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

        map_element 'r', to: :runs
        map_element 'oMathPara', to: :para
      end

      attribute :runs, MathRun, collection: true
      attribute :para, OMathPara
    end
  end
end
```

### Phase 3: Bookmark Elements (Week 2 Day 3)

**Goal**: Convert bookmarkStart/bookmarkEnd from UnknownElement to proper models

**Files to create:**
```
lib/uniword/
  ├── bookmark_start.rb
  └── bookmark_end.rb
```

**Implementation:**
```ruby
# lib/uniword/bookmark_start.rb
module Uniword
  class BookmarkStart < Element
    xml do
      root 'bookmarkStart'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_attribute 'id', to: :bookmark_id
      map_attribute 'name', to: :name
      map_attribute 'colFirst', to: :col_first
      map_attribute 'colLast', to: :col_last
    end

    attribute :bookmark_id, :string
    attribute :name, :string
    attribute :col_first, :integer
    attribute :col_last, :integer
  end
end
```

### Phase 4: Document & Body (Week 2 Day 3)

**Files to update:**
- [`lib/uniword/document.rb`](../lib/uniword/document.rb:58-65) - Already has namespace declarations ✅
- [`lib/uniword/body.rb`](../lib/uniword/body.rb) - Check namespace setup

---

## Testing Strategy

### Approach 1: Canon-Based Semantic XML Comparison

**Use for**: Round-trip validation where formatting may differ

```ruby
require 'canon/rspec_matchers'

RSpec.describe 'Round-Trip' do
  it 'preserves XML semantically' do
    original_xml = File.read('spec/fixtures/input.xml')

    # Parse → Modify → Serialize
    doc = parse(original_xml)
    generated_xml = serialize(doc)

    # Semantic comparison (ignores whitespace, attribute order)
    expect(generated_xml).to be_xml_equivalent_to(original_xml)
  end
end
```

### Approach 2: Unknown Element Preservation

**Use for**: Elements we don't fully support yet

```ruby
class UnknownElement < Element
  # Stores raw XML
  attribute :raw_xml, :string

  def to_xml
    raw_xml  # Return as-is
  end
end
```

### Approach 3: Byte-Level Comparison

**Use for**: Final validation of perfect round-trip

```ruby
it 'generates byte-perfect XML' do
  # Only after all elements properly modeled
  expect(generated_xml).to eq(original_xml)
end
```

---

## Common Patterns

### Pattern: Element with Simple Namespace

```ruby
class Paragraph < Element
  xml do
    root 'p'
    namespace Ooxml::Namespaces::WORDPROCESSINGML, 'w'

    map_element 'pPr', to: :properties
    map_element 'r', to: :runs
  end
end
```

### Pattern: Element with Multiple Child Namespaces

```ruby
class Run < Element
  xml do
    root 'r'
    namespace Ooxml::Namespaces::WORDPROCESSINGML, 'w'

    # Most children inherit 'w' namespace
    map_element 'rPr', to: :properties
    map_element 't', to: :text

    # Drawing element uses different namespace
    map_element 'drawing', to: :drawing,
      namespace: Ooxml::Namespaces::WORDPROCESSING_DRAWING,
      prefix: 'wp'
  end
end
```

### Pattern: Attribute with Different Namespace

```ruby
class TextElement < Element
  xml do
    root 't'
    namespace Ooxml::Namespaces::WORDPROCESSINGML, 'w'

    map_content to: :content

    # xml:space attribute uses XML namespace
    map_attribute 'space', to: :space,
      namespace: Ooxml::Namespaces::XML,
      prefix: 'xml'
  end
end
```

---

## Migration Checklist

### Week 2 Day 1: Setup
- [x] Create [`lib/uniword/ooxml/namespaces.rb`](../lib/uniword/ooxml/namespaces.rb)
- [x] Update [`Gemfile`](../Gemfile) with local lutaml-model
- [ ] Document migration patterns (this file)
- [ ] Identify all elements needing migration

### Week 2 Day 2: Math Namespace
- [ ] Create Math element classes with m: namespace
- [ ] Add Math namespace to deserializer
- [ ] Test with ISO 8601 documents
- [ ] Verify no `w:m:oMath` errors

### Week 2 Day 3: Bookmarks
- [ ] Create BookmarkStart/BookmarkEnd classes
- [ ] Remove from UnknownElement handling
- [ ] Add to KNOWN_PARAGRAPH_ELEMENTS
- [ ] Test bookmark preservation

### Week 2 Days 4-5: ISO 8601 Testing
- [ ] Round-trip `iso-wd-8601-2-2026.docx` (Math equations)
- [ ] Round-trip `document.doc` (MHTML, fix 92.7% size loss)
- [ ] Verify all elements preserved
- [ ] Canon-based XML equivalence tests

---

## Success Criteria

### Math Namespace Working When:
- [ ] Can load `iso-wd-8601-2-2026.docx` without XML errors
- [ ] Math equations round-trip perfectly
- [ ] No UnknownElements for m: namespace elements

### Bookmark Elements Working When:
- [ ] BookmarkStart/BookmarkEnd are known elements
- [ ] Round-trip preserves bookmark structure
- [ ] No UnknownElements for w:bookmarkStart/End

### Week 2 Complete When:
- [ ] ISO 8601 documents round-trip < 5% size difference
- [ ] Zero critical UnknownElements
- [ ] All Canon-based tests passing
- [ ] Namespace architecture documented

---

## Next Steps

**Starting Now**: Week 2 Day 1
1. Review lutaml-model namespace documentation (done)
2. Create this migration guide (done)
3. Begin Math namespace implementation

**This guide provides the roadmap for completing namespace migration.**