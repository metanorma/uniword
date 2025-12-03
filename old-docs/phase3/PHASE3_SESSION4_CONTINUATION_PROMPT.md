# Phase 3: Session 4 Continuation Prompt

## Context

This prompt continues work after **Phase 3 Session 3 completion** (CharacterSpacing, Kerning, WidthScale, EmphasisMark properties implemented, November 29, 2024). We need to achieve 100% round-trip fidelity for ALL 61 reference files in `references/word-package/`.

**Current Status**: 24/61 files (39%) round-trip complete, **18/30 properties (60%)** implemented
**Target**: 61/61 files (100%) round-trip complete, **30/30 properties (100%)**

## Objective

Complete Week 1 Day 3 by implementing remaining **7 simple properties** (2 numbering + 5 boolean paragraph properties).

### Progress Snapshot
- **StyleSets**: 24/24 ✅ (100% complete)
- **Themes**: 0/29 ⏳ (can load, need save/round-trip)
- **Document Elements**: 0/8 ❌ (no support yet)
- **Properties**: 18/30 ✅ (60% complete)

## Prerequisites

Before starting, review these files:
1. **Status Tracker**: `PHASE3_IMPLEMENTATION_STATUS.md` (updated Session 3)
2. **Pattern Guide**: `docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md` (408 lines)
3. **Memory Bank**: `.kilocode/rules/memory-bank/context.md`

## Session 3 Recap ✅

**Completed Properties (4)**:
- ✅ CharacterSpacing - `<w:spacing w:val="20"/>` (32 lines)
- ✅ Kerning - `<w:kern w:val="20"/>` (28 lines)
- ✅ WidthScale - `<w:w w:val="150"/>` (31 lines)
- ✅ EmphasisMark - `<w:em w:val="dot"/>` (32 lines)

**Results**:
- Tests: 168/168 passing ✅
- Time: ~35 minutes (~9 mins/property)
- Pattern 0 followed exactly
- Property count: 19 files (18 properties + containers)

## Critical Architecture Principles

### 1. Pattern 0 (MOST CRITICAL)
**Attributes MUST be declared BEFORE xml mappings!**

```ruby
# ✅ CORRECT
class MyProperty < Lutaml::Model::Serializable
  attribute :value, MyType  # FIRST
  xml do
    element 'myProp'        # SECOND
  end
end
```

### 2. Paragraph vs Run Properties
**IMPORTANT**: Numbering and boolean properties go in **ParagraphProperties**, not RunProperties!

```ruby
# lib/uniword/properties/paragraph_properties.rb
attribute :numbering_id, NumberingId
attribute :numbering_level, NumberingLevel
attribute :keep_next, :boolean
```

### 3. Boolean Properties Pattern
Boolean properties typically have no attributes, just presence/absence:

```ruby
# XML: <w:keepNext/> (presence = true)
# In ParagraphProperties:
attribute :keep_next, :boolean, default: -> { false }

# XML mapping:
map_element 'keepNext', to: :keep_next, render_nil: false, render_default: false
```

## Session 4 Task: Day 3 Properties (~45 mins)

### Properties to Implement

**Numbering Properties (2)** - ~20 mins:
1. **NumberingId** - `<w:numId w:val="1"/>` (required wrapper)
2. **NumberingLevel** - `<w:ilvl w:val="0"/>` (required wrapper)

**Boolean Properties (5)** - ~25 mins:
3. **KeepNext** - `<w:keepNext/>` (no wrapper, direct boolean)
4. **KeepLines** - `<w:keepLines/>` (no wrapper, direct boolean)
5. **PageBreakBefore** - `<w:pageBreakBefore/>` (no wrapper, direct boolean)
6. **WidowControl** - `<w:widowControl/>` (special: default true, opt-out)
7. **ContextualSpacing** - `<w:contextualSpacing/>` (no wrapper, direct boolean)

### Implementation Strategy

#### For NumberingId and NumberingLevel (Wrapper Pattern)

**Step 1**: Create wrapper class (e.g., `lib/uniword/properties/numbering_id.rb`)
```ruby
class NumberingIdValue < Lutaml::Model::Type::Integer
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

class NumberingId < Lutaml::Model::Serializable
  attribute :value, NumberingIdValue
  xml do
    element 'numId'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end
```

**Step 2**: Add to [`paragraph_properties.rb`](lib/uniword/properties/paragraph_properties.rb):
```ruby
require_relative 'numbering_id'
attribute :numbering_id, NumberingId
map_element 'numId', to: :numbering_id, render_nil: false
```

**Step 3**: Update [`styleset_xml_parser.rb`](lib/uniword/stylesets/styleset_xml_parser.rb) in `parse_paragraph_properties`:
```ruby
require_relative '../properties/numbering_id'
if (numPr = pPr_node.at_xpath('./w:numPr', WORDML_NS))
  if (numId = numPr.at_xpath('./w:numId', WORDML_NS))
    props.numbering_id = Properties::NumberingId.new(
      value: numId['w:val']&.to_i
    )
  end
end
```

**Note**: The parser already has `numPr` handling at lines 177-184, so you'll UPDATE that section.

#### For Boolean Properties (No Wrapper Pattern)

Boolean properties are already partially implemented! Check lines 154-169 in [`styleset_xml_parser.rb`](lib/uniword/stylesets/styleset_xml_parser.rb):

```ruby
# Keep together options (boolean elements)
props.keep_next = !pPr_node.at_xpath('./w:keepNext', WORDML_NS).nil?
props.keep_lines = !pPr_node.at_xpath('./w:keepLines', WORDML_NS).nil?
props.page_break_before = !pPr_node.at_xpath('./w:pageBreakBefore', WORDML_NS).nil?

# Widow control (boolean element)
widow_node = pPr_node.at_xpath('./w:widowControl', WORDML_NS)
if widow_node
  props.widow_control = widow_node['w:val'] != '0'
end

# Contextual spacing
props.contextual_spacing = !pPr_node.at_xpath('./w:contextualSpacing', WORDML_NS).nil?
```

**They just need XML mappings added to [`paragraph_properties.rb`](lib/uniword/properties/paragraph_properties.rb)!**

Current state (lines 21-32):
```ruby
attribute :keep_next, :boolean, default: -> { false }
attribute :keep_lines, :boolean, default: -> { false }
attribute :page_break_before, :boolean, default: -> { false }
attribute :widow_control, :boolean, default: -> { true }  # Default ON
attribute :contextual_spacing, :boolean, default: -> { false }
```

Need to add XML mappings (after line 79):
```ruby
map_element 'keepNext', to: :keep_next, render_nil: false, render_default: false
map_element 'keepLines', to: :keep_lines, render_nil: false, render_default: false
map_element 'pageBreakBefore', to: :page_break_before, render_nil: false, render_default: false
map_element 'widowControl', to: :widow_control, render_nil: false, render_default: false
map_element 'contextualSpacing', to: :contextual_spacing, render_nil: false, render_default: false
```

## Property Specifications

### 1. NumberingId
```xml
<w:numPr>
  <w:numId w:val="1"/>  <!-- Reference to numbering definition -->
</w:numPr>
```
- **Type**: Integer wrapper
- **Element**: `numId` (inside `numPr`)
- **Attribute**: `val`
- **Purpose**: Links paragraph to numbered list style

### 2. NumberingLevel
```xml
<w:numPr>
  <w:ilvl w:val="0"/>  <!-- List indentation level (0-based) -->
</w:numPr>
```
- **Type**: Integer wrapper
- **Element**: `ilvl` (inside `numPr`)
- **Attribute**: `val`
- **Range**: 0-8 (9 levels)
- **Purpose**: Nesting level in numbered/bulleted lists

### 3-7. Boolean Properties
```xml
<w:keepNext/>           <!-- Keep with next paragraph -->
<w:keepLines/>          <!-- Keep lines together -->
<w:pageBreakBefore/>    <!-- Insert page break before -->
<w:widowControl w:val="1"/>  <!-- Widow/orphan control (default ON) -->
<w:contextualSpacing/>  <!-- Ignore spacing when same style follows -->
```
- **Type**: Boolean (direct)
- **XML**: Empty element for true, absent for false
- **Exception**: `widowControl` defaults to true (Word standard)

## Step-by-Step Implementation

### Task 1: NumberingId Property (~10 mins)

1. Create `lib/uniword/properties/numbering_id.rb` (29 lines)
2. Update `lib/uniword/properties/paragraph_properties.rb`:
   - Add require
   - Add attribute (already exists as `num_id`, needs wrapper attribute)
   - Add xml mapping
3. Update `lib/uniword/stylesets/styleset_xml_parser.rb`:
   - Add require
   - Update numPr parsing section (lines 177-184)
4. Run tests: `bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb`

### Task 2: NumberingLevel Property (~10 mins)

1. Create `lib/uniword/properties/numbering_level.rb` (29 lines)
2. Update `lib/uniword/properties/paragraph_properties.rb`:
   - Add require
   - Add attribute (already exists as `ilvl`, needs wrapper attribute)
   - Add xml mapping
3. Update `lib/uniword/stylesets/styleset_xml_parser.rb`:
   - Add require
   - Update ilvl parsing in numPr section
4. Run tests

### Task 3-7: Boolean Properties (~5 mins each)

**These are ALREADY parsed in styleset_xml_parser.rb!**

Just need to add XML mappings to paragraph_properties.rb:

1. Update `lib/uniword/properties/paragraph_properties.rb`:
   - Add 5 xml mapping lines (after line 79)
2. Run tests after adding all 5

**Total time**: ~45 minutes

## Expected Outcomes

After completing all 7 properties:
- **New files**: 2 (numbering_id.rb, numbering_level.rb)
- **Modified files**: 2 (paragraph_properties.rb, styleset_xml_parser.rb)
- **Tests**: 168+ examples, 0 failures
- **Property count**: 18 → 25 properties (83% coverage)
- **Time**: ~45 minutes

## Success Criteria

- [ ] NumberingId property serializes correctly
- [ ] NumberingLevel property serializes correctly
- [ ] KeepNext property serializes correctly
- [ ] KeepLines property serializes correctly
- [ ] PageBreakBefore property serializes correctly
- [ ] WidowControl property serializes correctly (default true)
- [ ] ContextualSpacing property serializes correctly
- [ ] All tests passing (168+ examples, 0 failures)
- [ ] No regressions in existing properties
- [ ] Code follows Pattern 0 exactly (attributes BEFORE xml)

## Week 1 Remaining Work

### Days 4-5: Complex Properties (~14 hours)

**Priority Order**:
1. **Borders** (4 hours) - `<w:pBdr>` with top/bottom/left/right
2. **Tabs** (3 hours) - `<w:tabs>` with multiple tab stops
3. **Shading** (2 hours) - `<w:shd>` with fill/pattern
4. **Language** (2 hours) - `<w:lang>` with val/bidi/eastAsia
5. **TextEffects** (3 hours) - `<w:textFill>` with gradient/solid

**Target**: 30/30 properties (100%) by end of Week 1

## After Completing This Task

1. Update `PHASE3_IMPLEMENTATION_STATUS.md`:
   - Property count: 18 → 25 (83%)
   - Mark all 7 properties as complete
   - Update Week 1 Day 3 progress

2. Update `.kilocode/rules/memory-bank/context.md`:
   - Session 4 completion summary
   - New property count
   - Next session focus (complex properties)

3. Move to Session 5 (Days 4-5):
   - Implement 5 complex properties
   - Achieve 30/30 properties target
   - Complete Week 1

## Verification Commands

```bash
# Run tests
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb

# Property count
ls lib/uniword/properties/*.rb | wc -l
# Expected: 21 files after Session 4 (25 properties - some share files)

# Check numbering properties work
ruby -e "
require './lib/uniword'
ss = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
with_num = ss.styles.select { |s| s.paragraph_properties&.numbering_id }
puts \"Styles with numbering: #{with_num.count}\"
"
```

## Important Notes

1. **Numbering properties need wrappers** (Pattern 0)
2. **Boolean properties already parsed**, just need XML mappings
3. **WidowControl defaults to true** (Word standard)
4. **All properties go in ParagraphProperties**, not RunProperties
5. **Test after each property** to keep tests green
6. **Follow MECE principles** - one responsibility per class
7. **Compress timeline** - work efficiently to finish ASAP

## Start Command

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify current state (should be 168 passing, 18 properties)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
ls lib/uniword/properties/*.rb | wc -l

# Start with NumberingId property
# Use outline_level.rb as template (similar integer wrapper)
cp lib/uniword/properties/outline_level.rb lib/uniword/properties/numbering_id.rb

# Then modify following the wrapper pattern
```

Good luck! Focus on quality and architecture - we're 60% complete and accelerating toward 100% coverage.