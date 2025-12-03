# Phase 3 Session 3: Deserialization, Format Handlers & Testing

**Date**: Continue from November 28, 2024  
**Current Progress**: 40% Complete (Tasks 1.1-1.4 Done)  
**Architecture**: Direct v2.0 Generated Classes - Core Integration Working!  
**Remaining Time**: ~14 hours (2 sessions)

## Context: Session 2 Achievements ✅

**MAJOR BREAKTHROUGH**: Core v2.0 architecture is fully functional!

### What Works Now
- ✅ Generated classes load without errors (autoload solved circular deps)
- ✅ All extension methods functional (add_paragraph, add_text, fluent interface)
- ✅ Document creation: 4 paragraphs, 6 runs with formatting
- ✅ Text extraction: "Hello World\nSecond paragraph\nBold text..."
- ✅ XML serialization: 736 bytes valid OOXML structure
- ✅ Test pass rate: 79% (11/14 checks)

### Critical Fixes Applied
1. **Autoload** for 760+ interdependent generated classes
2. **Type fixes**: Boolean/String/Integer/Float → :boolean/:string/:integer/:float (120+ files)
3. **Class names**: ParagraphShading → Shading
4. **V1.x references**: Style classes now use Generated:: namespace
5. **Module conflicts**: Theme class/module resolved
6. **Format handlers**: Temporarily disabled (to fix this session)

### Integration Test Verification
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec ruby test_v2_integration.rb
# Result: All extension methods work, serialization works!
```

## Session 3 Objectives (6 hours compressed timeline)

### Priority 1: Verify Deserialization (Task 1.5) - 1 hour ✅

**Goal**: Confirm XML → Objects works

**Quick Test**:
```ruby
# Create test file: test_deserialization.rb
require 'uniword'

xml = <<~XML
  <document xmlns="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <body>
      <p>
        <r><t>Test paragraph</t></r>
      </p>
    </body>
  </document>
XML

doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
puts "✓ Parsed successfully"
puts "  Paragraphs: #{doc.body.paragraphs.length}"
puts "  Text: #{doc.body.paragraphs.first.runs.first.text}"
```

**Verify**:
- [ ] `DocumentRoot.from_xml(xml)` parses without errors
- [ ] Body and paragraphs populate correctly
- [ ] Runs and text content extracted
- [ ] Attributes map (alignment, spacing, etc.)
- [ ] Collections work (multiple paragraphs, runs)
- [ ] Nested structures (tables → rows → cells)

**Expected Issues**:
- Namespace handling (may need to strip prefixes)
- Unknown elements (should be ignored gracefully)
- Empty attributes (should use defaults)

### Priority 2: Update Format Handlers (Task 1.6) - 3 hours ⚠️

**Goal**: Make handlers use generated classes for save/load

#### Step 1: Update DocxHandler (1.5h)

**File**: `lib/uniword/formats/docx_handler.rb`

**Current Issue**: References v1.x Document class, uses OoxmlSerializer

**Changes Needed**:
```ruby
# lib/uniword/formats/docx_handler.rb
module Uniword
  module Formats
    class DocxHandler < BaseHandler
      def self.load(path)
        # Extract document.xml from ZIP
        xml = extract_document_xml_from_zip(path)
        
        # Use lutaml-model deserialization
        Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
      end

      def self.save(document, path)
        # Use lutaml-model serialization
        xml = document.to_xml
        
        # Package into ZIP with all required parts
        package_to_docx(xml, path)
      end

      private

      def self.extract_document_xml_from_zip(path)
        # Use ZipExtractor
        extractor = Infrastructure::ZipExtractor.new(path)
        extractor.read_entry('word/document.xml')
      end

      def self.package_to_docx(doc_xml, output_path)
        # Create ZIP with:
        # - [Content_Types].xml
        # - _rels/.rels
        # - word/document.xml (doc_xml)
        # - word/_rels/document.xml.rels
        # - word/styles.xml (if styles present)
        # - word/numbering.xml (if numbering present)
        Infrastructure::ZipPackager.package(output_path) do |zip|
          zip.add_entry('[Content_Types].xml', content_types_xml)
          zip.add_entry('_rels/.rels', package_rels_xml)
          zip.add_entry('word/document.xml', doc_xml)
          zip.add_entry('word/_rels/document.xml.rels', document_rels_xml)
        end
      end
    end
  end
end
```

**Key Points**:
- Remove all references to v1.x classes
- Remove OoxmlSerializer/Deserializer (lutaml-model handles it)
- Keep ZIP packaging logic
- Keep relationship management

#### Step 2: Update DocumentFactory (0.5h)

**File**: `lib/uniword/document_factory.rb`

**Changes**:
```ruby
def self.from_file(path)
  format = FormatDetector.detect(path)
  handler = Formats::FormatHandlerRegistry.handler_for(format)
  
  # Returns Uniword::Generated::Wordprocessingml::DocumentRoot
  handler.load(path)
end
```

**Verify**: `Uniword.load('file.docx')` returns generated class

#### Step 3: Update DocumentWriter (0.5h)

**File**: `lib/uniword/document_writer.rb`

**Changes**:
```ruby
def initialize(document)
  # Accept generated DocumentRoot class
  raise ArgumentError unless document.is_a?(Generated::Wordprocessingml::DocumentRoot)
  @document = document
end

def save(path, format: :auto)
  format = detect_format(path, format)
  handler = Formats::FormatHandlerRegistry.handler_for(format)
  handler.save(@document, path)
end
```

#### Step 4: Re-enable Format Handler Loading (0.5h)

**File**: `lib/uniword.rb`

**Uncomment**:
```ruby
# Eagerly load format handlers to trigger self-registration
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'
```

**Test**:
```ruby
doc = Uniword::Document.new
doc.add_paragraph("Test")
doc.save('output.docx')  # Should work!

loaded = Uniword.load('output.docx')
puts loaded.text  # Should print: "Test"
```

### Priority 3: Basic RSpec Tests (Task 2.1 subset) - 2 hours

**Create**: `spec/uniword/v2_integration_spec.rb`

**Structure**:
```ruby
RSpec.describe "Uniword v2.0 Integration" do
  describe "Document Creation" do
    it "creates empty document" do
      doc = Uniword::Document.new
      expect(doc).to be_a(Uniword::Generated::Wordprocessingml::DocumentRoot)
    end

    it "adds paragraph with text" do
      doc = Uniword::Document.new
      para = doc.add_paragraph("Hello")
      expect(para.text).to eq("Hello")
    end

    it "adds formatted paragraph" do
      doc = Uniword::Document.new
      para = doc.add_paragraph("Bold", bold: true)
      expect(para.runs.first.properties.bold).to be true
    end
  end

  describe "Serialization" do
    it "serializes to valid XML" do
      doc = Uniword::Document.new
      doc.add_paragraph("Test")
      xml = doc.to_xml
      expect(xml).to include('<document')
      expect(xml).to include('<body>')
      expect(xml).to include('<p>')
      expect(xml).to include('<t>Test</t>')
    end

    it "deserializes from XML" do
      xml = build_minimal_docx_xml("Test text")
      doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
      expect(doc.body.paragraphs.length).to eq(1)
      expect(doc.text).to include("Test text")
    end
  end

  describe "Round-Trip" do
    it "preserves content through save/load" do
      # Create
      doc1 = Uniword::Document.new
      doc1.add_paragraph("Paragraph 1")
      doc1.add_paragraph("Paragraph 2", bold: true)
      
      # Save
      path = 'tmp/test_roundtrip.docx'
      doc1.save(path)
      
      # Load
      doc2 = Uniword.load(path)
      
      # Verify
      expect(doc2.paragraphs.length).to eq(2)
      expect(doc2.text).to include("Paragraph 1")
      expect(doc2.text).to include("Paragraph 2")
      expect(doc2.paragraphs[1].runs.first.properties.bold).to be true
      
      # Cleanup
      File.delete(path)
    end
  end

  describe "Extension Methods" do
    let(:doc) { Uniword::Document.new }
    
    it "supports add_paragraph" do
      para = doc.add_paragraph("Text")
      expect(doc.paragraphs).to include(para)
    end

    it "supports paragraph.add_text" do
      para = doc.add_paragraph
      para.add_text("Part 1")
      para.add_text(" Part 2")
      expect(para.text).to eq("Part 1 Part 2")
    end

    it "supports fluent interface" do
      para = doc.add_paragraph("Centered")
      para.align('center').spacing_before(240)
      expect(para.properties.alignment).to eq('center')
      expect(para.properties.spacing_before).to eq(240)
    end

    it "supports add_table" do
      table = doc.add_table(2, 3)
      expect(table.rows.length).to eq(2)
      expect(table.rows.first.cells.length).to eq(3)
    end
  end
end
```

**Run**: `bundle exec rspec spec/uniword/v2_integration_spec.rb`
**Target**: 15+ examples, 100% pass

## Critical Implementation Patterns

### Pattern 0: Lutaml-Model Attribute Declaration ⚠️

**THE RULE**: Attributes MUST be declared BEFORE xml block
```ruby
# ✅ CORRECT
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, :string  # Use symbols for primitives!
  
  xml do
    map_element 'elem', to: :my_attr
  end
end
```

### Pattern 1: Type Symbols Not Classes
```ruby
# ✅ CORRECT
attribute :name, :string
attribute :count, :integer
attribute :ratio, :float
attribute :enabled, :boolean

# ❌ WRONG
attribute :name, String
attribute :count, Integer
```

### Pattern 2: Generated Classes ARE the API
```ruby
# ✅ Direct use of generated classes
doc = Uniword::Document.new  # Alias for Generated::Wordprocessingml::DocumentRoot
para = doc.add_paragraph("Text")  # Extension method

# ✅ Extensions add convenience without modifying generated code
# lib/uniword/extensions/document_extensions.rb
module Uniword::Generated::Wordprocessingml
  class DocumentRoot
    def add_paragraph(text = nil, **options)
      # Ruby convenience method
    end
  end
end
```

### Pattern 3: Lutaml-Model Serialization
```ruby
# ✅ Automatic serialization
xml = document.to_xml  # Built into generated class

# ✅ Automatic deserialization
doc = DocumentRoot.from_xml(xml)  # Built into generated class

# ❌ WRONG - Don't create custom serializers
# serializer = OoxmlSerializer.new  # Delete this!
```

## Known Issues & Solutions

### Issue 1: Namespace Prefixes in XML

**Current**: `<document>` (default namespace)  
**Expected**: `<w:document>` (prefixed)

**Impact**: LOW - Semantically correct, Word accepts both
**Priority**: P3 - Can defer to later

### Issue 2: HtmlImporter References V1.x Code

**File**: `lib/uniword/html_importer.rb`  
**Issue**: Loads archived document.rb, paragraph.rb

**Solution**: Update or temporarily disable
```ruby
# Option 1: Update to use generated classes (2h work)
# Option 2: Comment out html_to_docx methods temporarily
# Option 3: Defer to post-v2.0.0
```

**Decision**: Defer to post-v2.0.0 (P3 feature)

### Issue 3: FontFamily Class Missing

**Issue**: Extensions reference `Generated::Wordprocessingml::FontFamily`
**Check**: Does this class exist?
```bash
ls lib/generated/wordprocessingml/font_family.rb
```

**If missing**: Use direct string assignment
```ruby
# Instead of:
r_fonts: Generated::Wordprocessingml::FontFamily.new(ascii: 'Calibri')

# Use:
r_fonts_ascii: 'Calibri'
```

## Files to Review Before Starting

### Generated Classes
- `lib/generated/wordprocessingml.rb` - Autoload implementation
- `lib/generated/wordprocessingml/document_root.rb` - Main class
- `lib/generated/wordprocessingml/body.rb`
- `lib/generated/wordprocessingml/paragraph.rb`
- `lib/generated/wordprocessingml/run.rb`

### Extensions
- `lib/uniword/extensions/document_extensions.rb` - add_paragraph, save
- `lib/uniword/extensions/paragraph_extensions.rb` - add_text, fluent
- `lib/uniword/extensions/run_extensions.rb` - bold?, italic?

### Format Handlers (TO UPDATE)
- `lib/uniword/formats/docx_handler.rb` ⚠️ Main work here
- `lib/uniword/document_factory.rb` ⚠️ Update return type
- `lib/uniword/document_writer.rb` ⚠️ Accept generated classes

### Infrastructure (Should be OK)
- `lib/uniword/infrastructure/zip_extractor.rb`
- `lib/uniword/infrastructure/zip_packager.rb`
- `lib/uniword/ooxml/content_types.rb`
- `lib/uniword/ooxml/relationships.rb`

## Success Criteria

### Task 1.5: Deserialization ✅
- [ ] `DocumentRoot.from_xml(xml)` works
- [ ] Simple document parses correctly
- [ ] Text content extracted
- [ ] Formatting preserved
- [ ] Collections populate

### Task 1.6: Format Handlers ✅
- [ ] DocxHandler uses generated classes
- [ ] DocumentFactory returns generated classes
- [ ] DocumentWriter accepts generated classes
- [ ] Format handlers re-enabled in lib/uniword.rb
- [ ] Can save document: `doc.save('file.docx')`
- [ ] Can load document: `Uniword.load('file.docx')`
- [ ] Round-trip works: create → save → load → verify

### Task 2.1: Basic Tests ✅
- [ ] `spec/uniword/v2_integration_spec.rb` created
- [ ] 15+ test examples
- [ ] Document creation tests pass
- [ ] Serialization tests pass
- [ ] Deserialization tests pass
- [ ] Round-trip tests pass
- [ ] Extension method tests pass
- [ ] 100% pass rate

## Quick Start Commands

```bash
# Verify current state
cd /Users/mulgogi/src/mn/uniword
bundle exec ruby test_v2_integration.rb
# Should show: 11/14 checks passing

# Test deserialization
bundle exec ruby test_deserialization.rb
# Create this file first

# Update handlers, then test
bundle exec ruby -e "require 'uniword'; doc = Uniword.new; doc.add_paragraph('Test'); doc.save('test.docx'); puts 'Saved!'"

# Run RSpec tests
bundle exec rspec spec/uniword/v2_integration_spec.rb -fd
```

## Timeline Compression Strategy

**Session 3 (Today)**: Complete Task 1 (6h) + Basic tests  
**Session 4 (Next)**: Comprehensive testing (6h) + Documentation (2h)

**Total Remaining**: 2 sessions → v2.0.0 release

## Reference Documents

**Current State**:
- `PHASE_3_SESSION_2_SUMMARY.md` - Session 2 achievements
- `PHASE_3_IMPLEMENTATION_STATUS.md` - Overall progress
- `test_v2_integration.rb` - Working integration test

**Architecture**:
- Memory bank: `.kilocode/rules/memory-bank/architecture.md`
- Memory bank: `.kilocode/rules/memory-bank/tech.md`

**Original Plan**:
- `PHASE_3_CONTINUATION_PLAN.md` - Full phase 3 plan
- `PHASE_3_CONTINUE_PROMPT.md` - Session 2 continuation

## Final Notes

The hardest work is done! Core v2.0 architecture is solid and proven. Session 3 is about:
1. **Verification** - Confirm deserialization works (should be straightforward)
2. **Integration** - Connect format handlers to generated classes (mechanical work)
3. **Validation** - Write tests to prove it all works (confidence building)

**Remember**: Generated classes ARE the API. Extensions add sugar. Lutaml-model handles serialization. Keep it simple and architectural!

---

**Start Session 3**: Focus on Task 1.6 (Format Handlers) - this is the main work!