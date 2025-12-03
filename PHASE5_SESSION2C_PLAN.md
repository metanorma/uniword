# Phase 5 Session 2C: Integration with AlternateContent

**Goal**: Replace :string content in Choice/Fallback with proper DrawingML classes
**Duration**: 30-45 minutes (compressed timeline)
**Status**: Ready to begin
**Prerequisite**: Session 2B Complete ✅ (9 DrawingML classes created, 258/258 baseline)

## Context

Session 2B successfully created 9 DrawingML classes:
- ✅ Drawing, Extent, DocProperties, NonVisualDrawingProps
- ✅ Inline, Anchor
- ✅ Graphic, GraphicData
- ✅ Baseline: 258/258 tests passing

**Current Problem**: Choice and Fallback still store nested content as `:string`.

**The Solution**: Integrate DrawingML classes into AlternateContent hierarchy.

## Architecture Understanding

### Current AlternateContent Structure

```ruby
# lib/uniword/wordprocessingml/alternate_content.rb
class AlternateContent < Lutaml::Model::Serializable
  attribute :choice, Choice, collection: true
  attribute :fallback, Fallback
end

# lib/uniword/wordprocessingml/choice.rb
class Choice < Lutaml::Model::Serializable
  attribute :requires, :string
  attribute :content, :string  # ❌ WRONG - Should be Drawing
end

# lib/uniword/wordprocessingml/fallback.rb
class Fallback < Lutaml::Model::Serializable
  attribute :content, :string  # ❌ WRONG - Should be Pict or Drawing
end
```

### Target AlternateContent Structure

```ruby
class Choice < Lutaml::Model::Serializable
  attribute :requires, :string
  attribute :drawing, Drawing  # ✅ Modern DrawingML (w:drawing)
end

class Fallback < Lutaml::Model::Serializable
  attribute :pict, Pict        # ✅ VML picture (w:pict)
  attribute :drawing, Drawing  # ✅ Or DrawingML fallback
end
```

## Implementation Strategy

We'll modify 2 classes in 3 tasks:

### Task 1: Update Choice Class (15 min)

**File**: `lib/uniword/wordprocessingml/choice.rb`

**Change**:
```ruby
# BEFORE
attribute :content, :string

# AFTER
attribute :drawing, Drawing
```

**XML Mapping**:
```ruby
map_element 'drawing', to: :drawing, render_nil: false
```

### Task 2: Update Fallback Class (15 min)

**File**: `lib/uniword/wordprocessingml/fallback.rb`

**Change**:
```ruby
# BEFORE
attribute :content, :string

# AFTER
attribute :pict, Pict           # VML picture
attribute :drawing, Drawing     # DrawingML fallback
```

**XML Mapping**:
```ruby
map_element 'pict', to: :pict, render_nil: false
map_element 'drawing', to: :drawing, render_nil: false
```

### Task 3: Verification (15 min)

**Tests**:
1. Unit test: AlternateContent serialization
2. Baseline: 258/258 still passing
3. Document Elements: Check improvement in glossary tests

## Detailed Implementation

### Task 1: Choice Class

<read_file>
- `lib/uniword/wordprocessingml/choice.rb`
</read_file>

<apply_diff>
Replace:
```ruby
attribute :content, :string
```

With:
```ruby
attribute :drawing, Drawing
```

Replace in xml block:
```ruby
map_element 'drawing', to: :content
```

With:
```ruby
map_element 'drawing', to: :drawing, render_nil: false
```
</apply_diff>

### Task 2: Fallback Class

<read_file>
- `lib/uniword/wordprocessingml/fallback.rb`
</read_file>

<apply_diff>
Replace:
```ruby
attribute :content, :string
```

With:
```ruby
attribute :pict, Pict
attribute :drawing, Drawing
```

Replace in xml block:
```ruby
map_element 'pict', to: :content
```

With:
```ruby
map_element 'pict', to: :pict, render_nil: false
map_element 'drawing', to: :drawing, render_nil: false
```
</apply_diff>

### Task 3: Verification

**Unit Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec ruby -e "
require './lib/uniword'
ac = Uniword::Wordprocessingml::AlternateContent.new
choice = Uniword::Wordprocessingml::Choice.new
choice.drawing = Uniword::Wordprocessingml::Drawing.new
ac.choice = [choice]
puts 'AlternateContent integration: PASS' if ac.choice.first.drawing
"
```

**Baseline Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb \
                   --format progress
```

**Expected**: 258/258 passing ✅

**Document Elements Test**:
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/document_element_roundtrip_spec.rb \
                   --format progress
```

**Expected**: Improvement in glossary tests (currently 0/8, expecting 4-8/8)

## Success Criteria

- [ ] Choice class uses `Drawing` instead of `:string`
- [ ] Fallback class uses `Pict` and `Drawing` instead of `:string`
- [ ] All classes follow Pattern 0 (attributes BEFORE xml)
- [ ] All classes are model-driven (NO :string for XML content)
- [ ] Baseline tests: 258/258 still passing ✅
- [ ] Document Elements: Improvement in glossary round-trip

## Critical Reminders

1. ⚠️ **ALWAYS use `bundle exec` with Ruby commands!**
2. 🚨 **Pattern 0**: Attributes BEFORE xml (ALWAYS)
3. 🏗️ **Model-Driven**: NO :string for XML content
4. 🔧 **Namespace**: Each class defines its own
5. 📦 **Mixed Content**: Use `mixed_content` for elements with nested content
6. ✨ **Render Nil**: Use `render_nil: false` for optional elements
7. ✅ **Zero Regressions**: Baseline must stay at 258/258

## Expected Outcomes

### Before Integration
- Choice: stores Drawing as :string
- Fallback: stores Pict/Drawing as :string
- Round-trip: Limited (glossary 0/8)

### After Integration
- Choice: properly models Drawing
- Fallback: properly models Pict and Drawing
- Round-trip: Significant improvement (glossary 4-8/8)
- Architecture: 100% model-driven (no XML strings)

## Next Steps After Session 2C

**Session 2D: Final Verification (30 min)**
- Run complete test suite (expecting 270-274/274)
- Document improvements
- Create Phase 5 Session 2 summary
- Update memory bank
- Celebrate near-100% achievement! 🎊

## Risk Assessment

**Low Risk**:
- Simple attribute type changes
- No new classes needed
- Well-tested foundation (Session 2A/2B)

**Mitigation**:
- Verify baseline after each change
- Use `render_nil: false` for optional elements
- Follow exact pattern from Session 2A/2B

## Time Estimate

- Task 1 (Choice): 15 min
- Task 2 (Fallback): 15 min
- Task 3 (Verification): 15 min
- **Total**: 45 minutes

## Reference Files

**Created in Session 2B**:
- `lib/uniword/wordprocessingml/drawing.rb`
- `lib/uniword/wp_drawing/extent.rb`
- `lib/uniword/wp_drawing/doc_properties.rb`
- `lib/uniword/wp_drawing/non_visual_drawing_props.rb`
- `lib/uniword/wp_drawing/inline.rb`
- `lib/uniword/wp_drawing/anchor.rb`
- `lib/uniword/drawingml/graphic.rb`
- `lib/uniword/drawingml/graphic_data.rb`

**To Modify in Session 2C**:
- `lib/uniword/wordprocessingml/choice.rb`
- `lib/uniword/wordprocessingml/fallback.rb`

**Created in Session 2A**:
- `lib/uniword/wordprocessingml/text_box_content.rb`
- `lib/uniword/wordprocessingml/pict.rb`
- `lib/uniword/vml/textbox.rb`
- `lib/uniword/vml/shape.rb` (enhanced)

## Architecture Note

This integration completes the AlternateContent architecture:
1. **AlternateContent** - Container for modern/fallback content
2. **Choice** - Modern DrawingML content (Office 2007+)
3. **Fallback** - Legacy VML content (Office 2003+)
4. **Drawing** - WordProcessing Drawing (wp: namespace)
5. **Pict** - VML Picture (v: namespace)

All layers are now properly modeled with NO :string XML content! 🎯