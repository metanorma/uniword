# Phase 5 Session 2C: AlternateContent Integration - START HERE

**Goal**: Replace :string content in Choice/Fallback with proper DrawingML classes
**Duration**: 30-45 minutes (compressed timeline)
**Status**: Ready to begin
**Prerequisite**: Session 2B Complete ✅ (9 DrawingML classes created, 258/258 baseline)

## Quick Context

Session 2B successfully created 9 DrawingML classes with zero regressions:
- ✅ Drawing, Extent, DocProperties, NonVisualDrawingProps
- ✅ Inline, Anchor, Graphic, GraphicData
- ✅ Baseline: 258/258 tests passing

**Current Problem**: Choice and Fallback still store XML content as `:string`.

**The Solution**: Update 2 classes to use proper DrawingML types.

## Implementation (3 Tasks, 45 min)

### Task 1: Update Choice Class (15 min) - START HERE

**File**: `lib/uniword/wordprocessingml/choice.rb`

**Step 1**: Read the current file

```bash
<read_file>
<args>
  <file>
    <path>lib/uniword/wordprocessingml/choice.rb</path>
  </file>
</args>
</read_file>
```

**Step 2**: Apply changes using apply_diff

Change:
```ruby
# BEFORE
attribute :content, :string

# AFTER
attribute :drawing, Drawing
```

And in xml block:
```ruby
# BEFORE
map_element 'drawing', to: :content

# AFTER
map_element 'drawing', to: :drawing, render_nil: false
```

**Critical**: Ensure attributes are BEFORE xml block (Pattern 0)!

**Step 3**: Verify with unit test

```bash
<execute_command>
<command>cd /Users/mulgogi/src/mn/uniword && bundle exec ruby -e "
require './lib/uniword'
choice = Uniword::Wordprocessingml::Choice.new
choice.drawing = Uniword::Wordprocessingml::Drawing.new
puts 'Choice integration: PASS' if choice.drawing
"</command>
</execute_command>
```

**Expected**: "Choice integration: PASS"

### Task 2: Update Fallback Class (15 min)

**File**: `lib/uniword/wordprocessingml/fallback.rb`

**Step 1**: Read the current file

```bash
<read_file>
<args>
  <file>
    <path>lib/uniword/wordprocessingml/fallback.rb</path>
  </file>
</args>
</read_file>
```

**Step 2**: Apply changes using apply_diff

Change:
```ruby
# BEFORE
attribute :content, :string

# AFTER
attribute :pict, Pict
attribute :drawing, Drawing
```

And in xml block:
```ruby
# BEFORE
map_element 'pict', to: :content

# AFTER
map_element 'pict', to: :pict, render_nil: false
map_element 'drawing', to: :drawing, render_nil: false
```

**Critical**: Ensure attributes are BEFORE xml block (Pattern 0)!

**Step 3**: Verify with unit test

```bash
<execute_command>
<command>cd /Users/mulgogi/src/mn/uniword && bundle exec ruby -e "
require './lib/uniword'
fallback = Uniword::Wordprocessingml::Fallback.new
fallback.pict = Uniword::Wordprocessingml::Pict.new
puts 'Fallback integration: PASS' if fallback.pict
"</command>
</execute_command>
```

**Expected**: "Fallback integration: PASS"

### Task 3: Verification (15 min)

**Step 1**: Integration test

```bash
<execute_command>
<command>cd /Users/mulgogi/src/mn/uniword && bundle exec ruby -e "
require './lib/uniword'
ac = Uniword::Wordprocessingml::AlternateContent.new
choice = Uniword::Wordprocessingml::Choice.new
choice.drawing = Uniword::Wordprocessingml::Drawing.new
ac.choice = [choice]
fallback = Uniword::Wordprocessingml::Fallback.new
fallback.pict = Uniword::Wordprocessingml::Pict.new
ac.fallback = fallback
puts 'AlternateContent integration: PASS' if ac.choice.first.drawing && ac.fallback.pict
"</command>
</execute_command>
```

**Expected**: "AlternateContent integration: PASS"

**Step 2**: Baseline verification (CRITICAL)

```bash
<execute_command>
<command>cd /Users/mulgogi/src/mn/uniword && bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress</command>
</execute_command>
```

**MUST**: 258/258 still passing ✅

**Step 3**: Document Elements test (should show improvement)

```bash
<execute_command>
<command>cd /Users/mulgogi/src/mn/uniword && bundle exec rspec spec/uniword/document_element_roundtrip_spec.rb --format progress</command>
</execute_command>
```

**Expected**: Improvement in glossary tests (currently 0/8, expecting 2-8/8)

## Session 2C Success Criteria

- [ ] Choice class uses `Drawing` instead of `:string`
- [ ] Fallback class uses `Pict` and `Drawing` instead of `:string`
- [ ] All classes follow Pattern 0 (attributes BEFORE xml)
- [ ] Integration unit test passes
- [ ] Baseline tests: 258/258 still passing ✅
- [ ] Document Elements: Improvement shown (even 1 more test passing counts!)

## Critical Reminders

1. ⚠️ **ALWAYS use `bundle exec` with Ruby commands!**
2. 🚨 **Pattern 0**: Attributes BEFORE xml (ALWAYS)
3. 🏗️ **Model-Driven**: NO :string for XML content
4. 📦 **Mixed Content**: Already present in both files
5. ✨ **Render Nil**: Use `render_nil: false` for optional elements
6. ✅ **Zero Regressions**: Baseline MUST stay at 258/258

## After Session 2C Complete

Create these documents:

1. **Session Summary**: `PHASE5_SESSION2C_COMPLETE.md`
   - What was accomplished
   - Files modified (2 files)
   - Test results
   - Time taken

2. **Update Status**: `PHASE5_SESSION2C_STATUS.md`
   - Mark all tasks complete
   - Update test results
   - Record actual time

3. **Continuation Prompt**: `PHASE5_SESSION2D_PROMPT.md`
   - Final verification session
   - Complete round-trip testing
   - Documentation updates
   - Memory bank update

## Expected Outcomes

### Before Integration (Current)
- Choice: `attribute :content, :string` ❌
- Fallback: `attribute :content, :string` ❌
- Architecture: NOT fully model-driven
- Glossary tests: 0/8

### After Integration (Target)
- Choice: `attribute :drawing, Drawing` ✅
- Fallback: `attribute :pict, Pict` and `attribute :drawing, Drawing` ✅
- Architecture: 100% model-driven (no XML strings) ✅
- Glossary tests: 2-8/8 (improvement!)

## Next Steps After Session 2C

**Session 2D: Final Verification & Documentation (30 min)**
1. Run complete test suite (270-274/274 expected)
2. Analyze any remaining failures
3. Update official documentation
4. Update memory bank context
5. Create Phase 5 Session 2 complete summary
6. Celebrate 98-100% achievement! 🎊

## Architecture Note

This completes the AlternateContent model-driven architecture:

```
AlternateContent
├── Choice (modern)
│   └── Drawing (wp:drawing)
│       ├── Inline (flows with text)
│       │   ├── Extent
│       │   ├── DocProperties
│       │   ├── NonVisualDrawingProps
│       │   └── Graphic
│       │       └── GraphicData
│       │           └── Picture
│       └── Anchor (positioned)
│           └── (same structure as Inline)
└── Fallback (legacy)
    ├── Pict (w:pict - VML)
    │   └── Shape (v:shape)
    │       └── Textbox (v:textbox)
    │           └── TextBoxContent (w:txbxContent)
    └── Drawing (w:drawing - DrawingML fallback)
        └── (same as Choice)
```

All layers are now properly modeled with NO :string XML content! 🎯

## Reference Documents

- **Plan**: `PHASE5_SESSION2C_PLAN.md` - Full session details
- **Status**: `PHASE5_SESSION2C_STATUS.md` - Progress tracker
- **Session 2B**: `PHASE5_SESSION2B_COMPLETE.md` - Previous work
- **Session 2A**: `PHASE5_SESSION2A_COMPLETE.md` - Foundation
- **Overall**: `PHASE5_SESSION2_PLAN.md` - Complete Session 2 timeline

Good luck! Remember: **MODEL ALL THE CONTENT!!!** 🎯