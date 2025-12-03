# Phase 3 Week 3: Glossary Session 3 Continuation Prompt

## Context

You are continuing the Uniword Phase 3 Week 3 implementation. **Session 2 is COMPLETE** ✅ with 12/19 Glossary classes fixed. You are now starting **Session 3** to fix the final 9 classes and achieve 100% Glossary round-trip.

## Current State (December 1, 2024 - After Session 2)

**Version**: 1.1.0 (in development)
**Status**: Session 2 COMPLETE ✅, Session 3 STARTING

**Test Results**:
```bash
# Baseline (No Regressions)
StyleSets: 168/168 (100%) ✅
Themes: 174/174 (100%) ✅
Total Baseline: 342/342 (100%) ✅

# Document Elements (Our Target)
Content Types: 8/8 (100%) ✅
Glossary Round-Trip: 0/8 (structure complete, attributes pending)
Total: 8/16 (50%)
```

## Your Task (Session 3: Final 9 Classes)

**Objective**: Fix 9 remaining Glossary classes to achieve 16/16 tests passing (100%)

**Timeline**: 1.5 hours

**Target**: 16/16 tests passing (100%)

## Step-by-Step Instructions

### Step 1: Review Context (10 min)

Read these files to understand Session 2 accomplishments:
```bash
cd /Users/mulgogi/src/mn/uniword

# Read planning documents
cat PHASE3_WEEK3_GLOSSARY_SESSION3_PLAN.md
cat PHASE3_WEEK3_GLOSSARY_SESSION3_STATUS.md
cat .kilocode/rules/memory-bank/context.md
```

### Step 2: Verify Baseline (5 min)

```bash
# Ensure no regressions from Session 2
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 342 examples, 0 failures ✅

# Check current Glossary state
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Current: 16 examples, 8 failures (structural fixes complete from Session 2)
```

### Step 3: Batch 1 - Type System (30 min)

Fix the 2 type-related classes:

**3A: DocPartTypes Container**
```bash
# Read current state
cat lib/uniword/glossary/doc_part_types.rb
```

Expected fix:
```ruby
class DocPartTypes < Lutaml::Model::Serializable
  attribute :doc_part_type, DocPartType, collection: true  # ✅ FIRST
  
  xml do
    root 'types'  # NOT 'doc_part_types'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content
    
    map_element 'type', to: :doc_part_type, render_nil: false
  end
end
```

**3B: DocPartType Individual**
```bash
# Read current state
cat lib/uniword/glossary/doc_part_type.rb
```

Expected fix:
```ruby
class DocPartType < Lutaml::Model::Serializable
  attribute :val, :string  # ✅ FIRST
  
  xml do
    root 'type'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    
    map_attribute 'val', to: :val
  end
end
```

**Test After Batch 1**:
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Expected: Some improvement (maybe 10-12/16 passing)
```

### Step 4: Batch 2 - IDs & References (30 min)

Fix the 2 ID/reference classes (plus guid in DocPartProperties if needed):

**4A: DocPartId**
```bash
cat lib/uniword/glossary/doc_part_id.rb
```

Expected fix:
```ruby
class DocPartId < Lutaml::Model::Serializable
  attribute :val, :string  # ✅ FIRST
  
  xml do
    root 'guid'  # Element name is 'guid' in OOXML
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    
    map_attribute 'val', to: :val
  end
end
```

**4B: StyleId**
```bash
cat lib/uniword/glossary/style_id.rb
```

Expected fix:
```ruby
class StyleId < Lutaml::Model::Serializable
  attribute :val, :string  # ✅ FIRST
  
  xml do
    root 'style'  # Element name in DocPartPr
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    
    map_attribute 'val', to: :val
  end
end
```

**4C: Update DocPartProperties** (if guid/style not mapped):
Check if `guid` and `style` need element mappings:
```ruby
# In doc_part_properties.rb
attribute :guid, DocPartId  # Already exists as :string, check if needs class
attribute :style, StyleId   # Added in Session 2 as :string, check if needs class

xml do
  # ...
  map_element 'guid', to: :guid, render_nil: false
  map_element 'style', to: :style, render_nil: false
  # ...
end
```

**Test After Batch 2**:
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Expected: 13-14/16 passing (81-87%)
```

### Step 5: Batch 3 - Content Type Markers (30 min)

Fix the 3 content type marker classes:

**5A: AutoText**
```bash
cat lib/uniword/glossary/auto_text.rb
```

Expected pattern:
```ruby
class AutoText < Lutaml::Model::Serializable
  # Likely empty element marker
  xml do
    root 'autoText'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
  end
end
```

**5B: Equation**
```bash
cat lib/uniword/glossary/equation.rb
```

**5C: TextBox**
```bash
cat lib/uniword/glossary/text_box.rb
```

Apply same pattern to all three.

**Test After Batch 3**:
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format progress
# Expected: 16/16 passing (100%) ✅
```

### Step 6: Final Verification (15 min)

**6A: Verify No Regressions**
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
# Must still be: 342 examples, 0 failures ✅
```

**6B: Verify Complete Success**
```bash
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb --format documentation
# Target: 16 examples, 0 failures ✅
```

**6C: Update Status Files**
Update these files with Session 3 results:
- `PHASE3_WEEK3_GLOSSARY_SESSION3_STATUS.md`
- `.kilocode/rules/memory-bank/context.md`

## Critical Architecture Rules (From Sessions 1 & 2)

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
# ✅ CORRECT (camelCase for display, actual element name from OOXML)
root 'types'      # NOT 'doc_part_types'
root 'type'       # NOT 'doc_part_type'
root 'guid'       # NOT 'doc_part_id'
root 'style'      # NOT 'style_id'
root 'autoText'   # camelCase
root 'textBox'    # camelCase

# ❌ WRONG (snake_case)
element 'doc_part_types'
```

### Rule 4: Use root vs element
```ruby
# ✅ root - For top-level elements in their context
root 'types'      # Top of types collection
root 'type'       # Top of each type entry

# ✅ element - For nested/embedded elements (RARE in Glossary)
element 'somethingNested'
```

## Reference: Session 2 Success Pattern

Session 2 fixed 12 classes in 2 hours using this exact pattern:

```ruby
# Example: DocPartName (Session 2)
class DocPartName < Lutaml::Model::Serializable
  attribute :val, :string  # ✅ Step 1: Attribute FIRST
  
  xml do
    root 'name'  # ✅ Step 2: Use 'root' for top-level
    namespace Uniword::Ooxml::Namespaces::WordProcessingML  # ✅ Step 3: WordProcessingML
    
    map_attribute 'val', to: :val  # ✅ Step 4: Map attribute
  end
end
```

**Apply this exact pattern to all 9 remaining classes.**

## Files to Modify (Session 3)

**Type System** (Batch 1 - 2 files):
1. `lib/uniword/glossary/doc_part_types.rb`
2. `lib/uniword/glossary/doc_part_type.rb`

**IDs & References** (Batch 2 - 2-3 files):
3. `lib/uniword/glossary/doc_part_id.rb`
4. `lib/uniword/glossary/style_id.rb`
5. `lib/uniword/glossary/doc_part_properties.rb` (possibly update guid/style mappings)

**Content Markers** (Batch 3 - 3 files):
6. `lib/uniword/glossary/auto_text.rb`
7. `lib/uniword/glossary/equation.rb`
8. `lib/uniword/glossary/text_box.rb`

## Expected Outcomes

**After Batch 1** (30 min):
- 2 type classes fixed
- Tests: ~10-12/16 passing (62-75%)

**After Batch 2** (60 min total):
- 4-5 total classes fixed
- Tests: ~13-14/16 passing (81-87%)

**After Batch 3** (90 min total):
- 9 total classes fixed
- Tests: 16/16 passing (100%) ✅

**Session 3 Complete**:
- All 19 Glossary classes using WordProcessingML namespace
- All 19 classes using proper root/element directives
- All 19 classes using correct element names
- Zero regressions (342/342 baseline still passing)
- Status tracker updated

## If You Encounter Issues

**Issue**: Element names unclear
**Solution**: Check test output - it shows expected vs actual element names

**Issue**: Class already mostly correct
**Solution**: Still verify namespace, directive, and element name match pattern

**Issue**: Tests still failing after fixes
**Solution**: Check if DocPartProperties needs element mappings for guid/style

**Issue**: Regressions appear
**Solution**: STOP, revert changes, analyze what broke

## Success Criteria (Session 3)

- [ ] 9 remaining Glossary classes fixed
- [ ] All use WordProcessingML namespace
- [ ] All use proper root/element directives  
- [ ] All use correct element names (from OOXML spec)
- [ ] Pattern 0 compliance (100%)
- [ ] Tests: 16/16 passing (100%)
- [ ] Zero regressions (342/342 baseline still passing)
- [ ] Status tracker updated

## Next Session Preview (Session 4 - If Needed)

If Session 3 doesn't reach 100%, Session 4 will:
- Debug remaining test failures
- Add missing attributes (Ignorable, rsid, etc.)
- Achieve full round-trip fidelity

**Expected**: Session 3 should complete the work. Session 4 is buffer only.

## Starting Point

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify baseline from Session 2
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Start with Batch 1
# Read and fix: doc_part_types.rb, doc_part_type.rb
```

**Remember**: Work systematically, test after each batch, follow Pattern 0, maintain architecture quality! The foundation from Session 2 is solid - you just need to apply the proven fix pattern to the final 9 classes. 🎯