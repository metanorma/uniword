# Plan: Fix Headers, Footers, Fields Specs

## Problem

Four tests fail in `headers_footers_fields_spec.rb`:
1. `initializes with default section` (line 222) - sections returns empty
2. `adds sections` (line 228) - `add_section` method doesn't exist
3. `adds header to section` (line 234) - `current_section` returns nil
4. `creates document with page numbers in footer` (line 241) - related to sections

## Root Cause Analysis

### Architectural Mismatch

The tests expect a **Section as a first-class object** with a builder-style API:
```ruby
doc = DocumentRoot.new
section = doc.add_section
header = doc.current_section.header('default')
```

But OOXML defines sections as **sectPr elements embedded in paragraphs**:
```xml
<w:p>
  <w:pPr>
    <w:sectPr>
      <w:headerReference w:type="default" r:id="rId10"/>
    </w:sectPr>
  </w:pPr>
</w:p>
```

### Current Implementation

- `DocumentRoot.sections` returns paragraphs with sectPr elements
- `Section` is a separate class that wraps section-related data
- `add_section` method doesn't exist on DocumentRoot

### Key Issue

The tests are written for a **builder API** (adding sections, getting headers from current section), not a **model-driven OOXML API** (where sections are derived from document structure).

The user said "NO Document builder or writer API at this stage". These tests explicitly test a builder API.

## Fix Approach

### Option A: Update Tests to Match Model-Driven Architecture

Since the user wants model-driven OOXML and NOT builder API:

1. **`initializes with default section`**: Update test to expect empty sections for new document
   ```ruby
   it 'initializes with empty sections' do
     doc = Uniword::Wordprocessingml::DocumentRoot.new
     expect(doc.sections).to be_empty
   end
   ```

2. **`adds sections`**: This test requires builder API - should be removed or rewritten

3. **`adds header to section`**: Rewrite to use model-driven approach:
   ```ruby
   it 'creates section with header' do
     doc = Uniword::Wordprocessingml::DocumentRoot.new
     para = doc.body.add_paragraph
     para.properties.section_properties = SectionProperties.new
     para.properties.section_properties.header_reference = HeaderReference.new(...)
   end
   ```

### Option B: Implement Section Management API (Builder)

If we want to keep the builder-style API:

1. Add `add_section` method to DocumentRoot:
   ```ruby
   def add_section
     section = Section.new
     @sections ||= []
     @sections << section
     section
   end
   ```

2. Ensure `current_section` returns a Section

3. Link Section headers/footers to sectPr in paragraphs

## Recommended Approach

Given "model-driven, no builder API" requirement, **Option A** is correct:
- Update tests to reflect how OOXML sections actually work
- A new document has no paragraphs, hence no sections
- Sections are derived from paragraphs with sectPr, not added separately

## Implementation

Update `spec/uniword/headers_footers_fields_spec.rb`:

1. Change `initializes with default section` to `initializes with empty sections`
2. Remove or rewrite `adds sections` test
3. Rewrite header/footer tests to use model-driven approach

## Files to Modify

- `spec/uniword/headers_footers_fields_spec.rb` (update tests)

## Note

The Section class itself works correctly for representing section data. The issue is purely with how sections are managed in the DocumentRoot model.
