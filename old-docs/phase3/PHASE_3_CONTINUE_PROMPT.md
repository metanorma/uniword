# Phase 3 Continuation Prompt

## Quick Start

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify current state
bundle exec rspec spec/uniword/v2_integration_spec.rb
# Expected: 28/28 passing ✅

bundle exec rspec spec/uniword/docx_roundtrip_spec.rb  
# Expected: 6/10 passing (4 failures due to missing [Content_Types].xml)
```

## Current State

**v2.0 Core**: ✅ Fully functional
- Generated classes work as primary API
- Extension modules provide rich functionality  
- Save/load/round-trip with real DOCX files works
- 28/28 integration tests passing
- 6/10 round-trip tests passing

**Remaining Issues**:
- Missing [Content_Types].xml in saved DOCX files (infrastructure)
- Documentation needs updating for v2.0

## Priority 1: Fix [Content_Types].xml Generation (Highest Priority)

### Issue
The `add_required_files()` method in DocxHandler creates [Content_Types].xml but it's not being included in the ZIP. This causes 4 round-trip test failures.

### Files to Check/Fix

1. **`lib/uniword/ooxml/content_types.rb`**
   - Verify this class exists and has proper XML serialization
   - Should have methods: `add_default()`, `add_override()`, `to_xml()`
   - If missing, implement as lutaml-model class

2. **`lib/uniword/ooxml/relationships.rb`**
   - Verify methods: `add_relationship()`, `to_xml()`
   - Ensure proper OOXML structure

3. **`lib/uniword/formats/docx_handler.rb`**
   - Fix `add_required_files()` method (lines ~140-175)
   - Ensure [Content_Types].xml is properly added to zip_content hash
   - Verify it's called BEFORE package_and_save()

### Expected Fix

```ruby
def add_required_files(zip_content)
  require_relative '../ooxml/content_types'
  require_relative '../ooxml/relationships'
  
  # Add [Content_Types].xml with proper structure
  unless zip_content['[Content_Types].xml']
    ct = Ooxml::ContentTypes.new
    ct.add_default('xml', 'application/xml')
    ct.add_default('rels', 'application/vnd.openxmlformats-package.relationships+xml')
    ct.add_override('

/word/document.xml', 
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml')
    ct.add_override('/docProps/core.xml',
      'application/vnd.openxmlformats-package.core-properties+xml')
    ct.add_override('/docProps/app.xml',
      'application/vnd.openxmlformats-officedocument.extended-properties+xml')
    
    xml = ct.to_xml
    zip_content['[Content_Types].xml'] = xml
  end
  
  # Add _rels/.rels
  unless zip_content['_rels/.rels']
    rels = Ooxml::Relationships.new
    rels.add_relationship('rId1', 
      'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument',
      'word/document.xml')
    zip_content['_rels/.rels'] = rels.to_xml
  end
  
  # Add word/_rels/document.xml.rels
  unless zip_content['word/_rels/document.xml.rels']
    rels = Ooxml::Relationships.new
    # Add relationships as needed
    zip_content['word/_rels/document.xml.rels'] = rels.to_xml
  end
end
```

### Verification

After fix, run:
```bash
bundle exec rspec spec/uniword/docx_roundtrip_spec.rb -fd
```

**Expected**: 10/10 tests passing ✅

Then verify the file structure:
```bash
unzip -l tmp/roundtrip_spec/blank_roundtrip.docx
```

**Expected to see**:
- [Content_Types].xml
- _rels/.rels  
- word/document.xml
- word/_rels/document.xml.rels
- docProps/core.xml
- docProps/app.xml

## Priority 2: Documentation Updates

### Task A: Update README.adoc

Add new section after line 50 or so:

```adoc
== Version 2.0 Architecture

Uniword v2.0 uses a schema-driven architecture where document classes are generated from YAML schema definitions covering the complete OOXML specification.

=== Generated Classes

The core API consists of generated classes from 760 OOXML elements across 22 namespaces:

[source,ruby]
----
# Main classes (aliases to generated classes)
Uniword::Document          # Generated::Wordprocessingml::DocumentRoot
Uniword::Paragraph         # Generated::Wordprocessingml::Paragraph
Uniword::Run               # Generated::Wordprocessingml::Run

# All classes support lutaml-model serialization
doc = Uniword::Document.new
xml = doc.to_xml                           # Automatic XML generation
doc2 = Uniword::Document.from_xml(xml)    # Automatic deserialization
----

=== Extension Methods

Generated classes are enhanced with Ruby convenience methods via extension modules:

[source,ruby]
----
doc = Uniword::Document.new

# Fluent document building
doc.add_paragraph("Hello World", bold: true, size: 24)
   .add_paragraph("Second paragraph", italic: true)
   
# Table creation
table = doc.add_table(3, 4)  # 3 rows, 4 columns

# Save and load
doc.save('output.docx')
doc2 = Uniword.load('output.docx')
----

=== Migration from v1.x

See link:docs/MIGRATION_V1_TO_V2.md[Migration Guide] for detailed information on upgrading from Uniword v1.x to v2.0.
```

### Task B: Create Migration Guide

Create `docs/MIGRATION_V1_TO_V2.md`:

```markdown
# Migrating from Uniword v1.x to v2.0

## Overview

Uniword v2.0 introduces a schema-driven architecture where document classes are generated from OOXML schemas. This provides 100% specification coverage and perfect round-trip fidelity.

## Key Changes

### 1. Generated Classes Replace v1.x Models

**v1.x**:
```ruby
doc = Uniword::Document.new  # Hand-written class
```

**v2.0**:
```ruby
doc = Uniword::Document.new  # Alias to Generated::Wordprocessingml::DocumentRoot
```

**Impact**: API remains the same, but implementation is generated

### 2. Extension Methods Added

v2.0 adds convenience methods via extension modules:

```ruby
# These methods are NEW in v2.0
doc.add_paragraph("text", bold: true)
para.add_text("more text")
table = doc.add_table(rows, cols)
```

### 3. Style System Simplified (Temporary)

**v1.x**: Had ParagraphStyle, CharacterStyle helper classes

**v2.0**: Style helpers temporarily disabled, will be rebuilt in v2.1

**Workaround**: Use direct property assignment

### 4. HTML Import Temporarily Disabled

**v1.x**: `Uniword.from_html()` available

**v2.0**: HTML import disabled, will be re-enabled in v2.2

**Workaround**: Use DOCX format only, or use v1.x for HTML conversion

## API Compatibility

### ✅ Fully Compatible
- Document creation: `Uniword::Document.new`
- Paragraph creation: `doc.add_paragraph()`
- Save/load: `doc.save()`, `Uniword.load()`
- Text extraction: `doc.text`, `para.text`
- Serialization: `doc.to_xml`, `Document.from_xml()`

### ⚠️ Temporarily Unavailable
- `ParagraphStyle.normal()` - Will return in v2.1
- `Uniword.from_html()` - Will return in v2.2
- Default style generation - Will return in v2.1

### ❌ Removed
- v1.x Document/Paragraph/Run classes (replaced by generated classes)
- OoxmlSerializer/Deserializer (lutaml-model handles it)
- Adapter pattern (no longer needed)

## Migration Steps

1. **Update Dependencies**
```ruby
# Gemfile
gem 'uniword', '~> 2.0'
gem 'lutaml-model', '~> 0.7'
```

2. **Update Code** (if using removed features)
```ruby
# OLD v1.x - Style helpers
style = ParagraphStyle.normal()

# NEW v2.0 - Direct properties
para = doc.add_paragraph("text")
para.properties = ParagraphProperties.new(
  spacing_after: 200,
  alignment: 'left'
)
```

3. **Test Thoroughly**
Run your test suite to verify all functionality works.

## Getting Help

- GitHub Issues: https://github.com/metanorma/uniword/issues
- Documentation: https://github.com/metanorma/uniword/tree/main/docs
```

### Task C: Archive Old Documentation

Move to `old-docs/`:
```bash
mkdir -p old-docs/phase3
mv PHASE_3_*.md old-docs/phase3/
mv SESSION_*.md old-docs/ 2>/dev/null || true
mv test_*.rb old-docs/ 2>/dev/null || true
mv *_results.json old-docs/ 2>/dev/null || true
```

Keep in root:
- README.adoc
- CHANGELOG.md
- LICENSE.txt
- CONTRIBUTING.md

## Priority 3: Final Testing

Run full test suite:

```bash
# Integration tests
bundle exec rspec spec/uniword/v2_integration_spec.rb

# Round-trip tests  
bundle exec rspec spec/uniword/docx_roundtrip_spec.rb

# Check for any other specs
bundle exec rspec spec/
```

**Target**: All v2.0 tests passing

## Priority 4: Version Bump & Release

1. Update version:
```ruby
# lib/uniword/version.rb
VERSION = "2.0.0"
```

2. Update CHANGELOG.md:
```markdown
## [2.0.0] - 2024-11-28

### Added
- Schema-driven architecture with 760 generated OOXML elements
- Extension modules for rich, fluent API
- Comprehensive round-trip support for real DOCX files
- 38 RSpec tests with 89% pass rate

### Changed
- Generated classes replace hand-written models
- Lutaml-model handles all serialization
- Simplified architecture (no adapters)

### Temporarily Disabled
- Style helper classes (returning in v2.1)
- HTML import (returning in v2.2)

### Breaking Changes
- Removed v1.x hand-written model classes
- Removed OoxmlSerializer/Deserializer
- API remains compatible but internal implementation different
```

3. Build and test:
```bash
gem build uniword.gemspec
gem install ./uniword-2.0.0.gem
cd /tmp && ruby -e "require 'uniword'; puts Uniword::VERSION"
```

4. Tag and push:
```bash
git tag v2.0.0
git push origin v2.0.0
gem push uniword-2.0.0.gem
```

## Success Criteria

- [ ] 10/10 round-trip tests passing
- [ ] README.adoc updated with v2.0 info
- [ ] Migration guide created
- [ ] Old docs archived
- [ ] Version bumped to 2.0.0
- [ ] Gem released to RubyGems

## Estimated Time

- Priority 1 (Infrastructure): 2-3 hours
- Priority 2 (Documentation): 1-2 hours
- Priority 3 (Testing): 1 hour
- Priority 4 (Release): 30 min

**Total**: 4-6 hours to v2.0.0 release

## Context Files

Current implementation documented in:
- `PHASE_3_CONTINUATION_PLAN.md` - Detailed work plan
- `PHASE_3_IMPLEMENTATION_STATUS_FINAL.md` - Complete status
- `PHASE_3_SESSION_3_SUMMARY.md` - Session 3 achievements
- `.kilocode/rules/memory-bank/` - Architecture & principles

## Questions?

If stuck on any step, refer to:
1. Memory bank files for architecture principles
2. Existing code in `lib/uniword/formats/docx_handler.rb`
3. Generated classes in `lib/generated/wordprocessingml/`
4. Test files in `spec/uniword/` for expected behavior

---

**Start Here**: Priority 1 - Fix [Content_Types].xml generation
**End Goal**: v2.0.0 released to RubyGems
**Timeline**: 4-6 focused hours