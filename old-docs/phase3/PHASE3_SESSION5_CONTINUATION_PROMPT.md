# Phase 3: Session 5 Continuation Prompt

## Context

This prompt continues work after **Phase 3 Session 4 completion** (NumberingId, NumberingLevel properties implemented, November 30, 2024). All simple properties are complete! We need to implement the 5 remaining complex properties to achieve 100% property coverage.

**Current Status**: 20/25 properties (80%), **ALL SIMPLE PROPERTIES COMPLETE** ✅
**Target**: 25/25 properties (100%) by end of Week 1 (Days 4-5)

## Objective

Implement the 5 remaining **complex properties** to achieve complete property coverage for StyleSet round-trip fidelity.

### Progress Snapshot
- **StyleSets**: 24/24 ✅ (100% complete)
- **Themes**: 0/29 ⏳ (can load, need save/round-trip)
- **Document Elements**: 0/8 ❌ (no support yet)
- **Properties**: 20/25 ✅ (80% complete, all simple done)

## Prerequisites

Before starting, review these files:
1. **Status Tracker**: `PHASE3_IMPLEMENTATION_STATUS.md` (updated Session 4)
2. **Pattern Guide**: `docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md`
3. **Memory Bank**: `.kilocode/rules/memory-bank/context.md`

## Session 4 Recap ✅

**Completed Properties (2 + discovery)**:
- ✅ NumberingId - `<w:numId w:val="1"/>` (29 lines)
- ✅ NumberingLevel - `<w:ilvl w:val="0"/>` (29 lines)
- ✅ Discovery: 5 boolean properties already complete!

**Results**:
- Tests: 168/168 passing ✅
- Time: ~20 minutes (efficient!)
- Pattern 0 followed exactly
- Property count: 21 files (20 properties + containers)

**Key Discovery**:
Boolean properties (KeepNext, KeepLines, PageBreakBefore, WidowControl, ContextualSpacing) were already fully implemented with both parsing AND XML mappings in `paragraph_properties.rb`. Only the 2 numbering wrapper properties were missing!

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

### 2. Complex Properties Pattern

Complex properties have **multiple attributes or nested elements**:

```ruby
# Example: Borders has 4 border objects
class Borders < Lutaml::Model::Serializable
  attribute :top, Border
  attribute :bottom, Border
  attribute :left, Border
  attribute :right, Border
  
  xml do
    root 'pBdr'
    namespace Ooxml::Namespaces::WordProcessingML
    
    map_element 'top', to: :top, render_nil: false
    map_element 'bottom', to: :bottom, render_nil: false
    map_element 'left', to: :left, render_nil: false
    map_element 'right', to: :right, render_nil: false
  end
end

# Border is its own class
class Border < Lutaml::Model::Serializable
  attribute :style, BorderStyleValue
  attribute :size, IntegerValue
  attribute :color, ColorValue
  
  xml do
    element 'top'  # or 'bottom', 'left', 'right'
    namespace Ooxml::Namespaces::WordProcessingML
    
    map_attribute 'val', to: :style
    map_attribute 'sz', to: :size
    map_attribute 'color', to: :color
  end
end
```

### 3. Object-Oriented Design

**MECE Principle**: Each class has ONE clear responsibility

**Borders Example**:
- `Borders` class: Container for 4 borders
- `Border` class: Individual border with style/size/color
- `BorderStyleValue`: Custom type for style enumeration
- Separation of concerns maintained

### 4. Model-First Architecture

Never store raw strings when a proper model class makes sense:

```ruby
# ❌ WRONG
attribute :borders, :string  # Mixing serialization with model

# ✅ CORRECT
attribute :borders, Borders  # Pure model class
```

## Session 5 Task: Complex Properties (~14 hours)

### Properties to Implement

**Priority Order** (implement sequentially, test after each):

1. **Borders** (4 hours) - `<w:pBdr>` - Paragraph borders (top/bottom/left/right)
2. **Tabs** (3 hours) - `<w:tabs>` - Tab stop collection
3. **Shading** (2 hours) - `<w:shd>` - Background fill and pattern
4. **Language** (2 hours) - `<w:lang>` - Language settings (val/bidi/eastAsia)
5. **TextEffects** (3 hours) - `<w:textFill>`, `<w:textOutline>` - Gradient/solid fills

### Property 1: Borders (~4 hours)

**XML Structure**:
```xml
<w:pBdr>
  <w:top w:val="single" w:sz="4" w:space="1" w:color="auto"/>
  <w:bottom w:val="single" w:sz="4" w:space="1" w:color="auto"/>
  <w:left w:val="single" w:sz="4" w:space="1" w:color="auto"/>
  <w:right w:val="single" w:sz="4" w:space="1" w:color="auto"/>
</w:pBdr>
```

**Implementation Steps**:

1. Create `lib/uniword/properties/border.rb`:
   - BorderStyleValue (custom type): single, double, dashed, etc.
   - Border class with style, size, space, color attributes
   - XML mappings for border attributes

2. Create `lib/uniword/properties/borders.rb`:
   - Borders container class
   - Attributes: top, bottom, left, right (Border objects)
   - XML element `pBdr` with 4 nested borders

3. Update `lib/uniword/properties/paragraph_properties.rb`:
   - Add `require_relative 'borders'`
   - Add `attribute :borders, Borders`
   - Add `map_element 'pBdr', to: :borders, render_nil: false`

4. Update `lib/uniword/stylesets/styleset_xml_parser.rb`:
   - Add parsing for `<w:pBdr>` element
   - Create Border objects for each side
   - Assign to `props.borders`

**Border Style Values** (complete enumeration):
- nil, single, thick, double, dotted, dashed, dotDash, dotDotDash
- triple, thinThickSmallGap, thickThinSmallGap, thinThickThinSmallGap
- thinThickMediumGap, thickThinMediumGap, thinThickThinMediumGap
- thinThickLargeGap, thickThinLargeGap, thinThickThinLargeGap
- wave, doubleWave, dashSmallGap, dashDotStroked, threeDEmboss
- threeDEngrave, outset, inset

### Property 2: Tabs (~3 hours)

**XML Structure**:
```xml
<w:tabs>
  <w:tab w:val="left" w:pos="720"/>
  <w:tab w:val="center" w:pos="1440"/>
  <w:tab w:val="right" w:pos="2160"/>
</w:tabs>
```

**Implementation Steps**:

1. Create `lib/uniword/properties/tab_stop.rb`:
   - TabAlignmentValue (custom type): left, center, right, decimal, bar, num
   - TabLeaderValue (custom type): none, dot, hyphen, underscore, heavy, middleDot
   - TabStop class with alignment, position, leader attributes
   - XML element `tab` with attributes

2. Create `lib/uniword/properties/tabs.rb`:
   - Tabs container class
   - Attribute: `tab_stops, TabStop, collection: true`
   - XML element `tabs` with collection mapping

3. Update `lib/uniword/properties/paragraph_properties.rb`:
   - Add `require_relative 'tabs'`
   - Add `attribute :tabs, Tabs`
   - Add `map_element 'tabs', to: :tabs, render_nil: false`

4. Update `lib/uniword/stylesets/styleset_xml_parser.rb`:
   - Add parsing for `<w:tabs>` element
   - Iterate over `<w:tab>` children
   - Create TabStop objects for each
   - Assign to `props.tabs`

**Tab Alignment Values**: left, center, right, decimal, bar, num, clear

**Tab Leader Values**: none, dot, hyphen, underscore, heavy, middleDot

### Property 3: Shading (~2 hours)

**XML Structure**:
```xml
<w:shd w:val="clear" w:color="auto" w:fill="FFFF00"/>
```

**Implementation Steps**:

1. Create `lib/uniword/properties/shading.rb`:
   - ShadingPatternValue (custom type): clear, solid, horzStripe, etc.
   - Shading class with pattern, color, fill attributes
   - XML element `shd` with attributes

2. Update `lib/uniword/properties/paragraph_properties.rb`:
   - Add `require_relative 'shading'`
   - Add `attribute :shading, Shading`
   - Add `map_element 'shd', to: :shading, render_nil: false`
   - Remove flat shading attributes (shading_fill, shading_color, shading_type)

3. Update `lib/uniword/stylesets/styleset_xml_parser.rb`:
   - Update shading parsing to create Shading object
   - Remove flat attribute assignments
   - Assign to `props.shading`

**Shading Pattern Values** (partial list):
- nil, clear, solid, horzStripe, vertStripe, reverseDiagStripe
- diagStripe, horzCross, diagCross, thinHorzStripe, thinVertStripe
- thinReverseDiagStripe, thinDiagStripe, thinHorzCross, thinDiagCross

### Property 4: Language (~2 hours)

**XML Structure**:
```xml
<w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/>
```

**Implementation Steps**:

1. Create `lib/uniword/properties/language.rb`:
   - LanguageValue (custom type, String-based)
   - Language class with val, east_asia, bidi attributes
   - XML element `lang` with attributes

2. Update `lib/uniword/properties/run_properties.rb`:
   - Add `require_relative 'language'`
   - Add `attribute :language, Language`
   - Add `map_element 'lang', to: :language, render_nil: false`
   - Remove flat language attributes (language, language_bidi, language_east_asia)

3. Update `lib/uniword/stylesets/styleset_xml_parser.rb`:
   - Update language parsing to create Language object
   - Remove flat attribute assignments
   - Assign to `props.language`

### Property 5: TextEffects (~3 hours)

**XML Structure**:
```xml
<w:textFill>
  <w:solidFill>
    <w:schemeClr w:val="accent1"/>
  </w:solidFill>
</w:textFill>
```

**Implementation Steps**:

1. Create `lib/uniword/properties/text_fill.rb`:
   - TextFillType (custom type): solid, gradient, pattern
   - SolidFill class with color
   - TextFill class with fill_type and fill_object
   - XML element `textFill` with nested elements

2. Create `lib/uniword/properties/text_outline.rb`:
   - Similar structure to TextFill
   - Additional attributes: width, cap, compound, join
   - XML element `textOutline`

3. Update `lib/uniword/properties/run_properties.rb`:
   - Add `require_relative 'text_fill'`
   - Add `require_relative 'text_outline'`
   - Add `attribute :text_fill, TextFill`
   - Add `attribute :text_outline, TextOutline`
   - Add XML mappings

4. Update `lib/uniword/stylesets/styleset_xml_parser.rb`:
   - Add parsing for `<w:textFill>` and `<w:textOutline>`
   - Handle nested fill types (solidFill, gradFill)
   - Create appropriate objects

**Note**: TextEffects is the most complex property. May need to simplify to basic solid fill support initially, with full gradient support in v2.0.

## Implementation Strategy

### General Approach

1. **One property at a time**: Implement, test, commit
2. **Start simple**: Get basic structure working first
3. **Iterate**: Add more attributes/features incrementally
4. **Test continuously**: Run tests after each change
5. **Follow Pattern 0**: ALWAYS attributes before xml mappings

### File Organization

```
lib/uniword/properties/
├── border.rb           # Individual border (NEW)
├── borders.rb          # Border container (NEW)
├── tab_stop.rb         # Individual tab stop (NEW)
├── tabs.rb             # Tab collection (NEW)
├── shading.rb          # Shading (NEW)
├── language.rb         # Language (NEW)
├── text_fill.rb        # Text fill (NEW)
├── text_outline.rb     # Text outline (NEW)
├── paragraph_properties.rb  # UPDATE
└── run_properties.rb        # UPDATE
```

### Testing Strategy

1. **After each property**:
   ```bash
   bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
   ```

2. **Expect failures initially**: Complex properties may break existing tests

3. **Fix tests incrementally**: Update expectations to match new structure

4. **Verify round-trip**: Ensure XML serialization matches parsed structure

### Common Pitfalls

1. **🚨 Pattern 0 violation**: Attributes after xml mappings = no serialization
2. **Missing namespace**: All custom types need `xml_namespace`
3. **Wrong element name**: Use `element` not `root` for nested elements
4. **Flat attributes**: Remove when replacing with object wrappers
5. **Collection mapping**: Use `, collection: true` for arrays

## Expected Outcomes

After completing all 5 properties:
- **New files**: 8 (border, borders, tab_stop, tabs, shading, language, text_fill, text_outline)
- **Modified files**: 3 (paragraph_properties, run_properties, styleset_xml_parser)
- **Tests**: 168+ examples (may have initial failures to fix)
- **Property count**: 25/25 properties (100% coverage) ✅
- **Time**: ~14 hours total

## Success Criteria

- [ ] Borders property serializes correctly (4 sides)
- [ ] Tabs property serializes correctly (collection)
- [ ] Shading property serializes correctly (pattern/color/fill)
- [ ] Language property serializes correctly (val/eastAsia/bidi)
- [ ] TextEffects properties serialize correctly (basic solid fill)
- [ ] All tests passing (168+ examples, 0 failures)
- [ ] No regressions in existing properties
- [ ] Code follows Pattern 0 exactly (attributes BEFORE xml)
- [ ] All complex properties use proper wrapper classes
- [ ] MECE architecture maintained

## Timeline Compression

**Original Plan**: Days 4-5 (2 days)
**Compressed Target**: 1-2 days intensive work

**Optimization Strategies**:
1. Parallel development where possible (e.g., Shading + Language simultaneously)
2. Simplify TextEffects to basic support (full in v2.0)
3. Focus on round-trip fidelity, not 100% attribute coverage
4. Defer edge cases to future iterations

## Week 1 Completion

After Session 5:
- ✅ 25/25 properties (100%)
- ✅ Week 1 complete!
- ➡️ Move to Week 2: Package architecture + Theme round-trip

## After Completing This Task

1. Update `PHASE3_IMPLEMENTATION_STATUS.md`:
   - Property count: 20 → 25 (100%)
   - Mark all 5 complex properties as complete
   - Update Week 1 progress

2. Update `.kilocode/rules/memory-bank/context.md`:
   - Session 5 completion summary
   - New property count
   - Next focus (Week 2: Themes)

3. Celebrate: **ALL PROPERTIES COMPLETE!** 🎉

4. Prepare for Week 2:
   - Design PackageFile hierarchy
   - Plan Theme serialization
   - Create theme round-trip tests

## Important Notes

1. **Complex properties are harder**: Expect more time and iterations
2. **Tests may fail**: Breaking changes are okay if architecture is correct
3. **MECE is critical**: Each class ONE responsibility
4. **Simplify where needed**: Basic support now, full features in v2.0
5. **Follow proven patterns**: Look at existing complex properties (Spacing, Indentation, RunFonts)
6. **Object-oriented always**: Never store raw strings for structured data
7. **Compress timeline**: Work efficiently to finish ASAP

## Start Command

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify current state (should be 168 passing, 20 properties)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
ls lib/uniword/properties/*.rb | wc -l

# Start with Borders property (most complex, tackle first)
# Use spacing.rb and indentation.rb as templates
```

Good luck! Focus on architecture correctness and MECE principles. We're entering the final stretch of Week 1! 🚀