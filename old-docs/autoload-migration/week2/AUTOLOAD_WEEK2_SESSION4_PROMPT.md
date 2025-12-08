# Uniword: Week 2 Session 4 - Create MhtmlPackage

**Task**: Implement model-driven MhtmlPackage for legacy Word formats (.mht, .mhtml, .doc)
**Duration**: 2-3 hours (estimated - more complex than ZIP packages)
**Prerequisites**: Read [`AUTOLOAD_WEEK2_SESSION3_COMPLETE.md`](AUTOLOAD_WEEK2_SESSION3_COMPLETE.md)

---

## Quick Context

**What we completed** (Session 3):
- ✅ Created ThmxPackage for .thmx theme files
- ✅ Theme-specific API (from_theme_file, ThemeWriter)
- ✅ Zero regressions (258 examples, 32 failures baseline maintained)

**What we're doing now** (Session 4):
- Create MhtmlPackage for .mht, .mhtml, .doc legacy formats
- DIFFERENT infrastructure: MIME multipart (not ZIP)
- Use MimeParser/MimePackager (not ZipExtractor/ZipPackager)
- Complete all format support (5/5 formats = 100%)

**Why**: MHTML is Microsoft's legacy format for Word 2003 and earlier. Still used for .doc files from HTML conversion and some web-based Word exports.

---

## Critical Differences from Previous Sessions

### ZIP Packages (DOCX, DOTX, THMX) vs MIME Package (MHTML)

| Aspect | ZIP Packages | MHTML Package |
|--------|-------------|---------------|
| **Format** | ZIP archive | MIME multipart |
| **Infrastructure** | ZipExtractor/ZipPackager | MimeParser/MimePackager |
| **Content Structure** | XML files in folders | Base64-encoded parts |
| **File Extension** | .docx, .dotx, .dotm, .thmx | .mht, .mhtml, .doc |
| **Main Content** | word/document.xml | Embedded HTML with Word XML |
| **Complexity** | Medium | High (legacy quirks) |

---

## Architecture Pattern

MhtmlPackage should follow the SAME pattern as DocxPackage but use MIME infrastructure:

```ruby
class MhtmlPackage < Lutaml::Model::Serializable
  # 1. Attributes (SAME structure as DocxPackage)
  attribute :core_properties, CoreProperties
  attribute :app_properties, AppProperties
  attribute :theme, Theme
  attribute :styles_configuration, StylesConfiguration
  attribute :numbering_configuration, NumberingConfiguration

  # 2. Class methods for I/O (DIFFERENT infrastructure)
  def self.from_file(path)
    # MimeParser.parse(path) instead of ZipExtractor.extract
  end

  def self.to_file(document, path)
    # MimePackager.package instead of ZipPackager.package
  end

  # 3. Instance methods (SAME pattern)
  def self.supported_extensions
    ['.mht', '.mhtml', '.doc']  # Multiple extensions!
  end
end
```

---

## Step-by-Step Implementation

### Step 1: Review Existing MIME Infrastructure (30 min)

**Check what exists**:
```bash
ls lib/uniword/infrastructure/mime_*
```

**Expected files**:
- `mime_parser.rb` - Parse MHTML files
- `mime_packager.rb` - Create MHTML files

**If missing**, you'll need to create them following the ZipExtractor/ZipPackager pattern.

**Key difference**: MHTML uses Mail gem for MIME parsing, not RubyZip.

### Step 2: Create MhtmlPackage File (60 min)

**Create**: `lib/uniword/ooxml/mhtml_package.rb`

**Pattern**: Copy DocxPackage structure, change infrastructure:

```ruby
# lib/uniword/ooxml/mhtml_package.rb
# frozen_string_literal: true

require 'lutaml/model'
require_relative 'namespaces'
require_relative 'core_properties'
require_relative 'app_properties'
require_relative '../theme'
require_relative '../styles_configuration'
require_relative '../numbering_configuration'
require_relative '../document'

module Uniword
  module Ooxml
    # MHTML Package - Legacy Word format (.mht, .mhtml, .doc)
    #
    # Represents MHTML (MIME HTML) files used by Word 2003 and earlier.
    # Structure is MIME multipart (not ZIP).
    #
    # @example Load MHTML file
    #   document = MhtmlPackage.from_file('document.mht')
    #
    # @example Save MHTML file
    #   MhtmlPackage.to_file(document, 'output.mhtml')
    class MhtmlPackage < Lutaml::Model::Serializable
      # Same attributes as DocxPackage
      attribute :core_properties, CoreProperties
      attribute :app_properties, AppProperties
      attribute :theme, Theme
      attribute :styles_configuration, StylesConfiguration
      attribute :numbering_configuration, NumberingConfiguration

      # Load MHTML package from file
      def self.from_file(path)
        require_relative '../infrastructure/mime_parser'

        # Parse MIME content (DIFFERENT from ZIP!)
        parser = Infrastructure::MimeParser.new
        mime_parts = parser.parse(path)

        # Parse package from MIME parts
        package = from_mime_parts(mime_parts)

        # Parse main document (same as DocxPackage)
        document = if package.raw_document_xml
                     Document.from_xml(package.raw_document_xml)
                   else
                     Document.new
                   end

        # Transfer properties (same as DocxPackage)
        document.core_properties = package.core_properties if package.core_properties
        document.app_properties = package.app_properties if package.app_properties
        document.theme = package.theme if package.theme
        document.styles_configuration = package.styles_configuration if package.styles_configuration
        document.numbering_configuration = package.numbering_configuration if package.numbering_configuration

        document
      end

      # Create package from MIME parts
      def self.from_mime_parts(mime_parts)
        package = new

        # Parse properties from MIME parts
        # MIME parts use different naming than ZIP
        # Example: 'properties/core.xml' vs 'docProps/core.xml'

        # TODO: Implement MIME part parsing
        # This will be different from ZIP extraction

        package
      end

      # Access raw document XML
      attr_accessor :raw_document_xml

      # Get supported file extensions
      def self.supported_extensions
        ['.mht', '.mhtml', '.doc']  # Note: .doc is HTML-based Word 2003
      end

      # Save document to file
      def self.to_file(document, path)
        require_relative '../infrastructure/mime_packager'

        # Create package (same as DocxPackage)
        package = new
        package.core_properties = document.core_properties || CoreProperties.new
        package.app_properties = document.app_properties || AppProperties.new
        package.theme = document.theme
        package.styles_configuration = document.styles_configuration
        package.numbering_configuration = document.numbering_configuration
        package.raw_document_xml = document.to_xml(encoding: 'UTF-8')

        # Generate MIME parts
        mime_parts = package.to_mime_parts

        # Package and save (DIFFERENT from ZIP!)
        packager = Infrastructure::MimePackager.new
        packager.package(mime_parts, path)
      end

      # Generate MIME parts hash
      def to_mime_parts
        parts = {}

        # Serialize properties to MIME parts
        # MIME uses different structure than ZIP

        # TODO: Implement MIME part serialization

        parts
      end
    end
  end
end
```

### Step 3: Update/Create MIME Infrastructure (60-90 min)

**If MimeParser doesn't exist**, create it:

```ruby
# lib/uniword/infrastructure/mime_parser.rb
require 'mail'

module Uniword
  module Infrastructure
    class MimeParser
      def parse(path)
        # Read MHTML file
        content = File.read(path)
        
        # Parse with Mail gem
        mail = Mail.read_from_string(content)
        
        # Extract parts
        parts = {}
        mail.parts.each do |part|
          content_location = part.content_location
          parts[content_location] = decode_part(part)
        end
        
        parts
      end
      
      private
      
      def decode_part(part)
        case part.content_transfer_encoding
        when 'base64'
          Base64.decode64(part.body.to_s)
        when 'quoted-printable'
          part.body.decoded
        else
          part.body.to_s
        end
      end
    end
  end
end
```

**Similarly for MimePackager** (reverse operation).

### Step 4: Update DocumentFactory (10 min)

**File**: `lib/uniword/document_factory.rb`

**Add case**:
```ruby
case format
when :docx
  require_relative 'ooxml/docx_package'
  Ooxml::DocxPackage.from_file(path)
when :dotx, :dotm
  require_relative 'ooxml/dotx_package'
  Ooxml::DotxPackage.from_file(path)
when :mhtml
  require_relative 'ooxml/mhtml_package'
  Ooxml::MhtmlPackage.from_file(path)
else
  raise ArgumentError, "Unsupported format: #{format}"
end
```

**Remove**:
```ruby
when :mhtml
  raise ArgumentError, "MHTML format not yet migrated"
```

### Step 5: Update DocumentWriter (10 min)

**File**: `lib/uniword/document_writer.rb`

**Add case** to `save()`:
```ruby
when :mhtml
  require_relative 'ooxml/mhtml_package'
  Ooxml::MhtmlPackage.to_file(document, path)
```

**Add to infer_format()**:
```ruby
when '.mht', '.mhtml', '.doc'
  :mhtml
```

### Step 6: FormatDetector Already Supports MHTML (0 min)

**Check**: `lib/uniword/format_detector.rb` already has:
```ruby
when '.mhtml', '.mht'
  :mhtml
```

**Add .doc if needed**:
```ruby
when '.mhtml', '.mht', '.doc'
  :mhtml
```

### Step 7: Add Autoload (5 min)

**File**: `lib/uniword.rb`

**Add**:
```ruby
module Ooxml
  autoload :DocxPackage, 'uniword/ooxml/docx_package'
  autoload :DotxPackage, 'uniword/ooxml/dotx_package'
  autoload :ThmxPackage, 'uniword/ooxml/thmx_package'
  autoload :MhtmlPackage, 'uniword/ooxml/mhtml_package'
end
```

### Step 8: Test MHTML Loading (15 min)

**Find an MHTML test file** or create one.

**Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
ruby -e "
require './lib/uniword'
doc = Uniword::DocumentFactory.from_file('test.mhtml')
puts 'SUCCESS: Loaded MHTML document'
"
```

### Step 9: Run Full Test Suite (10 min)

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, ≤32 failures (baseline maintained)

### Step 10: Commit Changes (10 min)

```bash
git add lib/uniword/ooxml/mhtml_package.rb \
        lib/uniword/infrastructure/mime_parser.rb \
        lib/uniword/infrastructure/mime_packager.rb \
        lib/uniword/document_factory.rb \
        lib/uniword/document_writer.rb \
        lib/uniword/format_detector.rb \
        lib/uniword.rb

git commit -m "feat(packages): Add MhtmlPackage for legacy MHTML formats

Implement model-driven MhtmlPackage for .mht, .mhtml, and .doc files.
Completes format support migration (5/5 formats).

Changes:
- Created lib/uniword/ooxml/mhtml_package.rb
- Created/Updated lib/uniword/infrastructure/mime_parser.rb
- Created/Updated lib/uniword/infrastructure/mime_packager.rb
- Updated DocumentFactory to use MhtmlPackage
- Updated DocumentWriter to support MHTML format
- Updated FormatDetector to include .doc extension
- Added MhtmlPackage autoload

Architecture:
- ✅ Model-driven: MhtmlPackage owns MHTML I/O
- ✅ MECE: MIME infrastructure separate from ZIP
- ✅ Follows package pattern (same as DocxPackage)
- ✅ Supports .mht, .mhtml, .doc extensions

Format support: 5/5 (100%)
- .docx (DocxPackage) ✅
- .dotx (DotxPackage) ✅
- .dotm (DotxPackage) ✅
- .thmx (ThmxPackage) ✅
- .mht/.mhtml/.doc (MhtmlPackage) ✅

Test results:
- Before: 258 examples, 32 failures
- After: 258 examples, ≤32 failures
- Status: ✅ Baseline maintained"
```

---

## Success Criteria

- [ ] `lib/uniword/ooxml/mhtml_package.rb` created
- [ ] MIME infrastructure working (parser + packager)
- [ ] MhtmlPackage has `supported_extensions()` returning `['.mht', '.mhtml', '.doc']`
- [ ] MhtmlPackage has `from_file(path)` returning Document
- [ ] MhtmlPackage has `to_file(document, path)`
- [ ] DocumentFactory routes :mhtml to MhtmlPackage
- [ ] DocumentWriter supports MHTML format
- [ ] FormatDetector includes .doc extension
- [ ] MHTML files load without errors
- [ ] Tests: 258 examples, ≤32 failures
- [ ] Commit created
- [ ] **ALL FORMATS COMPLETE** (5/5 = 100%)

---

## Troubleshooting

### Issue: "Mail gem not available"
**Solution**: Already in Gemfile (`gem 'mail', '~> 2.8'`)

### Issue: "MIME parts structure different from expected"
**Solution**: MHTML has different naming - inspect actual .mht file structure

### Issue: "Cannot parse Word 2003 .doc format"
**Solution**: .doc from HTML conversion is MHTML, not binary DOC format

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Estimated Duration**: 2-3 hours
**Expected Result**: Complete format support (5/5 formats) ✅