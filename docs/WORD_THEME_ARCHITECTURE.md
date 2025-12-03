# Word Theme Architecture and Implementation Plan

## Overview

This document outlines the architecture and implementation plan for supporting Word themes (.thmx files) in uniword. Word themes provide a coordinated set of colors, fonts, and effects that can be applied to documents for consistent styling.

## Background

### What are Word Themes?

Word themes (.thmx files) are packages that contain:

- **Color schemes**: 12 standard theme colors (dark1, light1, dark2, light2, accent1-6, hyperlink, followed hyperlink)
- **Font schemes**: Major (heading) and minor (body) fonts for various scripts
- **Effect schemes**: Visual effects like shadows and reflections
- **Theme variants**: Different style variations of the same base theme

### File Structure

.thmx files are ZIP/CAB archives with the following structure:

```
theme.thmx (ZIP archive)
├── [Content_Types].xml
├── _rels/
│   └── .rels
└── theme/
    ├── theme1.xml              # Main theme definition
    └── themeVariant/
        ├── variant1.xml        # Theme variant (e.g., "fancy")
        ├── variant2.xml
        └── ...
```

The `theme1.xml` file contains:

```xml
<a:theme name="Atlas">
  <a:themeElements>
    <a:clrScheme name="Atlas">
      <a:dk1>...</a:dk1>
      <a:lt1>...</a:lt1>
      <a:accent1>...</a:accent1>
      ...
    </a:clrScheme>
    <a:fontScheme name="Atlas">
      <a:majorFont>...</a:majorFont>
      <a:minorFont>...</a:minorFont>
    </a:fontScheme>
    <a:fmtScheme name="Atlas">
      <!-- Effect schemes -->
    </a:fmtScheme>
  </a:themeElements>
</a:theme>
```

## Current State Analysis

### Existing Theme Support

Uniword already has basic theme support:

- [`Theme`](../lib/uniword/theme.rb:20) class - Core theme model
- [`ColorScheme`](../lib/uniword/color_scheme.rb:13) class - Theme color management
- [`FontScheme`](../lib/uniword/font_scheme.rb:13) class - Theme font management
- Theme serialization/deserialization in OOXML format

### Current Limitations

1. **No .thmx file support**: Cannot read or write .thmx files
2. **No theme variants**: Only supports single theme definition
3. **No effect schemes**: Missing visual effects support
4. **No theme application**: Cannot apply themes to existing documents

## Proposed Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Document Generation Layer                    │
├─────────────────────────────────────────────────────────────────┤
│  Document + Theme → Themed Document                              │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Theme System Layer                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │  ThemeLoader    │  │  ThemeApplicator │  │  ThemeRegistry │ │
│  │  - load_thmx()  │  │  - apply_to()    │  │  - register()  │ │
│  │  - parse()      │  │  - merge()       │  │  - get()       │ │
│  └─────────────────┘  └──────────────────┘  └────────────────┘ │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Domain Model Layer                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────────┐│
│  │   Theme     │  │ ColorScheme  │  │    FontScheme           ││
│  │  Extended   │  │  Extended    │  │    Extended             ││
│  └─────────────┘  └──────────────┘  └─────────────────────────┘│
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────────┐│
│  │EffectScheme │  │ThemeVariant  │  │  ThemeMetadata          ││
│  │    NEW      │  │     NEW      │  │       NEW               ││
│  └─────────────┘  └──────────────┘  └─────────────────────────┘│
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure Layer                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────┐  ┌────────────────────────────────┐│
│  │   ThemePackageReader   │  │   ThemeXmlParser               ││
│  │   - extract_thmx()     │  │   - parse_theme_xml()          ││
│  │   - read_variant()     │  │   - parse_color_scheme()       ││
│  └────────────────────────┘  └────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
.thmx file
    │
    ▼
ThemePackageReader (extract ZIP)
    │
    ▼
theme1.xml + variant files
    │
    ▼
ThemeXmlParser (parse XML)
    │
    ▼
Theme model (with variants)
    │
    ▼
ThemeApplicator (apply to document)
    │
    ▼
Themed Document
```

## Implementation Plan

### Phase 1: Theme Package Infrastructure

#### 1.1 Create ThemePackageReader

**File**: [`lib/uniword/theme/theme_package_reader.rb`](../lib/uniword/theme/theme_package_reader.rb)

```ruby
module Uniword
  module Theme
    class ThemePackageReader
      # Extract theme from .thmx file
      # @param path [String] Path to .thmx file
      # @return [Hash] Extracted theme files
      def extract(path)
        # Use ZipExtractor to read .thmx (which is a ZIP file)
        # Return hash with:
        # - 'theme/theme1.xml'
        # - 'theme/themeVariant/*.xml' (if variants exist)
      end
    end
  end
end
```

**Dependencies**: [`ZipExtractor`](../lib/uniword/infrastructure/zip_extractor.rb:19)

#### 1.2 Create ThemeXmlParser

**File**: [`lib/uniword/theme/theme_xml_parser.rb`](../lib/uniword/theme/theme_xml_parser.rb)

```ruby
module Uniword
  module Theme
    class ThemeXmlParser
      # Parse theme1.xml into Theme model
      # @param xml [String] Theme XML content
      # @return [Theme] Parsed theme
      def parse(xml)
        # Parse using Nokogiri
        # Extract color scheme, font scheme, effect scheme
      end

      # Parse theme variant XML
      # @param xml [String] Variant XML content
      # @return [ThemeVariant] Parsed variant
      def parse_variant(xml)
        # Parse variant-specific overrides
      end
    end
  end
end
```

### Phase 2: Extended Domain Models

#### 2.1 Extend Theme Model

**File**: [`lib/uniword/theme.rb`](../lib/uniword/theme.rb:20)

Add support for:

- Theme variants
- Effect schemes
- Theme metadata

```ruby
class Theme < Lutaml::Model::Serializable
  # Existing attributes
  attribute :name, :string
  attr_accessor :color_scheme
  attr_accessor :font_scheme

  # NEW: Add support for variants and effects
  attr_accessor :effect_scheme
  attr_accessor :variants        # Hash of variant_name => ThemeVariant
  attr_accessor :metadata        # ThemeMetadata (author, description, etc.)

  # Load theme from .thmx file
  # @param path [String] Path to .thmx file
  # @param variant [String, nil] Optional variant name
  # @return [Theme] Loaded theme
  def self.from_thmx(path, variant: nil)
    # Use ThemeLoader to load from .thmx file
  end

  # Apply this theme to a document
  # @param document [Document] Target document
  # @param variant [String, nil] Optional variant to apply
  # @return [void]
  def apply_to(document, variant: nil)
    # Use ThemeApplicator to apply theme
  end
end
```

#### 2.2 Create EffectScheme Model

**File**: [`lib/uniword/theme/effect_scheme.rb`](../lib/uniword/theme/effect_scheme.rb)

```ruby
module Uniword
  module Theme
    class EffectScheme < Lutaml::Model::Serializable
      attribute :name, :string

      # Effect definitions for different style types
      attr_accessor :fill_styles      # Array of fill definitions
      attr_accessor :line_styles      # Array of line definitions
      attr_accessor :effect_styles    # Array of effect definitions (shadow, glow, etc.)
      attr_accessor :background_fill  # Background fill style
    end
  end
end
```

#### 2.3 Create ThemeVariant Model

**File**: [`lib/uniword/theme/theme_variant.rb`](../lib/uniword/theme/theme_variant.rb)

```ruby
module Uniword
  module Theme
    class ThemeVariant < Lutaml::Model::Serializable
      attribute :name, :string

      # Variant-specific overrides
      attr_accessor :color_overrides    # ColorScheme overrides
      attr_accessor :font_overrides     # FontScheme overrides
      attr_accessor :effect_overrides   # EffectScheme overrides

      # Apply variant to base theme
      # @param base_theme [Theme] Base theme to modify
      # @return [Theme] New theme with variant applied
      def apply_to(base_theme)
        # Create copy of base theme
        # Apply overrides
      end
    end
  end
end
```

#### 2.4 Create ThemeMetadata Model

**File**: [`lib/uniword/theme/theme_metadata.rb`](../lib/uniword/theme/theme_metadata.rb)

```ruby
module Uniword
  module Theme
    class ThemeMetadata < Lutaml::Model::Serializable
      attribute :author, :string
      attribute :description, :string
      attribute :category, :string
      attribute :version, :string
      attribute :created_at, :string
      attribute :modified_at, :string
    end
  end
end
```

### Phase 3: Theme Loading System

#### 3.1 Create ThemeLoader

**File**: [`lib/uniword/theme/theme_loader.rb`](../lib/uniword/theme/theme_loader.rb)

```ruby
module Uniword
  module Theme
    class ThemeLoader
      # Load theme from .thmx file
      # @param path [String] Path to .thmx file
      # @return [Theme] Loaded theme
      def load(path)
        # 1. Extract .thmx using ThemePackageReader
        # 2. Parse theme1.xml using ThemeXmlParser
        # 3. Parse variants if present
        # 4. Construct Theme model with all components
      end

      # Load theme with specific variant applied
      # @param path [String] Path to .thmx file
      # @param variant_name [String] Variant name
      # @return [Theme] Theme with variant applied
      def load_with_variant(path, variant_name)
        # Load base theme
        # Apply specified variant
      end
    end
  end
end
```

### Phase 4: Theme Application System

#### 4.1 Create ThemeApplicator

**File**: [`lib/uniword/theme/theme_applicator.rb`](../lib/uniword/theme/theme_applicator.rb)

```ruby
module Uniword
  module Theme
    class ThemeApplicator
      # Apply theme to document
      # @param theme [Theme] Theme to apply
      # @param document [Document] Target document
      # @return [void]
      def apply(theme, document)
        # 1. Set document.theme
        # 2. Update style definitions to use theme colors/fonts
        # 3. Update existing content to reference theme colors
        # 4. Ensure theme is serialized in output
      end

      # Apply theme variant to document
      # @param theme [Theme] Base theme
      # @param variant_name [String] Variant to apply
      # @param document [Document] Target document
      # @return [void]
      def apply_variant(theme, variant_name, document)
        # Get variant from theme
        # Create themed copy with variant
        # Apply to document
      end
    end
  end
end
```

### Phase 5: Integration

#### 5.1 Extend Document API

Update [`Document`](../lib/uniword/document.rb:55) class:

```ruby
class Document < Lutaml::Model::Serializable
  # Apply theme from .thmx file
  # @param theme_path [String] Path to .thmx file
  # @param variant [String, nil] Optional variant name
  # @return [void]
  def apply_theme_file(theme_path, variant: nil)
    loader = Theme::ThemeLoader.new
    theme = if variant
              loader.load_with_variant(theme_path, variant)
            else
              loader.load(theme_path)
            end

    applicator = Theme::ThemeApplicator.new
    applicator.apply(theme, self)
  end
end
```

#### 5.2 Extend CLI

Update [`CLI`](../lib/uniword/cli.rb) to support theme files:

```ruby
class Cli < Thor
  desc 'apply-theme', 'Apply a theme to a document'
  option :theme, type: :string, required: true, desc: 'Path to .thmx file'
  option :variant, type: :string, desc: 'Theme variant name'
  option :input, type: :string, required: true, desc: 'Input document'
  option :output, type: :string, required: true, desc: 'Output document'
  def apply_theme
    # Load input document
    # Apply theme
    # Save output document
  end
end
```

#### 5.3 Update OOXMLDeserializer

Enhance theme parsing in [`OOXMLDeserializer`](../lib/uniword/serialization/ooxml_deserializer.rb:901):

```ruby
# Enhanced theme parsing with variants and effects
def parse_theme(theme_xml)
  # Current implementation parses basic theme
  # Extend to:
  # 1. Parse effect schemes
  # 2. Extract theme metadata
  # 3. Support theme variants (if embedded in document)
end
```

#### 5.4 Update OOXMLSerializer

Enhance theme serialization in [`OOXMLSerializer`](../lib/uniword/serialization/ooxml_serializer.rb:1026):

```ruby
# Enhanced theme serialization
def build_theme_xml(theme)
  # Current implementation serializes basic theme
  # Extend to:
  # 1. Serialize effect schemes
  # 2. Include theme metadata
  # 3. Support variant references
end
```

### Phase 6: Testing and Validation

#### 6.1 Unit Tests

Create test files:

- `spec/uniword/theme/theme_package_reader_spec.rb`
- `spec/uniword/theme/theme_xml_parser_spec.rb`
- `spec/uniword/theme/theme_loader_spec.rb`
- `spec/uniword/theme/theme_applicator_spec.rb`
- `spec/uniword/theme/effect_scheme_spec.rb`
- `spec/uniword/theme/theme_variant_spec.rb`

#### 6.2 Integration Tests

Test scenarios:

1. Load .thmx file and extract theme
2. Apply theme to new document
3. Apply theme with variant to document
4. Round-trip: Load themed document, modify, save
5. Verify theme application in generated DOCX

#### 6.3 Validation

Create validation script:

```ruby
# test_theme_application.rb
require 'uniword'

# Test 1: Load Atlas theme
theme = Uniword::Theme.from_thmx('references/word-package/office-themes/Atlas.thmx')
puts "Loaded theme: #{theme.name}"
puts "Colors: #{theme.color_scheme.colors.keys.join(', ')}"

# Test 2: Apply to document
doc = Uniword::Document.new
doc.apply_theme_file('references/word-package/office-themes/Atlas.thmx', variant: 'fancy')
doc.add_paragraph('Themed document')
doc.save('output_themed.docx')

# Test 3: Compare with reference
reference = Uniword::Document.open('namespace_demo_with_atlas_theme_variant_fancy.docx')
puts "Reference theme: #{reference.theme&.name}"
```

## Usage Examples

### Example 1: Apply Theme to New Document

```ruby
require 'uniword'

# Create document
doc = Uniword::Document.new
doc.add_paragraph('My Document')

# Apply theme from .thmx file
doc.apply_theme_file('themes/Atlas.thmx', variant: 'fancy')

# Save
doc.save('output.docx')
```

### Example 2: Load Theme and Use in Builder

```ruby
require 'uniword'

# Load theme
theme = Uniword::Theme.from_thmx('themes/Atlas.thmx', variant: 'fancy')

# Create document with theme
doc = Uniword::Document.new
doc.theme = theme

# Use theme colors in content
doc.add_paragraph('Heading') do |p|
  p.set_style('Heading 1')
  # Heading 1 style will use theme's accent1 color
end

doc.save('output.docx')
```

### Example 3: CLI Usage

```bash
# Apply theme to existing document
uniword apply-theme \
  --theme themes/Atlas.thmx \
  --variant fancy \
  --input document.docx \
  --output themed_document.docx

# Create new document with theme
uniword create \
  --theme themes/Atlas.thmx \
  --output new_themed.docx
```

## File Structure

```
lib/uniword/
├── theme.rb                           # Extended with .thmx support
├── color_scheme.rb                    # Existing
├── font_scheme.rb                     # Existing
└── theme/                             # NEW directory
    ├── theme_package_reader.rb        # Extract .thmx files
    ├── theme_xml_parser.rb            # Parse theme XML
    ├── theme_loader.rb                # Orchestrate loading
    ├── theme_applicator.rb            # Apply themes to documents
    ├── effect_scheme.rb               # Effect definitions
    ├── theme_variant.rb               # Theme variant model
    └── theme_metadata.rb              # Theme metadata model
```

## Dependencies

### Existing Dependencies

- `rubyzip` (already used for DOCX) - for .thmx extraction
- `nokogiri` (already used for XML) - for theme XML parsing
- `lutaml-model` (already used) - for model serialization

### No New Dependencies Required

All functionality can be implemented using existing dependencies.

## Migration Path

1. **Backward Compatibility**: Existing code continues to work
2. **Opt-in Feature**: Theme file support is optional
3. **Gradual Adoption**: Users can start with basic theme support, then add variants
4. **No Breaking Changes**: All new APIs are additive

## Success Criteria

- [ ] Can load .thmx files and extract theme data
- [ ] Can apply themes to new documents
- [ ] Can apply theme variants
- [ ] Theme colors are correctly used in styles
- [ ] Theme fonts are correctly applied
- [ ] Round-trip preserves theme information
- [ ] CLI supports theme operations
- [ ] Comprehensive tests cover all functionality
- [ ] Documentation explains theme usage

## Timeline Estimate

- **Phase 1** (Infrastructure): 2-3 days
- **Phase 2** (Domain Models): 2-3 days
- **Phase 3** (Loading System): 1-2 days
- **Phase 4** (Application System): 2-3 days
- **Phase 5** (Integration): 1-2 days
- **Phase 6** (Testing): 2-3 days

**Total**: 10-16 days

## Next Steps

1. Create analysis script to examine .thmx structure
2. Implement ThemePackageReader
3. Implement ThemeXmlParser
4. Extend Theme model
5. Create ThemeLoader
6. Create ThemeApplicator
7. Integration and testing