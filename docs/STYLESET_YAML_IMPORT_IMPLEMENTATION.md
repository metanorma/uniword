# StyleSet YAML Import System Implementation

## Overview

Successfully implemented the StyleSet YAML import system following the theme system pattern. This enables StyleSets to be:
1. Imported from .dotx files to YAML format
2. Bundled with the gem
3. Loaded from YAML for use in documents

## Implementation Summary

### Files Created

#### 1. Style YAML Serialization
**File**: [`lib/uniword/style.rb`](lib/uniword/style.rb:23)

Added YAML serialization mapping to the [`Style`](lib/uniword/style.rb:12) class:

```ruby
# YAML serialization (for bundled stylesets)
yaml do
  map 'id', to: :id
  map 'type', to: :type
  map 'name', to: :name
  map 'default', to: :default
  map 'custom', to: :custom
  map 'based_on', to: :based_on
  map 'next_style', to: :next_style
  map 'linked_style', to: :linked_style
  map 'ui_priority', to: :ui_priority
  map 'quick_format', to: :quick_format
end
```

#### 2. StyleSetImporter
**File**: [`lib/uniword/stylesets/styleset_importer.rb`](lib/uniword/stylesets/styleset_importer.rb:1)

Imports .dotx files to YAML format:

```ruby
# Import single StyleSet
importer = Uniword::StyleSets::StyleSetImporter.new
importer.import('Distinctive.dotx', 'data/stylesets/distinctive.yml')

# Import all StyleSets from directory
importer.import_all('stylesets/', 'data/stylesets/')
```

**Key Methods**:
- [`import(dotx_path, output_path)`](lib/uniword/stylesets/styleset_importer.rb:26) - Convert single StyleSet
- [`import_all(source_dir, output_dir)`](lib/uniword/stylesets/styleset_importer.rb:48) - Batch import
- [`serialize_styleset(styleset, source_file)`](lib/uniword/stylesets/styleset_importer.rb:71) - Convert to YAML hash

**Serialization Format**:
```yaml
name: Distinctive
source: Distinctive.dotx
imported_at: '2025-11-01T05:30:00Z'
styles:
  - id: Normal
    type: paragraph
    name: Normal
    default: true
  - id: Heading1
    type: paragraph
    name: Heading 1
    based_on: Normal
    next_style: Normal
    ui_priority: 10
    quick_format: true
```

#### 3. YamlStyleSetLoader
**File**: [`lib/uniword/stylesets/yaml_styleset_loader.rb`](lib/uniword/stylesets/yaml_styleset_loader.rb:1)

Loads StyleSets from YAML files:

```ruby
# Load from file
loader = Uniword::StyleSets::YamlStyleSetLoader.new
styleset = loader.load('custom_styleset.yml')

# Load bundled StyleSet
styleset = Uniword::StyleSets::YamlStyleSetLoader.load_bundled('distinctive')

# List available bundled StyleSets
available = Uniword::StyleSets::YamlStyleSetLoader.available_stylesets
```

**Key Methods**:
- [`load(path)`](lib/uniword/stylesets/yaml_styleset_loader.rb:24) - Load from YAML file
- [`load_bundled(name)`](lib/uniword/stylesets/yaml_styleset_loader.rb:52) - Load bundled StyleSet
- [`available_stylesets()`](lib/uniword/stylesets/yaml_styleset_loader.rb:36) - List available StyleSets

#### 4. CLI Tool
**File**: [`bin/import_stylesets.rb`](bin/import_stylesets.rb:1)

Command-line tool for batch importing StyleSets:

```bash
ruby bin/import_stylesets.rb
```

**Configuration**:
- Source: `references/word-package/stylesets/`
- Output: `data/stylesets/`

## Architecture

The implementation follows the exact pattern used for themes:

```
StyleSet (.dotx) Loading:
  .dotx file
    ↓
  StyleSetPackageReader (ZIP extraction)
    ↓
  StyleSetXmlParser (XML → Style objects)
    ↓
  StyleSetLoader (orchestration)
    ↓
  StyleSet object

YAML Import/Export:
  .dotx file
    ↓
  StyleSetLoader.load()
    ↓
  StyleSet object
    ↓
  StyleSetImporter.serialize_styleset()
    ↓
  YAML file (data/stylesets/)
    ↓
  YamlStyleSetLoader.load()
    ↓
  StyleSet object
```

## Usage Examples

### 1. Import StyleSets

```ruby
require 'uniword/stylesets/styleset_importer'

# Import single StyleSet
importer = Uniword::StyleSets::StyleSetImporter.new
importer.import(
  'references/word-package/stylesets/Distinctive.dotx',
  'data/stylesets/distinctive.yml'
)

# Batch import all StyleSets
count = importer.import_all(
  'references/word-package/stylesets',
  'data/stylesets'
)
puts "Imported #{count} StyleSets"
```

### 2. Load from YAML

```ruby
require 'uniword/stylesets/yaml_styleset_loader'

# Load custom YAML file
loader = Uniword::StyleSets::YamlStyleSetLoader.new
styleset = loader.load('my_styleset.yml')

# Load bundled StyleSet
styleset = Uniword::StyleSets::YamlStyleSetLoader.load_bundled('distinctive')

# Check what's available
available = Uniword::StyleSets::YamlStyleSetLoader.available_stylesets
puts "Available StyleSets: #{available.join(', ')}"
```

### 3. Apply to Document

```ruby
# Load bundled StyleSet
styleset = Uniword::StyleSets::YamlStyleSetLoader.load_bundled('distinctive')

# Apply to document
doc = Uniword::Document.new
styleset.apply_to(doc, strategy: :keep_existing)

# Or with different strategy
styleset.apply_to(doc, strategy: :replace)
```

## Data Format

### YAML Structure

```yaml
name: Distinctive              # StyleSet name
source: Distinctive.dotx       # Original .dotx file
imported_at: 2025-11-01T05:30:00Z  # Import timestamp
styles:                        # Array of styles
  - id: Normal                 # Style ID (required)
    type: paragraph            # Style type (required)
    name: Normal               # Display name (required)
    default: true              # Is default style (optional)
    custom: false              # Is custom style (optional)
    based_on: null             # Base style ID (optional)
    next_style: Normal         # Next paragraph style (optional)
    linked_style: null         # Linked style (optional)
    ui_priority: 1             # UI priority (optional)
    quick_format: false        # Quick format gallery (optional)
```

### Style Types

- `paragraph` - Paragraph styles
- `character` - Character/run styles
- `table` - Table styles
- `numbering` - Numbering styles

## Bundled StyleSets Location

Bundled StyleSets are stored in:
```
data/stylesets/
  distinctive.yml
  basic.yml
  ...
```

## Integration with StyleSet Class

The [`StyleSet`](lib/uniword/styleset.rb:20) class already has YAML serialization defined:

```ruby
class StyleSet < Lutaml::Model::Serializable
  yaml do
    map 'name', to: :name
    map 'source_file', to: :source_file
    map 'styles', to: :styles
  end
end
```

However, we use manual serialization/deserialization via [`StyleSetImporter`](lib/uniword/stylesets/styleset_importer.rb:20) and [`YamlStyleSetLoader`](lib/uniword/stylesets/yaml_styleset_loader.rb:18) to maintain full control over the format and handle nested Style objects properly.

## Benefits

1. **Human-Readable**: YAML format is easy to read and edit
2. **Version Control**: Can track changes to StyleSets in git
3. **Bundling**: Ship common StyleSets with the gem
4. **No Dependencies**: Don't need .dotx files at runtime
5. **Fast Loading**: YAML parsing is faster than ZIP+XML
6. **Portable**: Works across platforms without binary dependencies

## Future Enhancements

Potential improvements:

1. **Validation**: Add schema validation for YAML files
2. **Merging**: Support merging multiple StyleSets
3. **Filtering**: Import only specific style types
4. **Templates**: Create StyleSets from templates
5. **Export**: Export document styles to StyleSet YAML

## Testing

The system has been tested with:
- Manual YAML serialization/deserialization
- Style attribute preservation
- Round-trip compatibility
- Bundled StyleSet loading

## Related Documentation

- [Theme YAML Import Implementation](THEME_YAML_IMPORT_PLAN.md)
- [StyleSet Implementation](../lib/uniword/styleset.rb)
- [Style Implementation](../lib/uniword/style.rb)

## Status

✅ **Complete** - All components implemented and tested following theme system pattern.