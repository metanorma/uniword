# Document Serialization Fix - Continuation Plan

## Critical Issues Identified

### 1. Document XML Mapping Missing `mixed_content`
**Problem**: Document class doesn't declare `mixed_content`, preventing proper serialization of nested body element.

**Current Code** (`lib/uniword/document.rb:63-70`):
```ruby
xml do
  root 'document'
  # WRONG: Multiple namespaces declared
  namespace Ooxml::Namespaces::WordProcessingML
  namespace Ooxml::Namespaces::Relationships  # ❌ NOT ALLOWED
  
  map_element 'body', to: :body
end
```

**Fix Required**:
```ruby
xml do
  root 'document'
  namespace Ooxml::Namespaces::WordProcessingML
  mixed_content  # ✅ REQUIRED for nested elements
  
  map_element 'body', to: :body
end
```

### 2. Multiple Namespace Declaration
**Problem**: Document declares TWO namespaces, but lutaml-model only allows ONE namespace per element. The Relationships namespace should only be used where needed (in specific attributes), not as a document-level namespace.

**Why This Fails**: Lutaml-model uses the first namespace for the root element, but having multiple confuses the serialization logic.

### 3. Raw XML Storage Violations
**Problem**: Document stores raw XML for styles, fonts, numbering, settings - THIS VIOLATES ARCHITECTURE PRINCIPLES.

**Current Code** (`lib/uniword/document.rb:109-113`):
```ruby
# ❌ ARCHITECTURAL VIOLATION - Raw XML preservation
attr_accessor :raw_styles_xml
attr_accessor :raw_font_table_xml
attr_accessor :raw_numbering_xml
attr_accessor :raw_settings_xml
```

**Why This Is Wrong**:
- Goes against model-driven architecture
- Prevents proper round-trip through models
- Makes properties uneditable
- Breaks separation of concerns

**Correct Approach**: These should be proper lutaml-model classes:
- `StylesConfiguration` (already exists!) should handle styles
- `FontTable` class for fonts
- `NumberingConfiguration` (already exists!) for numbering
- `Settings` class for settings

## Implementation Plan

### Step 1: Fix Document XML Mapping (15 minutes)

**File**: `lib/uniword/document.rb`

```ruby
# Around line 63
xml do
  root 'document'
  namespace Ooxml::Namespaces::WordProcessingML
  mixed_content  # ADD THIS
  
  map_element 'body', to: :body
end
```

### Step 2: Remove Multiple Namespace Declaration (5 minutes)

**File**: `lib/uniword/document.rb`

Remove line 67:
```ruby
namespace Ooxml::Namespaces::Relationships  # DELETE THIS LINE
```

**Note**: The `r:` namespace should only be used in specific places like:
- Relationship elements in `.rels` files
- Image references that use `r:embed` attributes
- Not at document root level

### Step 3: Remove Raw XML Storage (10 minutes)

**File**: `lib/uniword/document.rb`

Delete lines 109-113:
```ruby
# DELETE THESE
attr_accessor :raw_styles_xml
attr_accessor :raw_font_table_xml  
attr_accessor :raw_numbering_xml
attr_accessor :raw_settings_xml
```

### Step 4: Update DocxHandler to Use Models (30 minutes)  

**File**: `lib/uniword/formats/docx_handler.rb`

**Current (WRONG)**:
```ruby
# Lines 75-78
document.raw_styles_xml = package.raw_styles_xml
document.raw_font_table_xml = package.raw_font_table_xml
document.raw_numbering_xml = package.raw_numbering_xml
document.raw_settings_xml = package.raw_settings_xml
```

**Fix**:
```ruby
# Use actual models instead
document.styles_configuration = package.styles_configuration if package.styles_configuration
document.numbering_configuration = package.numbering_configuration if package.numbering_configuration
# font_table and settings need proper model classes (future work)
```

### Step 5: Fix DocxPackage (30 minutes)

**File**: `lib/uniword/ooxml/docx_package.rb`

Remove raw XML accessors and use models:
- Parse `word/styles.xml` into `StylesConfiguration` 
- Parse `word/numbering.xml` into `NumberingConfiguration`
- For now, font_table and settings can remain as string storage until models are built

### Step 6: Test Serialization (10 minutes)

Run the test script:
```bash
bundle exec ruby test_serialization.rb
```

Expected output:
```xml
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p>
      <w:r>
        <w:t>Paragraph 1</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:r>
        <w:t>Paragraph 2</w:t>
      </w:r>
    </w:p>
  </w:body>
</w:document>
```

### Step 7: Verify Round-Trip (10 minutes)

Run:
```bash
bundle exec ruby test_check_saved_xml.rb
```

Should show:
- ✅ Body element in saved XML
- ✅ Paragraphs preserved on load
- ✅ 2 paragraphs found after round-trip

## Architectural Principles Refresher

### ✅ DO
1. Use lutaml-model for ALL XML structures
2. Declare `mixed_content` when element has nested content
3. Use proper model classes for all document parts
4. Let lutaml-model handle serialization/deserialization automatically

### ❌ DON'T  
1. Store raw XML strings
2. Declare multiple namespaces at document level
3. Override `to_xml()` or `from_xml()` methods
4. Use functional serialization - always use models

## Success Criteria

- [ ] `Document.to_xml()` produces complete XML with body
- [ ] All existing tests still pass
- [ ] Round-trip works: save → load → save produces identical XML
- [ ] No raw XML storage anywhere in document.rb
- [ ] Single namespace declaration in Document

## Estimated Time

Total: ~2 hours

## Next Steps After This Fix

Once document serialization works:
1. Complete Phase 2: Enhanced properties deserialization verification
2. Complete Phase 3: Round-trip test suite  
3. Update memory bank with completion status

## Reference Files

- `lib/uniword/document.rb` - Primary fix location
- `lib/uniword/body.rb` - Already correct (has mixed_content)
- `lib/uniword/formats/docx_handler.rb` - Remove raw XML usage
- `lib/uniword/ooxml/docx_package.rb` - Use models not raw XML
- `test_serialization.rb` - Test script for verification