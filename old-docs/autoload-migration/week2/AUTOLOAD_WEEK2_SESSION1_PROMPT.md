# Uniword: Week 2 Session 1 - Merge DocxHandler into DocxPackage

**Task**: Eliminate orchestrator anti-pattern by merging DocxHandler into DocxPackage
**Duration**: 3 hours
**Prerequisites**: Read [`AUTOLOAD_WEEK2_CONTINUATION_PLAN.md`](AUTOLOAD_WEEK2_CONTINUATION_PLAN.md)

---

## Quick Context

**Current Architecture (WRONG)**:
```
DocumentFactory → DocxHandler → DocxPackage
                  (orchestrator)  (model)
```

**Target Architecture (CORRECT)**:
```
DocumentFactory → DocxPackage
                  (model with I/O)
```

**Problem**: DocxHandler is a redundant orchestration layer that violates model-driven architecture.

**Solution**: Merge all DocxHandler logic into DocxPackage (the model owns its persistence).

**ULTIMATE GOAL**: Delete the entire `lib/uniword/formats/` directory (4 files) by end of Phase 1:
- Session 1: Delete docx_handler.rb
- Session 2: Delete mhtml_handler.rb
- Session 3: Delete base_handler.rb + format_handler_registry.rb + directory

---

## Step-by-Step Execution

### Step 1: Understand Current Responsibilities (15 min)

Read these files to understand the split:
1. [`lib/uniword/formats/docx_handler.rb`](lib/uniword/formats/docx_handler.rb:1) - Orchestrator
2. [`lib/uniword/ooxml/docx_package.rb`](lib/uniword/ooxml/docx_package.rb:1) - Model
3. [`lib/uniword/document_factory.rb`](lib/uniword/document_factory.rb:1) - Entry point

**DocxHandler Current Methods**:
- `supported_extensions()` → Move to DocxPackage.supported_extensions
- `extract_content(path)` → Merge into DocxPackage.from_file
- `deserialize(content)` → Already in DocxPackage.from_zip_content (enhance)
- `serialize(document)` → Already in DocxPackage.to_zip_content (enhance)
- `package_and_save(content, path)` → Merge into DocxPackage.to_file
- `add_required_files(zip_content)` → Move to DocxPackage (private)

### Step 2: Enhance DocxPackage.from_file (30 min)

Currently `DocxPackage.from_file` just extracts and delegates to `from_zip_content`.

**Enhance it to**:
1. Extract ZIP content
2. Call from_zip_content
3. Parse main document XML
4. Transfer properties (core, app, theme, styles, numbering)
5. Return fully loaded Document (not DocxPackage!)

```ruby
# lib/uniword/ooxml/docx_package.rb

def self.from_file(path)
  require_relative '../infrastructure/zip_extractor'

  # Extract ZIP
  extractor = Infrastructure::ZipExtractor.new
  zip_content = extractor.extract(path)

  # Parse package
  package = from_zip_content(zip_content)

  # Parse main document (Generated::Wordprocessingml::DocumentRoot)
  # Note: Document is aliased in lib/uniword.rb
  document = if package.raw_document_xml
               Wordprocessingml::DocumentRoot.from_xml(package.raw_document_xml)
             else
               Wordprocessingml::DocumentRoot.new
             end

  # Transfer properties from package to document
  document.core_properties = package.core_properties if package.core_properties
  document.app_properties = package.app_properties if package.app_properties
  document.theme = package.theme if package.theme
  document.styles_configuration = package.styles_configuration if package.styles_configuration
  document.numbering_configuration = package.numbering_configuration if package.numbering_configuration

  document
end
```

### Step 3: Enhance DocxPackage.to_file (30 min)

Currently `DocxPackage.to_file` just creates ZIP content and packages it.

**Enhance it to**:
1. Accept a Document object (not self!)
2. Create package and transfer properties
3. Serialize document to XML
4. Add required OOXML files
5. Package and save

```ruby
# lib/uniword/ooxml/docx_package.rb

def self.to_file(document, path)
  require_relative '../infrastructure/zip_packager'

  # Create package
  package = new

  # Transfer properties to package
  package.core_properties = document.core_properties || CoreProperties.new
  package.app_properties = document.app_properties || AppProperties.new
  package.theme = document.theme
  package.styles_configuration = document.styles_configuration
  package.numbering_configuration = document.numbering_configuration

  # Serialize main document
  package.raw_document_xml = document.to_xml(encoding: 'UTF-8')

  # Generate ZIP content
  zip_content = package.to_zip_content

  # Add required OOXML infrastructure files
  add_required_files(zip_content)

  # Package and save
  packager = Infrastructure::ZipPackager.new
  packager.package(zip_content, path)
end

private

# Add required OOXML files for a valid DOCX package
def self.add_required_files(zip_content)
  # Add [Content_Types].xml if not present
  unless zip_content['[Content_Types].xml']
    require_relative '../content_types'
    zip_content['[Content_Types].xml'] =
      ContentTypes.generate.to_xml(declaration: true)
  end

  # Add _rels/.rels if not present
  unless zip_content['_rels/.rels']
    require_relative '../relationships/relationships'
    zip_content['_rels/.rels'] =
      Relationships::Relationships.generate_package_rels.to_xml(declaration: true)
  end

  # Add word/_rels/document.xml.rels if not present
  unless zip_content['word/_rels/document.xml.rels']
    zip_content['word/_rels/document.xml.rels'] =
      Relationships::Relationships.generate_document_rels.to_xml(declaration: true)
  end
end
```

### Step 4: Add supported_extensions class method (5 min)

```ruby
# lib/uniword/ooxml/docx_package.rb

def self.supported_extensions
  ['.docx']
end
```

### Step 5: Update DocumentFactory (15 min)

Change from using DocxHandler to using DocxPackage directly:

```ruby
# lib/uniword/document_factory.rb

# Before:
def self.from_file(path)
  handler = Formats::FormatHandlerRegistry.handler_for_path(path)
  handler.read(path)
end

# After:
def self.from_file(path)
  format = FormatDetector.detect_from_path(path)

  case format
  when :docx
    Ooxml::DocxPackage.from_file(path)
  when :mhtml
    Ooxml::MhtmlPackage.from_file(path) # Will create in Session 2
  else
    raise InvalidFormatError, "Unsupported format: #{format}"
  end
end
```

### Step 6: Update DocumentWriter (15 min)

Change from using DocxHandler to using DocxPackage directly:

```ruby
# lib/uniword/document_writer.rb

# Before:
def save(document, path)
  handler = Formats::FormatHandlerRegistry.handler_for_path(path)
  handler.write(document, path)
end

# After:
def save(document, path)
  format = FormatDetector.detect_from_path(path)

  case format
  when :docx
    Ooxml::DocxPackage.to_file(document, path)
  when :mhtml
    Ooxml::MhtmlPackage.to_file(document, path) # Will create in Session 2
  else
    raise InvalidFormatError, "Unsupported format for save: #{format}"
  end
end
```

### Step 7: Delete DocxHandler (5 min)

```bash
git rm lib/uniword/formats/docx_handler.rb
```

**Note**: This is 1 of 4 files to delete. Entire directory will be removed in Session 3.

### Step 8: Update lib/uniword.rb (10 min)

Remove the format handler require:

```ruby
# lib/uniword.rb

# DELETE these lines:
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

### Step 9: Run Tests (30 min)

```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
```

**Expected**: 258 examples, 32 failures (baseline maintained)

**If > 32 failures**:
1. Check DocxPackage.from_file implementation
2. Verify property transfers
3. Check add_required_files logic
4. Revert and retry with fixes

### Step 10: Commit Changes (10 min)

```bash
git add lib/uniword/ooxml/docx_package.rb \
        lib/uniword/document_factory.rb \
        lib/uniword/document_writer.rb \
        lib/uniword.rb

git commit -m "refactor(architecture): Merge DocxHandler into DocxPackage

Eliminate orchestrator anti-pattern by moving all DOCX I/O logic into the
DocxPackage model class. This follows proper model-driven architecture where
models own their persistence logic.

Changes:
- Enhanced DocxPackage.from_file to parse document and transfer properties
- Enhanced DocxPackage.to_file to serialize document and package ZIP
- Moved add_required_files logic into DocxPackage (private class method)
- Updated DocumentFactory to use DocxPackage.from_file directly
- Updated DocumentWriter to use DocxPackage.to_file directly
- Deleted lib/uniword/formats/docx_handler.rb (180 lines removed)
- Removed format handler requires from lib/uniword.rb

Architecture improvements:
- ✅ Model-driven: DocxPackage owns its serialization
- ✅ No orchestrator: Removed redundant coordination layer
- ✅ MECE: Clear single responsibility for DocxPackage
- ✅ Simpler: Direct model usage, no handler indirection

Next: Session 2 will delete mhtml_handler.rb, Session 3 will remove entire
lib/uniword/formats/ directory (4 files total).

Test results:
- Before: 258 examples, 32 failures
- After: 258 examples, 32 failures
- Status: ✅ Baseline maintained, zero regressions"
```

### Step 11: Verify Directory Status (5 min)

Check remaining files in formats/ directory:

```bash
ls -la lib/uniword/formats/
```

**Expected**:
```
base_handler.rb              (to delete in Session 3)
format_handler_registry.rb   (to delete in Session 3)
mhtml_handler.rb             (to delete in Session 2)
```

**After Week 2 Phase 1 Complete**: This directory should be empty and deleted.

---

## Success Criteria Checklist

- [ ] DocxPackage.from_file returns Document (not DocxPackage)
- [ ] DocxPackage.to_file accepts Document and path
- [ ] add_required_files is private class method in DocxPackage
- [ ] DocumentFactory uses DocxPackage.from_file
- [ ] DocumentWriter uses DocxPackage.to_file
- [ ] lib/uniword/formats/docx_handler.rb deleted
- [ ] Format handler requires removed from lib/uniword.rb
- [ ] Tests: 258 examples, ≤32 failures
- [ ] Commit created with detailed message

---

## Expected Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Files with require_relative | 161 | 158 | -3 |
| Lines of code | N/A | N/A | -180 |
| Orchestrator classes | 3 | 2 | -1 |
| Test failures | 32 | ≤32 | 0 |

---

## Troubleshooting

### Issue: Tests fail with "undefined method `from_file'"
**Solution**: Check DocxPackage has `def self.from_file(path)` (class method)

### Issue: Document properties missing after load
**Solution**: Verify property transfer logic in from_file (lines copying properties)

### Issue: [Content_Types].xml missing in output
**Solution**: Check add_required_files is being called in to_file

### Issue: Circular dependency errors
**Solution**: Use require_relative for Infrastructure classes inside methods (not at top)

---

**Created**: December 8, 2024
**Status**: Ready to execute
**Estimated Duration**: 3 hours
**Expected Result**: DocxHandler eliminated, model-driven architecture achieved