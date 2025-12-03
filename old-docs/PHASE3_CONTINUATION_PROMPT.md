# Phase 3: Full Round-Trip Implementation - Continuation Prompt

## Context

This prompt continues work after **Phase 3 Session 1 completion** (Underline property implemented, November 29, 2024). We need to achieve 100% round-trip fidelity for ALL 61 reference files in `references/word-package/`.

**Current Status**: 24/61 files (39%) round-trip complete
**Target**: 61/61 files (100%) round-trip complete

## Objective

Complete comprehensive round-trip support for all Office file types:
- **StyleSets**: 24/24 ✅ (100% complete)
- **Themes**: 0/29 ⏳ (can load, need save/round-trip)
- **Document Elements**: 0/8 ❌ (no support yet)

## Prerequisites

Before starting, review these files:
1. **Master Plan**: `PHASE3_FULL_ROUNDTRIP_PLAN.md` (626 lines)
2. **Status Tracker**: `PHASE3_IMPLEMENTATION_STATUS.md` (330 lines)
3. **Pattern Guide**: `docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md` (408 lines)
4. **Memory Bank**: `.kilocode/rules/memory-bank/context.md`

## Critical Architectural Principles

### 1. Model-Based File Types (MOST IMPORTANT)

Each file type MUST be a proper model class:

```ruby
# WRONG - Mixing concerns
class StyleSet
  def self.from_dotx(path)
    # Loading logic mixed with model
  end
end

# CORRECT - Separation of concerns
class StyleSetPackage < DotxPackage  # File handling
  attribute :styleset, StyleSet       # Domain model
  
  def self.from_file(path)
    pkg = new(path: path)
    pkg.extract     # ZIP handling
    pkg.load_styleset  # Parse to model
    pkg
  end
  
  def save_to_file(path)
    update_styles_xml(@styleset.to_xml)  # Model to XML
    package_to_dotx(path)  # ZIP packaging
  end
end

class StyleSet < Lutaml::Model::Serializable  # Pure domain model
  attribute :styles, Style, collection: true
  # No file handling here!
end
```

### 2. Package Hierarchy (Object-Oriented)

```ruby
PackageFile (abstract)
├── DotxPackage < PackageFile
│   ├── StyleSetPackage < DotxPackage
│   ├── DocumentElementPackage < DotxPackage
│   └── QuickStylePackage < DotxPackage
└── ThmxPackage < PackageFile
    └── ThemePackage < ThmxPackage
```

### 3. MECE Responsibility Layers

```
Models (Domain)  → Theme, StyleSet, Style (NO file I/O)
    ↓
Packages (File)  → ThmxPackage, DotxPackage (ZIP + XML)
    ↓
Loaders (Parse)  → ThemeLoader, StyleSetLoader (XML → Model)
    ↓
Writers (Serial) → ThemeWriter, StyleSetWriter (Model → XML)
```

## Current Implementation Week: Week 1 (Property Expansion)

### Session 1 Complete ✅
- [x] Underline property implemented
- [x] Tests passing (168/168)
- [x] Round-trip verified

### Next Priority: Simple Properties (Days 2-3)

Implement 14 simple properties following the EXACT underline pattern:

#### Priority Queue (Implement in Order)

1. **Highlight** - `<w:highlight w:val="yellow"/>`
2. **VerticalAlign** - `<w:vertAlign w:val="superscript"/>`
3. **Position** - `<w:position w:val="5"/>`
4. **CharacterSpacing** - `<w:spacing w:val="20"/>`
5. **Kerning** - `<w:kern w:val="20"/>`
6. **WidthScale** - `<w:w w:val="150"/>`
7. **EmphasisMark** - `<w:em w:val="dot"/>`
8. **NumberingId** - `<w:numId w:val="1"/>`
9. **NumberingLevel** - `<w:ilvl w:val="0"/>`
10. **KeepNext** - `<w:keepNext/>` (boolean)
11. **KeepLines** - `<w:keepLines/>` (boolean)
12. **PageBreakBefore** - `<w:pageBreakBefore/>` (boolean)
13. **WidowControl** - `<w:widowControl/>` (boolean)
14. **ContextualSpacing** - `<w:contextualSpacing/>` (boolean)

#### 5-Step Implementation Pattern (10 mins each)

```ruby
# Step 1: Create lib/uniword/properties/highlight.rb
class HighlightValue < Lutaml::Model::Type::String
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

class Highlight < Lutaml::Model::Serializable
  attribute :value, HighlightValue
  
  xml do
    element 'highlight'  # NOT 'root'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# Step 2: Update lib/uniword/properties/run_properties.rb
require_relative 'highlight'
attribute :highlight, Highlight  # Single attribute only
map_element 'highlight', to: :highlight, render_nil: false

# Step 3: Update lib/uniword/stylesets/styleset_xml_parser.rb
require_relative '../properties/highlight'
if (highlight = rPr_node.at_xpath('./w:highlight', WORDML_NS))
  props.highlight = Properties::Highlight.new(value: highlight['w:val'])
end

# Step 4: Test
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
# Expected: 168+ examples, 0 failures

# Step 5: Verify (optional)
ruby -e "
require './lib/uniword'
ss = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
style = ss.styles.find { |s| s.run_properties&.highlight }
puts style.run_properties.highlight.value if style
"
```

## Task: Implement Next 3 Properties

### Instructions

Implement these 3 properties in sequence:

1. **Highlight** (10 mins)
2. **VerticalAlign** (10 mins)
3. **Position** (10 mins)

For each property:
- Create wrapper class file
- Update run_properties.rb (attribute + xml mapping)
- Update styleset_xml_parser.rb (parser logic)
- Run tests after EACH property (keep tests green)

### Expected Outcomes

After completing all 3 properties:
- **New files**: 3 (highlight.rb, vertical_align.rb, position.rb)
- **Modified files**: 2 (run_properties.rb, styleset_xml_parser.rb)
- **Tests**: 168+ examples, 0 failures
- **Property count**: 11 → 14 properties
- **Time**: ~30 minutes

### Success Criteria

- [ ] Highlight property serializes correctly
- [ ] VerticalAlign property serializes correctly
- [ ] Position property serializes correctly
- [ ] All tests passing (168+ examples, 0 failures)
- [ ] No regressions in existing properties
- [ ] Code follows pattern exactly (no shortcuts)

## Reference: Property Specifications

### Highlight Property
```xml
<w:highlight w:val="yellow"/>
```
- **Type**: String
- **Values**: yellow, green, cyan, magenta, blue, red, darkBlue, darkCyan, darkGreen, darkMagenta, darkRed, darkYellow, darkGray, lightGray, black, white, none
- **Element**: `highlight`
- **Attribute**: `val`

### VerticalAlign Property
```xml
<w:vertAlign w:val="superscript"/>
```
- **Type**: String
- **Values**: baseline, superscript, subscript
- **Element**: `vertAlign`
- **Attribute**: `val`

### Position Property
```xml
<w:position w:val="5"/>
```
- **Type**: Integer
- **Values**: Any integer (half-points, positive = raised, negative = lowered)
- **Element**: `position`
- **Attribute**: `val`

## Troubleshooting

### If tests fail:
1. Check attribute declared BEFORE xml block (Pattern 0)
2. Verify `element` not `root`
3. Verify namespace is class reference
4. Verify single attribute (no dual attributes)
5. Check `render_nil: false` in xml mapping

### If serialization empty:
- Attribute declared before xml block?
- Custom type has `xml_namespace`?
- Using `element` not `root`?
- Namespace reference correct?

### If parser fails:
- Required relative imports present?
- XPath namespace prefix correct (`w:`)?
- Wrapper object created properly?
- Handling nil values correctly?

## After Completing This Task

Update the status tracker:

```markdown
# PHASE3_IMPLEMENTATION_STATUS.md

### ✅ Implemented (14 properties) ← Update count

| Property | Type | Element | File | Status |
|----------|------|---------|------|--------|
| ... existing properties ...
| Highlight | Simple | `<w:highlight>` | highlight.rb | ✅ Complete |
| VerticalAlign | Simple | `<w:vertAlign>` | vertical_align.rb | ✅ Complete |
| Position | Simple | `<w:position>` | position.rb | ✅ Complete |
```

Then continue with next 3 properties:
- CharacterSpacing
- Kerning  
- WidthScale

## Long-Term Context (Weeks 2-4)

### Week 2: Package Architecture + Themes
After completing 30 properties, switch to:
- Design PackageFile hierarchy
- Implement ThmxPackage with save capability
- Create Theme round-trip tests (29 .thmx files)
- Target: 53/61 files round-trip ✅

### Week 3: Document Elements
- Implement HeaderTemplate, FooterTemplate models
- Add Bibliography, TocStyle, Watermark support
- Create DocumentElementPackage class
- Target: 61/61 files load

### Week 4: Testing & Documentation
- Comprehensive test suite (61 examples)
- Fix any failing round-trips
- Update README.adoc
- Archive old documentation
- Target: 61/61 files round-trip ✅

## Files to Reference

### Pattern Examples
- `lib/uniword/properties/underline.rb` - Working example
- `lib/uniword/properties/alignment.rb` - Working example
- `lib/uniword/properties/font_size.rb` - Integer type example

### Core Files to Modify
- `lib/uniword/properties/run_properties.rb` - Add attributes here
- `lib/uniword/stylesets/styleset_xml_parser.rb` - Add parsing here

### Test Files
- `spec/uniword/styleset_roundtrip_spec.rb` - Run after each property
- `verify_underline.rb` - Modify to test new properties

## Verification Commands

```bash
# Run tests
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb

# Quick property check
ruby -e "
require './lib/uniword'
ss = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
styles = ss.styles.select { |s| s.run_properties&.highlight }
puts \"Found #{styles.count} styles with highlight\"
"

# Full property inventory
ruby -e "
require './lib/uniword'
ss = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
props = [:highlight, :vertical_align, :position]
props.each do |prop|
  count = ss.styles.count { |s| s.run_properties&.send(prop) }
  puts \"#{prop}: #{count} styles\"
end
"
```

## Remember

1. **One property at a time** - Test after each
2. **Follow pattern exactly** - No shortcuts or variations
3. **Keep tests green** - Never commit broken tests
4. **Model-based architecture** - No raw XML, no file handling in models
5. **MECE separation** - Models ≠ Packages ≠ Loaders ≠ Writers
6. **Object-oriented** - Inheritance, polymorphism, clean APIs
7. **Pattern 0** - Attributes BEFORE xml mappings (ALWAYS)

## Start Command

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify current state
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb
# Expected: 168 examples, 0 failures

# Start with Highlight property
# Copy underline.rb as template
cp lib/uniword/properties/underline.rb lib/uniword/properties/highlight.rb

# Then modify highlight.rb following the 5-step pattern
```

Good luck! Maintain the quality bar - architecture correctness is paramount.