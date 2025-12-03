# Phase 3 Week 3: Glossary/Building Blocks - Session 2 Continuation Prompt

## Context

You are continuing the Uniword Phase 3 Week 3 implementation. **Session 1 is COMPLETE** with test infrastructure established and root cause identified. You are now starting **Session 2** to fix the Glossary class hierarchy.

## Current State (December 1, 2024 - After Session 1)

**Version**: 1.1.0 (in development)
**Status**: Session 1 COMPLETE ✅, Session 2 STARTING

**Test Results**:
```bash
# Baseline (No Regressions)
StyleSets: 168/168 (100%) ✅
Themes: 174/174 (100%) ✅
Total Baseline: 342/342 (100%) ✅

# Document Elements (Our Target)
Content Types: 8/8 (100%) ✅
Glossary Round-Trip: 0/8 (0%) ❌
Total: 8/16 (50%)
```

## Your Task (Session 2: Core Glossary Fixes)

**Objective**: Fix 10 core Glossary classes to achieve 75% test passing rate

**Timeline**: 2 hours

**Target**: 12/16 tests passing (75%)

## Step-by-Step Instructions

### Step 1: Review Context (15 min)

Read these files to understand the full situation:
```bash
cd /Users/mulgogi/src/mn/uniword

# Read planning documents
cat PHASE3_WEEK3_GLOSSARY_CONTINUATION_PLAN.md
cat PHASE3_WEEK3_GLOSSARY_STATUS.md
cat .kilocode/rules/memory-bank/context.md
```

### Step 2: Verify Baseline (5 min)

```bash
# Ensure no regressions
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 342 examples, 0 failures ✅

# Check current state
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Current: 16 examples, 8 failures (50%)
```

### Step 3: Batch 1 - Critical Path (45 min)

Fix the 4 most critical classes that form the core serialization path:

**3A: Complete GlossaryDocument Fix**
```ruby
# lib/uniword/glossary/glossary_document.rb
# Verify: root 'glossaryDocument', namespace WordProcessingML, mixed_content
```

**3B: Fix DocParts Container**
```ruby
# lib/uniword/glossary/doc_parts.rb
class DocParts < Lutaml::Model::Serializable
  attribute :doc_part, DocPart, collection: true  # ✅ FIRST
  
  xml do
    root 'docParts'  # NOT element (this is root level in collection)
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content
    
    map_element 'docPart', to: :doc_part
  end
end
```

**3C: Fix DocPart Entry**
```ruby
# lib/uniword/glossary/doc_part.rb
# Already correct structure, just verify namespace
class DocPart < Lutaml::Model::Serializable
  attribute :doc_part_pr, DocPartProperties      # ✅ FIRST
  attribute :doc_part_body, DocPartBody          # ✅ FIRST
  
  xml do
    root 'docPart'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content
    
    map_element 'docPartPr', to: :doc_part_pr, render_nil: false
    map_element 'docPartBody', to: :doc_part_body, render_nil: false
  end
end
```

**3D: Fix DocPartBody (CRITICAL)**
```ruby
# lib/uniword/glossary/doc_part_body.rb
# This contains the actual content (paragraphs, tables, etc.)
# Must use Wordprocessingml classes for content
```

**Test After Batch 1**:
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Expected: Some improvement (maybe 9-10/16 passing)
```

### Step 4: Batch 2 - Properties & Metadata (45 min)

Fix the 6 property/metadata classes:

**4A: DocPartProperties**
```ruby
# lib/uniword/glossary/doc_part_properties.rb
# Container for all properties - check all child elements
```

**4B-4F: Individual Property Classes**
```ruby
# Fix each:
# - doc_part_name.rb
# - doc_part_description.rb
# - doc_part_gallery.rb
# - doc_part_category.rb
# - category_name.rb

# Pattern for each:
class ClassName < Lutaml::Model::Serializable
  attribute :value, :string  # or appropriate type
  
  xml do
    root 'elementName'  # camelCase
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value  # if attribute-based
    # OR
    map_content to: :value  # if text content
  end
end
```

**Test After Batch 2**:
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Expected: 12/16 passing (75%) ✅
```

### Step 5: Verification & Status Update (15 min)

**5A: Verify No Regressions**
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
# Must still be: 342 examples, 0 failures ✅
```

**5B: Update Status**
Update `PHASE3_WEEK3_GLOSSARY_STATUS.md`:
- Mark completed classes as ✅
- Update test results
- Note any issues discovered

## Critical Architecture Rules

### Rule 1: Pattern 0 (ALWAYS)
```ruby
# ✅ CORRECT
attribute :my_attr, Type  # Declare FIRST
xml do
  map_element 'elem', to: :my_attr
end

# ❌ WRONG
xml do
  map_element 'elem', to: :my_attr
end
attribute :my_attr, Type  # Too late!
```

### Rule 2: Namespace (ALL Classes)
```ruby
# ✅ CORRECT
namespace Uniword::Ooxml::Namespaces::WordProcessingML

# ❌ WRONG
namespace Uniword::Ooxml::Namespaces::Glossary
```

### Rule 3: Element Names
```ruby
# ✅ CORRECT (camelCase)
root 'glossaryDocument'
root 'docParts'
root 'docPart'

# ❌ WRONG (snake_case)
element 'glossary_document'
element 'doc_parts'
```

### Rule 4: Use root vs element
```ruby
# ✅ root - For top-level elements in their context
root 'glossaryDocument'  # Top of glossary document
root 'docPart'          # Top of each doc part entry

# ✅ element - For nested/embedded elements
element 'docPartPr'     # Nested in docPart
```

## Reference: Successful Pattern (from Theme fixes)

```ruby
# This pattern achieved 174/174 (100%) in Theme week
class MyClass < Lutaml::Model::Serializable
  # Step 1: Declare attributes FIRST
  attribute :my_child, ChildClass
  attribute :my_attr, :string
  
  # Step 2: XML mapping
  xml do
    root 'myElement'  # camelCase
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content  # If has text/children
    
    map_element 'myChild', to: :my_child, render_nil: false
    map_attribute 'myAttr', to: :my_attr
  end
end
```

## Files to Modify (Session 2)

**Critical Path** (Batch 1 - 4 classes):
1. `lib/uniword/glossary/glossary_document.rb` (verify/complete)
2. `lib/uniword/glossary/doc_parts.rb`
3. `lib/uniword/glossary/doc_part.rb`
4. `lib/uniword/glossary/doc_part_body.rb` (CRITICAL)

**Properties/Metadata** (Batch 2 - 6 classes):
5. `lib/uniword/glossary/doc_part_properties.rb`
6. `lib/uniword/glossary/doc_part_name.rb`
7. `lib/uniword/glossary/doc_part_description.rb`
8. `lib/uniword/glossary/doc_part_gallery.rb`
9. `lib/uniword/glossary/doc_part_category.rb`
10. `lib/uniword/glossary/category_name.rb`

## Expected Outcomes

**After Batch 1** (45 min):
- 4 core classes fixed
- Tests: ~10/16 passing (62%)
- Content starts appearing in round-trip

**After Batch 2** (90 min total):
- 10 total classes fixed
- Tests: 12/16 passing (75%) ✅
- Properties preserved in round-trip

**Session 2 Complete**:
- Status tracker updated
- Ready for Session 3 (supporting classes)

## If You Encounter Issues

**Issue**: Tests not improving after fixes
**Solution**: Check DocPartBody - it must properly reference Wordprocessingml::Paragraph, etc.

**Issue**: Content still missing
**Solution**: Verify `mixed_content` directive in parent elements

**Issue**: Regressions appear
**Solution**: STOP, revert changes, analyze what broke

## Success Criteria (Session 2)

- [ ] 10 core Glossary classes fixed
- [ ] Tests: 12/16 passing (75%)
- [ ] Zero regressions (342/342 baseline still passing)
- [ ] All fixes follow Pattern 0
- [ ] All classes use WordProcessingML namespace
- [ ] Status tracker updated

## Next Session Preview (Session 3)

After Session 2 completes at 75%, Session 3 will:
- Fix remaining 9 supporting classes
- Achieve 16/16 passing (100%)
- Complete Glossary round-trip

**Total remaining time**: 2.5 hours (1.5 Session 3 + 1 Session 4)

## Starting Point

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify baseline
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Start with Batch 1
# Fix: glossary_document.rb, doc_parts.rb, doc_part.rb, doc_part_body.rb
```

**Remember**: Work systematically, test after each batch, follow Pattern 0, maintain architecture quality!

Good luck! The foundation from Session 1 is solid - you just need to apply the proven fix pattern to each class. 🎯