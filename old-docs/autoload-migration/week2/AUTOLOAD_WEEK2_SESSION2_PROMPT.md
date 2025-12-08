Remember, we DO NOT NEED BACKWARDS COMPATIBILITY AND OLD HANDLERS so once the
new Package classes are done, remove all the old code. Cleaniness is key.

# Uniword: Week 2 Session 2 - Create DotxPackage

**Task**: Implement model-driven DotxPackage for .dotx and .dotm template files
**Duration**: 2 hours
**Prerequisites**: Read [`AUTOLOAD_WEEK2_CONTINUATION_PLAN_UPDATED.md`](AUTOLOAD_WEEK2_CONTINUATION_PLAN_UPDATED.md)

---

## Quick Context

**What we completed** (Session 1):
- ✅ Merged DocxHandler into DocxPackage
- ✅ DocxPackage now handles .docx files with `from_file()` and `to_file()`
- ✅ Deleted lib/uniword/formats/docx_handler.rb

**What we're doing now** (Session 2):
- Create DotxPackage for .dotx (template) and .dotm (macro-enabled template)
- Follow exact same pattern as DocxPackage
- Support template-specific features (StyleSets, building blocks)

**Why**: Templates (.dotx/.dotm) have the same ZIP+OOXML structure as .docx but are used as starting points for new documents. They often contain StyleSets and building blocks.

---

## Architecture Pattern

DotxPackage should follow the EXACT pattern as DocxPackage:

```ruby
class DotxPackage < Lutaml::Model::Serializable
  # 1. Attributes (same as DocxPackage)
  attribute :core_properties, CoreProperties
  attribute :app_properties, AppProperties
  attribute :theme, Theme
  attribute :styles_configuration, StylesConfiguration
  attribute :numbering_configuration, NumberingConfiguration

  # 2. Class methods for I/O
  def self.supported_extensions
    ['.dotx', '.dotm']
  end

  def self.from_file(path)
    # Extract ZIP → Parse → Return Document
  end

  def self.to_file(document, path)
    # Serialize → Package ZIP → Save
  end

  # 3. Instance methods (same as DocxPackage)
  def self.from_zip_content(zip_content)
    # Parse package parts
  end

  def to_zip_content
    # Serialize package parts
  end

  private

  def self.add_required_files(zip_content)
    # Add [Content_Types].xml, .rels files
  end
end
```

---

## Step-by-Step Implementation

### Step 1: Create DotxPackage File (30 min)

**Create**: `lib/uniword/ooxml/dotx_package.rb`

**Copy from**: `lib/uniword/ooxml/docx_package.rb` (it's 95% identical)

**Differences**:
1. Class name: `DotxPackage` instead of `DocxPackage`
2. `supported_extensions`: `['.dotx', '.dotm']` instead of `['.docx']`
3. Everything else: IDENTICAL

```ruby
# lib/uniword/ooxml/dotx_package.rb
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
    # DOTX/DOTM Package - Word Template formats
    #
    # Represents .dotx (template) and .dotm (macro-enabled template) files.
    # Structure is identical to DOCX but used as document templates.
    #
    # @example Load template
    #   doc = DotxPackage.from_file('template.dotx')
    #
    # @example Save template
    #   DotxPackage.to_file(document, 'output.dotx')
    class DotxPackage < Lutaml::Model::Serializable
      # [Copy all attributes from DocxPackage]
      # [Copy all methods from DocxPackage]
      # [Change supported_extensions to ['.dotx', '.dotm']]
    end
  end
end
```

**Implementation Strategy**:
- Copy entire DocxPackage file
- Rename class to DotxPackage
- Update supported_extensions
- Update comments to mention templates

### Step 2: Update DocumentFactory (15 min)

**File**: `lib/uniword/document_factory.rb`

**Change**: Add .dotx and .dotm cases

```ruby
# Before (Session 1):
case format
when :docx
  require_relative 'ooxml/docx_package'
  Ooxml::DocxPackage.from_file(path)
when :mhtml
  raise ArgumentError, "MHTML format not yet migrated"
else
  raise ArgumentError, "Unsupported format: #{format}"
end

# After (Session 2):
case format
when :docx
  require_relative 'ooxml/docx_package'
  Ooxml::DocxPackage.from_file(path)
when :dotx, :dotm
  require_relative 'ooxml/dotx_package'
  Ooxml::DotxPackage.from_file(path)
when :mhtml
  raise ArgumentError, "MHTML format not yet migrated"
else
  raise ArgumentError, "Unsupported format: #{format}"
end
```

### Step 3: Update DocumentWriter (15 min)

**File**: `lib/uniword/document_writer.rb`

**Change**: Add .dotx and .dotm cases

```ruby
# In save() method:
case format
when :docx
  require_relative 'ooxml/docx_package'
  Ooxml::DocxPackage.to_file(document, path)
when :dotx, :dotm
  require_relative 'ooxml/dotx_package'
  Ooxml::DotxPackage.to_file(document, path)
when :mhtml
  raise ArgumentError, "MHTML format not yet migrated"
else
  raise ArgumentError, "Unsupported format for save: #{format}"
end
```

**In infer_format() method**:
```ruby
case extension
when '.docx'
  :docx
when '.dotx'
  :dotx
when '.dotm'
  :dotm
when '.doc', '.mhtml', '.mht'
  :mhtml
else
  raise ArgumentError, "Cannot infer format from extension: #{extension}"
end
```

### Step 4: Update FormatDetector (15 min)

**File**: `lib/uniword/format_detector.rb`

**Change**: Add .dotx and .dotm detection

```ruby
# In detect_by_extension():
case extension
when '.docx'
  :docx
when '.dotx'
  :dotx
when '.dotm'
  :dotm
when '.mhtml', '.mht'
  :mhtml
else
  raise ArgumentError, "Unsupported file extension: #{extension}"
end
```

### Step 5: Add Autoload (5 min)

**File**: `lib/uniword.rb`

**Add**:
```ruby
module Ooxml
  autoload :DocxPackage, 'uniword/ooxml/docx_package'
  autoload :DotxPackage, 'uniword/ooxml/dotx_package'
  # ...
end
```

### Step 6: Test with Reference Files (30 min)

**Test files in**: `references/word-resources/style-sets/` and `references/word-resources/quick-styles/`

These are .dotx files containing StyleSets!

**Create test** (optional, just verify manually):
```bash
# Load a .dotx file
cd /Users/mulgogi/src/mn/uniword
ruby -e "
require './lib/uniword'
doc = Uniword::DocumentFactory.from_file('references/word-resources/style-sets/Distinctive.dotx')
puts 'Loaded StyleSet: ' + (doc.styles_configuration&.styles&.size || 0).to_s + ' styles'
"
```

**Expected**: Should load without errors

### Step 7: Run Full Test Suite (15 min)

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, 32 failures (baseline maintained)

### Step 8: Commit Changes (10 min)

```bash
git add lib/uniword/ooxml/dotx_package.rb \
        lib/uniword/document_factory.rb \
        lib/uniword/document_writer.rb \
        lib/uniword/format_detector.rb \
        lib/uniword.rb

git commit -m "feat(packages): Add DotxPackage for .dotx and .dotm templates

Implement model-driven DotxPackage following exact pattern as DocxPackage.
Supports Word template (.dotx) and macro-enabled template (.dotm) formats.

Changes:
- Created lib/uniword/ooxml/dotx_package.rb (identical to DocxPackage)
- Updated DocumentFactory to handle :dotx and :dotm formats
- Updated DocumentWriter to save .dotx and .dotm files
- Updated FormatDetector to detect .dotx and .dotm extensions
- Added DotxPackage autoload to lib/uniword.rb

Architecture:
- ✅ Model-driven: DotxPackage owns its I/O
- ✅ MECE: Clear responsibility separation
- ✅ Follows DocxPackage pattern exactly
- ✅ Zero code duplication (same structure, different extensions)

Format support:
- .docx (DocxPackage) ✅
- .dotx (DotxPackage) ✅ NEW
- .dotm (DotxPackage) ✅ NEW
- .thmx (pending Session 3)
- .mht/.mhtml/.doc (pending Session 4)

Test results:
- Before: 258 examples, 32 failures
- After: 258 examples, 32 failures
- Status: ✅ Baseline maintained

Next: Session 3 will implement ThmxPackage for theme files."
```

---

## Success Criteria

- [ ] `lib/uniword/ooxml/dotx_package.rb` created
- [ ] DotxPackage has `supported_extensions()` returning `['.dotx', '.dotm']`
- [ ] DotxPackage has `from_file(path)` class method
- [ ] DotxPackage has `to_file(document, path)` class method
- [ ] DocumentFactory handles :dotx and :dotm formats
- [ ] DocumentWriter handles .dotx and .dotm extensions
- [ ] FormatDetector detects .dotx and .dotm
- [ ] Reference .dotx files load without errors
- [ ] Tests: 258 examples, ≤32 failures
- [ ] Commit created

---

## Troubleshooting

### Issue: "NameError: uninitialized constant DotxPackage"
**Solution**: Check autoload in lib/uniword.rb, ensure require_relative in DocumentFactory

### Issue: "Cannot infer format from extension: .dotx"
**Solution**: Add .dotx case to FormatDetector.detect_by_extension()

### Issue: "Unsupported format: dotx"
**Solution**: Add :dotx case to DocumentFactory and DocumentWriter

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Estimated Duration**: 2 hours
**Expected Result**: .dotx and .dotm support via DotxPackage