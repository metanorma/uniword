# Phase 3 Week 3: Document Elements Continuation Prompt

## Context

You are continuing the Uniword theme round-trip implementation. **Phase 3 Week 2 is COMPLETE** with 100% (174/174) theme round-trip achieved! You are now starting **Phase 3 Week 3** to achieve 100% round-trip for all 61 reference files.

## Current State

**Version**: 1.1.0 (in development)
**Status**: Phase 3 Week 2 COMPLETE ✅ + Week 3 STARTING

**Test Results**:
- StyleSets: 168/168 (100%) ✅
- Themes: 174/174 (100%) ✅
- Document Elements: 0/8 (0%)
- **Total**: 342/342 (100% of implemented) ✅
- **Target**: 350/350 (100% including document elements)

## Your Task

**Objective**: Implement round-trip support for 8 document element types to achieve 61/61 (100%) complete.

**Timeline**: 5 days (December 2-6, 2024)

**Reference Files**: `references/word-package/document-elements/*.dotx`

## Step-by-Step Instructions

### Step 1: Review Planning Documents (15 min)

Read these files to understand the full plan:
```ruby
read_file('PHASE3_WEEK3_DOCUMENT_ELEMENTS_PLAN.md')
read_file('PHASE3_WEEK3_IMPLEMENTATION_STATUS.md')
read_file('.kilocode/rules/memory-bank/context.md')
```

### Step 2: List Document Element Files (5 min)

```bash
ls -la references/word-package/document-elements/
```

Verify all 8 .dotx files are present:
1. header-footer.dotx
2. complex-header-footer.dotx
3. table-styles.dotx
4. bibliography.dotx
5. toc.dotx
6. watermark.dotx
7. equations.dotx
8. cover-page.dotx

### Step 3: Day 1 - Headers & Footers (6 hours)

#### 3A: Create Model Classes (3 hours)

**Header class**:
```ruby
# lib/uniword/header.rb
class Header < Lutaml::Model::Serializable
  attribute :paragraphs, Paragraph, collection: true
  attribute :tables, Table, collection: true
  
  xml do
    root 'hdr'
    namespace Ooxml::Namespaces::WordProcessingML
    mixed_content
    
    map_element 'p', to: :paragraphs
    map_element 'tbl', to: :tables, render_nil: false
  end
end
```

**Footer class**: Similar structure with root 'ftr'

**SectionProperties enhancement**:
```ruby
# Enhance existing lib/uniword/section_properties.rb
attribute :header_reference, HeaderReference
attribute :footer_reference, FooterReference
```

#### 3B: Create Part Classes (2 hours)

```ruby
# lib/uniword/ooxml/header_part.rb
class HeaderPart < Part
  attribute :header, Header
  
  def filename
    "word/header#{@index}.xml"
  end
end
```

#### 3C: Write Tests & Verify (1 hour)

```ruby
# spec/uniword/document_elements_roundtrip_spec.rb
RSpec.describe 'Document Elements Round-Trip' do
  it 'round-trips header-footer.dotx' do
    # Load, serialize, compare
  end
end
```

**Target**: 2/8 files passing

### Step 4: Day 2 - Complex Headers & Tables (6 hours)

**Morning**: Multi-section headers (3 hours)
- Handle first/even/odd page headers
- Test `complex-header-footer.dotx`

**Afternoon**: Table styles (3 hours)
- Enhance TableStyle class
- Add table formatting properties
- Test `table-styles.dotx`

**Target**: 4/8 files passing

### Step 5: Day 3 - Bibliography, TOC, Watermark (6 hours)

**Bibliography** (2 hours):
```ruby
# lib/uniword/bibliography.rb
class Bibliography < Lutaml::Model::Serializable
  attribute :sources, Source, collection: true
end

class Source < Lutaml::Model::Serializable
  attribute :source_type, :string
  attribute :title, :string
  attribute :author, :string
  # ... metadata fields
end
```

**TOC** (2 hours):
```ruby
# lib/uniword/table_of_contents.rb
class TableOfContents < Lutaml::Model::Serializable
  attribute :field_code, :string
  attribute :entries, TocEntry, collection: true
end
```

**Watermark** (2 hours):
```ruby
# lib/uniword/watermark.rb (VML-based)
class Watermark < Lutaml::Model::Serializable
  attribute :text, :string
  attribute :color, :string
  # VML properties
end
```

**Target**: 7/8 files passing

### Step 6: Day 4 - Equations & Cover Page (6 hours)

**Equations** (3 hours):
- Verify Plurimath integration
- Test OMML round-trip
- Ensure `equations.dotx` passes

**Cover Page** (3 hours):
- BuildingBlock support (if needed)
- ContentControl support
- Test `cover-page.dotx`

**Target**: 8/8 files passing ✅

### Step 7: Day 5 - Verification & Documentation (6 hours)

**Verification** (3 hours):
```bash
# Run all tests
bundle exec rspec

# Expected results:
# 350 examples, 0 failures ✅
```

**Documentation** (3 hours):
- Update README.adoc with new features
- Update architecture docs
- Update memory bank
- Create v1.1.0 release notes

## Critical Architecture Principles

### Pattern 0: ALWAYS Declare Attributes First

```ruby
# ✅ CORRECT
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # FIRST!
  
  xml do
    map_element 'elem', to: :my_attr
  end
end

# ❌ WRONG - Will NOT serialize
class MyClass < Lutaml::Model::Serializable
  xml do
    map_element 'elem', to: :my_attr
  end
  attribute :my_attr, MyType  # TOO LATE!
end
```

### MECE: Clear Separation

- **Model classes**: Pure domain objects (Header, Footer, etc.)
- **Part classes**: Handle packaging (HeaderPart, FooterPart, etc.)  
- **Serializers**: Convert models ↔ XML
- **NO mixing** of concerns

### Model-Driven: No Raw XML

- Every element is a proper lutaml-model class
- No string-based XML manipulation
- All serialization through lutaml-model

## Reference Files

**Planning**:
- `PHASE3_WEEK3_DOCUMENT_ELEMENTS_PLAN.md` (286 lines)
- `PHASE3_WEEK3_IMPLEMENTATION_STATUS.md` (228 lines)

**Previous Work**:
- `old-docs/theme-sessions/` (all theme session docs)
- `.kilocode/rules/memory-bank/context.md` (updated with Session 5)

**Test Examples**:
- `spec/uniword/theme_roundtrip_spec.rb` (174 examples ✅)
- `spec/uniword/styleset_roundtrip_spec.rb` (168 examples ✅)

## Success Checklist

- [ ] All 8 document element files pass round-trip tests
- [ ] Test suite: 350/350 examples passing (100%)
- [ ] Zero regressions (342/342 still passing)
- [ ] All new code follows architecture principles
- [ ] README.adoc updated with features
- [ ] Memory bank updated
- [ ] Ready for v1.1.0 release

## Expected Output

At completion, you should have:

**New Files Created** (~15-20):
- 8-12 model classes (Header, Footer, TableStyle, etc.)
- 4 part classes (HeaderPart, FooterPart, etc.)
- 3 test files (integration, round-trip, units)

**Files Modified** (~5-10):
- `lib/uniword.rb` (autoloads)
- `lib/uniword/formats/docx_handler.rb` (package headers/footers)
- `lib/uniword/ooxml/docx_package.rb` (part management)
- Existing stub files (enhance)

**Test Results**:
```
Document Elements Round-Trip: 8 examples, 0 failures ✅
StyleSet Round-Trip: 168 examples, 0 failures ✅
Theme Round-Trip: 174 examples, 0 failures ✅
Total: 350 examples, 0 failures (100%) ✅
```

## Key Reminders

1. **Pattern 0 is CRITICAL**: Attributes BEFORE xml mappings (ALWAYS!)
2. **One feature at a time**: Test after each implementation
3. **Follow proven patterns**: Look at Theme/StyleSet implementations
4. **No shortcuts**: Maintain architecture quality
5. **Update tests**: Ensure comprehensive coverage
6. **Document as you go**: Update status tracker

## Starting Point

Begin with:
```bash
cd /Users/mulgogi/src/mn/uniword

# Check current state
bundle exec rspec --format progress | grep examples

# List document element files
ls -la references/word-package/document-elements/

# Read planning docs
cat PHASE3_WEEK3_DOCUMENT_ELEMENTS_PLAN.md
```

Then proceed systematically through Days 1-5.

**Goal**: 350/350 (100%) by December 6, 2024! 🎯

Good luck! The foundation from Weeks 1-2 is solid - you just need to apply the same proven patterns!