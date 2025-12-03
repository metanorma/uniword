# Phase 3 Week 3: Glossary/Building Blocks Continuation Plan

## Executive Summary

**Discovery**: The 8 document element reference files (.dotx) are **Building Blocks galleries**, not regular documents. They use the Glossary infrastructure with 19 classes that currently have incorrect namespaces.

**Status**: Test infrastructure complete (16 tests), Foundation laid (1.5 hours), Systematic fixes ready.

**Current Results**: 8/16 passing (50% - content types only)
**Target Results**: 16/16 passing (100% - full round-trip)

## Root Cause Analysis

### Issue: Namespace Mismatch

**Problem**: All 19 Glossary classes use wrong namespace
```ruby
# WRONG (current)
namespace Uniword::Ooxml::Namespaces::Glossary  # g: prefix

# CORRECT (needed)
namespace Uniword::Ooxml::Namespaces::WordProcessingML  # w: prefix
```

**Evidence**: XML uses `<w:glossaryDocument>`, not `<g:glossaryDocument>`

### Issue: Element Name Format

**Problem**: Some classes use snake_case instead of camelCase
```ruby
# WRONG
element 'glossary_document'

# CORRECT  
root 'glossaryDocument'
```

### Issue: Missing Content Preservation

**Problem**: Nested elements not serializing (DocPartBody content missing)

## Strategic Approach: Systematic Fixes

### Phase 1: Glossary Class Hierarchy Fixes (4 hours)

**Target**: Fix all 19 classes in `lib/uniword/glossary/`

**Classes to Fix** (Priority Order):
1. ✅ `glossary_document.rb` - PARTIAL (namespace fixed, element name fixed)
2. `doc_parts.rb` - Container
3. `doc_part.rb` - Individual entry
4. `doc_part_properties.rb` - Metadata
5. `doc_part_body.rb` - Content (CRITICAL)
6. `doc_part_name.rb`
7. `doc_part_description.rb`
8. `doc_part_gallery.rb`
9. `doc_part_category.rb`
10. `category_name.rb`
11. `doc_part_behaviors.rb`
12. `doc_part_behavior.rb`
13. `doc_part_types.rb`
14. `doc_part_type.rb`
15. `doc_part_id.rb`
16. `style_id.rb`
17. `auto_text.rb`
18. `equation.rb`
19. `text_box.rb`

**Pattern for Each Class**:
```ruby
class ClassName < Lutaml::Model::Serializable
  # STEP 1: Attributes FIRST (Pattern 0)
  attribute :attr_name, Type

  # STEP 2: XML mapping
  xml do
    root 'elementName'  # NOT element (unless embedded)
    namespace Uniword::Ooxml::Namespaces::WordProcessingML  # w: NOT g:
    mixed_content  # For elements with text/child content
    
    map_element 'childName', to: :attr_name, render_nil: false
    map_attribute 'attrName', to: :attr_name
  end
end
```

### Phase 2: Verification (1 hour)

**Test Strategy**:
- Run tests after each batch of 5 classes
- Target progression: 8→10→12→14→16/16 passing
- Zero regressions in existing 342 tests

### Phase 3: Documentation (30 min)

**Updates Required**:
- Memory bank (context.md, architecture.md)
- Status tracker
- README.adoc (Building Blocks support)

## Implementation Timeline (Compressed)

### Session 2: Core Glossary Fixes (2 hours)
**Time**: 2 hours
**Files**: 10 core classes
- [x] GlossaryDocument (partial)
- [ ] DocParts, DocPart, DocPartBody (CRITICAL path)
- [ ] DocPartProperties, DocPartName, DocPartDescription
- [ ] DocPartGallery, DocPartCategory, CategoryName

**Target**: 12/16 tests passing (75%)

### Session 3: Supporting Classes (1.5 hours)
**Time**: 1.5 hours
**Files**: 9 supporting classes
- [ ] DocPartBehaviors, DocPartBehavior
- [ ] DocPartTypes, DocPartType, DocPartId
- [ ] StyleId, AutoText, Equation, TextBox

**Target**: 16/16 tests passing (100%)

### Session 4: Verification & Documentation (1 hour)
**Time**: 1 hour
- [ ] Run full test suite (350 examples expected)
- [ ] Verify zero regressions (342/342 still passing)
- [ ] Update documentation
- [ ] Update memory bank

**Total Time**: 4.5 hours (compressed from original 6 hours)

## Architecture Compliance

### MECE Principle
- Each Glossary class has ONE responsibility
- No overlap in functionality
- Complete coverage of OOXML spec

### Pattern 0 Compliance
```ruby
# ✅ ALWAYS: Attributes BEFORE xml block
attribute :my_attr, Type
xml do
  map_element 'elem', to: :my_attr
end
```

### Separation of Concerns
- **Model classes** (Glossary::*): Pure domain (NO file I/O)
- **Part classes** (Ooxml::GlossaryPart): Packaging (future)
- **Serializers**: lutaml-model handles

### Open/Closed Principle
- Existing classes: extensions
- New classes: composition
- No modification of core framework

## Risk Mitigation

### Risk 1: Time Pressure
**Mitigation**: Batch processing (5 classes at a time)
**Buffer**: 30-min buffer per session

### Risk 2: Unexpected Issues
**Mitigation**: Test after each batch
**Fallback**: Systematic analysis, not guessing

### Risk 3: Regressions
**Mitigation**: Run 342 existing tests after each batch
**Recovery**: Git revert if >5% regression

## Success Criteria

1. ✅ All 16 document element tests passing (100%)
2. ✅ Zero regressions (342/342 existing tests still passing)
3. ✅ All architecture principles maintained
4. ✅ Documentation updated
5. ✅ Memory bank current

## Files to Modify

**Glossary Classes** (19 files):
```
lib/uniword/glossary/
├── glossary_document.rb ⏳ (partial)
├── doc_parts.rb ❌
├── doc_part.rb ❌
├── doc_part_body.rb ❌ (CRITICAL)
├── doc_part_properties.rb ❌
├── doc_part_name.rb ❌
├── doc_part_description.rb ❌
├── doc_part_gallery.rb ❌
├── doc_part_category.rb ❌
├── category_name.rb ❌
├── doc_part_behaviors.rb ❌
├── doc_part_behavior.rb ❌
├── doc_part_types.rb ❌
├── doc_part_type.rb ❌
├── doc_part_id.rb ❌
├── style_id.rb ❌
├── auto_text.rb ❌
├── equation.rb ❌
└── text_box.rb ❌
```

**Test Files** (1 file):
```
spec/uniword/document_elements_roundtrip_spec.rb ✅ (created)
```

**No new files needed** - infrastructure exists!

## Next Session Start

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify baseline
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 342 examples, 0 failures ✅

# Check document elements
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Current: 16 examples, 8 failures (50%)
# Target: 16 examples, 0 failures (100%)
```

Then proceed systematically through Sessions 2-4.

## Key Learnings

1. **Building Blocks are Glossary-based** - Not regular documents
2. **Namespace is WordProcessingML** - Not a separate Glossary namespace
3. **Infrastructure exists** - Just needs systematic fixes
4. **Batch processing works** - Proven in Theme week (174 tests→100%)

## Reference

**Similar Success**: Phase 3 Week 2 (Themes)
- Started: 145/174 (83%)
- Fixed: Namespace issues + missing elements
- Result: 174/174 (100%) in 5 sessions
- **Same pattern applies here**

**Confidence**: HIGH - Proven approach, existing infrastructure, clear path