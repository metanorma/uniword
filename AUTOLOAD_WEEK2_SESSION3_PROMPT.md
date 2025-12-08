# Uniword: Week 2 Session 3 - Create ThmxPackage

**Task**: Implement model-driven ThmxPackage for .thmx theme files
**Duration**: 1.5 hours (estimated, likely faster with pattern mastery)
**Prerequisites**: Read [`AUTOLOAD_WEEK2_SESSION2_COMPLETE.md`](AUTOLOAD_WEEK2_SESSION2_COMPLETE.md)

---

## Quick Context

**What we completed** (Session 2):
- ✅ Created DotxPackage for .dotx and .dotm template files
- ✅ Followed exact DocxPackage pattern
- ✅ Zero regressions (258 examples, 32 failures baseline maintained)

**What we're doing now** (Session 3):
- Create ThmxPackage for .thmx theme files
- Follow exact same pattern as DocxPackage/DotxPackage
- Support standalone theme file loading/saving

**Why**: Theme files (.thmx) are standalone ZIP packages containing theme1.xml. They can be applied to documents or imported from other documents.

---

## Architecture Pattern

ThmxPackage follows the EXACT pattern as DocxPackage/DotxPackage:

```ruby
class ThmxPackage < Lutaml::Model::Serializable
  # 1. Attributes (DIFFERENT from DocxPackage - themes only!)
  attribute :theme, Theme

  # 2. Class methods for I/O
  def self.supported_extensions
    ['.thmx']
  end

  def self.from_file(path)
    # Extract ZIP → Parse theme1.xml → Return Theme
  end

  def self.to_file(theme, path)
    # Serialize → Package ZIP → Save
  end

  # 3. Instance methods
  def self.from_zip_content(zip_content)
    # Parse theme1.xml
  end

  def to_zip_content
    # Serialize theme1.xml
  end

  private

  def self.add_required_files(zip_content)
    # Add [Content_Types].xml, .rels files
  end
end
```

---

## Key Differences from DocxPackage

Unlike DocxPackage which has document + properties + theme + styles:

**ThmxPackage has ONLY**:
- `theme` (Theme object from theme1.xml)
- No document.xml
- No styles.xml
- No numbering.xml
- No core/app properties

**ZIP structure** of .thmx file:
```
theme.thmx
├── [Content_Types].xml
├── _rels/
│   └── .rels
└── theme/
    ├── theme1.xml          # ← The only content!
    └── _rels/
        └── theme1.xml.rels  # ← Relationships (if any)
```

---

## Step-by-Step Implementation

### Step 1: Create ThmxPackage File (45 min)

**Create**: `lib/uniword/ooxml/thmx_package.rb`

**Simpler than DocxPackage** because only theme, no other parts:

```ruby
# lib/uniword/ooxml/thmx_package.rb
# frozen_string_literal: true

require 'lutaml/model'
require_relative 'namespaces'
require_relative '../theme'

module Uniword
  module Ooxml
    # THMX Package - Word Theme format
    #
    # Represents .thmx (theme) files.
    # Contains only a single theme1.xml file.
    #
    # @example Load theme
    #   theme = ThmxPackage.from_file('celestial.thmx')
    #
    # @example Save theme
    #   ThmxPackage.to_file(theme, 'output.thmx')
    class ThmxPackage < Lutaml::Model::Serializable
      # Theme (the only content)
      attribute :theme, Theme

      # Load THMX package from file
      #
      # @param path [String] Path to .thmx file
      # @return [Theme] Loaded theme
      def self.from_file(path)
        require_relative '../infrastructure/zip_extractor'

        # Extract ZIP content
        extractor = Infrastructure::ZipExtractor.new
        zip_content = extractor.extract(path)

        # Parse package
        package = from_zip_content(zip_content)

        # Return theme directly (not document!)
        package.theme || Theme.new
      end

      # Create package from extracted ZIP content
      #
      # @param zip_content [Hash] Extracted ZIP files
      # @return [ThmxPackage] Package object
      def self.from_zip_content(zip_content)
        package = new

        # Parse theme (the only content)
        if zip_content['theme/theme1.xml']
          package.theme = Theme.from_xml(zip_content['theme/theme1.xml'])
        end

        package
      end

      # Access theme
      attr_accessor :theme

      # Get supported file extensions
      #
      # @return [Array<String>] Array of supported extensions
      def self.supported_extensions
        ['.thmx']
      end

      # Save theme to file
      #
      # @param theme [Theme] The theme to save
      # @param path [String] Output path
      def self.to_file(theme, path)
        require_relative '../infrastructure/zip_packager'

        # Create package
        package = new
        package.theme = theme

        # Generate ZIP content
        zip_content = package.to_zip_content

        # Add required OOXML infrastructure files
        add_required_files(zip_content)

        # Package and save
        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Generate ZIP content hash
      #
      # @return [Hash] File paths => content
      def to_zip_content
        content = {}

        # Serialize theme (the only content)
        if theme
          content['theme/theme1.xml'] = theme.to_xml(encoding: 'UTF-8')
        end

        content
      end

      # Add required OOXML files for a valid THMX package
      #
      # @param zip_content [Hash] The ZIP content hash
      # @return [void]
      def self.add_required_files(zip_content)
        # Add [Content_Types].xml if not present
        unless zip_content['[Content_Types].xml']
          require_relative '../content_types'
          zip_content['[Content_Types].xml'] =
            ContentTypes.generate_for_theme.to_xml(declaration: true)
        end

        # Add _rels/.rels if not present
        unless zip_content['_rels/.rels']
          require_relative '../relationships/relationships'
          zip_content['_rels/.rels'] =
            Relationships::Relationships.generate_theme_package_rels.to_xml(declaration: true)
        end

        # Add theme/_rels/theme1.xml.rels if not present
        unless zip_content['theme/_rels/theme1.xml.rels']
          zip_content['theme/_rels/theme1.xml.rels'] =
            Relationships::Relationships.generate_theme_rels.to_xml(declaration: true)
        end
      end

      private_class_method :add_required_files
    end
  end
end
```

**IMPORTANT**: ThmxPackage returns `Theme` from `from_file()`, NOT `Document`!

### Step 2: Update ContentTypes for Theme (15 min)

**File**: `lib/uniword/content_types.rb`

**Add method**:
```ruby
def self.generate_for_theme
  # Return ContentTypes with only theme/theme1.xml
  # No document.xml, no styles.xml
end
```

**Check**: May already exist, verify implementation.

### Step 3: Update Relationships for Theme (15 min)

**File**: `lib/uniword/relationships/relationships.rb`

**Add methods**:
```ruby
def self.generate_theme_package_rels
  # Return package-level .rels for theme
end

def self.generate_theme_rels
  # Return theme/_rels/theme1.xml.rels
end
```

**Check**: May already exist, verify implementation.

### Step 4: Update DocumentFactory (10 min)

**File**: `lib/uniword/document_factory.rb`

**IMPORTANT**: ThmxPackage returns Theme, not Document!

**Option 1** (Simpler - Theme-specific method):
```ruby
# Add new method
def from_theme_file(path, format: :auto)
  format = detect_format(path) if format == :auto
  
  case format
  when :thmx
    require_relative 'ooxml/thmx_package'
    Ooxml::ThmxPackage.from_file(path)
  else
    raise ArgumentError, "Not a theme format: #{format}"
  end
end
```

**Option 2** (Unified - Add to from_file):
```ruby
case format
when :docx
  require_relative 'ooxml/docx_package'
  Ooxml::DocxPackage.from_file(path)
when :dotx, :dotm
  require_relative 'ooxml/dotx_package'
  Ooxml::DotxPackage.from_file(path)
when :thmx
  require_relative 'ooxml/thmx_package'
  Ooxml::ThmxPackage.from_file(path)  # Returns Theme, not Document!
when :mhtml
  raise ArgumentError, "MHTML format not yet migrated"
else
  raise ArgumentError, "Unsupported format: #{format}"
end
```

**Recommendation**: Use Option 1 (separate method), cleaner API.

### Step 5: Create ThemeWriter (10 min)

**Create**: `lib/uniword/theme_writer.rb`

```ruby
# frozen_string_literal: true

module Uniword
  # Writer for saving Theme instances to files.
  class ThemeWriter
    attr_reader :theme

    def initialize(theme)
      @theme = theme
    end

    def save(path, format: :auto)
      format = infer_format(path) if format == :auto

      case format
      when :thmx
        require_relative 'ooxml/thmx_package'
        Ooxml::ThmxPackage.to_file(theme, path)
      else
        raise ArgumentError, "Unsupported format for theme: #{format}"
      end
    end

    def infer_format(path)
      extension = File.extname(path).downcase
      case extension
      when '.thmx'
        :thmx
      else
        raise ArgumentError, "Cannot infer theme format from: #{extension}"
      end
    end
  end
end
```

### Step 6: Update FormatDetector (5 min)

**File**: `lib/uniword/format_detector.rb`

**Add**:
```ruby
case extension
when '.docx'
  :docx
when '.dotx'
  :dotx
when '.dotm'
  :dotm
when '.thmx'
  :thmx
when '.mhtml', '.mht'
  :mhtml
else
  raise ArgumentError, "Unsupported file extension: #{extension}"
end
```

### Step 7: Add Autoload (5 min)

**File**: `lib/uniword.rb`

**Add**:
```ruby
module Ooxml
  autoload :DocxPackage, 'uniword/ooxml/docx_package'
  autoload :DotxPackage, 'uniword/ooxml/dotx_package'
  autoload :ThmxPackage, 'uniword/ooxml/thmx_package'
end

# Also add ThemeWriter
autoload :ThemeWriter, 'uniword/theme_writer'
```

### Step 8: Test Loading Theme File (10 min)

**Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
ruby -e "
require './lib/uniword'
theme = Uniword::DocumentFactory.from_theme_file('references/word-resources/office-themes/celestial.thmx')
puts 'SUCCESS: Loaded theme: ' + (theme.name || 'Unknown')
"
```

**Expected**: Should load without errors

### Step 9: Run Full Test Suite (10 min)

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, ≤32 failures (baseline maintained)

### Step 10: Commit Changes (10 min)

```bash
git add lib/uniword/ooxml/thmx_package.rb \
        lib/uniword/theme_writer.rb \
        lib/uniword/document_factory.rb \
        lib/uniword/format_detector.rb \
        lib/uniword.rb \
        lib/uniword/content_types.rb \
        lib/uniword/relationships/relationships.rb

git commit -m "feat(packages): Add ThmxPackage for .thmx theme files

Implement model-driven ThmxPackage for standalone theme file support.
Includes ThemeWriter for saving themes independently.

Changes:
- Created lib/uniword/ooxml/thmx_package.rb (theme-only package)
- Created lib/uniword/theme_writer.rb (theme file writer)
- Updated DocumentFactory with from_theme_file() method
- Updated FormatDetector to detect .thmx extensions
- Updated ContentTypes with generate_for_theme() method
- Updated Relationships with theme-specific rels methods
- Added ThmxPackage and ThemeWriter autoloads

Architecture:
- ✅ Model-driven: ThmxPackage owns theme I/O
- ✅ MECE: Clear separation (Theme vs Document)
- ✅ Follows package pattern
- ✅ Theme-specific API (from_theme_file, ThemeWriter)

Format support:
- .docx (DocxPackage) ✅
- .dotx (DotxPackage) ✅
- .dotm (DotxPackage) ✅
- .thmx (ThmxPackage) ✅ NEW
- .mht/.mhtml/.doc (pending Session 4)

Test results:
- Before: 258 examples, 32 failures
- After: 258 examples, ≤32 failures
- Status: ✅ Baseline maintained"
```

---

## Success Criteria

- [ ] `lib/uniword/ooxml/thmx_package.rb` created
- [ ] `lib/uniword/theme_writer.rb` created
- [ ] ThmxPackage has `supported_extensions()` returning `['.thmx']`
- [ ] ThmxPackage has `from_file(path)` returning Theme
- [ ] ThmxPackage has `to_file(theme, path)`
- [ ] DocumentFactory has `from_theme_file(path)` method
- [ ] ThemeWriter class created
- [ ] FormatDetector detects .thmx
- [ ] ContentTypes has `generate_for_theme()` method
- [ ] Relationships has theme-specific methods
- [ ] Reference .thmx files load without errors
- [ ] Tests: 258 examples, ≤32 failures
- [ ] Commit created

---

## Troubleshooting

### Issue: "Theme returns Document instead of Theme"
**Solution**: ThmxPackage.from_file() should return `package.theme`, not a Document

### Issue: "ContentTypes missing for theme"
**Solution**: Implement `ContentTypes.generate_for_theme()` with only theme entries

### Issue: "Cannot infer format from extension: .thmx"
**Solution**: Add .thmx case to FormatDetector.detect_by_extension()

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Estimated Duration**: 1.5 hours (likely faster)
**Expected Result**: .thmx theme file support via ThmxPackage