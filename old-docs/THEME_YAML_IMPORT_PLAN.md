# Theme YAML Import Architecture

## Overview

Convert all Office .thmx theme files to YAML format and bundle them with uniword for easy access and fast loading.

## YAML Theme File Format

### Structure

```yaml
---
name: "Atlas"
source: "Atlas.thmx"
imported_at: "2025-10-31T23:19:00Z"

color_scheme:
  name: "Atlas"
  colors:
    dk1: "000000"
    lt1: "FFFFFF"
    dk2: "454545"
    lt2: "E0E0E0"
    accent1: "F81B02"
    accent2: "FC7715"
    accent3: "F05A28"
    accent4: "FF0000"
    accent5: "7CAFDD"
    accent6: "4E8542"
    hlink: "0563C1"
    folHlink: "954F72"

font_scheme:
  name: "Atlas"
  major_font: "Calibri Light"
  minor_font: "Rockwell"
  # Optional: script-specific fonts
  major_east_asian: null
  major_complex_script: null
  minor_east_asian: null
  minor_complex_script: null

variants:
  variant1:
    color_scheme:
      name: "Atlas"
      colors:
        dk1: "000000"
        lt1: "FFFFFF"
        # ... variant colors
    font_scheme:
      name: "Atlas"
      major_font: "Calibri Light"
      minor_font: "Rockwell"

  variant2:
    color_scheme:
      # ... variant2 colors
    font_scheme:
      # ... variant2 fonts

  # ... more variants
```

### Benefits

1. **Human-readable** - Easy to view and modify
2. **Fast loading** - No ZIP extraction required
3. **Bundled** - Themes included with gem
4. **Version control friendly** - Text format diffs well
5. **Editable** - Users can create custom themes easily

## Directory Structure

```
data/
└── themes/
    ├── office_theme.yml        # Office Theme
    ├── atlas.yml               # Atlas theme
    ├── badge.yml               # Badge theme
    ├── berlin.yml              # Berlin theme
    ├── celestial.yml           # Celestial theme
    ├── crop.yml                # Crop theme
    ├── depth.yml               # Depth theme
    ├── droplet.yml             # Droplet theme
    ├── facet.yml               # Facet theme
    ├── feathered.yml           # Feathered theme
    ├── gallery.yml             # Gallery theme
    ├── headlines.yml           # Headlines theme
    ├── integral.yml            # Integral theme
    ├── ion.yml                 # Ion theme
    ├── ion_boardroom.yml       # Ion Boardroom theme
    ├── madison.yml             # Madison theme
    ├── main_event.yml          # Main Event theme
    ├── mesh.yml                # Mesh theme
    ├── office_2013_2022.yml    # Office 2013-2022 theme
    ├── organic.yml             # Organic theme
    ├── parallax.yml            # Parallax theme
    ├── parcel.yml              # Parcel theme
    ├── retrospect.yml          # Retrospect theme
    ├── savon.yml               # Savon theme
    ├── slice.yml               # Slice theme
    ├── vapor_trail.yml         # Vapor Trail theme
    ├── view.yml                # View theme
    ├── wisp.yml                # Wisp theme
    └── wood_type.yml           # Wood Type theme
```

## Implementation Components

### 1. Theme Importer (`lib/uniword/themes/theme_importer.rb`)

```ruby
module Uniword
  module Themes
    class ThemeImporter
      # Import .thmx file to YAML
      #
      # @param thmx_path [String] Path to .thmx file
      # @param output_path [String] Output YAML path
      # @return [void]
      def import(thmx_path, output_path)
        # Load theme using existing ThemeLoader
        loader = ThemeLoader.new
        theme = loader.load(thmx_path)

        # Convert to YAML-friendly hash
        theme_data = serialize_theme(theme)

        # Write YAML file
        File.write(output_path, YAML.dump(theme_data))
      end

      # Import all themes from directory
      #
      # @param source_dir [String] Directory with .thmx files
      # @param output_dir [String] Output directory for YAML files
      # @return [void]
      def import_all(source_dir, output_dir)
        Dir.glob("#{source_dir}/*.thmx").each do |thmx_file|
          theme_name = theme_name_from_file(thmx_file)
          output_file = "#{output_dir}/#{theme_name}.yml"
          import(thmx_file, output_file)
        end
      end

      private

      def serialize_theme(theme)
        {
          'name' => theme.name,
          'source' => theme.source_file,
          'imported_at' => Time.now.utc.iso8601,
          'color_scheme' => serialize_color_scheme(theme.color_scheme),
          'font_scheme' => serialize_font_scheme(theme.font_scheme),
          'variants' => serialize_variants(theme.variants)
        }
      end

      def serialize_color_scheme(color_scheme)
        {
          'name' => color_scheme.name,
          'colors' => color_scheme.colors.transform_keys(&:to_s)
        }
      end

      def serialize_font_scheme(font_scheme)
        {
          'name' => font_scheme.name,
          'major_font' => font_scheme.major_font,
          'minor_font' => font_scheme.minor_font,
          'major_east_asian' => font_scheme.major_east_asian,
          'major_complex_script' => font_scheme.major_complex_script,
          'minor_east_asian' => font_scheme.minor_east_asian,
          'minor_complex_script' => font_scheme.minor_complex_script
        }
      end

      def serialize_variants(variants)
        result = {}
        variants.each do |variant_id, variant|
          variant.parse_theme
          result[variant_id] = {
            'color_scheme' => serialize_color_scheme(variant.theme.color_scheme),
            'font_scheme' => serialize_font_scheme(variant.theme.font_scheme)
          }
        end
        result
      end

      def theme_name_from_file(path)
        File.basename(path, '.thmx')
          .downcase
          .gsub(/[^a-z0-9]+/, '_')
          .gsub(/^_|_$/, '')
      end
    end
  end
end
```

### 2. YAML Theme Loader (`lib/uniword/themes/yaml_theme_loader.rb`)

```ruby
module Uniword
  module Themes
    class YamlThemeLoader
      # Load theme from YAML file
      #
      # @param path [String] Path to YAML file
      # @param variant [String, Integer, nil] Optional variant to apply
      # @return [Theme] Loaded theme
      def load(path, variant: nil)
        data = YAML.load_file(path)

        # Create theme from YAML data
        theme = deserialize_theme(data)

        # Apply variant if specified
        if variant
          variant_key = normalize_variant_id(variant)
          apply_variant(theme, data['variants'][variant_key])
        end

        theme
      end

      # List all available bundled themes
      #
      # @return [Array<String>] Theme names
      def self.available_themes
        theme_dir = File.join(__dir__, '../../..', 'data', 'themes')
        Dir.glob("#{theme_dir}/*.yml").map do |path|
          File.basename(path, '.yml')
        end
      end

      # Load bundled theme by name
      #
      # @param name [String] Theme name (e.g., 'atlas', 'office_theme')
      # @param variant [String, Integer, nil] Optional variant
      # @return [Theme] Loaded theme
      def self.load_bundled(name, variant: nil)
        theme_dir = File.join(__dir__, '../../..', 'data', 'themes')
        path = File.join(theme_dir, "#{name}.yml")

        unless File.exist?(path)
          raise ArgumentError,
                "Theme '#{name}' not found. Available: #{available_themes.join(', ')}"
        end

        new.load(path, variant: variant)
      end

      private

      def deserialize_theme(data)
        theme = Theme.new(name: data['name'])

        # Deserialize color scheme
        theme.color_scheme = deserialize_color_scheme(data['color_scheme'])

        # Deserialize font scheme
        theme.font_scheme = deserialize_font_scheme(data['font_scheme'])

        # Deserialize variants
        theme.variants = deserialize_variants(data['variants'])

        theme
      end

      def deserialize_color_scheme(data)
        scheme = ColorScheme.new(name: data['name'])
        data['colors'].each do |color_name, color_value|
          scheme[color_name.to_sym] = color_value
        end
        scheme
      end

      def deserialize_font_scheme(data)
        scheme = FontScheme.new(name: data['name'])
        scheme.major_font = data['major_font']
        scheme.minor_font = data['minor_font']
        scheme.major_east_asian = data['major_east_asian']
        scheme.major_complex_script = data['major_complex_script']
        scheme.minor_east_asian = data['minor_east_asian']
        scheme.minor_complex_script = data['minor_complex_script']
        scheme
      end

      def deserialize_variants(variants_data)
        return {} unless variants_data

        variants = {}
        variants_data.each do |variant_id, variant_data|
          variant = ThemeVariant.new(variant_id)

          # Create a theme for this variant
          variant_theme = Theme.new
          variant_theme.color_scheme = deserialize_color_scheme(variant_data['color_scheme'])
          variant_theme.font_scheme = deserialize_font_scheme(variant_data['font_scheme'])
          variant.theme = variant_theme

          variants[variant_id] = variant
        end
        variants
      end

      def apply_variant(theme, variant_data)
        return unless variant_data

        # Apply variant colors
        variant_data['color_scheme']['colors'].each do |color_name, color_value|
          theme.color_scheme[color_name.to_sym] = color_value
        end

        # Apply variant fonts
        theme.font_scheme.major_font = variant_data['font_scheme']['major_font']
        theme.font_scheme.minor_font = variant_data['font_scheme']['minor_font']
      end

      def normalize_variant_id(variant_id)
        case variant_id
        when Integer
          "variant#{variant_id}"
        when /^\d+$/
          "variant#{variant_id}"
        else
          variant_id.to_s
        end
      end
    end
  end
end
```

### 3. Update Theme Class

Add convenience methods to Theme class:

```ruby
class Theme
  # Load theme from YAML file
  #
  # @param path [String] Path to YAML file or theme name
  # @param variant [String, Integer, nil] Optional variant
  # @return [Theme] Loaded theme
  def self.from_yaml(path, variant: nil)
    require_relative 'themes/yaml_theme_loader'

    loader = Themes::YamlThemeLoader.new
    loader.load(path, variant: variant)
  end

  # Load bundled theme by name
  #
  # @param name [String] Theme name (e.g., 'atlas', 'office_theme')
  # @param variant [String, Integer, nil] Optional variant
  # @return [Theme] Loaded theme
  def self.load(name, variant: nil)
    require_relative 'themes/yaml_theme_loader'

    Themes::YamlThemeLoader.load_bundled(name, variant: variant)
  end

  # List all available bundled themes
  #
  # @return [Array<String>] Theme names
  def self.available_themes
    require_relative 'themes/yaml_theme_loader'

    Themes::YamlThemeLoader.available_themes
  end
end
```

### 4. Import Script (`bin/import_themes`)

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/uniword'

# Import all Office themes to YAML
importer = Uniword::Themes::ThemeImporter.new

source_dir = 'references/word-package/office-themes'
output_dir = 'data/themes'

# Create output directory
FileUtils.mkdir_p(output_dir)

# Import all themes
puts "Importing themes from #{source_dir}..."
importer.import_all(source_dir, output_dir)

puts "Themes imported successfully to #{output_dir}"
puts "Total themes: #{Dir.glob("#{output_dir}/*.yml").count}"
```

### 5. CLI Command

Add to CLI:

```ruby
desc 'import-themes', 'Import .thmx files to YAML theme library'
long_desc <<~DESC
  Import Office theme (.thmx) files to YAML format for bundling with gem.

  Examples:
    $ uniword import-themes references/word-package/office-themes data/themes
    $ uniword import-themes --source themes/ --output data/themes
DESC
option :source, type: :string, default: 'references/word-package/office-themes',
       desc: 'Source directory with .thmx files'
option :output, type: :string, default: 'data/themes',
       desc: 'Output directory for YAML files'
def import_themes
  require_relative 'themes/theme_importer'

  importer = Themes::ThemeImporter.new
  importer.import_all(options[:source], options[:output])

  count = Dir.glob("#{options[:output]}/*.yml").count
  say "Imported #{count} themes to #{options[:output]}", :green
end

desc 'list-themes', 'List all available bundled themes'
def list_themes
  themes = Theme.available_themes

  say "Available themes (#{themes.count}):", :green
  themes.sort.each do |theme_name|
    say "  - #{theme_name}"
  end
end
```

## Usage Examples

### After Import

```ruby
# Load bundled theme by name
theme = Uniword::Theme.load('atlas')
theme = Uniword::Theme.load('atlas', variant: 2)

# Load from YAML file
theme = Uniword::Theme.from_yaml('custom_theme.yml')

# List available themes
themes = Uniword::Theme.available_themes
# => ["atlas", "badge", "berlin", ...]

# Apply to document
doc = Uniword::Document.new
doc.add_paragraph('Themed Document')
theme = Uniword::Theme.load('atlas', variant: 2)
theme.apply_to(doc)
doc.save('output.docx')

# Or shorthand
doc.apply_theme('atlas', variant: 2)
```

### CLI

```bash
# Import themes
uniword import-themes

# List themes
uniword list-themes

# Apply bundled theme
uniword apply-theme input.docx output.docx --theme atlas --variant 2
```

## Migration Path

1. Keep `.from_thmx()` method for custom .thmx files
2. Add `.load()` method for bundled themes
3. Update documentation to prefer bundled themes
4. Deprecate .thmx in future version (optional)

## Benefits

- **No external files needed** - Themes bundled with gem
- **Faster loading** - YAML parsing vs ZIP extraction + XML parsing
- **Easier distribution** - Include themes in gem package
- **Version control** - Text diffs for theme changes
- **User customization** - Easy to create custom YAML themes
- **Smaller size** - YAML more compact than .thmx packages

## Implementation Steps

1. Create `data/themes` directory
2. Implement `ThemeImporter`
3. Implement `YamlThemeLoader`
4. Run import script on all Office themes
5. Update `Theme` class with new methods
6. Add CLI commands
7. Update documentation
8. Test with all imported themes

## Future Enhancements

- Theme preview generation
- Theme validation
- Theme merging/inheritance
- Custom theme builder
- Theme metadata (author, description, tags)