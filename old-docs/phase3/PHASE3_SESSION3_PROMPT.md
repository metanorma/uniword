# Phase 3: Full Round-Trip Implementation - Session 3 Prompt

## Context

This prompt continues work after **Phase 3 Session 2 completion** (Highlight, VerticalAlign, Position properties implemented, November 29, 2024). We need to achieve 100% round-trip fidelity for ALL 61 reference files in `references/word-package/`.

**Current Status**: 24/61 files (39%) round-trip complete, **14/30 properties (47%)** implemented
**Target**: 61/61 files (100%) round-trip complete, **30/30 properties (100%)**

## Objective

Complete Week 1 property expansion by implementing remaining **16 properties** (11 simple + 5 complex).

### Progress Snapshot
- **StyleSets**: 24/24 ✅ (100% complete)
- **Themes**: 0/29 ⏳ (can load, need save/round-trip)
- **Document Elements**: 0/8 ❌ (no support yet)
- **Properties**: 14/30 ✅ (47% complete)

## Prerequisites

Before starting, review these files:
1. **Master Plan**: `PHASE3_FULL_ROUNDTRIP_PLAN.md` (626 lines)
2. **Status Tracker**: `PHASE3_IMPLEMENTATION_STATUS.md` (updated Session 2)
3. **Pattern Guide**: `docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md` (408 lines)
4. **Memory Bank**: `.kilocode/rules/memory-bank/context.md`

## Session 2 Recap ✅

**Completed Properties (3)**:
- ✅ Highlight - `<w:highlight w:val="yellow"/>` (30 lines)
- ✅ VerticalAlign - `<w:vertAlign w:val="superscript"/>` (28 lines)
- ✅ Position - `<w:position w:val="5"/>` (30 lines)

**Results**:
- Tests: 168/168 passing ✅
- Time: 30 minutes (~10 mins/property)
- Pattern 0 followed exactly

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

# ❌ WRONG
class MyProperty < Lutaml::Model::Serializable
  xml do
    element 'myProp'
  end
  attribute :value, MyType  # Too late!
end
```

### 2. Model-Based Architecture
Each file type MUST be a proper model class:

```ruby
# CORRECT: Separation of concerns
class StyleSetPackage < DotxPackage  # File handling
  attribute :styleset, StyleSet       # Domain model
end

class StyleSet < Lutaml::Model::Serializable  # Pure model
  attribute :styles, Style, collection: true
  # No file I/O!
end
```

### 3. MECE Structure
- Mutually Exclusive: No overlapping responsibilities
- Collectively Exhaustive: Complete coverage
- One class, one responsibility

## Week 1 Remaining Work (Days 2-5)

### Day 2 Remaining: 4 Simple Properties (~40 mins)

**Priority Queue**:
1. **CharacterSpacing** - `<w:spacing w:val="20"/>` (attribute-only)
2. **Kerning** - `<w:kern w:val="20"/>` (attribute-only)
3. **WidthScale** - `<w:w w:val="150"/>` (attribute-only)
4. **EmphasisMark** - `<w:em w:val="dot"/>` (attribute-only)

**Implementation Pattern** (10 mins each):
```ruby
# Step 1: Create lib/uniword/properties/character_spacing.rb
class CharacterSpacingValue < Lutaml::Model::Type::Integer
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

class CharacterSpacing < Lutaml::Model::Serializable
  attribute :value, CharacterSpacingValue
  xml do
    element 'spacing'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# Step 2: Update run_properties.rb
require_relative 'character_spacing'
attribute :character_spacing, CharacterSpacing
map_element 'spacing', to: :character_spacing, render_nil: false

# Step 3: Update styleset_xml_parser.rb
require_relative '../properties/character_spacing'
if (spacing = rPr_node.at_xpath('./w:spacing', WORDML_NS))
  props.character_spacing = Properties::CharacterSpacing.new(
    value: spacing['w:val']&.to_i
  )
end

# Step 4: Test
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
```

### Day 3: 7 Simple Properties (~1.5 hours)

1. **NumberingId** - `<w:numId w:val="1"/>` (paragraph property)
2. **NumberingLevel** - `<w:ilvl w:val="0"/>` (paragraph property)
3. **KeepNext** - `<w:keepNext/>` (boolean, paragraph)
4. **KeepLines** - `<w:keepLines/>` (boolean, paragraph)
5. **PageBreakBefore** - `<w:pageBreakBefore/>` (boolean, paragraph)
6. **WidowControl** - `<w:widowControl/>` (boolean, paragraph)
7. **ContextualSpacing** - `<w:contextualSpacing/>` (boolean, paragraph)

**Note**: These go in `paragraph_properties.rb`, not `run_properties.rb`!

### Days 4-5: 5 Complex Properties (~14 hours)

**Priority Order**:
1. **Borders** (4 hours) - `<w:pBdr>` with top/bottom/left/right
2. **Tabs** (3 hours) - `<w:tabs>` with multiple tab stops
3. **Shading** (2 hours) - `<w:shd>` with fill/pattern
4. **Language** (2 hours) - `<w:lang>` with val/bidi/eastAsia
5. **TextEffects** (3 hours) - `<w:textFill>` with gradient/solid

**Complex Property Pattern**:
```ruby
# Multi-attribute wrapper
class Borders < Lutaml::Model::Serializable
  attribute :top, Border
  attribute :bottom, Border
  attribute :left, Border
  attribute :right, Border
  
  xml do
    root 'pBdr'  # Complex properties use 'root'
    namespace Ooxml::Namespaces::WordProcessingML
    map_element 'top', to: :top
    map_element 'bottom', to: :bottom
  end
end
```

## Task: Implement Next 4 Simple Properties

### Instructions

Implement these 4 properties in sequence (Day 2 remaining):

1. **CharacterSpacing** (10 mins) - integer twips
2. **Kerning** (10 mins) - integer half-points
3. **WidthScale** (10 mins) - integer percentage
4. **EmphasisMark** (10 mins) - string enumeration

For each property:
- Create wrapper class file with namespaced type
- Update run_properties.rb (require, attribute, xml mapping)
- Update styleset_xml_parser.rb (require, XPath parsing)
- Run tests after EACH property (keep tests green)

### Expected Outcomes

After completing all 4 properties:
- **New files**: 4 (character_spacing.rb, kerning.rb, width_scale.rb, emphasis_mark.rb)
- **Modified files**: 2 (run_properties.rb, styleset_xml_parser.rb)
- **Tests**: 168+ examples, 0 failures
- **Property count**: 14 → 18 properties (60% coverage)
- **Time**: ~40 minutes

### Success Criteria

- [ ] CharacterSpacing property serializes correctly
- [ ] Kerning property serializes correctly
- [ ] WidthScale property serializes correctly
- [ ] EmphasisMark property serializes correctly
- [ ] All tests passing (168+ examples, 0 failures)
- [ ] No regressions in existing properties
- [ ] Code follows Pattern 0 exactly (attributes BEFORE xml)
- [ ] All values use proper types (Integer vs String)

## Property Specifications

### 1. CharacterSpacing
```xml
<w:spacing w:val="20"/>  <!-- In twips (1/1440 inch) -->
```
- **Type**: Integer
- **Element**: `spacing`
- **Attribute**: `val`
- **Range**: Any integer (positive = expanded, negative = condensed)
- **Note**: NOT the paragraph spacing (that's in ParagraphProperties)

### 2. Kerning
```xml
<w:kern w:val="20"/>  <!-- In half-points -->
```
- **Type**: Integer
- **Element**: `kern`
- **Attribute**: `val`
- **Range**: Typically 0-72 (0 = disabled, >0 = threshold)

### 3. WidthScale
```xml
<w:w w:val="150"/>  <!-- 150% width -->
```
- **Type**: Integer
- **Element**: `w`
- **Attribute**: `val`
- **Range**: 50-600 (percentage)
- **Default**: 100 (normal width)

### 4. EmphasisMark
```xml
<w:em w:val="dot"/>
```
- **Type**: String
- **Element**: `em`
- **Attribute**: `val`
- **Values**: none, dot, comma, circle, underDot

## Architecture Evolution (Week 2)

After completing Week 1 (30 properties), we shift to **package architecture**:

### Package Hierarchy (OOP, MECE)
```
PackageFile (abstract)
├── attributes: path, content_types, relationships
├── methods: extract, package, validate
│
├── DotxPackage < PackageFile
│   ├── attributes: styles, fonts, settings
│   ├── methods: load_styles, save_styles
│   │
│   ├── StyleSetPackage < DotxPackage
│   │   └── attributes: styleset (domain model)
│   │
│   ├── DocumentElementPackage < DotxPackage
│   │   └── attributes: headers, footers, etc
│   │
│   └── QuickStylePackage < DotxPackage
│       └── attributes: quick_styles
│
└── ThmxPackage < PackageFile
    ├── attributes: theme, fonts, color_schemes
    ├── methods: load_theme, save_theme
    │
    └── ThemePackage < ThmxPackage
        └── attributes: theme (domain model)
```

### Separation of Concerns
- **Models**: Pure domain objects (Theme, StyleSet, Style)
- **Packages**: File handling (ZIP, XML, relationships)
- **Loaders**: Parsing (XML → Models)
- **Writers**: Serialization (Models → XML)

## Timeline Compression Strategy

To finish ASAP, we're **compressing the 4-week plan**:

### Accelerated Schedule
- **Week 1**: 30 properties (Days 2-5) ← Current
- **Week 2**: Package architecture + 29 themes (Days 1-5)
- **Week 3**: 8 document elements + testing (Days 1-5)
- **Week 4**: Documentation + release (Days 1-2)

**Total**: 17 days → ~2.5 weeks

### Parallelization Opportunities
1. Complex properties can be implemented simultaneously
2. Theme tests can be written while implementing package architecture
3. Documentation can be updated incrementally

## Troubleshooting

### If tests fail:
1. Check Pattern 0: Attributes BEFORE xml block
2. Verify `element` (not `root`) for simple properties
3. Verify namespace is class reference
4. Check `render_nil: false` in xml mapping
5. Ensure proper type (Integer vs String)

### If serialization empty:
- Attribute declared before xml block?
- Custom type has `xml_namespace`?
- Using `element` not `root`?
- Namespace reference correct?

### If parser fails:
- Required relative imports present?
- XPath namespace prefix correct (`w:`)?
- Wrapper object created properly?
- Integer conversion (`&.to_i`) for numeric values?

## After Completing This Task

1. Update `PHASE3_IMPLEMENTATION_STATUS.md`:
   - Property count: 14 → 18 (60%)
   - Mark CharacterSpacing, Kerning, WidthScale, EmphasisMark as complete
   - Update Week 1 Day 2 progress

2. Update `.kilocode/rules/memory-bank/context.md`:
   - Session 3 completion summary
   - New property count
   - Next session focus (Day 3 properties)

3. Continue to Session 4:
   - Implement 7 properties on Day 3 (paragraph properties)
   - Then tackle complex properties (Days 4-5)

## Verification Commands

```bash
# Run tests
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb

# Property count
ls lib/uniword/properties/*.rb | wc -l
# Expected: 18 files after Session 3

# Quick property check
ruby -e "
require './lib/uniword'
ss = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
props = [:character_spacing, :kerning, :w_scale, :emphasis_mark]
props.each do |prop|
  count = ss.styles.count { |s| s.run_properties&.send(prop) }
  puts \"#{prop}: #{count} styles\"
end
"
```

## Remember

1. **One property at a time** - Test after each, keep green
2. **Follow Pattern 0 exactly** - Attributes BEFORE xml
3. **Model-based architecture** - No raw XML, no file handling in models
4. **MECE separation** - Models ≠ Packages ≠ Loaders ≠ Writers
5. **Object-oriented** - Inheritance, polymorphism, clean APIs
6. **Compress timeline** - Work efficiently to finish ASAP
7. **Architecture correctness** - Even if tests regress, fix architecture first

## Start Command

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify current state (should be 168 passing, 14 properties)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
ls lib/uniword/properties/*.rb | wc -l

# Start with CharacterSpacing property
# Copy position.rb as template (it's also an integer type)
cp lib/uniword/properties/position.rb lib/uniword/properties/character_spacing.rb

# Then modify following the 4-step pattern
```

Good luck! Focus on quality and architecture - we're building a foundation for 100% OOXML coverage.