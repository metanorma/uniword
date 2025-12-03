# Phase 2 Session 2: Fix Core Serialization Issues

**Context**: You are continuing Phase 2 of Uniword StyleSet Round-Trip implementation. Session 1 created the infrastructure (40% complete). Session 2 must fix serialization errors.

## What Was Done in Session 1 ✅

Created complete property infrastructure:
- `lib/uniword/properties/paragraph_properties.rb` (50+ attributes)
- `lib/uniword/properties/run_properties.rb` (30+ attributes)
- `lib/uniword/properties/table_properties.rb` (40+ attributes)
- `lib/uniword/properties/spacing.rb` (complex object)
- `lib/uniword/properties/indentation.rb` (complex object)
- `lib/uniword/style.rb` (complete Style model)
- `spec/uniword/styleset_roundtrip_spec.rb` (test suite)

**Status**: All 24 .dotx files load successfully, but serialization fails with attribute errors.

## Your Mission: Fix Serialization (2-3 hours)

Make all 24 StyleSet files serialize without errors by fixing XML mappings and boolean handling.

---

## Task 1: Fix ParagraphProperties XML Mappings (30 min)

**Problem**: `Attribute 'numbering' not found` error affects 40+ styles.

**Root Cause**: XML mappings try to use non-existent intermediate attributes.

**Solution**: Simplify mappings using direct element-to-attribute mapping.

### Current Code (Broken)
```ruby
# lib/uniword/properties/paragraph_properties.rb (lines 59-84)
map_element 'pStyle', to: :style, render_nil: false do
  map_attribute 'val', to: :content  # ❌ 'content' doesn't exist
end

map_element 'jc', to: :alignment, render_nil: false do
  map_attribute 'val', to: :content  # ❌ 'content' doesn't exist
end
```

### Fixed Code
```ruby
# Direct attribute mapping (no intermediate)
map_element 'pStyle', to: :style, render_nil: false, delegate: :val

map_element 'jc', to: :alignment, render_nil: false, delegate: :val

map_element 'outlineLvl', to: :outline_level, render_nil: false, delegate: :val
```

**Action Steps**:
1. Edit `lib/uniword/properties/paragraph_properties.rb`
2. Replace XML mappings (lines 59-110) with simplified versions
3. Remove all `do ... map_attribute 'val', to: :content ... end` blocks
4. Use `delegate: :val` for single-attribute elements
5. Test with: `bundle exec ruby -e "require './lib/uniword/styleset'; s = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx'); h1 = s.styles.find { |s| s.id == 'Heading1' }; puts h1.to_xml[0..500]"`

---

## Task 2: Create RunFonts Supporting Class (30 min)

**Problem**: `Attribute 'fonts' not found` error affects 30+ character styles.

**Root Cause**: RunProperties tries to serialize font data as flat attributes, but XML expects `<w:rFonts>` element.

**Solution**: Create RunFonts class similar to Spacing and Indentation.

### Create File: `lib/uniword/properties/run_fonts.rb`
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Font family element for run properties
    #
    # Represents <w:rFonts> with ascii, hAnsi, eastAsia, cs, hint attributes
    class RunFonts < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :ascii, :string
      attribute :h_ansi, :string
      attribute :east_asia, :string
      attribute :cs, :string
      attribute :hint, :string
      
      xml do
        root 'rFonts'
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
        
        map_attribute 'ascii', to: :ascii
        map_attribute 'hAnsi', to: :h_ansi
        map_attribute 'eastAsia', to: :east_asia
        map_attribute 'cs', to: :cs
        map_attribute 'hint', to: :hint
      end
    end
  end
end
```

### Update `lib/uniword/properties/run_properties.rb`

**Add** (after line 4):
```ruby
require_relative 'run_fonts'
```

**Add** (after line 18):
```ruby
# Complex fonts object
attribute :fonts, RunFonts
```

**Update XML mapping** (around line 87):
```ruby
# Fonts (complex object)
map_element 'rFonts', to: :fonts, render_nil: false
```

**Update Parser** in `lib/uniword/stylesets/styleset_xml_parser.rb` (around line 199):
```ruby
# Font families (w:rFonts) - create RunFonts object
if (rFonts = rPr_node.at_xpath('./w:rFonts', WORDML_NS))
  fonts_attrs = {}
  fonts_attrs[:ascii] = rFonts['w:ascii'] if rFonts['w:ascii']
  fonts_attrs[:h_ansi] = rFonts['w:hAnsi'] if rFonts['w:hAnsi']
  fonts_attrs[:east_asia] = rFonts['w:eastAsia'] if rFonts['w:eastAsia']
  fonts_attrs[:cs] = rFonts['w:cs'] if rFonts['w:cs']
  fonts_attrs[:hint] = rFonts['w:hint'] if rFonts['w:hint']
  
  props.fonts = Properties::RunFonts.new(fonts_attrs)
  
  # Also set flat attributes for compatibility
  props.font = fonts_attrs[:h_ansi] || fonts_attrs[:ascii]
  props.font_ascii = fonts_attrs[:ascii]
  props.font_east_asia = fonts_attrs[:east_asia]
  props.font_hint = fonts_attrs[:hint]
end
```

---

## Task 3: Fix TableProperties Width Mapping (15 min)

**Problem**: `Attribute 'tbl_width' not found` error.

**Root Cause**: TableProperties XML tries to map to non-existent `tbl_width` intermediate attribute.

**Solution**: Simplify width element mapping.

### Update `lib/uniword/properties/table_properties.rb`

**Current (Broken)** around line 84:
```ruby
map_element 'tblW', to: :tbl_width, render_nil: false do
  map_attribute 'w', to: :width
  map_attribute 'type', to: :width_type
end
```

**Fixed**:
```ruby
# Table width - compound element with two attributes
map_element 'tblW', to: :tbl_w, render_nil: false do
  map_attribute 'w', to: :width
  map_attribute 'type', to: :width_type
end
```

OR use custom deserialization (better):
```ruby
# Leave attributes as-is, handle in parser only
# Remove tblW mapping entirely, parser sets width/width_type directly
```

---

## Task 4: Fix Boolean Serialization (30 min)

**Problem**: Boolean elements render as `<w:b>false</w:b>` instead of being omitted.

**Root Cause**: Lutaml-model renders boolean attributes even when false.

**Solution**: Add `render_default: false` to all boolean mappings.

### Update `lib/uniword/properties/paragraph_properties.rb`

**Find all boolean mappings** (around lines 86-98) and add `render_default: false`:

```ruby
# Keep options (only render if true)
map_element 'keepNext', to: :keep_next, render_nil: false, render_default: false
map_element 'keepLines', to: :keep_lines, render_nil: false, render_default: false
map_element 'pageBreakBefore', to: :page_break_before, render_nil: false, render_default: false
map_element 'widowControl', to: :widow_control, render_nil: false, render_default: false

# Spacing options
map_element 'contextualSpacing', to: :contextual_spacing, render_nil: false, render_default: false
map_element 'suppressLineNumbers', to: :suppress_line_numbers, render_nil: false, render_default: false

# Bidirectional
map_element 'bidi', to: :bidirectional, render_nil: false, render_default: false
```

### Update `lib/uniword/properties/run_properties.rb`

**Find all boolean mappings** (around lines 100-108) and add `render_default: false`:

```ruby
# Boolean formatting (only render if true)
map_element 'b', to: :bold, render_nil: false, render_default: false
map_element 'i', to: :italic, render_nil: false, render_default: false
map_element 'strike', to: :strike, render_nil: false, render_default: false
map_element 'dstrike', to: :double_strike, render_nil: false, render_default: false
map_element 'smallCaps', to: :small_caps, render_nil: false, render_default: false
map_element 'caps', to: :caps, render_nil: false, render_default: false
map_element 'vanish', to: :hidden, render_nil: false, render_default: false
```

---

## Task 5: Update Tests for Both Directories (15 min)

**Current**: Tests only check `style-sets/` directory (12 files).

**Target**: Test both `style-sets/` and `quick-styles/` directories (24 files total).

### Update `spec/uniword/styleset_roundtrip_spec.rb`

**Replace** (around line 6):
```ruby
let(:stylesets_dir) { 'references/word-package/style-sets' }

Dir.glob('references/word-package/style-sets/*.dotx').sort.each do |styleset_file|
```

**With**:
```ruby
# Test both directories
['style-sets', 'quick-styles'].each do |dir_name|
  describe "#{dir_name}/" do
    Dir.glob("references/word-package/#{dir_name}/*.dotx").sort.each do |styleset_file|
      styleset_name = File.basename(styleset_file, '.dotx')
      
      describe styleset_name do
        # ... existing tests ...
      end
    end
  end
end
```

---

## Task 6: Run Tests and Verify (15 min)

```bash
cd /Users/mulgogi/src/mn/uniword

# Run full test suite
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb --format documentation

# Expected results after fixes:
# - 24/24 files load successfully ✅
# - 0 "Attribute not found" errors ✅
# - Boolean elements only when true ✅
# - Basic round-trip works ✅
```

**If tests pass**: Update status to Session 2 Complete (60-70%)

**If tests fail**: Debug specific issues:
```bash
# Test single file
bundle exec ruby -e "
require './lib/uniword/styleset'
styleset = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
heading1 = styleset.styles.find { |s| s.id == 'Heading1' }
xml = heading1.to_xml
puts xml
reparsed = Uniword::Style.from_xml(xml)
puts 'Success!' if reparsed
"
```

---

## Success Criteria for Session 2

- [ ] No "Attribute not found" errors
- [ ] All 24 .dotx files serialize without errors
- [ ] Boolean elements only render when true
- [ ] XML output matches OOXML structure
- [ ] Basic round-trip preservation works

## Files to Modify

1. `lib/uniword/properties/paragraph_properties.rb` - Simplify XML mappings
2. `lib/uniword/properties/run_properties.rb` - Add RunFonts, fix booleans
3. `lib/uniword/properties/table_properties.rb` - Fix width mapping
4. `lib/uniword/properties/run_fonts.rb` - CREATE NEW
5. `lib/uniword/stylesets/styleset_xml_parser.rb` - Add RunFonts parsing
6. `spec/uniword/styleset_roundtrip_spec.rb` - Test both directories

## Reference Documents

- `PHASE2_SESSION1_SUMMARY.md` - What was done in Session 1
- `PHASE2_IMPLEMENTATION_STATUS.md` - Detailed status tracker
- `PHASE2_CONTINUATION_PLAN.md` - Overall plan

## After Session 2 Complete

Update:
1. `PHASE2_IMPLEMENTATION_STATUS.md` - Mark Session 2 complete
2. `.kilocode/rules/memory-bank/context.md` - Update progress
3. Create `PHASE2_SESSION2_SUMMARY.md` with results

Then proceed to Session 3 (Property Coverage) per continuation plan.

---

**Time Budget**: 2-3 hours  
**Priority**: Get to 0 attribute errors first, then fix booleans
**Success**: 24/24 files round-trip without serialization errors