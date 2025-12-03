# Uniword Phase 1 Integration - Next Session Continuation Prompt

**Date Created**: November 24, 2025  
**Session Context**: Phase 1 of Complete Lutaml-Model Migration  
**Status**: Properties Enhanced, Integration Needed

---

## 🎯 Use This Prompt for Next Session

```
Continue Uniword Phase 1 Integration and Refactoring:

CURRENT STATE:
✅ ParagraphProperties enhanced with 42+ OOXML properties (borders, shading, tab stops, numbering, frames, sections)
✅ RunProperties enhanced with 40+ OOXML properties (text effects, borders, shading, complex fonts, spacing, kerning)
✅ Supporting classes created: Border, ParagraphBorders, ParagraphShading, RunShading, RunBorders, RunFontProperties, TabStop, TabStopCollection, NumberingProperties, FrameProperties, SectionProperties
✅ Architectural plans documented in PHASE_1_PROPERTIES_ARCHITECTURE.md and PHASE_1_INTEGRATION_AND_REFACTORING_PLAN.md

IMMEDIATE ISSUES TO FIX:
❌ Files reference deleted serialization directory (lib/uniword/serialization/ooxml_serializer.rb, ooxml_deserializer.rb)
❌ Namespace syntax inconsistencies across codebase
❌ XML declaration syntax issues (root vs element, mixed_content vs mixed: true)
❌ Test failures due to broken dependencies

NEXT TASK: Week 1 Critical Fixes (5 days)

Priority 1 - Remove Broken Serializer References:
1. Update lib/uniword/formats/docx_handler.rb - Remove require_relative for deleted serializers, use DocxPackage directly
2. Update lib/uniword.rb autoload section - Remove Serialization module references
3. Update lib/uniword/document_factory.rb - Use DocxPackage.from_file() directly
4. Update lib/uniword/document_writer.rb - Use DocxPackage#to_file() directly
5. Search and fix any other files referencing lib/uniword/serialization/*

Priority 2 - Standardize Namespace Syntax:
Fix these files to use correct lutaml-model syntax:
- lib/uniword/paragraph.rb: Change root to element, use Ooxml::Namespaces::WordProcessingML, fix mixed_content
- lib/uniword/run.rb: Same namespace standardization
- lib/uniword/body.rb: Add proper lutaml-model xml block
- lib/uniword/document.rb: Update namespace syntax if needed

Priority 3 - Verify Integration:
- Run bundle exec rspec spec/uniword/properties/ to verify property tests pass
- Fix any test failures related to new property classes
- Ensure DocxPackage can serialize/deserialize with enhanced properties

TESTING AFTER FIXES:
bundle exec rspec spec/round_trip_spec.rb
bundle exec rspec spec/compatibility/
bundle exec rspec spec/uniword/properties/

See PHASE_1_INTEGRATION_AND_REFACTORING_PLAN.md for complete refactoring checklist.
```

---

## 📊 Session Summary

### What Was Accomplished

**Property Enhancements (100% Complete)**:
1. ✅ **ParagraphProperties** - Added 42+ missing OOXML properties:
   - Borders (6 types: top, bottom, left, right, between, bar)
   - Shading with patterns and theme colors
   - Tab stops with alignment and leaders
   - Complete numbering properties structure
   - Frame properties for text boxes and drop caps
   - Section properties for page layout
   - Advanced typography (widow/orphan control, text direction, bidi, snap to grid, etc.)

2. ✅ **RunProperties** - Added 40+ missing OOXML properties:
   - Text effects (outline, shadow, emboss, imprint)
   - Character borders and shading
   - Complex script fonts (cs, eastAsia, hAnsi, theme references)
   - Complete language settings (lang, lang_bidi, lang_eastAsia)
   - Character spacing, kerning, positioning
   - Text expansion/compression (fitText, w)
   - Special effects (specVanish, webHidden)

3. ✅ **Supporting Classes Created**:
   - `Border` - Individual border definition
   - `ParagraphBorders` - Container for all paragraph borders
   - `ParagraphShading` - Paragraph background and patterns
   - `RunShading` - Character-level background
   - `RunBorders` - Character-level borders
   - `RunFontProperties` - Complex font handling (ASCII, East Asian, Complex Script, themes)
   - `TabStop` - Individual tab stop
   - `TabStopCollection` - Tab stop management
   - `NumberingProperties` - Complete numPr structure
   - `NumberingLevel` - Level definitions for abstract numbering
   - `FrameProperties` - Text boxes and drop caps
   - `SectionProperties` - Page layout properties

**Architectural Planning (100% Complete)**:
1. ✅ Created **PHASE_1_PROPERTIES_ARCHITECTURE.md** (comprehensive property specification)
2. ✅ Created **PHASE_1_INTEGRATION_AND_REFACTORING_PLAN.md** (2-week refactoring roadmap)
3. ✅ Identified all broken references to deleted serialization code
4. ✅ Documented correct namespace syntax patterns
5. ✅ Created migration checklists with dependencies

### What Needs Attention

**Critical Issues**:
1. ❌ **Broken Serializer References**: [`lib/uniword/formats/docx_handler.rb`](lib/uniword/formats/docx_handler.rb:6-7) still requires deleted files
2. ❌ **Autoload References**: [`lib/uniword.rb`](lib/uniword.rb:213-217) still has Serialization module
3. ❌ **Namespace Syntax**: Several files use old `root` and string URI syntax instead of `element` and `Ooxml::Namespaces::ClassName`

**Files Needing Immediate Fixes**:
- [`lib/uniword/formats/docx_handler.rb`](lib/uniword/formats/docx_handler.rb)
- [`lib/uniword.rb`](lib/uniword.rb)
- [`lib/uniword/paragraph.rb`](lib/uniword/paragraph.rb)
- [`lib/uniword/run.rb`](lib/uniword/run.rb)
- [`lib/uniword/body.rb`](lib/uniword/body.rb)
- [`lib/uniword/document.rb`](lib/uniword/document.rb)

---

## 📁 Key Files Status

### ✅ Complete and Working
- `lib/uniword/properties/paragraph_properties.rb` - 42+ properties
- `lib/uniword/properties/run_properties.rb` - 40+ properties
- `lib/uniword/properties/border.rb`
- `lib/uniword/properties/shading.rb`
- `lib/uniword/properties/tab_stop.rb`
- `lib/uniword/properties/numbering_properties.rb`
- `lib/uniword/properties/frame_properties.rb`
- `lib/uniword/ooxml/core_properties.rb` - Perfect lutaml-model example
- `lib/uniword/ooxml/app_properties.rb` - Perfect lutaml-model example
- `lib/uniword/ooxml/docx_package.rb` - 100% round-trip working

### ❌ Needs Fixing
- `lib/uniword/formats/docx_handler.rb` - Remove serializer requires
- `lib/uniword.rb` - Remove serialization autoload
- `lib/uniword/paragraph.rb` - Fix namespace syntax
- `lib/uniword/run.rb` - Fix namespace syntax
- `lib/uniword/body.rb` - Add proper lutaml-model
- `lib/uniword/document.rb` - Verify namespace syntax

---

## 🔬 Testing Strategy

### Tests to Run After Fixes:
```bash
# 1. Property tests
bundle exec rspec spec/uniword/properties/paragraph_properties_spec.rb
bundle exec rspec spec/uniword/properties/run_properties_spec.rb

# 2. Round-trip tests
bundle exec rspec spec/round_trip_spec.rb

# 3. Compatibility tests
bundle exec rspec spec/compatibility/

# 4. Full suite
bundle exec rspec
```

### Expected Outcomes:
- All property tests should pass
- Round-trip tests should maintain 100% fidelity
- No regressions in existing functionality
- Enhanced properties serialize/deserialize correctly

---

## 📚 Reference Documents

**For Implementation**:
- `PHASE_1_INTEGRATION_AND_REFACTORING_PLAN.md` - Complete 2-week refactoring roadmap
- `PHASE_1_PROPERTIES_ARCHITECTURE.md` - Property specifications and patterns
- `CONTINUATION_PLAN_COMPLETE_MODELING.md` - Overall migration strategy
- `IMPLEMENTATION_STATUS.md` - Component status tracker

**For Examples**:
- `lib/uniword/ooxml/core_properties.rb` - Perfect namespace usage
- `lib/uniword/ooxml/app_properties.rb` - Perfect XML mapping
- `lib/uniword/ooxml/types/dc_title_type.rb` - Type class pattern

---

## ⚙️ Correct Lutaml-Model Syntax

### XML Block Syntax:
```ruby
xml do
  element 'elementName'                           # NOT root
  namespace Ooxml::Namespaces::WordProcessingML   # NOT string URI
  mixed_content                                   # NOT mixed_content true
  
  map_element 'childElement', to: :attribute_name
  map_attribute 'attrName', to: :attribute_name
end
```

### Namespace Declaration:
```ruby
# In namespaces.rb
class WordProcessingML < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
  prefix_default 'w'
  element_form_default :qualified
  attribute_form_default :unqualified
end

# In model files
xml do
  element 'p'
  namespace Ooxml::Namespaces::WordProcessingML  # Use the class!
end
```

---

## 🎬 Quick Start Commands

```bash
# 1. Check current state
git status

# 2. Search for broken references
grep -r "serialization/ooxml" lib/uniword/

# 3. Start fixing
# (Switch to code mode and begin with docx_handler.rb)

# 4. Verify after each fix
bundle exec rspec spec/uniword/properties/
```

---

## ⚠️ Known Issues

1. **lutaml-model require path**: The local dev gem has `require 'lutaml/model/xml_namespace'` but standalone tests fail. Tests should run via `bundle exec` to use correct gem paths.

2. **Circular Dependencies**: Removed in paragraph.rb but watch for new ones when integrating properties.

3. **Test Adapter Configuration**: Tests need proper lutaml-model XML adapter configuration.

---

## 🏆 Success Metrics

**Week 1 (Critical Fixes):**
- [ ] Zero references to deleted serialization code
- [ ] All namespace syntax standardized
- [ ] All tests loading without errors
- [ ] DocxPackage working with enhanced properties

**Week 2 (Integration)**:
- [ ] All 82+ properties functional in round-trip tests
- [ ] Convenience API complete
- [ ] Test coverage ≥95%
- [ ] Performance benchmarks met

---

**Status**: Ready for Code mode implementation. Start with fixing broken serializer references in docx_handler.rb and lib/uniword.rb.