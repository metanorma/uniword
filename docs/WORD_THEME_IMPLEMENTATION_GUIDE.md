# Word Theme Implementation Quick Start Guide

## Overview

This guide provides step-by-step instructions for implementing Word theme (.thmx) support in uniword based on the [architecture](WORD_THEME_ARCHITECTURE.md) and [technical analysis](WORD_THEME_TECHNICAL_ANALYSIS.md).

## Prerequisites

Read these documents first:
- [Word Theme Architecture](WORD_THEME_ARCHITECTURE.md) - Overall design
- [Word Theme Technical Analysis](WORD_THEME_TECHNICAL_ANALYSIS.md) - Detailed specifications

## Implementation Phases

### Phase 1: Theme Package Infrastructure (Days 1-3)

#### Step 1.1: Create Theme Module Structure

```bash
mkdir -p lib/uniword/theme
```

Create the following files:
- `lib/uniword/theme/theme_package_reader.rb`
- `lib/uniword/theme/theme_xml_parser.rb`

#### Step 1.2: Implement ThemePackageReader

**File**: `lib/uniword/theme/theme_package_reader.rb`

```ruby
# frozen_string_literal: true

module Uniword
  module Theme
    # Reads and extracts .thmx theme package files
    #
    # .thmx files are ZIP archives containing theme definitions
    # and optional variant files.
    class ThemePackageReader
      # Extract theme files from .thmx package
      #
      # @param path [String] Path to .thmx file
      # @return [Hash] Extracted files
      #   - 'theme/theme1.xml' => theme XML content
      #   - 'theme/themeVariant/*.xml' => variant XML content (if present)
      def extract(path)
        require_relative '../infrastructure/zip_extractor'

        extractor = Infrastructure::ZipExtractor.new
        content = extractor.extract(path)

        # Filter to theme-related files only
        theme_files = {}
        content.each do |file_path, file_content|
          if file_path.start_with?('theme/')
            theme_files[file_path] = file_content
          end
        end

        validate_theme_package(theme_files)
        theme_files
      end

      private

      # Validate that required theme files are present
      #
      # @param files [Hash] Extracted theme files
      # @raise [ArgumentError] if theme1.xml is missing
      def validate_theme_package(files)
        unless files.key?('theme/theme1.xml')
          raise ArgumentError, 'Invalid theme package: missing theme/theme1.xml'
        end
      end
    end
  end
end
```

#### Step 1.3: Implement ThemeXmlParser (Basic)

**File**: `lib/uniword/theme/theme_xml_parser.rb`

Start with basic parsing, extend in later phases:

```ruby
# frozen_string_literal: true

require 'nokogiri'

module Uniword
  module Theme
    # Parses theme XML files into Theme models
    class ThemeXmlParser
      THEME_NS = { 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main' }.freeze

      # Parse theme1.xml into Theme model
      #
      # @param xml [String] Theme XML content
      # @return [Theme] Parsed theme
      def parse(xml)
        doc = Nokogiri::XML(xml)
        theme_node = doc.at_xpath('//a:theme', THEME_NS)

        raise ArgumentError, 'Invalid theme XML: missing theme element' unless theme_node

        theme = ::Uniword::Theme.new
        theme.name = theme_node['name'] || 'Untitled Theme'

        # Parse color scheme
        color_scheme_node = doc.at_xpath('//a:themeElements/a:clrScheme', THEME_NS)
        theme.color_scheme = parse_color_scheme(color_scheme_node) if color_scheme_node

        # Parse font scheme
        font_scheme_node = doc.at_xpath('//a:themeElements/a:fontScheme', THEME_NS)
        theme.font_scheme = parse_font_scheme(font_scheme_node) if font_scheme_node

        theme
      end

      private

      # Parse color scheme from XML
      #
      # @param node [Nokogiri::XML::Element] Color scheme node
      # @return [ColorScheme] Parsed color scheme
      def parse_color_scheme(node)
        require_relative '../color_scheme'

        scheme = ColorScheme.new
        scheme.name = node['name'] || 'Color Scheme'

        # Parse each theme color
        ColorScheme::THEME_COLORS.each do |color_name|
          color_node = node.at_xpath("a:#{color_name}", THEME_NS)
          next unless color_node

          color_value = extract_color_value(color_node)
          scheme[color_name] = color_value if color_value
        end

        scheme
      end

      # Extract color value from color node
      #
      # @param node [Nokogiri::XML::Element] Color node
      # @return [String, nil] RGB hex value
      def extract_color_value(node)
        # Try sRGB color first
        srgb_node = node.at_xpath('.//a:srgbClr', THEME_NS)
        return srgb_node['val'] if srgb_node

        # Try system color
        sys_node = node.at_xpath('.//a:sysClr', THEME_NS)
        return sys_node['lastClr'] if sys_node

        # Default fallback
        nil
      end

      # Parse font scheme from XML
      #
      # @param node [Nokogiri::XML::Element] Font scheme node
      # @return [FontScheme] Parsed font scheme
      def parse_font_scheme(node)
        require_relative '../font_scheme'

        scheme = FontScheme.new
        scheme.name = node['name'] || 'Font Scheme'

        # Parse major font (headings)
        major_node = node.at_xpath('a:majorFont/a:latin', THEME_NS)
        scheme.major_font = major_node['typeface'] if major_node

        # Parse minor font (body)
        minor_node = node.at_xpath('a:minorFont/a:latin', THEME_NS)
        scheme.minor_font = minor_node['typeface'] if minor_node

        scheme
      end
    end
  end
end
```

#### Step 1.4: Create Tests

**File**: `spec/uniword/theme/theme_package_reader_spec.rb`

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Theme::ThemePackageReader do
  let(:reader) { described_class.new }
  let(:theme_path) { 'references/word-package/office-themes/Office Theme.thmx' }

  describe '#extract' do
    it 'extracts theme files from .thmx package' do
      files = reader.extract(theme_path)

      expect(files).to have_key('theme/theme1.xml')
      expect(files['theme/theme1.xml']).to include('<?xml')
    end

    it 'raises error for invalid theme package' do
      # Create invalid .thmx without theme1.xml
      expect {
        reader.extract('invalid.thmx')
      }.to raise_error(ArgumentError)
    end
  end
end
```

### Phase 2: Domain Model Extensions (Days 4-6)

#### Step 2.1: Extend Theme Model

**File**: `lib/uniword/theme.rb`

Add to existing Theme class:

```ruby
# Add these attributes after existing attributes
attr_accessor :variants        # Hash of variant_name => ThemeVariant
attr_accessor :source_file     # Original .thmx file path (for reference)

# Class method to load from .thmx
#
# @param path [String] Path to .thmx file
# @param variant [String, nil] Optional variant name to apply
# @return [Theme] Loaded theme
def self.from_thmx(path, variant: nil)
  require_relative 'theme/theme_loader'

  loader = Theme::ThemeLoader.new
  if variant
    loader.load_with_variant(path, variant)
  else
    loader.load(path)
  end
end

# Apply this theme to a document
#
# @param document [Document] Target document
# @param variant [String, nil] Optional variant to apply
# @return [void]
def apply_to(document, variant: nil)
  require_relative 'theme/theme_applicator'

  applicator = Theme::ThemeApplicator.new
  if variant && variants&.key?(variant)
    # Apply with variant
    themed = variants[variant].apply_to(self)
    applicator.apply(themed, document)
  else
    # Apply base theme
    applicator.apply(self, document)
  end
end
```

#### Step 2.2: Create ThemeVariant Model

**File**: `lib/uniword/theme/theme_variant.rb`

```ruby
# frozen_string_literal: true

module Uniword
  module Theme
    # Represents a theme variant
    #
    # Variants provide style variations of a base theme
    class ThemeVariant
      attr_accessor :name
      attr_accessor :color_overrides
      attr_accessor :font_overrides

      def initialize(name = nil)
        @name = name
        @color_overrides = {}
        @font_overrides = {}
      end

      # Apply this variant to a base theme
      #
      # @param base_theme [Theme] Base theme
      # @return [Theme] New theme with variant applied
      def apply_to(base_theme)
        themed = base_theme.dup

        # Apply color overrides
        color_overrides.each do |color_name, color_value|
          themed.color_scheme[color_name] = color_value
        end

        # Apply font overrides
        themed.font_scheme.major_font = font_overrides[:major] if font_overrides[:major]
        themed.font_scheme.minor_font = font_overrides[:minor] if font_overrides[:minor]

        themed
      end
    end
  end
end
```

### Phase 3: Theme Loading System (Days 7-8)

#### Step 3.1: Create ThemeLoader

**File**: `lib/uniword/theme/theme_loader.rb`

```ruby
# frozen_string_literal: true

module Uniword
  module Theme
    # Orchestrates theme loading from .thmx files
    class ThemeLoader
      # Load theme from .thmx file
      #
      # @param path [String] Path to .thmx file
      # @return [Theme] Loaded theme
      def load(path)
        # Extract package
        reader = ThemePackageReader.new
        files = reader.extract(path)

        # Parse main theme
        parser = ThemeXmlParser.new
        theme = parser.parse(files['theme/theme1.xml'])
        theme.source_file = path

        # Load variants if present
        theme.variants = load_variants(files)

        theme
      end

      # Load theme with specific variant applied
      #
      # @param path [String] Path to .thmx file
      # @param variant_name [String] Variant name
      # @return [Theme] Theme with variant applied
      def load_with_variant(path, variant_name)
        base_theme = load(path)

        variant = base_theme.variants[variant_name]
        raise ArgumentError, "Variant '#{variant_name}' not found" unless variant

        variant.apply_to(base_theme)
      end

      private

      # Load all variants from theme package
      #
      # @param files [Hash] Extracted theme files
      # @return [Hash] variant_name => ThemeVariant
      def load_variants(files)
        variants = {}

        files.each do |path, content|
          next unless path.start_with?('theme/themeVariant/')

          variant_name = File.basename(path, '.xml')
          # For now, create empty variant (full parsing in later iteration)
          variants[variant_name] = ThemeVariant.new(variant_name)
        end

        variants
      end
    end
  end
end
```

### Phase 4: Theme Application (Days 9-10)

#### Step 4.1: Create ThemeApplicator

**File**: `lib/uniword/theme/theme_applicator.rb`

```ruby
# frozen_string_literal: true

module Uniword
  module Theme
    # Applies themes to documents
    class ThemeApplicator
      # Apply theme to document
      #
      # @param theme [Theme] Theme to apply
      # @param document [Document] Target document
      # @return [void]
      def apply(theme, document)
        # Set document theme
        document.theme = theme.dup

        # Update styles to reference theme (future enhancement)
        # For now, just setting theme is sufficient for basic support
      end
    end
  end
end
```

### Phase 5: Integration (Days 11-12)

#### Step 5.1: Extend Document API

**File**: `lib/uniword/document.rb`

Add method around line 411 (after `apply_template`):

```ruby
# Apply theme from .thmx file
#
# @param theme_path [String] Path to .thmx file
# @param variant [String, nil] Optional variant name
# @return [void]
#
# @example Apply theme
#   doc.apply_theme_file('themes/Atlas.thmx')
#
# @example Apply theme with variant
#   doc.apply_theme_file('themes/Atlas.thmx', variant: 'fancy')
def apply_theme_file(theme_path, variant: nil)
  self.theme = Theme.from_thmx(theme_path, variant: variant)
end
```

#### Step 5.2: Update CLI

**File**: `lib/uniword/cli.rb`

Add new command:

```ruby
desc 'apply-theme', 'Apply a theme to a document'
option :theme, type: :string, required: true,
       desc: 'Path to .thmx theme file'
option :variant, type: :string,
       desc: 'Theme variant name (optional)'
option :input, type: :string, required: true,
       desc: 'Input document path'
option :output, type: :string, required: true,
       desc: 'Output document path'
def apply_theme
  require_relative 'document'

  # Load input document
  doc = Document.open(options[:input])

  # Apply theme
  doc.apply_theme_file(options[:theme], variant: options[:variant])

  # Save output
  doc.save(options[:output])

  puts "Theme applied successfully to #{options[:output]}"
rescue StandardError => e
  puts "Error applying theme: #{e.message}"
  exit 1
end
```

### Phase 6: Testing (Days 13-14)

#### Step 6.1: Create Integration Test

**File**: `test_theme_application.rb`

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

# Test 1: Load Office Theme
puts "Test 1: Loading Office Theme..."
theme = Uniword::Theme.from_thmx('references/word-package/office-themes/Office Theme.thmx')
puts "✓ Loaded: #{theme.name}"
puts "  Colors: #{theme.color_scheme.colors.keys.join(', ')}"
puts "  Major font: #{theme.font_scheme.major_font}"
puts "  Minor font: #{theme.font_scheme.minor_font}"
puts

# Test 2: Load Atlas Theme
puts "Test 2: Loading Atlas Theme..."
atlas = Uniword::Theme.from_thmx('references/word-package/office-themes/Atlas.thmx')
puts "✓ Loaded: #{atlas.name}"
puts "  Variants: #{atlas.variants.keys.join(', ')}" if atlas.variants.any?
puts

# Test 3: Apply theme to new document
puts "Test 3: Creating themed document..."
doc = Uniword::Document.new
doc.add_paragraph('Sample Document', heading: :heading_1)
doc.add_paragraph('This document uses the Atlas theme.')
doc.apply_theme_file('references/word-package/office-themes/Atlas.thmx')
doc.save('output_atlas_themed.docx')
puts "✓ Saved: output_atlas_themed.docx"
puts

# Test 4: Compare with reference
puts "Test 4: Comparing with reference document..."
reference = Uniword::Document.open('namespace_demo_with_atlas_theme_variant_fancy.docx')
puts "  Reference theme: #{reference.theme&.name}"
puts "  Reference colors: #{reference.theme&.color_scheme&.colors&.keys&.join(', ')}"
puts

puts "All tests completed!"
```

Run with:
```bash
ruby test_theme_application.rb
```

## Quick Reference

### Loading a Theme

```ruby
# Load theme
theme = Uniword::Theme.from_thmx('path/to/theme.thmx')

# Load with variant
theme = Uniword::Theme.from_thmx('path/to/theme.thmx', variant: 'fancy')
```

### Applying to Document

```ruby
# Method 1: During creation
doc = Uniword::Document.new
doc.apply_theme_file('path/to/theme.thmx')

# Method 2: Using theme object
theme = Uniword::Theme.from_thmx('path/to/theme.thmx')
doc.theme = theme

# Method 3: With variant
doc.apply_theme_file('path/to/theme.thmx', variant: 'fancy')
```

### CLI Usage

```bash
# Apply theme
uniword apply-theme \
  --theme references/word-package/office-themes/Atlas.thmx \
  --input document.docx \
  --output themed_document.docx

# Apply with variant
uniword apply-theme \
  --theme references/word-package/office-themes/Atlas.thmx \
  --variant fancy \
  --input document.docx \
  --output themed_document.docx
```

## Development Workflow

1. **Start with Phase 1**: Get basic .thmx extraction working
2. **Validate with real files**: Test with Office Theme.thmx first
3. **Extend incrementally**: Add variant support in Phase 2
4. **Test continuously**: Run tests after each phase
5. **Compare with reference**: Use namespace_demo document as validation

## Common Issues and Solutions

### Issue: "Invalid theme package"
**Solution**: Verify .thmx file is valid ZIP and contains theme/theme1.xml

### Issue: Colors not appearing correctly
**Solution**: Check color parsing logic handles all color types (srgbClr, sysClr)

### Issue: Fonts not applying
**Solution**: Ensure font scheme parser extracts both major and minor fonts

### Issue: Variant not found
**Solution**: List available variants with `theme.variants.keys`

## Next Steps After Implementation

1. **Enhance color parsing**: Support color transformations (tint, shade)
2. **Full variant support**: Parse variant XML completely
3. **Effect schemes**: Add support for visual effects
4. **Style integration**: Automatically update styles to use theme references
5. **Theme registry**: Cache loaded themes for performance

## Resources

- [Architecture Document](WORD_THEME_ARCHITECTURE.md)
- [Technical Analysis](WORD_THEME_TECHNICAL_ANALYSIS.md)
- [ISO 29500-1](http://www.ecma-international.org/publications/standards/Ecma-376.htm) - DrawingML specification
- Reference .thmx files in `references/word-package/office-themes/`
- Reference document: `namespace_demo_with_atlas_theme_variant_fancy.docx`