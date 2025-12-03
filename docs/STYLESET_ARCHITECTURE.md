# StyleSet Architecture and Implementation Plan

## Overview

StyleSets are collections of predefined paragraph, character, and table style definitions that provide consistent formatting for Word documents. StyleSets work in conjunction with themes (colors/fonts) to create professionally styled documents.

## Background

### What are StyleSets?

StyleSets (.dotx files) are Word template packages containing:

- **Style definitions**: Complete style specifications for headings, body text, quotes, etc.
- **Default theme**: A base theme (often Office Theme)
- **Font table**: Font definitions used by styles
- **Settings**: Document settings and preferences

### Relationship: Theme vs StyleSet

```
Theme (Colors + Fonts)
    +
StyleSet (Style Formatting Rules)
    =
Beautifully Styled Document
```

**Example**:
- **Theme "Celestial"**: Provides colors (blue accent1, orange accent2) and fonts (Avenir, Gill Sans)
- **StyleSet "Distinctive"**: Defines Heading 1 uses accent1 color, 18pt, bold
- **Result**: Heading 1 appears in Celestial blue, 18pt, bold, Avenir font

## Analysis Findings

### .dotx File Structure

.dotx files are **ZIP archives** (same as .docx):

```
Distinctive.dotx/
├── [Content_Types].xml
├── _rels/.rels
├── docProps/
│   ├── app.xml
│   └── core.xml
└── word/
    ├── document.xml          # Minimal/empty document
    ├── styles.xml            # ← Contains all style definitions (20KB+)
    ├── theme/theme1.xml      # Default theme (usually Office Theme)
    ├── fontTable.xml         # Font definitions
    ├── settings.xml          # Document settings
    └── webSettings.xml
```

**Key insight**: The main content is in `word/styles.xml` which contains ~42 style definitions.

### Style Types in StyleSets

From analysis of Distinctive.dotx:

1. **Paragraph styles** (e.g., Normal, Heading1-9, Title, Subtitle)
2. **Character styles** (e.g., DefaultParagraphFont, Heading1Char)
3. **Table styles** (e.g., TableNormal, TableGrid)
4. **Numbering styles** (e.g., NoList)

### Reference Document Structure

The reference [`sample-theme_celestial-style_distinctive.docx`](../examples/sample-theme_celestial-style_distinctive.docx) shows:

```
Theme: Celestial (colors/fonts)
    +
StyleSet: Distinctive (42 style definitions)
    =
Document with both applied
```

## Proposed Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Document Generation Layer                    │
├─────────────────────────────────────────────────────────────────┤
│  Document + Theme + StyleSet → Fully Styled Document             │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       StyleSet System Layer                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌────────────────────┐  ┌────────────────┐ │
│  │  StyleSetLoader│  │  StyleSetApplicator│  │ StyleSetRegistry││
│  │  - load_dotx() │  │  - apply_to()      │  │  - register()  │ │
│  │  - from_yaml() │  │  - merge()         │  │  - get()       │ │
│  └───────────────┘  └────────────────────┘  └────────────────┘ │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Domain Model Layer                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌──────────────────┐  ┌──────────────────────┐│
│  │  StyleSet   │  │StylesConfiguration│  │     Style            ││
│  │   NEW       │  │   EXISTING        │  │   EXISTING           ││
│  └─────────────┘  └──────────────────┘  └──────────────────────┘│
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure Layer                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────┐  ┌────────────────────────────────┐│
│  │ StyleSetPackageReader  │  │   StyleSetXmlParser            ││
│  │   - extract_dotx()     │  │   - parse_styles_xml()         ││
│  └────────────────────────┘  └────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
.dotx file
    │
    ▼
StyleSetPackageReader (extract ZIP)
    │
    ▼
word/styles.xml
    │
    ▼
StyleSetXmlParser (parse XML)
    │
    ▼
StyleSet model (collection of styles)
    │
    ▼
StyleSetApplicator (merge into document.styles_configuration)
    │
    ▼
Styled Document
```

## Design Decisions

### 1. StyleSet as Named Collection

```ruby
class StyleSet
  attr_accessor :name           # E.g., "Distinctive"
  attr_accessor :styles         # Array of Style objects from existing Style class
  attr_accessor :source_file    # Original .dotx file
end
```

**Rationale**: StyleSet is simply a named collection of existing [`Style`](../lib/uniword/style.rb) objects. Leverages existing infrastructure.

### 2. Integration with StylesConfiguration

```ruby
class Document
  def apply_styleset(styleset_name)
    # Load StyleSet
    styleset = StyleSet.load(styleset_name)

    # Merge styles into document's styles_configuration
    styles_configuration.merge_styleset(styleset)
  end
end
```

**Rationale**: Uses existing [`StylesConfiguration`](../lib/uniword/styles_configuration.rb) to store styles. StyleSet is just a source/loader.

### 3. Theme + StyleSet Combination

```ruby
# Apply both theme and styleset
doc = Uniword::Document.new
doc.apply_theme('celestial')              # Sets colors/fonts
doc.apply_styleset('distinctive')         # Sets style definitions
doc.add_paragraph('Heading', heading: :heading_1)
doc.save('output.docx')
```

**Workflow**:
1. Theme provides colors/fonts
2. StyleSet provides style definitions that reference theme colors/fonts
3. Content uses the style definitions
4. Final document has themed, styled appearance

## Implementation Plan

### Phase 1: StyleSet Package Infrastructure

#### 1.1 Create StyleSetPackageReader

**File**: `lib/uniword/stylesets/styleset_package_reader.rb`

```ruby
module Uniword
  module StyleSets
    class StyleSetPackageReader
      # Extract styles from .dotx file
      # @param path [String] Path to .dotx file
      # @return [Hash] Extracted files
      def extract(path)
        # Use ZipExtractor (same as for .docx/.thmx)
        # Return hash with word/styles.xml content
      end
    end
  end
end
```

#### 1.2 Create StyleSetXmlParser

**File**: `lib/uniword/stylesets/styleset_xml_parser.rb`

```ruby
module Uniword
  module StyleSets
    class StyleSetXmParser
      # Parse styles.xml into array of Style objects
      # @param xml [String] styles.xml content
      # @return [Array<Style>] Parsed styles
      def parse(xml)
        # Parse using existing OOXML deserialization logic
        # Leverage existing Style class
      end
    end
  end
end
```

### Phase 2: StyleSet Model

#### 2.1 Create StyleSet Model

**File**: `lib/uniword/styleset.rb`

```ruby
module Uniword
  class StyleSet
    attr_accessor :name
    attr_accessor :styles           # Array of Style objects
    attr_accessor :source_file

    # Load StyleSet from .dotx file
    # @param path [String] Path to .dotx file
    # @return [StyleSet] Loaded StyleSet
    def self.from_dotx(path)
      # Use StyleSetLoader
    end

    # Load bundled StyleSet by name
    # @param name [String] StyleSet name
    # @return [StyleSet] Loaded StyleSet
    def self.load(name)
      # Load from YAML (similar to themes)
    end

    # Apply this StyleSet to a document
    # @param document [Document] Target document
    # @return [void]
    def apply_to(document)
      # Merge styles into document.styles_configuration
    end
  end
end
```

### Phase 3: Integration

#### 3.1 Extend Document API

```ruby
class Document
  # Apply StyleSet from .dotx file
  # @param styleset_path [String] Path to .dotx file
  # @return [void]
  def apply_styleset_file(styleset_path)
    styleset = StyleSet.from_dotx(styleset_path)
    styleset.apply_to(self)
  end

  # Apply bundled StyleSet by name
  # @param styleset_name [String] StyleSet name
  # @return [void]
  def apply_styleset(styleset_name)
    styleset = StyleSet.load(styleset_name)
    styleset.apply_to(self)
  end
end
```

#### 3.2 Extend StylesConfiguration

```ruby
class StylesConfiguration
  # Merge StyleSet into configuration
  # @param styleset [StyleSet] StyleSet to merge
  # @param strategy [Symbol] :replace, :merge, :skip_existing
  # @return [void]
  def merge_styleset(styleset, strategy: :merge)
    styleset.styles.each do |style|
      case strategy
      when :replace
        add_style(style)  # Replace if exists
      when :merge
        add_style(style) unless has_style?(style.style_id)
      when :skip_existing
        add_style(style) unless has_style?(style.style_id)
      end
    end
  end
end
```

### Phase 4: YAML Import System

Similar to themes, import StyleSets to YAML:

**Directory**: `data/stylesets/`
```
data/stylesets/
├── distinctive.yml
├── elegant.yml
├── fancy.yml
├── formal.yml
└── ... (12 stylesets)
```

**YAML Format**:
```yaml
---
name: "Distinctive"
source: "Distinctive.dotx"
imported_at: "2025-11-01T05:20:00Z"
styles:
  - style_id: "Normal"
    name: "Normal"
    type: "paragraph"
    properties:
      font_size: 11
      font: "Calibri"
  - style_id: "Heading1"
    name: "heading 1"
    type: "paragraph"
    properties:
      font_size: 16
      font_theme: "majorHAnsi"
      color_theme: "accent1"
      bold: true
  # ... more styles
```

### Phase 5: CLI Integration

```bash
# List StyleSets
uniword styleset list

# Import StyleSets
uniword styleset import

# Apply StyleSet
uniword styleset apply input.docx output.docx --name distinctive

# Apply both Theme and StyleSet
uniword theme apply input.docx temp.docx --name celestial
uniword styleset apply temp.docx output.docx --name distinctive
```

## Usage Examples

### Combined Theme + StyleSet

```ruby
require 'uniword'

# Create document
doc = Uniword::Document.new

# Apply theme (colors/fonts)
doc.apply_theme('celestial')

# Apply styleset (style definitions)
doc.apply_styleset('distinctive')

# Use styled content
doc.add_paragraph('My Document', heading: :heading_1)
doc.add_paragraph('Introduction paragraph using Normal style.')

doc.save('output.docx')
# Result: Document with Celestial colors/fonts + Distinctive style formatting
```

### Shorthand Builder

```ruby
doc = Uniword::Document.new
doc.use_theme('celestial').use_styleset('distinctive')
doc.add_paragraph('Heading', heading: :heading_1)
doc.save('output.docx')
```

## Key Design Principles

1. **Separation of Concerns**
   - Theme: Colors and fonts
   - StyleSet: Style definitions and formatting
   - Document: Content

2. **Composability**
   - Themes and StyleSets work independently
   - Can be mixed and matched
   - Can apply theme only, styleset only, or both

3. **Leverage Existing Infrastructure**
   - Use existing `ZipExtractor` for .dotx
   - Use existing `Style` class
   - Use existing `StylesConfiguration`
   - Follow theme system pattern

4. **YAML Import**
   - Same pattern as themes
   - Bundle all 12 Office StyleSets
   - Fast loading, human-readable

## Implementation Phases

1. **StyleSet Infrastructure** (2-3 days)
   - StyleSetPackageReader
   - StyleSetXmlParser

2. **StyleSet Model** (1-2 days)
   - StyleSet class
   - Integration with StylesConfiguration

3. **StyleSet Loading** (1-2 days)
   - StyleSetLoader (.dotx)
   - YamlStyleSetLoader (YAML)

4. **StyleSet Application** (1-2 days)
   - StyleSetApplicator
   - Document integration

5. **YAML Import** (1 day)
   - StyleSetImporter
   - Import all 12 Office StyleSets

6. **CLI Integration** (1 day)
   - `uniword styleset` subcommands

7. **Testing** (2 days)
   - Unit tests
   - Integration tests
   - Theme + StyleSet combination tests

**Total**: 9-14 days

## Implementation Status

### Phase 2 COMPLETE ✅ (November 29, 2024)

#### Achievements

- [x] **Can load .dotx files and extract styles** - 24 StyleSets load successfully
- [x] **Can apply StyleSets to documents** - StyleSet.apply_to() implemented
- [x] **StyleSets work with themes correctly** - Combined theme+styleset usage working
- [x] **All 12 Office StyleSets imported to YAML** - Plus 12 quick-styles = 24 total
- [x] **Round-trip preserves styles** - 168/168 tests passing (100%)
- [x] **Documentation complete** - CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md (408 lines)

#### Test Results

- **Total StyleSets Tested**: 24 (12 style-sets + 12 quick-styles)
- **Total Test Examples**: 168
- **Failures**: 0
- **Success Rate**: 100%
- **Duration**: ~8.76 seconds

#### Properties Implemented (10 categories)

**Simple Element Properties (7)**:
1. Alignment - `<w:jc w:val="center"/>`
2. Font Size - `<w:sz w:val="32"/>`
3. Font Size CS - `<w:szCs w:val="32"/>`
4. Color - `<w:color w:val="FF0000"/>`
5. Style References - `<w:pStyle>`, `<w:rStyle>`
6. Outline Level - `<w:outlineLvl w:val="0"/>`

**Complex Object Properties (3)**:
7. Spacing - `<w:spacing>` with before/after/lineSpacing
8. Indentation - `<w:ind>` with left/right/hanging/firstLine
9. RunFonts - `<w:rFonts>` with ASCII/eastAsia/cs fonts

**Boolean Properties (1)**:
10. Boolean flags - bold, italic, smallCaps, caps, hidden

#### Architecture

**Correct Pattern** (lutaml-model v0.7+):
```ruby
# Step 1: Namespaced custom type
class AlignmentValue < Lutaml::Model::Type::String
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

# Step 2: Wrapper class
class Alignment < Lutaml::Model::Serializable
  attribute :value, AlignmentValue
  xml do
    element 'jc'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# Step 3: Single attribute in property class
attribute :alignment, Alignment
xml { map_element 'jc', to: :alignment, render_nil: false }
```

#### Files Created/Modified

**Created (7 files)**:
- `lib/uniword/properties/alignment.rb`
- `lib/uniword/properties/font_size.rb`
- `lib/uniword/properties/color_value.rb`
- `lib/uniword/properties/style_reference.rb`
- `lib/uniword/properties/outline_level.rb`
- `lib/uniword/properties/spacing.rb`
- `lib/uniword/properties/indentation.rb`
- `lib/uniword/properties/run_fonts.rb`

**Modified (3 files)**:
- `lib/uniword/properties/paragraph_properties.rb` - Added wrapper attributes
- `lib/uniword/properties/run_properties.rb` - Added wrapper attributes
- `lib/uniword/stylesets/styleset_xml_parser.rb` - Creates wrapper objects

**Documentation**:
- `docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md` (408 lines)
- `PHASE2_CONTINUATION_PLAN.md` (complete summary)

### Phase 3: Additional Properties (Planned)

See link:../PHASE3_CONTINUATION_PLAN.md[Phase 3 Continuation Plan] for:
- 15 additional simple element properties
- 5 complex properties (borders, tabs, shading)
- Enhanced table properties
- Target: >95% OOXML property coverage

## References

- **Pattern Documentation**: link:CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md[CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md]
- **Phase 2 Summary**: link:../PHASE2_CONTINUATION_PLAN.md[PHASE2_CONTINUATION_PLAN.md]
- **Phase 3 Plan**: link:../PHASE3_CONTINUATION_PLAN.md[PHASE3_CONTINUATION_PLAN.md]
- **Test Spec**: link:../spec/uniword/styleset_roundtrip_spec.rb[styleset_roundtrip_spec.rb]