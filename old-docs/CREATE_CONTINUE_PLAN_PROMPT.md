# Uniword Enhanced Properties Round-Trip - Next Session Plan

## Session Summary: Document Serialization Issue Discovered

### What Was Accomplished ✅

**Phase 1: Enhanced Properties XML Serialization - COMPLETE**
- All 22/22 enhanced properties XML serialization tests passing
- All wrapper classes implemented and working:
  - `CharacterSpacing`, `TextExpansion`, `Kerning`, `Position`
  - `EmphasisMark`, `Language`, `TabStop`
  - `Border`, `Shading` (both paragraph and run level)
- XML mappings complete in `RunProperties` and `ParagraphProperties`
- Element-level serialization verified (`Paragraph.to_xml()`, `Run.to_xml()`)

### Critical Issue Found 🚨

**Document Serialization Is Broken**

While attempting to verify round-trip functionality, discovered that `Document.to_xml()` produces **empty XML** with no body element:

```ruby
doc = Uniword::Document.new
doc.add_paragraph("Test 1")
doc.add_paragraph("Test 2")

doc.body.paragraphs.size  # => 2 ✅ In memory
doc.to_xml                # => '<document xmlns="..."/>' ❌ EMPTY!
```

Saved DOCX files contain empty `word/document.xml` with no content.

**BUT**: Deserialization works perfectly! `Document.from_xml()` correctly parses all XML.

### Root Causes Identified

Three architectural problems in `lib/uniword/document.rb`:

#### 1. Missing `mixed_content` (Lines 63-70)
```ruby
# CURRENT (WRONG)
xml do
  root 'document'
  namespace Ooxml::Namespaces::WordProcessingML
  namespace Ooxml::Namespaces::Relationships  # Also wrong, see #2
  map_element 'body', to: :body  # Missing mixed_content!
end
```

#### 2. Multiple Namespace Declaration (Line 67)
```ruby
namespace Ooxml::Namespaces::Relationships  # ❌ NOT ALLOWED
```

Lutaml-model only allows **ONE** namespace per element. Multiple namespaces break serialization.

#### 3. Raw XML Storage (Lines 109-113)
```ruby
# ❌ ARCHITECTURAL VIOLATION
attr_accessor :raw_styles_xml
attr_accessor :raw_font_table_xml  
attr_accessor :raw_numbering_xml
attr_accessor :raw_settings_xml
```

This violates model-driven architecture. All XML should be handled through proper lutaml-model classes.

## Next Session Tasks

### Priority 1: Fix Document Serialization (2 hours) 🔥

**File**: `lib/uniword/document.rb`

**Changes Required**:

1. **Add `mixed_content` to XML mapping** (lines 63-70):
```ruby
xml do
  root 'document'
  namespace Ooxml::Namespaces::WordProcessingML
  mixed_content  # ✅ ADD THIS LINE
  
  map_element 'body', to: :body
end
```

2. **Remove multiple namespace declaration** (line 67):
```ruby
# DELETE THIS LINE
namespace Ooxml::Namespaces::Relationships
```

3. **Remove raw XML storage** (lines 109-113):
```ruby
# DELETE ALL THESE
attr_accessor :raw_styles_xml
attr_accessor :raw_font_table_xml
attr_accessor :raw_numbering_xml
attr_accessor :raw_settings_xml
```

4. **Update `DocxHandler`** (`lib/uniword/formats/docx_handler.rb`, lines 75-78):
```ruby
# REMOVE raw XML assignment
# Use actual models instead:
document.styles_configuration = package.styles_configuration if package.styles_configuration
document.numbering_configuration = package.numbering_configuration if package.numbering_configuration
```

5. **Update `DocxPackage`** (`lib/uniword/ooxml/docx_package.rb`):
- Remove raw XML accessors
- Parse `word/styles.xml` into `StylesConfiguration`
- Parse `word/numbering.xml` into `NumberingConfiguration`

**Verification**:
```bash
# Should show body with paragraphs
bundle exec ruby test_serialization.rb

# Should preserve paragraphs on round-trip
bundle exec ruby test_check_saved_xml.rb
```

### Priority 2: Complete Enhanced Properties Round-Trip (2-3 hours)

Once document serialization works:

1. **Verify Deserialization** (30 min)
   - Run: `bundle exec ruby test_enhanced_properties_deserialization_baseline.rb`
   - Should show all properties deserialize correctly

2. **Create Round-Trip Tests** (2 hours)
   - File: `spec/uniword/enhanced_properties_roundtrip_spec.rb`
   - Test each property: character_spacing, kerning, position, text_expansion, emphasis_mark, language, borders, shading, tab_stops
   - Verify: create → save → load → save → load maintains all properties

3. **Update Documentation** (30 min)
   - Add enhanced properties section to README.adoc
   - Update CHANGELOG.md for v1.1.0
   - Document wrapper class pattern

## Test Files Created

Ready-to-use test scripts in repository root:
1. `test_minimal_deser.rb` - Proves deserialization works
2. `test_serialization.rb` - Exposes serialization bug  
3. `test_check_saved_xml.rb` - Shows empty saved XML
4. `test_enhanced_props_focused.rb` - Round-trip test (blocked by serialization)

## Architecture Principles - REMEMBER

### ✅ Always Do
1. Use lutaml-model for ALL XML structures
2. Declare `mixed_content` when element has nested elements
3. Use ONE namespace per element only
4. Let lutaml-model handle serialization/deserialization
5. NEVER override `to_xml()` or `from_xml()` methods

### ❌ Never Do
1. Store raw XML strings in attributes
2. Declare multiple namespaces at document level
3. Skip `mixed_content` for nested elements
4. Use functional serialization - always use models

## Key Files Reference

### Implementation Files
- `lib/uniword/document.rb` - **PRIMARY FIX LOCATION**
- `lib/uniword/body.rb` - Already correct (has mixed_content)
- `lib/uniword/properties/run_properties.rb` - Enhanced properties mappings
- `lib/uniword/properties/paragraph_properties.rb` - Enhanced properties mappings
- `lib/uniword/formats/docx_handler.rb` - Remove raw XML usage
- `lib/uniword/ooxml/docx_package.rb` - Use models not raw XML

### Test Files
- `spec/uniword/enhanced_properties_xml_spec.rb` - 22/22 passing ✅
- `test_serialization.rb` - Shows the bug
- `test_check_saved_xml.rb` - Verifies fix

### Documentation
- `CONTINUATION_PLAN_DOCUMENT_SERIALIZATION_FIX.md` - Detailed fix instructions
- `.kilocode/rules/memory-bank/context.md` - Updated with findings

## Success Criteria

- [ ] `Document.to_xml()` produces complete XML with `<w:body>` element
- [ ] All existing tests still pass (run full suite)
- [ ] `test_serialization.rb` shows body and paragraphs in XML
- [ ] `test_check_saved_xml.rb` shows paragraphs preserved after round-trip
- [ ] No raw XML storage in document.rb
- [ ] Single namespace declaration in Document
- [ ] Enhanced properties round-trip tests passing

## Estimated Timeline

- **Document Serialization Fix**: 2 hours
- **Enhanced Properties Round-Trip**: 2-3 hours
- **Total**: 4-5 hours

## Current Cost: $1.80

## Next Step Command

After memory bank review, start with:
```bash
# Verify the issue
bundle exec ruby test_serialization.rb

# Then make the fixes to document.rb
# Then verify the fix
bundle exec ruby test_serialization.rb
bundle exec ruby test_check_saved_xml.rb
```

---

**Note**: The enhanced properties implementation itself is COMPLETE and WORKING. The only blocker is document-level serialization, which affects ALL round-trip testing, not just enhanced properties.