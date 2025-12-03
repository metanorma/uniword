# Continue Round-Trip Work - Phase 2: StyleSet Round-Trip

## Context

You are working on Uniword v1.0, a Ruby library for Word documents. **Phase 1 (Theme Round-Trip) is COMPLETE** with all 29 .thmx files passing 233 tests with 0 failures!

Now we must complete **Phase 2: StyleSet Round-Trip** to achieve 100% round-trip fidelity for 12 .dotx StyleSet files.

## Current State

**What's Working** ✅:
- Theme serialization: All 29 themes round-trip perfectly
- Basic document infrastructure  
- 28/28 integration tests passing
- Pattern 0 architecture proven successful

**What's Broken** 🔴:
- **StyleSet properties**: Only 30-40% of properties parsed/serialized
- **Property serialization**: No XML generation for properties
- **Round-trip**: StyleSets load but can't serialize back to XML

## Your Mission: Phase 2 - StyleSet Round-Trip

**Goal**: Make all 12 .dotx StyleSet files round-trip with 100% XML fidelity.

**Files Location**: `references/word-package/style-sets/*.dotx`

### Step 1: Understand StyleSet Structure (30 min)

Extract and analyze a StyleSet file:

```bash
cd /Users/mulgogi/src/mn/uniword
unzip -l "references/word-package/style-sets/Distinctive.dotx"
unzip -p "references/word-package/style-sets/Distinctive.dotx" word/styles.xml | xmllint --format - | head -200
```

**Key structure to understand**:
- `<w:styles>` - Root element
- `<w:style>` - Individual style definitions
- `<w:pPr>` - Paragraph properties (alignment, spacing, indentation)
- `<w:rPr>` - Run properties (bold, italic, font, color)
- `<w:tblPr>` - Table properties (borders, shading)

### Step 2: Expand Paragraph Properties (1.5 hours)

**File**: `lib/uniword/properties/paragraph_properties.rb`

**Current Coverage**: ~10 properties  
**Target**: ~50 properties (100% coverage)

**Properties to Add**:

```ruby
# Alignment & Justification
attribute :jc, :string              # Alignment (left, center, right, justify)

# Spacing
attribute :spacing_before, :integer  # Space before paragraph (twips)
attribute :spacing_after, :integer   # Space after paragraph (twips)
attribute :line_spacing, :integer    # Line spacing (twips or percentage)
attribute :line_rule, :string        # Line spacing rule (auto, exact, atLeast)

# Indentation
attribute :ind_left, :integer        # Left indent (twips)
attribute :ind_right, :integer       # Right indent (twips)
attribute :ind_first_line, :integer  # First line indent (twips)
attribute :ind_hanging, :integer     # Hanging indent (twips)

# Numbering
attribute :num_pr, NumberingProperties  # Numbering reference

# Keep Together
attribute :keep_next, :boolean       # Keep with next paragraph
attribute :keep_lines, :boolean      # Keep lines together
attribute :page_break_before, :boolean  # Page break before
attribute :widow_control, :boolean   # Widow/orphan control

# Borders
attribute :pBdr, ParagraphBorders    # Paragraph borders

# Shading
attribute :shd, Shading              # Background shading

# Tabs
attribute :tabs, Tabs                # Tab stops
```

**XML Mappings**:
```ruby
xml do
  root 'pPr'
  namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
  
  map_element 'jc', to: :jc, attribute: 'val'
  map_element 'spacing', to: :spacing, render_nil: false
  map_element 'ind', to: :indentation, render_nil: false
  map_element 'numPr', to: :num_pr
  map_element 'keepNext', to: :keep_next
  map_element 'keepLines', to: :keep_lines
  # ... etc
end
```

**Supporting Classes to Create**:
- `NumberingProperties` - numId, ilvl
- `ParagraphBorders` - top, bottom, left, right borders
- `Shading` - fill, val, color
- `Tabs` - collection of Tab objects
- `Spacing` - before, after, line, lineRule attributes
- `Indentation` - left, right, firstLine, hanging attributes

### Step 3: Expand Run Properties (1 hour)

**File**: `lib/uniword/properties/run_properties.rb`

**Current Coverage**: ~8 properties  
**Target**: ~30 properties

**Properties to Add**:

```ruby
# Font
attribute :rFonts, RunFonts          # Font family (ascii, hAnsi, eastAsia, cs)
attribute :sz, :integer              # Font size (half-points)
attribute :szCs, :integer            # Complex script font size

# Style
attribute :b, :boolean               # Bold
attribute :i, :boolean               # Italic
attribute :u, Underline              # Underline (type and color)
attribute :strike, :boolean          # Strikethrough
attribute :dstrike, :boolean         # Double strikethrough

# Color
attribute :color, :string            # Text color (RGB hex)
attribute :highlight, :string        # Highlight color

# Position
attribute :vertAlign, :string        # Subscript/superscript
attribute :position, :integer        # Raise/lower text

# Caps
attribute :smallCaps, :boolean       # Small capitals
attribute :caps, :boolean            # All capitals

# Spacing
attribute :spacing, :integer         # Character spacing (twips)
attribute :kern, :integer            # Kerning (half-points)
attribute :w, :integer               # Character width scaling (%)

# Language
attribute :lang, Language            # Language settings
```

**Supporting Classes**:
- `RunFonts` - ascii, hAnsi, eastAsia, cs fonts
- `Underline` - val (type), color
- `Language` - val, eastAsia, bidi

### Step 4: Expand Table Properties (1 hour)

**File**: `lib/uniword/properties/table_properties.rb`

**Current Coverage**: ~5 properties  
**Target**: ~40 properties

**Properties to Add**:

```ruby
# Table Layout
attribute :tblW, TableWidth          # Table width
attribute :jc, :string               # Table alignment
attribute :tblCellSpacing, :integer  # Cell spacing

# Borders
attribute :tblBorders, TableBorders  # All table borders

# Cell Margins
attribute :tblCellMar, TableCellMargins  # Cell margins (top, bottom, left, right)

# Look
attribute :tblLook, TableLook        # Table style flags

# Indentation
attribute :tblInd, :integer          # Table indentation

# Layout
attribute :tblLayout, :string        # Table layout (fixed, autofit)
```

**Supporting Classes**:
- `TableWidth` - w, type (dxa, pct, auto)
- `TableBorders` - top, bottom, left, right, insideH, insideV
- `Border` - val (style), sz (size), space, color
- `TableCellMargins` - top, bottom, left, right
- `TableLook` - firstRow, lastRow, firstColumn, lastColumn, noHBand, noVBand

### Step 5: Create StyleSet Serializer (1 hour)

**File**: `lib/uniword/stylesets/styleset_xml_serializer.rb` (NEW)

**Purpose**: Generate XML from StyleSet model

```ruby
module Uniword
  module Stylesets
    class StyleSetXmlSerializer
      def serialize(styleset)
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['w'].styles(xmlns_w) do
            styleset.styles.each do |style|
              serialize_style(xml, style)
            end
          end
        end
        builder.to_xml
      end

      private

      def serialize_style(xml, style)
        xml['w'].style(
          'w:type' => style.type,
          'w:styleId' => style.style_id
        ) do
          xml['w'].name('w:val' => style.name) if style.name
          
          # Serialize paragraph properties
          if style.paragraph_properties
            style.paragraph_properties.to_xml(xml)
          end
          
          # Serialize run properties
          if style.run_properties
            style.run_properties.to_xml(xml)
          end
          
          # Serialize table properties
          if style.table_properties
            style.table_properties.to_xml(xml)
          end
        end
      end

      def xmlns_w
        'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
      end
    end
  end
end
```

**Alternative**: Use lutaml-model for serialization (preferred if feasible)

### Step 6: Create Round-Trip Tests (30 min)

**File**: `spec/uniword/styleset_roundtrip_spec.rb` (NEW)

```ruby
require 'spec_helper'

RSpec.describe 'StyleSet Round-Trip Fidelity' do
  let(:stylesets_dir) { 'references/word-package/style-sets' }

  Dir.glob('references/word-package/style-sets/*.dotx').each do |styleset_file|
    describe File.basename(styleset_file) do
      let(:styleset) { Uniword::StyleSet.from_dotx(styleset_file) }
      
      it 'loads successfully' do
        expect(styleset).to be_a(Uniword::StyleSet)
        expect(styleset.name).not_to be_nil
      end
      
      it 'preserves all styles' do
        original_count = styleset.styles.count
        xml = styleset.to_xml
        reparsed = Uniword::StyleSet.from_xml(xml)
        
        expect(reparsed.styles.count).to eq(original_count)
      end
      
      it 'round-trips paragraph properties' do
        styleset.styles.each do |style|
          next unless style.paragraph_properties
          
          xml = style.to_xml
          reparsed = Uniword::Style.from_xml(xml)
          
          # Compare each property
          expect(reparsed.paragraph_properties.alignment).to eq(style.paragraph_properties.alignment)
          # ... more assertions
        end
      end
      
      # Similar tests for run and table properties
    end
  end
end
```

### Step 7: Debug and Fix (variable time)

**Process**:
1. Run test suite
2. Note which StyleSet fails and which property
3. Check XML structure of that property
4. Add missing attribute/class
5. Update XML mappings
6. Run test again
7. Repeat until 12/12 pass

**Debugging Commands**:
```bash
# Extract and view styles XML
unzip -p <styleset.dotx> word/styles.xml | xmllint --format - | less

# Compare original vs saved
diff <(unzip -p original.dotx word/styles.xml | xmllint --format -) \
     <(unzip -p saved.dotx word/styles.xml | xmllint --format -)
```

## Critical Architecture Principles

### Pattern 0: Attributes BEFORE XML Mappings
```ruby
# ✅ CORRECT
class MyProperties < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # FIRST
  
  xml do
    map_element 'elem', to: :my_attr  # AFTER
  end
end
```

### MECE Property Classes
Each property group (Spacing, Indentation, Borders) should be its own class:
```ruby
class Spacing < Lutaml::Model::Serializable
  attribute :before, :integer
  attribute :after, :integer
  attribute :line, :integer
  attribute :line_rule, :string
  
  xml do
    root 'spacing'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
    map_attribute 'before', to: :before
    map_attribute 'after', to: :after
    map_attribute 'line', to: :line
    map_attribute 'lineRule', to: :line_rule
  end
end
```

### Model-Driven, Not Hash-Driven
**BAD**: `{spacing: {before: 240, after: 120}}`  
**GOOD**: `Spacing.new(before: 240, after: 120)`

## Success Criteria for Session 2

By end of Phase 2:
- [ ] `lib/uniword/properties/paragraph_properties.rb` has 50+ properties
- [ ] `lib/uniword/properties/run_properties.rb` has 30+ properties
- [ ] `lib/uniword/properties/table_properties.rb` has 40+ properties
- [ ] All supporting classes created (Spacing, Indentation, Borders, etc.)
- [ ] StyleSet serialization working
- [ ] `spec/uniword/styleset_roundtrip_spec.rb` created
- [ ] **12/12 .dotx files pass round-trip test**

## After Session 2

Update `ROUNDTRIP_IMPLEMENTATION_STATUS.md`:
- Mark Phase 2 as ✅ Complete
- Update test counts (100+/100+)
- Note any issues found

Then move to Phase 3 (Document Elements).

## Time Budget

- **Step 1** (Understand): 30 min
- **Step 2** (Paragraph): 1.5 hours
- **Step 3** (Run): 1 hour
- **Step 4** (Table): 1 hour
- **Step 5** (Serializer): 1 hour
- **Step 6** (Tests): 30 min
- **Step 7** (Debug): Variable (aim for 1 hour)

**Total**: 4-5 hours

## Commands to Start

```bash
cd /Users/mulgogi/src/mn/uniword

# Check current state
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --fail-fast  # Should be 233/233

# Analyze first StyleSet
unzip -p "references/word-package/style-sets/Distinctive.dotx" word/styles.xml | xmllint --format - | head -300

# Start implementing
# 1. Edit lib/uniword/properties/paragraph_properties.rb
# 2. Create supporting classes
# 3. Update serialization
# 4. Create tests
# 5. Run and debug
```

## Questions to Ask Before Starting

1. Are all memory bank files read?
2. Do you understand Pattern 0?
3. Do you have access to the 12 .dotx files in `references/word-package/style-sets/`?
4. Are you ready to follow MECE principles?

---

**Ready to start Phase 2? Begin with**: Step 1 - Analyze Distinctive.dotx structure