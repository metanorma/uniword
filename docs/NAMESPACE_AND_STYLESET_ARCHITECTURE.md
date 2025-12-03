
# Uniword: Namespace Support & StyleSet Completion Architecture

**Version:** 1.0.0
**Date:** 2025-11-13
**Status:** Implementation Plan (Ready to Execute)

---

## Executive Summary

With **lutaml-model v0.7+ now supporting native XML namespaces**, we can:

1. **Complete StyleSet implementation** - Full OOXML property parsing and serialization
2. **Eliminate namespace workarounds** - Replace placeholder-based approach with native namespace declarations
3. **Fix ISO 8601 round-trip** - Handle Math equations (`m:` namespace) and Bookmarks properly
4. **Enable V2.0.0** - Foundation for schema-driven OOXML architecture

**Timeline:** 2 weeks + V2.0.0 (8 weeks)

---

## Part 1: Current State Analysis

### ✅ Completed Components

#### 1. Theme System (COMPLETE)
- **Files:** `lib/uniword/theme/theme_package_reader.rb`, `theme_xml_parser.rb`, `theme_loader.rb`, `theme_applicator.rb`, `theme_variant.rb`
- **Capability:** Load .thmx files, apply themes with variants, YAML import complete
- **Status:** Production ready, all tests passing

#### 2. StyleSet Infrastructure (75% COMPLETE)
- **Files:** `lib/uniword/styleset.rb`, `stylesets/styleset_package_reader.rb`, `styleset_xml_parser.rb`, `styleset_loader.rb`, `yaml_styleset_loader.rb`, `styleset_importer.rb`
- **Capability:** Load .dotx files, extract style metadata, YAML import infrastructure
- **Missing:** Property parsing (paragraph, run, table properties) + OOXML serialization

#### 3. Namespace Workaround (FUNCTIONAL BUT HACKY)
- **Current Approach:** Placeholder-based (`<!-- PLACEHOLDER_xxx -->`) for preserving namespaces
- **Works for:** Charts (`c:`), Diagrams (`dgm:`), Drawing (`wp:`)
- **Issue:** Not using lutaml-model's native namespace support

### ❌ Critical Gaps

#### 1. StyleSet Property Parsing
**Problem:** [`StyleSetXmlParser`](../lib/uniword/stylesets/styleset_xml_parser.rb:40) only parses basic metadata:
```ruby
# Currently parses:
style.type, style.id, style.name, style.based_on, style.next_style, style.ui_priority

# MISSING: Actual properties from XML
w:pPr → ParagraphProperties (alignment, spacing, borders, shading, etc.)
w:rPr → RunProperties (fonts, colors, bold, italic, size, etc.)
w:tblPr → TableProperties (borders, width, spacing, etc.)
```

#### 2. StyleSet OOXML Serialization
**Problem:** Cannot serialize complete style definitions to `styles.xml`
- [`Style`](../lib/uniword/style.rb) model lacks property attributes
- No OOXML serialization for style properties in [`OoxmlSerializer`](../lib/uniword/serialization/ooxml_serializer.rb)

#### 3. Namespace Architecture
**Problem:** Not using lutaml-model native namespace support
- **Math namespace (`m:`)** - Causes `Failed to parse QName 'w:m:oMath'` error
- **Bookmarks** - Still `UnknownElement` instead of proper models
- **All models** - Using placeholder workaround instead of native declarations

#### 4. ISO 8601 Round-Trip Failures
**Problem:** Documents cannot round-trip perfectly
- **iso-wd-8601-2-2026.docx (295KB)** - XML parsing error on Math equations
- **document.doc (985KB MHTML)** - 92.7% size loss (985KB → 72KB)

---

## Part 2: Lutaml-Model Namespace API

### Native Namespace Support (v0.7+)

Based on [`/Users/mulgogi/src/lutaml/lutaml-model/README.adoc`](../Users/mulgogi/src/lutaml/lutaml-model/README.adoc), lutaml-model now supports:

#### 1. Root Namespace Declaration

```ruby
class Document < Lutaml::Model::Serializable
  xml do
    root 'document'
    # Default namespace (no prefix)
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

    # Or with prefix
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
  end
end
```

#### 2. Element-Level Namespace Override

```ruby
class Paragraph < Lutaml::Model::Serializable
  xml do
    root 'p'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    # Element with different namespace
    map_element 'math', to: :math,
      namespace: 'http://schemas.openxmlformats.org/officeDocument/2006/math',
      prefix: 'm'
  end
end
```

#### 3. Namespace Inheritance

```ruby
xml do
  map_element 'type', to: :type, namespace: :inherit  # Inherits parent namespace
end
```

#### 4. XmlNamespace Class (Declarative Approach)

```ruby
class WordProcessingNamespace < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  schema_location 'http://schemas.openxmlformats.org/...xsd'
  prefix_default 'w'
  element_form_default :qualified
  attribute_form_default :unqualified
  documentation "WordProcessingML Main Namespace"
end

class Document < Lutaml::Model::Serializable
  xml do
    element 'document'
    namespace WordProcessingNamespace  # Clean declarative usage
  end
end
```

### OOXML Namespace Registry

All OOXML namespaces that need support:

```ruby
# lib/uniword/ooxml/namespaces.rb (to be created)
module Uniword
  module Ooxml
    module Namespaces
      # WordProcessingML Main
      class WordProcessingML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        prefix_default 'w'
        element_form_default :qualified
      end

      # Office Math Markup Language (CRITICAL for ISO docs)
      class MathML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/math'
        prefix_default 'm'
        documentation "Office Math Markup Language"
      end

      # DrawingML - WordProcessing Drawing
      class WordProcessingDrawing < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing'
        prefix_default 'wp'
      end

      # DrawingML - Main
      class DrawingML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/main'
        prefix_default 'a'
      end

      # Relationships
      class Relationships < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
        prefix_default 'r'
      end

      # VML (Legacy)
      class VML < Lutaml::Model::XmlNamespace
        uri 'urn:schemas-microsoft-com:vml'
        prefix_default 'v'
      end
    end
  end
end
```

---

## Part 3: Two-Week Implementation Plan

### Week 1: StyleSet Full Implementation

#### Day 1-2: Complete Property Parsing

**Goal:** Parse ALL OOXML style properties from `word/styles.xml`

**Files to modify:**
1. [`lib/uniword/stylesets/styleset_xml_parser.rb`](../lib/uniword/stylesets/styleset_xml_parser.rb:40)
2. [`lib/uniword/style.rb`](../lib/uniword/style.rb:23)

**Implementation:**

```ruby
# In StyleSetXmlParser
def parse_style_node(style_node)
  style = Style.new

  # Existing metadata parsing...
  style.type = style_node['w:type']
  style.id = style_node['w:styleId']
  # ...

  # NEW: Parse properties
  pPr_node = style_node.at_xpath('./w:pPr', WORDML_NS)
  if pPr_node
    style.paragraph_properties = parse_paragraph_properties(pPr_node)
  end

  rPr_node = style_node.at_xpath('./w:rPr', WORDML_NS)
  if rPr_node
    style.run_properties = parse_run_properties(rPr_node)
  end

  tblPr_node = style_node.at_xpath('./w:tblPr', WORDML_NS)
  if tblPr_node
    style.table_properties = parse_table_properties(tblPr_node)
  end

  style
end

private

# Parse w:pPr (Paragraph Properties)
def parse_paragraph_properties(pPr_node)
  require_relative '../properties/paragraph_properties'

  props = Properties::ParagraphProperties.new

  # Alignment (w:jc)
  if (jc = pPr_node.at_xpath('./w:jc', WORDML_NS))
    props.alignment = jc['w:val']
  end

  # Spacing (w:spacing)
  if (spacing = pPr_node.at_xpath('./w:spacing', WORDML_NS))
    props.spacing_before = spacing['w:before']&.to_i
    props.spacing_after = spacing['w:after']&.to_i
    props.line_spacing = spacing['w:line']&.to_i
    props.line_rule = spacing['w:lineRule']
  end

  # Indentation (w:ind)
  if (ind = pPr_node.at_xpath('./w:ind', WORDML_NS))
    props.indent_left = ind['w:left']&.to_i
    props.indent_right = ind['w:right']&.to_i
    props.first_line_indent = ind['w:firstLine']&.to_i
    props.hanging_indent = ind['w:hanging']&.to_i
  end

  # Borders (w:pBdr)
  if (pBdr = pPr_node.at_xpath('./w:pBdr', WORDML_NS))
    props.borders = parse_paragraph_borders(pBdr)
  end

  # Shading (w:shd)
  if (shd = pPr_node.at_xpath('./w:shd', WORDML_NS))
    props.shading = parse_shading(shd)
  end

  # Numbering (w:numPr)
  if (numPr = pPr_node.at_xpath('./w:numPr', WORDML_NS))
    props.numbering_id = numPr.at_xpath('./w:numId', WORDML_NS)&.[]('w:val')&.to_i
    props.numbering_level = numPr.at_xpath('./w:ilvl', WORDML_NS)&.[]('w:val')&.to_i
  end

  # ... 50+ more properties

  props
end

# Parse w:rPr (Run Properties)
def parse_run_properties(rPr_node)
  require_relative '../properties/run_properties'

  props = Properties::RunProperties.new

  # Font (w:rFonts)
  if (rFonts = rPr_node.at_xpath('./w:rFonts', WORDML_NS))
    props.font_ascii = rFonts['w:ascii']
    props.font_h_ansi = rFonts['w:hAnsi']
    props.font_cs = rFonts['w:cs']
    props.font_east_asia = rFonts['w:eastAsia']
  end

  # Size (w:sz)
  if (sz = rPr_node.at_xpath('./w:sz', WORDML_NS))
    props.size = sz['w:val']&.to_i
  end

  # Bold (w:b)
  props.bold = !rPr_node.at_xpath('./w:b', WORDML_NS).nil?

  # Italic (w:i)
  props.italic = !rPr_node.at_xpath('./w:i', WORDML_NS).nil?

  # Underline (w:u)
  if (u = rPr_node.at_xpath('./w:u', WORDML_NS))
    props.underline = u['w:val']
  end

  # Color (w:color)
  if (color = rPr_node.at_xpath('./w:color', WORDML_NS))
    props.color = color['w:val']
  end

  # Shading (w:shd)
  if (shd = rPr_node.at_xpath('./w:shd', WORDML_NS))
    props.shading = parse_shading(shd)
  end

  # ... 40+ more properties

  props
end

# Parse w:tblPr (Table Properties)
def parse_table_properties(tblPr_node)
  require_relative '../properties/table_properties'

  props = Properties::TableProperties.new

  # Width (w:tblW)
  if (tblW = tblPr_node.at_xpath('./w:tblW', WORDML_NS))
    props.width = tblW['w:w']&.to_i
    props.width_type = tblW['w:type']
  end

  # Borders (w:tblBorders)
  if (tblBorders = tblPr_node.at_xpath('./w:tblBorders', WORDML_NS))
    props.borders = parse_table_borders(tblBorders)
  end

  # ... more properties

  props
end
```

**Deliverable:** 100+ OOXML properties parsed into property objects.

#### Day 3-4: OOXML Serialization

**Goal:** Serialize complete style definitions to `styles.xml`

**Files to modify:**
1. [`lib/uniword/serialization/ooxml_serializer.rb`](../lib/uniword/serialization/ooxml_serializer.rb:130)
2. [`lib/uniword/style.rb`](../lib/uniword/style.rb:23) - Add XML serialization mapping

**Implementation:**

```ruby
# In Style class
class Style < Lutaml::Model::Serializable
  # Add XML serialization
  xml do
    root 'style'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    map_attribute 'type', to: :type, namespace: 'w'
    map_attribute 'styleId', to: :id, namespace: 'w'
    map_attribute 'default', to: :default, namespace: 'w'
    map_attribute 'customStyle', to: :custom, namespace: 'w'

    map_element 'name', to: :name
    map_element 'basedOn', to: :based_on
    map_element 'next', to: :next_style
    map_element 'pPr', to: :paragraph_properties
    map_element 'rPr', to: :run_properties
    map_element 'tblPr', to: :table_properties
  end

  # Add property attributes
  attribute :paragraph_properties, Properties::ParagraphProperties
  attribute :run_properties, Properties::RunProperties
  attribute :table_properties, Properties::TableProperties
end
```

**Deliverable:** Complete styles.xml generation with all properties.

#### Day 5: Integration Testing

**Test scenarios:**
1. Load Distinctive.dotx → Extract all styles → Verify all properties captured
2. Apply StyleSet to document → Save → Open in Word → Verify rendering
3. Round-trip: .dotx → YAML → StyleSet → Document → .docx → Open in Word
4. Performance: < 500ms to load and apply any Office StyleSet

---

### Week 2: Native Namespace Support

#### Day 1: Namespace Architecture Design

**Deliverable:** `docs/NAMESPACE_MIGRATION_GUIDE.md`

**Design decisions:**
1. Create `lib/uniword/ooxml/namespaces.rb` with all OOXML namespace classes
2. Migration strategy from placeholder to native namespaces
3. Namespace usage patterns for all OOXML elements

#### Day 2-3: Critical Element Implementation

**Goal:** Fix ISO 8601 round-trip blockers

##### 1. Math Namespace Support

**Files to create:**
```
lib/uniword/math/
  ├── math_element.rb       # Base class for math elements
  ├── o_math.rb             # m:oMath container
  ├── o_math_para.rb        # m:oMathPara
  ├── math_run.rb           # m:r
  └── math_text.rb          # m:t
```

**Example implementation:**

```ruby
# lib/uniword/math/o_math.rb
module Uniword
  module Math
    class OMath < Element
      xml do
        root 'oMath'
        namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

        # Math children
        map_element 'r', to: :runs, namespace: 'm'
        map_element 'oMathPara', to: :para, namespace: 'm'
      end

      attribute :runs, MathRun, collection: true, default: -> { [] }
      attribute :para, OMathPara
    end
  end
end
```

##### 2. Bookmark Elements

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

      map_attribute 'id', to: :bookmark_id, namespace: 'w'
      map_attribute 'name', to: :name, namespace: 'w'
      map_attribute 'colFirst', to: :col_first, namespace: 'w'
      map_attribute 'colLast', to: :col_last, namespace: 'w'
    end

    attribute :bookmark_id, :string
    attribute :name, :string
    attribute :col_first, :integer
    attribute :col_last, :integer
  end
end

# lib/uniword/bookmark_end.rb
module Uniword
  class BookmarkEnd < Element
    xml do
      root 'bookmarkEnd'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_attribute 'id', to: :bookmark_id, namespace: 'w'
    end

    attribute :bookmark_id, :string
  end
end
```

**Integration:**
- Add to [`lib/uniword/serialization/ooxml_deserializer.rb`](../lib/uniword/serialization/ooxml_deserializer.rb:26) `KNOWN_PARAGRAPH_ELEMENTS`
- Update parsing logic to handle as known elements

#### Day 4-5: Round-Trip Testing

**Test documents:**
- `iso-wd-8601-2-2026.docx` (295KB, with Math)
- `document.doc` (985KB MHTML)

**Success criteria:**
- ✅ Zero XML parsing errors
- ✅ Math equations preserved
- ✅ Bookmarks are known elements
- ✅ File size within 5%
- ✅ Visual comparison identical

---

## Part 4: V2.0.0 Schema-Driven Architecture (8 Weeks)

### Vision

**External OOXML Schema Configuration** as per [`docs/V2.0.0_COMPLETE_OOXML_ARCHITECTURE.md`](V2.0.0_COMPLETE_OOXML_ARCHITECTURE.md):

```yaml
# config/ooxml/schema_main.yml
schema:
  version: "ISO 29500"
  namespace:
    prefix: 'w'
    uri: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

elements:
  paragraph:
    tag: 'w:p'
    children:
      - element: paragraph_properties
        tag: 'w:pPr'
        optional: true
      - element: run
        tag: 'w:r'
        multiple: true
    attributes: []

  run:
    tag: 'w:r'
    children:
      - element: run_properties
        tag: 'w:rPr'
        optional: true
      - element: text
        tag: 'w:t'
        optional: false
```

### Phase 3.1: Schema Infrastructure (Week 3)

**Files to create:**
```
config/ooxml/
  ├── schema_main.yml          # w: namespace (200+ elements)
  ├── schema_relationships.yml # r: namespace
  ├── schema_drawing.yml       # wp:, a: namespaces
  ├── schema_math.yml          # m: namespace (OMML)
  ├── schema_vml.yml           # v:, o: namespaces
  ├── schema_styles.yml        # Style elements
  ├── schema_numbering.yml     # Numbering elements
  └── schema_settings.yml      # Settings elements

lib/uniword/ooxml/schema/
  ├── ooxml_schema.rb          # Main schema loader
  ├── element_definition.rb    # Element schema
  ├── child_definition.rb      # Child relationship schema
  ├── attribute_definition.rb  # Attribute schema
  └── schema_validator.rb      # Schema validation
```

### Phase 3.2: Schema-Driven Serializer (Week 4-5)

**Architecture:**

```ruby
module Uniword
  module Ooxml
    class ElementSerializer
      def initialize(schema: nil)
        @schema = schema || Schema::OoxmlSchema.load('config/ooxml/schema_main.yml')
      end

      # Serialize ANY element using schema definition
      def serialize(element, options = {})
        schema_def = @schema.definition_for(element.class)
        build_xml_from_schema(element, schema_def, options)
      end

      private

      def build_xml_from_schema(element, schema_def, options)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send(schema_def.tag.to_sym, schema_def.namespaces) do
            # Serialize attributes according to schema
            serialize_attributes(xml, element, schema_def)

            # Serialize children according to schema
            serialize_children(xml, element, schema_def, options)
          end
        end.to_xml
      end
    end
  end
end
```

**Benefits:**
- No hardcoded XML building
- All element structures in YAML
- Easy to extend with new OOXML elements
- Single serializer for ALL elements

### Phase 3.3: Complete OOXML Coverage (Week 6-7)

**Target:** 100% ISO 29500 specification coverage

**Schema files for:**
- All paragraph elements (50+)
- All run elements (30+)
- All table elements (40+)
- All section elements (20+)
- Math equations (OMML 50+)
- Drawings (DrawingML 100+)
- VML (Legacy 80+)

### Phase 3.4: Testing & Migration (Week 8)

- Comprehensive test suite
- Performance benchmarks
- Migration documentation
- Feature flags for gradual rollout

---

## Part 5: Implementation Priorities

### Priority 1: StyleSet (Days 1-5)

**Why first:**
- Nearly complete (75% done)
- User-facing feature (apply Office stylesets)
- Quick win (1 week)
- Independent of other work

**Value:**
- Users can apply Distinctive, Elegant, Fancy, etc. stylesets
- Professional document styling without manual work
- Parity with Word's built-in StyleSet functionality

### Priority 2: Namespaces (Days 6-10)

**Why second:**
- Foundation for everything else
- Fixes ISO 8601 round-trip
- Eliminates technical debt
- Enables V2.0.0

**Value:**
- ISO documents work perfectly
- Math equations preserved
- Bookmarks are proper elements
- Clean architecture

### Priority 3: V2.0.0 (Weeks 3-10)

**Why later:**
- Biggest effort (8 weeks)
- Needs stable foundation
- Can be iterative
- Benefits from Weeks 1-2 learnings

**Value:**
- Zero hardcoding
- 100% OOXML coverage
- Easy extensibility
- Production-grade architecture

---

## Part 6: Success Metrics

### Week 1 Complete When:
- [ ] All 12 Office stylesets parse without errors
- [ ] Every OOXML property captured from .dotx files
- [ ] StyleSet applied to document and saves correctly
- [ ] Round-trip: .dotx → parse → apply → save → identical in Word
- [ ] Performance: < 500ms to load and apply StyleSet
- [ ] README examples work

### Week 2 Complete When:
- [ ] `iso-wd-8601-2-2026.docx` loads without XML errors
- [ ] Math equations preserved (no `w:m:oMath` error)
- [ ] Bookmarks are known elements (not UnknownElement)
- [ ] MHTML size loss fixed (within 5%)
- [ ] All 2100+ test examples pass
- [ ] Namespace architecture document complete

### V2.0.0 Complete When:
- [ ] 100% OOXML coverage via external schema
- [ ] Zero hardcoded XML in serializers
- [ ] New elements added via YAML only
- [ ] Performance maintained or improved
- [ ] Full backward compatibility
- [ ] Production deployment ready

---

## Part 7: File Organization

### New Files (Week 1)
```
(No new files - enhancing existing)
```

### New Files (Week 2)
```
lib/uniword/
  ├── bookmark_start.rb
  ├── bookmark_end.rb
  └── ooxml/
      └── namespaces.rb

lib/uniword/math/
  ├── math_element.rb
  ├── o_math.rb
  ├── o_math_para.rb
  ├── math_run.rb
  └── math_text.rb

docs/
  └── NAMESPACE_MIGRATION_GUIDE.md
```

### New Files (V2.0.0)
```
config/ooxml/
  ├── schema_main.yml
  ├── schema_relationships.yml
  ├── schema_drawing.yml
  ├── schema_math.yml
  ├── schema_vml.yml
  ├── schema_styles.yml
  ├── schema_numbering.yml
  └── schema_settings.yml

lib/uniword/ooxml/schema/
  ├── ooxml_schema.rb
  ├── element_definition.rb
  ├── child_definition.rb
  ├── attribute_definition.rb
  └── schema_validator.rb

lib/uniword/ooxml/serialization/
  ├── element_serializer.rb
  ├── element_deserializer.rb
  ├── serialization_context.rb
  └── namespace_registry.rb
```

---

## Part 8: Risk Mitigation

### Risk 1: StyleSet Properties Too Complex

**Risk:** 100+ OOXML properties may be difficult to parse correctly

**Mitigation:**
- Start with most common properties (20 properties)
- Add iteratively based on priority
- Test with real Office stylesets continuously
- Use Word's XML diff to verify correctness

### Risk 2: Namespace API Insufficient

**Risk:** lutaml-model namespace features may not handle all OOXML scenarios

**Mitigation:**
- Thoroughly review lutaml-model README (DONE)
- Test with complex multi-namespace documents
- Have fallback to enhanced placeholder approach
- Document limitations clearly

### Risk 3: Performance Degradation

**Risk:** Schema-driven approach may be slower

**Mitigation:**
- Schema caching/memoization
- Lazy loading of schema definitions
- Performance benchmarks at each phase
- Optimize hot paths

### Risk 4: Breaking Changes

**Risk:** Refactoring may break existing functionality

**Mitigation:**
- Comprehensive test suite (2100+ examples)
- Feature flags for new code
- Gradual rollout
- Maintain 100% backward compatibility

---

## Part 9: Technical Specifications

### StyleSet Property Coverage

#### Paragraph Properties (60+ properties)
```yaml
alignment:          # w:jc@w:val (left, center, right, etc.)
spacing_before:     # w:spacing@w:before (twips)
spacing_after:      # w:spacing@w:after (twips)
line_spacing:       # w:spacing@w:line (twips)
line_rule:          # w:spacing@w:lineRule (auto, exact, atLeast)
indent_left:        # w:ind@w:left (twips)
indent_right:       # w:ind@w:right (twips)
first_line_indent:  # w:ind@w:firstLine (twips)
hanging_indent:     # w:ind@w:hanging (twips)

# Borders
border_top:         # w:pBdr/w:top (style, size, color)
border_bottom:      # w:pBdr/w:bottom
border_left:        # w:pBdr/w:left
border_right:       # w:pBdr/w:right
border_between:     # w:pBdr/w:between

# Shading
shading_fill:       # w:shd@w:fill (hex color)
shading_color:      # w:shd@w:color (hex color)
shading_pattern:    # w:shd@w:val (clear, solid, pct10, etc.)

# Numbering
numbering_id:       # w:numPr/w:numId@w:val
numbering_level:    # w:numPr/w:ilvl@w:val

# Keep together
keep_next:          # w:keepNext (boolean)
keep_lines:         # w:keepLines (boolean)
page_break_before:  # w:pageBreakBefore (boolean)
widow_control:      # w:widowControl (boolean)

# Tabs
tab_stops:          # w:tabs/w:tab (array of tab stops)

# Outline
outline_level:      # w:outlineLvl@w:val (0-8)

# ... 30+ more properties
```

#### Run Properties (50+ properties)
```yaml
fonts:
  ascii:            # w:rFonts@w:ascii
  h_ansi:           # w:rFonts@w:hAnsi
  cs:               # w:rFonts@w:cs
  east_asia:        # w:rFonts@w:eastAsia

size:               # w:sz@w:val (half-points)
size_cs:            # w:szCs@w:val

formatting:
  bold:             # w:b (boolean)
  italic:           # w:i (boolean)
  underline:        # w:u@w:val (single, double, etc.)
  strike:           # w:strike (boolean)
  double_strike:    # w:dstrike (boolean)
  caps:             # w:caps (boolean)
  small_caps:       # w:smallCaps (boolean)

color:              # w:color@w:val (hex)
highlight:          # w:highlight@w:val (color name)
shading:            # w:shd (fill, color, pattern)

effects:
  emboss:           # w:emboss (boolean)
  shadow:           # w:shadow (boolean)
  outline:          # w:outline (boolean)
  imprint:          # w:imprint (boolean)

spacing:            # w:spacing@w:val (twips)
position:           # w:position@w:val (half-points)
kern:               # w:kern@w:val (half-points)
w_scale:            # w:w@w:val (percentage)

# ... 20+ more properties
```

### Namespace Declaration Patterns

#### Pattern 1: Simple Element

```ruby
class Paragraph < Element
  xml do
    root 'p'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    map_element 'pPr', to: :properties
    map_element 'r', to: :runs
  end
end
```

#### Pattern 2: Multi-Namespace Element

```ruby
class Drawing < Element
  xml do
    root 'drawing'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    # Child from different namespace
    map_element 'inline', to: :inline,
      namespace: 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
      prefix: 'wp'
  end
end
```

#### Pattern 3: Namespace Class Usage

```ruby
class Document < Element
  xml do
    element 'document'
    namespace Ooxml::Namespaces::WordProcessingML

    map_element 'body', to: :body
  end
end
```

---

## Part 10: Next Steps

### Immediate Actions (This Session)

1. ✅ Update Gemfile to use local lutaml-model
2. ✅ Run `bundle install`
3. ✅ Create architecture document
4. ⏳ Begin Week 1 Day 1: Enhance StyleSetXmlParser

### Week 1 Deliverables

- Working StyleSet system with full property parsing
- All Office stylesets bundled and tested
- Documentation and examples
- Integration with Document API

### Week 2 Deliverables

- Native namespace support throughout codebase
- Math equations working
- Bookmarks as proper elements
- ISO 8601 perfect round-trip
- Namespace migration guide

### V2.0.0 Deliverables

- Complete OOXML schema in YAML
- Schema-driven serialization
- 100% element coverage
- Zero hardcoding
- Production deployment

---

## Conclusion

This architecture provides a clear, executable path to:

1. **Complete StyleSet** (1 week) - Finish what we started
2. **Native Namespaces** (1 week) - Eliminate technical debt
3. **Perfect Round-Trip** (ongoing) - ISO standards compliance
4. **V2.0.0** (8 weeks) - Schema-driven future

All work follows SOLID principles, MECE organization, and clean architecture patterns established in Uniword.

**Ready to implement!**