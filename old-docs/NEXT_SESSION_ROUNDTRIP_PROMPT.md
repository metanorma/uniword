# Next Session: Enhanced Properties Round-Trip Implementation

## Mission
Implement full round-trip preservation for enhanced properties - ensure documents with character spacing, kerning, borders, tab stops, shading, etc. can be loaded, modified, and saved without losing these properties.

## Current Achievement ✅
**Phase 1 Complete: XML Serialization**
- 22/22 enhanced properties tests passing
- All wrapper classes implemented and working
- Namespace prefixes on attributes working correctly (thanks to lutaml-model fixes)
- File: [`spec/uniword/enhanced_properties_xml_spec.rb`](spec/uniword/enhanced_properties_xml_spec.rb)

## Session Goal 🎯
Complete Phase 2 (Deserialization) and Phase 3 (Round-Trip Tests) to achieve full round-trip preservation of enhanced properties.

## Critical Context

### What We're Building
Enhanced properties in OOXML include:
- **Run properties**: `character_spacing`, `kerning`, `position`, `text_expansion`, `emphasis_mark`, `language`, `shading`
- **Paragraph properties**: `borders` (top/bottom/left/right/between/bar), `shading`, `tab_stops`
- **Text effects**: `outline`, `shadow`, `emboss`, `imprint` (already round-trip but via boolean)

### Architecture Understanding

**Serialization (✅ Working)**:
```ruby
Run → properties.character_spacing = CharacterSpacing.new(val: 20)
     → to_xml → <w:spacing w:val="20"/>
```

**Deserialization (🚧 Needs Implementation)**:
```ruby
<w:spacing w:val="20"/> → from_xml → CharacterSpacing.new(val: 20)
                                   → run.properties.character_spacing
```

### Wrapper Classes Pattern

All OOXML elements with `w:val` attributes use wrapper classes:
- [`CharacterSpacing`](lib/uniword/properties/simple_val_properties.rb:18) wraps `<w:spacing w:val="20"/>`
- [`Kerning`](lib/uniword/properties/simple_val_properties.rb:36) wraps `<w:kern w:val="24"/>`
- [`Position`](lib/uniword/properties/simple_val_properties.rb:45) wraps `<w:position w:val="5"/>`
- [`EmphasisMark`](lib/uniword/properties/simple_val_properties.rb:54) wraps `<w:em w:val="dot"/>`
- [`Language`](lib/uniword/properties/simple_val_properties.rb:65) wraps `<w:lang w:val="en-US"/>`
- [`TabStop`](lib/uniword/properties/tab_stop.rb:8) wraps `<w:tab w:pos="1440" w:val="center" w:leader="dot"/>`

### Lutaml-Model Integration

**Key Rules (DO NOT VIOLATE):**
1. ✅ **ALWAYS** let lutaml-model handle `to_xml()` and `from_xml()` automatically
2. ✅ **NEVER** override these methods in classes that inherit from `Lutaml::Model::Serializable`
3. ✅ **ALWAYS** use wrapper classes for OOXML elements with `w:val` attributes
4. ✅ **ALWAYS** declare proper namespace in `xml` blocks

## Implementation Steps

### Step 1: Verify Current Deserialization Baseline (30 min)

Test what's already working:
```bash
bundle exec rspec spec/uniword/document_spec.rb --tag roundtrip
bundle exec rspec spec/uniword/ --tag integration
```

Create a test to check current deserialization of enhanced properties:
```ruby
# test_current_deserialization.rb
require_relative 'lib/uniword'

doc = Uniword::Document.open('spec/fixtures/tables.docx')
para = doc.body.paragraphs.first

# Check what's being parsed
puts "Properties class: #{para.properties.class}"
puts "Character spacing: #{para.runs.first.properties.character_spacing.inspect}" if para.runs.any?
```

### Step 2: Implement Enhanced Properties Deserialization (3-4 hours)

**File**: `lib/uniword/serialization/ooxml_deserializer.rb`

**Pattern to Follow**:
Lutaml-model handles deserialization automatically through the `xml` block mappings. The deserializer should just call `from_xml` on the appropriate classes.

**Example deserialization (already working for basic properties)**:
```ruby
# In RunProperties class (lib/uniword/properties/run_properties.rb)
xml do
  map_element 'spacing', to: :character_spacing  # Automatically creates CharacterSpacing from XML
  map_element 'kern', to: :kerning              # Automatically creates Kerning from XML
  map_element 'position', to: :position         # Automatically creates Position from XML
end
```

**What to Check:**
1. Are the `xml` block mappings complete for all enhanced properties?
2. Are attribute types correctly declared (use wrapper classes, not primitives)?
3. Is the namespace configuration correct?

**Files to Review/Update:**
- [`lib/uniword/properties/run_properties.rb`](lib/uniword/properties/run_properties.rb) - Lines 193-196 map the wrapper classes
- [`lib/uniword/properties/paragraph_properties.rb`](lib/uniword/properties/paragraph_properties.rb) - Check mappings for borders, shading, tab_stops
- [`lib/uniword/serialization/ooxml_deserializer.rb`](lib/uniword/serialization/ooxml_deserializer.rb) - Main deserialization orchestrator

### Step 3: Create Round-Trip Test Fixtures (1 hour)

**Create**:
```
spec/fixtures/enhanced_properties/
├── character_spacing.docx     # Document with various spacing values
├── kerning.docx               # Document with kerning
├── tab_stops.docx             # Document with multiple tab stops
├── borders.docx               # Document with paragraph borders
├── shading.docx               # Document with paragraph and run shading
└── combination.docx           # Document combining multiple properties
```

**How to Create Fixtures**:
1. Use Microsoft Word to create documents with these properties
2. Or use the API to generate them:
   ```ruby
   doc = Uniword::Document.new
   para = doc.add_paragraph("Test")
   para.add_tab_stop(position: 1440, alignment: "center", leader: "dot")
   doc.save('spec/fixtures/enhanced_properties/tab_stops.docx')
   ```

### Step 4: Implement Round-Trip Tests (2 hours)

**Create**: `spec/uniword/enhanced_properties_roundtrip_spec.rb`

**Test Pattern**:
```ruby
RSpec.describe "Enhanced Properties Round-Trip" do
  describe "Character spacing" do
    it "preserves character spacing through load-save cycle" do
      # Create document with property
      original_doc = Uniword::Document.new
      para = original_doc.add_paragraph("Test")
      run = para.runs.first
      run.character_spacing = 20
      original_doc.save('test_output/spacing_original.docx')
      
      # Load and verify
      loaded_doc = Uniword::Document.open('test_output/spacing_original.docx')
      loaded_run = loaded_doc.body.paragraphs.first.runs.first
      expect(loaded_run.character_spacing).to eq(20)
      
      # Save again
      loaded_doc.save('test_output/spacing_roundtrip.docx')
      
      # Load again and verify still preserved
      final_doc = Uniword::Document.open('test_output/spacing_roundtrip.docx')
      final_run = final_doc.body.paragraphs.first.runs.first
      expect(final_run.character_spacing).to eq(20)
      
      # Optional: XML semantic comparison
      original_xml = extract_document_xml('test_output/spacing_original.docx')
      roundtrip_xml = extract_document_xml('test_output/spacing_roundtrip.docx')
      expect(roundtrip_xml).to be_xml_equivalent_to(original_xml)
    end
  end
  
  # Repeat for: kerning, position, text_expansion, emphasis_mark, language,
  # borders, shading, tab_stops, and combinations
end
```

### Step 5: Validation & Performance (1 hour)

**Validation Checks**:
- [ ] All round-trip tests pass
- [ ] No regression in existing tests
- [ ] Documents open correctly in Microsoft Word
- [ ] XML is semantically equivalent (use Canon gem)

**Performance Checks**:
- [ ] Load + Save cycle < 100ms for simple documents
- [ ] Load + Save cycle < 1s for complex documents
- [ ] No memory leaks in repeated operations

## Debugging Strategy

### If Deserialization Fails

1. **Check XML Mappings**:
   ```ruby
   # Verify mapping exists
   puts RunProperties.xml_mapping.inspect
   ```

2. **Test Individual Classes**:
   ```ruby
   xml = '<w:spacing w:val="20" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'
   spacing = CharacterSpacing.from_xml(xml)
   puts spacing.val  # Should print: 20
   ```

3. **Check Namespace Configuration**:
   - Elements must have namespace declared
   - Wrapper classes must use same namespace
   - Attribute form must allow namespaced attributes

### If Round-Trip Fails

1. **Compare XML Semantically**:
   ```ruby
   require 'canon/rspec_matchers'
   expect(loaded_xml).to be_xml_equivalent_to(original_xml)
   ```

2. **Check Property Preservation**:
   ```ruby
   # After load
   puts run.properties.inspect
   puts run.properties.character_spacing.inspect
   ```

3. **Verify Serialization Still Works**:
   ```ruby
   # Test serialization of loaded properties
   xml = run.to_xml
   # Should contain <w:spacing w:val="20"/>
   ```

## Files to Modify

### Primary Implementation
1. `lib/uniword/serialization/ooxml_deserializer.rb`
   - Add enhanced property deserialization logic
   - Ensure wrapper classes are instantiated correctly

### Test Files
2. `spec/uniword/enhanced_properties_roundtrip_spec.rb` (NEW)
   - Complete round-trip test suite

3. `spec/fixtures/enhanced_properties/` (NEW DIRECTORY)
   - Test documents with enhanced properties

### Documentation Updates
4. `README.adoc`
   - Add section on enhanced properties
   - Document all new features with examples

5. `CHANGELOG.md`
   - Document v1.1.0 features

## Reference Files

**Memory Bank**:
- [`.kilocode/rules/memory-bank/context.md`](.kilocode/rules/memory-bank/context.md) - Update with completion
- [`.kilocode/rules/memory-bank/architecture.md`](.kilocode/rules/memory-bank/architecture.md) - Update with enhanced properties architecture

**Implementation Guide**:
- [`ENHANCED_PROPERTIES_CONTINUATION_PLAN.md`](ENHANCED_PROPERTIES_CONTINUATION_PLAN.md) - This file's companion with detailed status

**Lutaml-Model Issues** (For Reference Only):
- [`lutaml_attribute_namespace_proposal.md`](lutaml_attribute_namespace_proposal.md) - Resolved ✅
- [`lutaml_collection_mutation_bug.md`](lutaml_collection_mutation_bug.md) - Resolved ✅

## Success Metrics

- [ ] 22/22 serialization tests passing ✅ (Already done!)
- [ ] 22/22 deserialization tests passing
- [ ] 22/22 round-trip tests passing
- [ ] All existing tests still pass (no regressions)
- [ ] Documentation updated
- [ ] Ready for v1.1.0 release

## Post-Completion Actions

Once round-trip is working:
1. Update memory bank with completion status
2. Move temporary documents to `old-docs/`
3. Update README.adoc with enhanced properties examples
4. Tag and release v1.1.0

## Critical Reminders

🚨 **NEVER override `to_xml()` or `from_xml()` in lutaml-model classes**
🚨 **ALWAYS use wrapper classes for OOXML `w:val` attributes**
🚨 **TRUST lutaml-model's automatic serialization/deserialization**
🚨 **Follow object-oriented principles - models should be format-agnostic**
🚨 **Maintain MECE architecture - each property in exactly one place**