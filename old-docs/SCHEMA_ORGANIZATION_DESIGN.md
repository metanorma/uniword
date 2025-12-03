# OOXML Schema Organization Design

## Purpose

This document defines the architectural design for organizing 200+ ISO/IEC 29500-1 OOXML elements in the Uniword schema system.

## Current State Analysis

### Existing Implementation

**Current Coverage:**
- Elements defined: 37 core elements
- File: `config/ooxml/schema_main.yml` (524 lines)
- Architecture: Single YAML file with all elements
- Loader: [`OoxmlSchema`](lib/uniword/ooxml/schema/ooxml_schema.rb) class
- Definition classes:
  - [`ElementDefinition`](lib/uniword/ooxml/schema/element_definition.rb)
  - [`ChildDefinition`](lib/uniword/ooxml/schema/child_definition.rb)
  - [`AttributeDefinition`](lib/uniword/ooxml/schema/attribute_definition.rb)

**Current Element Categories:**
- Document structure: `document`, `body`
- Paragraphs: `paragraph`, `paragraphproperties`
- Runs: `run`, `runproperties`, `textelement`
- Tables: `table`, `tableproperties`, `tablerow`, `tablecell`, etc.
- Hyperlinks: `hyperlink`
- Images: `image` (simplified DrawingML)
- Comments: `comment`

## Design Principles

### MECE Organization

All elements must be **Mutually Exclusive, Collectively Exhaustive**:
- Each element appears in exactly one schema file
- All ISO/IEC 29500-1 elements are covered
- Clear categorization by functional domain

### Configuration Over Convention

- Schema is external YAML, not hardcoded
- Changes require no code modifications
- Machine-readable for validation and tooling

### Separation of Concerns

- Each schema file represents one functional domain
- Clear boundaries between namespaces
- Independent versioning possible

## Architecture Decision: Multi-File Schema

### Rationale

**REJECTED: Single File Approach**
- ❌ Single 5000+ line YAML file is unmaintainable
- ❌ Difficult to navigate and edit
- ❌ Merge conflicts in team development
- ❌ Slow to parse and load

**SELECTED: Multi-File Schema by Namespace/Domain**
- ✅ Maintainable file sizes (200-500 lines each)
- ✅ Clear separation of concerns
- ✅ Easy to navigate and extend
- ✅ Parallel development possible
- ✅ Selective loading for performance

### File Organization Structure

```
config/ooxml/
├── schema_loader.yml          # Master index of all schema files
├── namespaces/
│   ├── main/
│   │   ├── document.yml       # Document structure (w:document, w:body)
│   │   ├── paragraph.yml      # Paragraph elements (w:p, w:pPr)
│   │   ├── run.yml            # Run elements (w:r, w:rPr, w:t)
│   │   ├── table.yml          # Table elements (w:tbl, w:tr, w:tc)
│   │   ├── section.yml        # Section properties (w:sectPr, w:pgSz, w:pgMar)
│   │   ├── numbering.yml      # Numbering (w:num, w:abstractNum, w:lvl)
│   │   ├── styles.yml         # Styles (w:style, w:basedOn, w:next)
│   │   ├── fields.yml         # Fields (w:fldSimple, w:fldChar, w:instrText)
│   │   ├── footnotes.yml      # Footnotes/Endnotes (w:footnote, w:endnote)
│   │   ├── headers_footers.yml # Headers/Footers (w:hdr, w:ftr)
│   │   ├── comments.yml       # Comments (w:comment, w:commentRangeStart)
│   │   ├── revisions.yml      # Track changes (w:ins, w:del, w:moveFrom)
│   │   ├── bookmarks.yml      # Bookmarks (w:bookmarkStart, w:bookmarkEnd)
│   │   ├── hyperlinks.yml     # Hyperlinks (w:hyperlink)
│   │   └── math.yml           # Math elements (w:oMath, w:oMathPara)
│   ├── drawing/
│   │   ├── inline.yml         # Inline drawings (wp:inline)
│   │   ├── anchor.yml         # Floating drawings (wp:anchor)
│   │   ├── picture.yml        # Pictures (pic:pic)
│   │   └── shapes.yml         # Shapes (wps:wsp)
│   ├── relationships/
│   │   └── rels.yml           # Relationships namespace
│   └── content_types/
│       └── types.yml          # Content Types
└── legacy/
    └── schema_main.yml        # Current schema (deprecated in v2.0)
```

### Master Schema Loader

**File: `config/ooxml/schema_loader.yml`**

```yaml
# OOXML Schema Loader Configuration
# Defines which schema files to load and in what order

version: "2.0.0"
iso_reference: "ISO/IEC 29500-1:2016"

# Schema files organized by namespace and functional domain
schema_files:
  # Core document structure (REQUIRED)
  - namespaces/main/document.yml
  - namespaces/main/paragraph.yml
  - namespaces/main/run.yml

  # Tables (HIGH PRIORITY)
  - namespaces/main/table.yml

  # Document features (MEDIUM PRIORITY)
  - namespaces/main/section.yml
  - namespaces/main/numbering.yml
  - namespaces/main/styles.yml
  - namespaces/main/headers_footers.yml
  - namespaces/main/footnotes.yml

  # Advanced features (LOW PRIORITY)
  - namespaces/main/fields.yml
  - namespaces/main/comments.yml
  - namespaces/main/revisions.yml
  - namespaces/main/bookmarks.yml
  - namespaces/main/hyperlinks.yml
  - namespaces/main/math.yml

  # Drawing namespace (HIGH PRIORITY)
  - namespaces/drawing/inline.yml
  - namespaces/drawing/anchor.yml
  - namespaces/drawing/picture.yml
  - namespaces/drawing/shapes.yml

  # Supporting namespaces (REQUIRED)
  - namespaces/relationships/rels.yml
  - namespaces/content_types/types.yml

# Namespace definitions
namespaces:
  w:
    uri: "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    description: "Main WordProcessingML namespace"

  wp:
    uri: "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    description: "WordProcessingML Drawing namespace"

  a:
    uri: "http://schemas.openxmlformats.org/drawingml/2006/main"
    description: "DrawingML main namespace"

  pic:
    uri: "http://schemas.openxmlformats.org/drawingml/2006/picture"
    description: "Picture namespace"

  r:
    uri: "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    description: "Relationships namespace"

  m:
    uri: "http://schemas.openxmlformats.org/officeDocument/2006/math"
    description: "Office Math Markup Language (OMML) namespace"

# Schema metadata
metadata:
  total_files: 17
  estimated_elements: 200+
  coverage: "Complete ISO/IEC 29500-1"
```

### Individual Schema File Format

Each schema file follows this structure:

```yaml
# Example: config/ooxml/namespaces/main/section.yml

# Section Properties Schema
# ISO/IEC 29500-1:2016 - Section 17.6

schema:
  namespace: w
  category: "Section Properties"
  iso_section: "17.6"

elements:
  section_properties:
    tag: 'w:sectPr'
    description: "Section properties"
    iso_reference: "17.6.18"
    children:
      - element: page_size
        tag: 'w:pgSz'
        optional: true
        attributes:
          - name: w
            type: integer
            description: "Page width in twentieths of a point"
          - name: h
            type: integer
            description: "Page height in twentieths of a point"
          - name: orient
            type: enum
            values: [portrait, landscape]

      - element: page_margins
        tag: 'w:pgMar'
        optional: true
        attributes:
          - name: top
            type: integer
          - name: right
            type: integer
          - name: bottom
            type: integer
          - name: left
            type: integer
          - name: header
            type: integer
          - name: footer
            type: integer
          - name: gutter
            type: integer

      # ... more section elements

metadata:
  element_count: 15
  priority: "HIGH"
  status: "planned"
```

## Enhanced Schema Loader Implementation

### Updated OoxmlSchema Class

```ruby
# lib/uniword/ooxml/schema/ooxml_schema.rb

module Uniword
  module Ooxml
    module Schema
      class OoxmlSchema
        attr_reader :version, :namespaces, :elements, :schema_files

        # Load complete schema from master loader
        #
        # @param loader_file [String] Path to schema loader YAML
        # @return [OoxmlSchema] Loaded schema
        def self.load(loader_file = nil)
          loader_file ||= default_loader_path
          loader_config = Configuration::ConfigurationLoader.load_file(loader_file)

          # Load all schema files defined in loader
          combined_schema = load_all_schemas(loader_config)

          new(combined_schema)
        end

        # Load single schema file (for testing/selective loading)
        #
        # @param schema_file [String] Path to individual schema file
        # @return [OoxmlSchema] Schema with single file loaded
        def self.load_file(schema_file)
          config = Configuration::ConfigurationLoader.load_file(schema_file)
          new(config)
        end

        private

        # Load all schema files and combine into single schema
        def self.load_all_schemas(loader_config)
          base_path = File.dirname(loader_file)
          all_elements = {}

          loader_config[:schema_files].each do |schema_file|
            file_path = File.join(base_path, schema_file)
            file_config = Configuration::ConfigurationLoader.load_file(file_path)

            # Merge elements from this file
            all_elements.merge!(file_config[:elements] || {})
          end

          {
            schema: {
              version: loader_config[:version],
              namespaces: loader_config[:namespaces]
            },
            elements: all_elements
          }
        end

        def self.default_loader_path
          File.expand_path('../../../../config/ooxml/schema_loader.yml', __dir__)
        end
      end
    end
  end
end
```

## File Size Guidelines

- **Individual schema files:** 200-500 lines
- **Total elements per file:** 10-20 elements
- **Maximum file size:** 1000 lines (exception for complex domains)

## Naming Conventions

### File Names

- Lowercase with underscores: `headers_footers.yml`
- Descriptive of functional domain
- Singular form for element types: `paragraph.yml` not `paragraphs.yml`

### Element Keys

- Lowercase with underscores: `section_properties`
- Match ISO spec terminology where possible
- Consistent with existing Ruby class names

## Validation Strategy

### Schema File Validation

Each schema file must validate against:
1. YAML syntax correctness
2. Required fields present (`tag`, `description`)
3. Valid attribute types
4. Valid child element references
5. ISO reference format

### Cross-File Validation

- No duplicate element definitions
- All child element references resolve
- Namespace prefixes are defined
- Circular dependency detection

## Migration Strategy

### Phase 1: Backward Compatibility (v2.0.0)

1. Keep `schema_main.yml` as fallback
2. Implement new multi-file loader
3. Migrate existing 37 elements to new structure
4. Ensure 100% test pass rate

### Phase 2: Schema Expansion (v2.1.0 - v2.5.0)

1. Add high-priority elements (see V2.0_COMPLETE_SCHEMA_PLAN.md)
2. Implement validation system
3. Add comprehensive tests
4. Update documentation

### Phase 3: Complete Coverage (v2.6.0+)

1. Add remaining ISO/IEC 29500-1 elements
2. Deprecate `schema_main.yml`
3. Full schema validation suite
4. Performance optimization

## Benefits of Multi-File Approach

### Development Benefits

1. **Parallel Development:** Multiple developers can work on different domains
2. **Easier Reviews:** Smaller files are easier to review in PRs
3. **Clear Ownership:** Each file has clear functional boundary
4. **Reduced Conflicts:** Less merge conflicts with separate files

### Maintenance Benefits

1. **Easier Navigation:** Find elements by functional domain
2. **Targeted Updates:** Update only relevant files
3. **Clear Dependencies:** File structure shows relationships
4. **Better Documentation:** Each file documents one domain

### Performance Benefits

1. **Lazy Loading:** Load only needed schema files
2. **Faster Parsing:** Smaller files parse faster
3. **Caching:** Cache individual file results
4. **Memory Efficiency:** Load subsets for specific operations

## Implementation Checklist

- [ ] Create directory structure
- [ ] Implement enhanced `OoxmlSchema` loader
- [ ] Create `schema_loader.yml` master index
- [ ] Migrate existing 37 elements to new files
- [ ] Implement schema file validator
- [ ] Add RSpec tests for new loader
- [ ] Update documentation
- [ ] Ensure backward compatibility
- [ ] Performance benchmarking

## Related Documents

- [`V2.0_COMPLETE_SCHEMA_PLAN.md`](V2.0_COMPLETE_SCHEMA_PLAN.md) - Priority elements and implementation phases
- [`V3.0_PLURIMATH_ARCHITECTURE.md`](V3.0_PLURIMATH_ARCHITECTURE.md) - Math integration architecture
- Current schema: [`config/ooxml/schema_main.yml`](config/ooxml/schema_main.yml)
- Schema loader: [`lib/uniword/ooxml/schema/ooxml_schema.rb`](lib/uniword/ooxml/schema/ooxml_schema.rb)