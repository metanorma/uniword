# Phase 3 Continuation: v2.0 Integration - Session 2

**Date**: Continue from November 28, 2024  
**Current Progress**: 25% Complete (Tasks 1.1-1.3 Done)  
**Architecture**: Direct v2.0 Generated Classes (No backward compatibility)  
**Remaining Time**: ~19.5 hours (3 sessions)

## Context

Uniword v2.0 uses **schema-driven architecture** with 760 elements across 22 namespaces generated from YAML schemas. The foundational work is complete, with generated classes now serving as the primary API enhanced by extension modules.

## Session 1 Achievements ✅

### Completed (6.5 hours):
1. **Task 1.1**: Archived v1.x code (10 files + properties/ dir)
2. **Task 1.2**: Created 4 extension modules (643 lines):
   - `document_extensions.rb` - add_paragraph, save, apply_theme
   - `paragraph_extensions.rb` - add_text, fluent formatting
   - `run_extensions.rb` - bold?, italic?, formatting setters
   - `properties_extensions.rb` - fluent interface
3. **Task 1.3**: Rewrote `lib/uniword.rb` (189 lines)
   - Re-exported generated classes as primary API
   - Added module-level convenience methods

### Key Files Created:
- `lib/uniword/extensions/*_extensions.rb` (4 files)
- `lib/generated/wordprocessingml.rb` (loader)
- `test_v2_integration.rb` (verification test)
- `PHASE_3_SESSION_SUMMARY.md` (progress report)
- `PHASE_3_IMPLEMENTATION_STATUS.md` (tracker)

### Current API Works:
```ruby
doc = Uniword::Document.new
doc.add_paragraph("Hello", bold: true)
doc.add_paragraph("World", italic: true, color: 'FF0000')
doc.save('output.docx')  # Extension method
```

## Immediate Next Steps (Session 2)

### Priority 1: Complete Core Integration (Tasks 1.4-1.6) - 4 hours

#### Task 1.4: Verify Serialization (1 hour)
**Goal**: Confirm generated classes serialize correctly to OOXML

**Actions**:
```bash
# Fix bundler if needed, then run test
bundle exec ruby test_v2_integration.rb
```

**Verify**:
- [ ] `document.to_xml()` produces valid OOXML
- [ ] Namespace prefixes correct (w:, m:, a:, etc.)
- [ ] All 22 namespaces serialize
- [ ] XML structure matches OOXML spec
- [ ] Body contains paragraphs with runs

**Expected Output**:
```xml
<w:document xmlns:w="http://schemas.openxmlformats.org/...">
  <w:body>
    <w:p>
      <w:r>
        <w:rPr><w:b/></w:rPr>
        <w:t>Hello</w:t>
      </w:r>
    </w:p>
  </w:body>
</w:document>
```

**If Issues**: Check attribute ordering (must be before xml block in lutaml-model)

#### Task 1.5: Verify Deserialization (1 hour)
**Goal**: Confirm XML parsing to generated classes works

**Test**:
```ruby
# Create simple XML
xml = <<~XML
  <w:document xmlns:w="http://schemas...">
    <w:body>
      <w:p><w:r><w:t>Test</w:t></w:r></w:p>
    </w:body>
  </w:document>
XML

# Parse it
doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
puts doc.body.paragraphs.first.runs.first.text  # Should print "Test"
```

**Verify**:
- [ ] `DocumentRoot.from_xml(xml)` parses successfully
- [ ] All 22 namespaces deserialize
- [ ] Attributes map correctly
- [ ] Collections work (paragraphs, runs)
- [ ] Nested structures work (tables → rows → cells)

#### Task 1.6: Update Format Handlers (2 hours)
**Goal**: Make DocxHandler, DocumentFactory, DocumentWriter use generated classes

**Files to Update**:
1. `lib/uniword/formats/docx_handler.rb`:
   ```ruby
   def self.load(path)
     xml = extract_document_xml(path)
     # Use lutaml-model deserialization
     Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
   end

   def self.save(document, path)
     # Use lutaml-model serialization
     xml = document.to_xml
     package_to_zip(xml, path)
   end
   ```

2. `lib/uniword/document_factory.rb`:
   - Update to return generated `DocumentRoot` class
   - Use format detection then call appropriate handler

3. `lib/uniword/document_writer.rb`:
   - Accept generated classes
   - Use `document.to_xml()` instead of custom serialization
   - Package ZIP with all parts

**Critical**: Remove ALL old v1.x serialization code

### Priority 2: Basic Testing (Task 2.1 subset) - 2 hours

**Create**: `spec/uniword/v2_integration_spec.rb`

```ruby
RSpec.describe "Uniword v2.0 Integration" do
  describe "Document Extensions" do
    it "creates document with add_paragraph" do
      doc = Uniword::Document.new
      para = doc.add_paragraph("Test", bold: true)
      
      expect(para).to be_a(Uniword::Paragraph)
      expect(para.text).to eq("Test")
      expect(para.runs.first.properties.bold).to be true
    end

    it "saves document" do
      doc = Uniword::Document.new
      doc.add_paragraph("Test")
      
      # Mock DocumentWriter
      expect_any_instance_of(Uniword::DocumentWriter)
        .to receive(:save)
      
      doc.save('test.docx')
    end
  end

  describe "Serialization" do
    it "serializes to valid OOXML" do
      doc = Uniword::Document.new
      doc.add_paragraph("Test")
      
      xml = doc.to_xml
      expect(xml).to include('<w:document')
      expect(xml).to include('<w:body>')
      expect(xml).to include('<w:p>')
      expect(xml).to include('<w:r>')
      expect(xml).to include('<w:t>Test</w:t>')
    end

    it "deserializes from OOXML" do
      xml = build_simple_docx_xml("Test paragraph")
      doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
      
      expect(doc.body.paragraphs.length).to eq(1)
      expect(doc.body.paragraphs.first.text).to eq("Test paragraph")
    end
  end
end
```

**Run**: `bundle exec rspec spec/uniword/v2_integration_spec.rb`

### Priority 3: Documentation Cleanup - 1 hour

**Move to old-docs/**:
- All v2.0 planning docs that are now complete
- Temporary implementation status docs
- Old architecture documents superseded by v2.0

**Keep in docs/**:
- Current feature specifications
- User-facing guides
- Migration guides (once updated)

## Critical Implementation Patterns

### Pattern 0: Lutaml-Model Attribute Ordering ⚠️ CRITICAL
```ruby
# ✅ CORRECT - Attributes FIRST
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType
  
  xml do
    map_element 'elem', to: :my_attr
  end
end

# ❌ WRONG - Will NOT serialize
class MyClass < Lutaml::Model::Serializable
  xml do
    map_element 'elem', to: :my_attr
  end
  attribute :my_attr, MyType  # Too late!
end
```

### Pattern 1: Extension Methods
Add methods to generated classes via reopening:
```ruby
module Uniword::Generated::Wordprocessingml
  class DocumentRoot
    def add_paragraph(text = nil, **options)
      # Implementation
    end
  end
end
```

### Pattern 2: Fluent Interface
Return `self` for method chaining:
```ruby
def align(value)
  self.properties ||= ParagraphProperties.new
  properties.alignment = value.to_s
  self  # Enable chaining
end
```

## Success Criteria for Session 2

- [ ] Task 1.4-1.6 complete (core integration done)
- [ ] Serialization verified with real XML output
- [ ] Deserialization verified with XML parsing
- [ ] Format handlers updated and working
- [ ] Basic RSpec tests passing (10+ examples)
- [ ] Can create → save → load → verify document
- [ ] Ready for comprehensive testing (Task 2)

## Troubleshooting Common Issues

### Issue: "cannot load such file lutaml/model"
**Solution**: Use `bundle exec ruby` or fix bundler version

### Issue: Empty XML serialization
**Cause**: Attributes declared after xml block  
**Solution**: Move attribute declarations before xml block

### Issue: Namespace errors
**Cause**: Multiple namespace declarations at one level  
**Solution**: Only ONE namespace declaration per element

### Issue: Properties not serializing
**Cause**: Missing `render_nil: false` or `render_default: true`  
**Solution**: Check xml mapping configuration

## Files to Review/Update

### Must Update:
- `lib/uniword/formats/docx_handler.rb` (use generated classes)
- `lib/uniword/document_factory.rb` (return generated classes)
- `lib/uniword/document_writer.rb` (accept generated classes)
- `spec/uniword/v2_integration_spec.rb` (create new)

### Must Test:
- `test_v2_integration.rb` (run and verify)
- Basic RSpec suite (create and pass)

### Review for Issues:
- All generated classes in `lib/generated/wordprocessingml/`
- Extension modules in `lib/uniword/extensions/`

## Architecture Principles (MECE, OOP, Separation of Concerns)

1. **Generated Classes** - Pure lutaml-model serialization, NO business logic
2. **Extensions** - Ruby convenience methods, NO serialization code
3. **Format Handlers** - File I/O and packaging, NO document logic
4. **Infrastructure** - ZIP/MIME handling, NO document knowledge

Each layer has ONE responsibility and is MUTUALLY EXCLUSIVE from others.

## Timeline Compression Strategy

**Session 2 (Today)**: Complete Task 1 (4h) + Basic tests (2h)  
**Session 3 (Next)**: Comprehensive testing (8h)  
**Session 4 (Final)**: Documentation (6h) + Release prep (2h)

**Total Remaining**: 3 sessions → v2.0.0 release

## Quick Start Command

```bash
# Continue from where Session 1 left off
cd /Users/mulgogi/src/mn/uniword

# Verify environment
bundle exec ruby -v
bundle exec ruby -e "require 'uniword'; puts Uniword::Document.new.class"

# Run integration test
bundle exec ruby test_v2_integration.rb

# If all good, proceed with handler updates
# If issues, debug serialization first
```

## Reference Documents

- **Progress**: `PHASE_3_IMPLEMENTATION_STATUS.md`
- **Summary**: `PHASE_3_SESSION_SUMMARY.md`
- **Continuation Plan**: `PHASE_3_CONTINUATION_PLAN.md`
- **Test Script**: `test_v2_integration.rb`
- **Extensions**: `lib/uniword/extensions/` (4 files)

## Final Notes

The foundation is solid. Generated classes work, extensions add convenience, API is clean. Now we need to:
1. Verify serialization/deserialization works
2. Update format handlers to use it
3. Write comprehensive tests
4. Update documentation

**Remember**: Generated classes ARE the model. Extensions add Ruby sugar. No adapters, no v1/v2 split. Clean and simple.

---

**Start Session 2 by running**: `bundle exec ruby test_v2_integration.rb`  
**Expected**: All 8 tests pass, showing serialization works  
**If not**: Debug lutaml-model attribute ordering first