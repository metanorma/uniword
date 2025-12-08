# StylesetPackage Implementation Plan

**Goal**: Implement StylesetPackage using MODEL-DRIVEN lutaml-model architecture
**Timeline**: 4-6 hours
**Pattern**: Follow DocxPackage pattern
**Status**: Ready to begin

---

## Objective

Replace deleted manual parsers with proper lutaml-model package:

**Before (DELETED)**:
```ruby
StylesetLoader → StylesetPackageReader → StylesetXmlParser
# Manual ZIP, manual XML parsing
```

**After (TO IMPLEMENT)**:
```ruby
StylesetPackage (lutaml-model)
├── from_file() → Extract ZIP, deserialize XML
└── styleset → Convert to StyleSet model
```

---

## Step 1: Create StylesetPackage Class (2 hours)

### File: `lib/uniword/stylesets/package.rb`

```ruby
# frozen_string_literal: true

module Uniword
  module Stylesets
    # Represents a .dotx StyleSet package (ZIP with word/styles.xml)
    #
    # Follows MODEL-DRIVEN architecture using lutaml-model for XML
    # deserialization. No manual parsing.
    #
    # @example Load StyleSet from .dotx
    #   package = Package.from_file('Distinctive.dotx')
    #   styleset = package.styleset
    #   puts styleset.name
    class Package < Lutaml::Model::Serializable
      # word/styles.xml content (lutaml-model deserialization)
      attribute :styles_configuration, StylesConfiguration

      # Source .dotx file path (for reference)
      attribute :source_path, :string

      # Initialize Package
      #
      # @param attributes [Hash] Package attributes
      def initialize(attributes = {})
        super
        @styles_configuration ||= StylesConfiguration.new
      end

      # Load Package from .dotx file
      #
      # @param path [String] Path to .dotx file
      # @return [Package] Loaded package
      # @raise [ArgumentError] if file invalid
      # @raise [Uniword::CorruptedFileError] if ZIP corrupt
      #
      # @example
      #   pkg = Package.from_file('Distinctive.dotx')
      def self.from_file(path)
        # Validate file exists
        unless File.exist?(path)
          raise Uniword::FileNotFoundError, "File not found: #{path}"
        end

        # Extract ZIP
        extracted = extract_zip(path)

        # Deserialize styles.xml using lutaml-model (MODEL-DRIVEN!)
        styles_xml = extracted['word/styles.xml']
        raise Uniword::CorruptedFileError, 
              "styles.xml missing from #{path}" unless styles_xml

        styles_config = StylesConfiguration.from_xml(styles_xml)

        # Create Package instance
        new(
          styles_configuration: styles_config,
          source_path: path
        )
      end

      # Convert to StyleSet model
      #
      # @return [StyleSet] StyleSet with styles from package
      def styleset
        StyleSet.new(
          name: extract_name,
          styles: styles_configuration.styles,
          source_file: source_path
        )
      end

      private

      # Extract ZIP contents
      #
      # @param path [String] ZIP file path
      # @return [Hash] Extracted files {path => content}
      def self.extract_zip(path)
        require 'zip'

        contents = {}
        Zip::File.open(path) do |zip|
          zip.each do |entry|
            next if entry.directory?
            contents[entry.name] = entry.get_input_stream.read
          end
        end
        contents
      rescue Zip::Error => e
        raise Uniword::CorruptedFileError, 
              "Failed to extract #{path}: #{e.message}"
      end

      # Extract StyleSet name from source path
      #
      # @return [String] StyleSet name
      def extract_name
        return 'Custom StyleSet' unless source_path

        # Get filename without extension
        filename = File.basename(source_path, '.*')

        # Convert to title case (e.g., 'distinctive' -> 'Distinctive')
        filename.split(/[-_]/).map(&:capitalize).join(' ')
      end
    end
  end
end
```

### Checklist for Step 1
- [ ] Create `lib/uniword/stylesets/package.rb`
- [ ] Follow Pattern 0 (attributes before xml)
- [ ] Use lutaml-model for deserialization
- [ ] Handle errors properly
- [ ] Add comprehensive documentation

---

## Step 2: Update StyleSet.from_dotx() (30 minutes)

### File: `lib/uniword/styleset.rb`

Change from NotImplementedError to using StylesetPackage:

```ruby
# Load StyleSet from .dotx file
#
# @param path [String] Path to .dotx file
# @return [StyleSet] Loaded StyleSet
#
# @example Load StyleSet
#   styleset = StyleSet.from_dotx('Distinctive.dotx')
def self.from_dotx(path)
  require_relative 'stylesets/package'

  Stylesets::Package.from_file(path).styleset
end
```

### Checklist for Step 2
- [ ] Update `StyleSet.from_dotx()` method
- [ ] Remove NotImplementedError
- [ ] Add require_relative for package
- [ ] Update documentation if needed

---

## Step 3: Add Autoload Declaration (15 minutes)

### File: `lib/uniword.rb`

Add autoload for the new Package class:

```ruby
# Autoload styleset infrastructure
module Stylesets
  autoload :Package, 'uniword/stylesets/package'
  # Note: Manual parsers deleted (anti-pattern)
end
```

Or add to existing Stylesets module if it exists.

### Checklist for Step 3
- [ ] Add autoload for Stylesets::Package
- [ ] Follow existing autoload organization
- [ ] Add comment about deleted parsers

---

## Step 4: Verify StylesConfiguration (1 hour)

### Check: Does StylesConfiguration XML mapping work?

**File**: `lib/uniword/styles_configuration.rb`

The class currently has XML mapping disabled (lines 16-23):

```ruby
xml do
  element 'styles'
  namespace Ooxml::Namespaces::WordProcessingML

  # TEMPORARY: Disabled - requires Style class
  # map_element 'style', to: :styles
end
```

**Action needed**:
1. Check if `Style` class exists and has XML mapping
2. If yes, enable `map_element 'style', to: :styles`
3. If no, create minimal Style class with XML mapping
4. Test deserialization

### Possible Issues

**Issue 1**: Style class doesn't exist or has wrong format
**Solution**: Create/fix Style class as lutaml-model

**Issue 2**: StylesConfiguration can't deserialize
**Solution**: Fix XML mappings, ensure Style class correct

### Checklist for Step 4
- [ ] Check Style class exists
- [ ] Verify Style has XML mapping
- [ ] Enable map_element in StylesConfiguration
- [ ] Test: `StylesConfiguration.from_xml(xml_string)`
- [ ] Verify styles array populates

---

## Step 5: Test Implementation (1-2 hours)

### Unit Tests

Create `spec/uniword/stylesets/package_spec.rb`:

```ruby
RSpec.describe Uniword::Stylesets::Package do
  let(:dotx_path) { 'spec/fixtures/stylesets/Distinctive.dotx' }

  describe '.from_file' do
    it 'loads package from .dotx file' do
      pkg = described_class.from_file(dotx_path)
      expect(pkg).to be_a(described_class)
      expect(pkg.styles_configuration).to be_a(Uniword::StylesConfiguration)
    end

    it 'raises error for missing file' do
      expect {
        described_class.from_file('nonexistent.dotx')
      }.to raise_error(Uniword::FileNotFoundError)
    end
  end

  describe '#styleset' do
    it 'converts to StyleSet' do
      pkg = described_class.from_file(dotx_path)
      styleset = pkg.styleset
      
      expect(styleset).to be_a(Uniword::StyleSet)
      expect(styleset.name).to eq('Distinctive')
      expect(styleset.styles).to be_an(Array)
    end
  end
end
```

### Integration Tests

Update existing `spec/uniword/styleset_roundtrip_spec.rb`:

```ruby
# Should still pass - tests bundled YAML stylesets
describe 'StyleSet round-trip' do
  it 'loads bundled styleset' do
    styleset = Uniword::StyleSet.load('distinctive')
    expect(styleset.name).to eq('Distinctive')
  end
end

# Add new test for .dotx loading
describe 'StyleSet .dotx loading' do
  it 'loads from .dotx file' do
    dotx_path = 'references/word-resources/style-sets/Distinctive.dotx'
    styleset = Uniword::StyleSet.from_dotx(dotx_path)
    
    expect(styleset.name).to eq('Distinctive')
    expect(styleset.styles.count).to be > 0
  end
end
```

### Test Commands

```bash
# Unit tests
bundle exec rspec spec/uniword/stylesets/package_spec.rb

# Integration tests  
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb

# Full baseline (should still pass)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb
```

### Checklist for Step 5
- [ ] Create unit tests for Package
- [ ] Update integration tests for .dotx loading
- [ ] Run all tests
- [ ] Fix any failures
- [ ] Verify baseline still passes (258 tests)

---

## Step 6: Update Documentation (30 minutes)

### Update README.adoc

Document the new Package class in architecture section.

### Update CHANGELOG.md

Add entry:

```markdown
### Added
- **StylesetPackage**: Proper MODEL-DRIVEN package for .dotx files
  - Replaces deleted manual parsers
  - Uses lutaml-model for XML deserialization
  - Follows DocxPackage pattern
  - `Uniword::Stylesets::Package.from_file(path).styleset`

### Fixed
- **StyleSet.from_dotx()**: Now works using StylesetPackage
  - Previously raised NotImplementedError
  - Full functionality restored
```

### Checklist for Step 6
- [ ] Update README.adoc
- [ ] Update CHANGELOG.md
- [ ] Document Package API
- [ ] Add usage examples

---

## Success Criteria

- ✅ StylesetPackage class created (lutaml-model)
- ✅ StyleSet.from_dotx() working
- ✅ Zero manual XML parsing
- ✅ All baseline tests passing (258/258)
- ✅ New tests for Package added
- ✅ Documentation updated
- ✅ MODEL-DRIVEN architecture maintained

---

## Timeline

| Step | Estimated | Task |
|------|-----------|------|
| 1 | 2 hours | Create StylesetPackage |
| 2 | 30 min | Update StyleSet.from_dotx() |
| 3 | 15 min | Add autoload |
| 4 | 1 hour | Fix StylesConfiguration |
| 5 | 1-2 hours | Testing |
| 6 | 30 min | Documentation |
| **Total** | **4.5-5.5 hours** | **Complete** |

---

## Troubleshooting

### Issue: StylesConfiguration.from_xml() fails
**Cause**: Style class missing or wrong format
**Solution**: Create/fix Style class with proper XML mapping

### Issue: Tests fail
**Cause**: XML structure mismatch
**Solution**: Debug XML structure, adjust mappings

### Issue: Performance slow
**Cause**: ZIP extraction overhead
**Solution**: Accept for now, optimize later if needed

---

**Created**: December 4, 2024
**Status**: Ready to implement
**Next Action**: Begin Step 1 - Create StylesetPackage class