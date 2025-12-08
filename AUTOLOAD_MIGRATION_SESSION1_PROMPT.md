# Autoload Migration: Session 1 Start Prompt

**Session**: Phase 1, Session 1 - Run & Paragraph Properties
**Duration**: 3 hours
**Goal**: Migrate two largest property containers to autoload pattern
**Target**: 27 require_relative → 2 (-25, 93% reduction in this session)

---

## Context

You are continuing the autoload migration for Uniword. The analysis phase is complete, and we're ready to begin implementation.

**Key Files to Review**:
1. `AUTOLOAD_MIGRATION_CORRECTED_ANALYSIS.md` - Corrected scope analysis
2. `AUTOLOAD_MIGRATION_CONTINUATION_PLAN.md` - Complete implementation plan
3. `AUTOLOAD_MIGRATION_STATUS.md` - Progress tracker

**Current State**:
- Namespace modules already use autoload ✅
- Main entry point already optimized ✅
- Property containers need migration (48 → 10 target)
- This session tackles the two largest: RunProperties (17) + ParagraphProperties (10)

---

## Session 1 Objectives

### Task 1.1: RunProperties Migration (90 min)

**Objective**: Convert RunProperties from 17 require_relative to autoload pattern

**Current File**: `lib/uniword/ooxml/wordprocessingml/run_properties.rb`

**Current State** (lines 1-20):
```ruby
require 'lutaml/model'
require_relative '../../properties/run_fonts'
require_relative '../../properties/font_size'
require_relative '../../properties/color_value'
require_relative '../../properties/style_reference'
require_relative '../../properties/underline'
require_relative '../../properties/highlight'
require_relative '../../properties/vertical_align'
require_relative '../../properties/position'
require_relative '../../properties/character_spacing'
require_relative '../../properties/kerning'
require_relative '../../properties/width_scale'
require_relative '../../properties/emphasis_mark'
require_relative '../../properties/shading'
require_relative '../../properties/language'
require_relative '../../properties/text_fill'
require_relative '../../properties/text_outline'

module Uniword
  module Ooxml
    # ...
```

#### Step 1: Create Properties Module (30 min)

**Create**: `lib/uniword/properties.rb`

**Content**:
```ruby
# frozen_string_literal: true

# Properties module autoload index
# Provides lazy loading for all property wrapper classes
#
# Property classes wrap simple OOXML elements with type-safe Ruby objects.
# Using autoload allows property classes to load only when needed,
# improving startup time and memory usage.

module Uniword
  module Properties
    # Simple property wrappers (simple XML elements)
    autoload :Alignment, 'uniword/properties/alignment'
    autoload :Border, 'uniword/properties/border'
    autoload :CellVerticalAlign, 'uniword/properties/cell_vertical_align'
    autoload :CellWidth, 'uniword/properties/cell_width'
    autoload :CharacterSpacing, 'uniword/properties/character_spacing'
    autoload :ColorValue, 'uniword/properties/color_value'
    autoload :EmphasisMark, 'uniword/properties/emphasis_mark'
    autoload :FontSize, 'uniword/properties/font_size'
    autoload :Highlight, 'uniword/properties/highlight'
    autoload :Kerning, 'uniword/properties/kerning'
    autoload :NumberingId, 'uniword/properties/numbering_id'
    autoload :NumberingLevel, 'uniword/properties/numbering_level'
    autoload :OutlineLevel, 'uniword/properties/outline_level'
    autoload :Position, 'uniword/properties/position'
    autoload :StyleReference, 'uniword/properties/style_reference'
    autoload :TableWidth, 'uniword/properties/table_width'
    autoload :Underline, 'uniword/properties/underline'
    autoload :VerticalAlign, 'uniword/properties/vertical_align'
    autoload :WidthScale, 'uniword/properties/width_scale'

    # Complex property objects (contain multiple child elements)
    autoload :Borders, 'uniword/properties/borders'
    autoload :Indentation, 'uniword/properties/indentation'
    autoload :Language, 'uniword/properties/language'
    autoload :Margin, 'uniword/properties/margin'
    autoload :RunFonts, 'uniword/properties/run_fonts'
    autoload :Shading, 'uniword/properties/shading'
    autoload :Spacing, 'uniword/properties/spacing'
    autoload :TableCellMargin, 'uniword/properties/table_cell_margin'
    autoload :TableLook, 'uniword/properties/table_look'
    autoload :Tabs, 'uniword/properties/tabs'
    autoload :TabStop, 'uniword/properties/tab_stop'
    autoload :TextFill, 'uniword/properties/text_fill'
    autoload :TextOutline, 'uniword/properties/text_outline'
  end
end
```

**Why This Works**:
- All property files are in `lib/uniword/properties/`
- Autoload paths are correct relative to load path
- Properties namespace is explicit
- Lazy loading improves performance

#### Step 2: Update Main Entry Point (10 min)

**File**: `lib/uniword.rb`

**Find** (around line 106):
```ruby
  # Autoload styles
  autoload :StylesConfiguration, 'uniword/styles_configuration'
  autoload :Style, 'uniword/style'
```

**Add After**:
```ruby
  # Autoload properties
  autoload :Properties, 'uniword/properties'
```

**Why**: Makes Properties module available throughout codebase

#### Step 3: Update RunProperties File (30 min)

**File**: `lib/uniword/ooxml/wordprocessingml/run_properties.rb`

**Replace Lines 1-20 With**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'
# Property classes are autoloaded via Uniword::Properties module
# No require_relative needed - they load on first access
```

**Why This Works**:
- `Uniword::Properties` is defined in main entry point
- Properties autoload on first use (e.g., `Properties::RunFonts`)
- All class references in this file already use `Properties::` prefix
- No code changes needed in class body!

#### Step 4: Verify & Test (20 min)

**Commands**:
```bash
# 1. Verify syntax
ruby -c lib/uniword/properties.rb
ruby -c lib/uniword/ooxml/wordprocessingml/run_properties.rb

# 2. Test autoload trigger
ruby -I lib -e "require 'uniword'; puts Uniword::Properties::RunFonts"

# 3. Run full test suite
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb

# 4. Expected: 168/168 tests passing
```

**Success Criteria**:
- ✅ All syntax checks pass
- ✅ Autoload triggers correctly
- ✅ 168 StyleSet tests pass
- ✅ No "uninitialized constant" errors

---

### Task 1.2: ParagraphProperties Migration (90 min)

**Objective**: Convert ParagraphProperties from 10 require_relative to autoload

**Current File**: `lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb`

**Current State** (lines 1-14):
```ruby
require 'lutaml/model'
require_relative '../../properties/spacing'
require_relative '../../properties/indentation'
require_relative '../../properties/alignment'
require_relative '../../properties/style_reference'
require_relative '../../properties/outline_level'
require_relative '../../properties/numbering_id'
require_relative '../../properties/numbering_level'
require_relative '../../properties/borders'
require_relative '../../properties/tabs'
require_relative '../../properties/shading'
```

#### Step 1: Verify Properties Module (10 min)

**Check**: All properties used by ParagraphProperties are in autoload list
- ✅ Spacing - already in properties.rb
- ✅ Indentation - already in properties.rb  
- ✅ Alignment - already in properties.rb
- ✅ StyleReference - already in properties.rb
- ✅ OutlineLevel - already in properties.rb
- ✅ NumberingId - already in properties.rb
- ✅ NumberingLevel - already in properties.rb
- ✅ Borders - already in properties.rb
- ✅ Tabs - already in properties.rb
- ✅ Shading - already in properties.rb

**Result**: All properties already autoloaded! No need to modify properties.rb

#### Step 2: Update ParagraphProperties File (40 min)

**File**: `lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb`

**Replace Lines 1-14 With**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'
# Property classes are autoloaded via Uniword::Properties module
# No require_relative needed - they load on first access
```

**Why**: Same pattern as RunProperties - clean and consistent

#### Step 3: Verify & Test (40 min)

**Commands**:
```bash
# 1. Verify syntax
ruby -c lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb

# 2. Test autoload
ruby -I lib -e "require 'uniword'; puts Uniword::Properties::Spacing"

# 3. Run StyleSet tests (paragraph properties heavily used)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb

# 4. Run Theme tests (use paragraph properties)
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb

# 5. Expected: 342 tests passing (168 StyleSet + 174 Theme)
```

**Success Criteria**:
- ✅ All syntax checks pass
- ✅ Autoload triggers correctly
- ✅ 168 StyleSet tests pass
- ✅ 174 Theme tests pass
- ✅ Zero regressions

---

## Session 1 Completion Checklist

### Files Created
- [ ] `lib/uniword/properties.rb` (40 lines, 35 autoload declarations)

### Files Modified
- [ ] `lib/uniword.rb` (added 1 autoload line)
- [ ] `lib/uniword/ooxml/wordprocessingml/run_properties.rb` (removed 17 require_relative)
- [ ] `lib/uniword/ooxml/wordprocessingml/paragraph_properties.rb` (removed 10 require_relative)

### Tests Passing
- [ ] StyleSet round-trip: 168/168
- [ ] Theme round-trip: 174/174
- [ ] Total: 342/342 (100%)

### Migration Count
- **Before**: 27 require_relative (17 + 10)
- **After**: 2 require_relative (1 + 1 for lutaml/model)
- **Eliminated**: 25 (-93%)

### Performance Notes
- [ ] Measured baseline startup time
- [ ] Measured post-migration startup time
- [ ] Documented improvement (expected: 5-10%)

---

## Update Status Tracker

After session completion, update `AUTOLOAD_MIGRATION_STATUS.md`:

**Phase 1, Session 1 section**:
```markdown
### Session 1: Run & Paragraph Properties (3 hours)
**Status**: ✅ Complete | **Progress**: 27/27 migrations

| Task | File | Before | After | Status | Time |
|------|------|--------|-------|--------|------|
| 1.1 | RunProperties | 17 | 1 | ✅ | 90m |
| 1.2 | ParagraphProperties | 10 | 1 | ✅ | 90m |

**Deliverables**:
- [x] Created `lib/uniword/properties.rb` with autoload declarations
- [x] Updated `lib/uniword.rb` to autoload Properties module
- [x] Removed 27 require_relative from property containers
- [x] All 342+ tests passing
- [x] Property lazy loading verified
```

---

## Next Steps

After Session 1 completion:
1. **Verify all tests pass** (342/342)
2. **Update status tracker** (AUTOLOAD_MIGRATION_STATUS.md)
3. **Commit changes** with message: `feat(autoload): migrate RunProperties and ParagraphProperties to autoload`
4. **Proceed to Session 2** or take a break

**Session 2 Preview**: Table & SDT Properties (21 migrations, 2 hours)

---

## Troubleshooting

### Issue: "uninitialized constant Properties::RunFonts"
**Cause**: Autoload path incorrect
**Fix**: Check `lib/uniword/properties.rb` paths are relative to load path

### Issue: Tests fail with NameError
**Cause**: Property class not in autoload list
**Fix**: Add missing property to `properties.rb` autoload declarations

### Issue: Circular dependency error
**Cause**: Property class requires another property before autoload triggers
**Fix**: Usually auto-resolves with autoload; if not, use require_relative for that one property

---

## Architecture Notes

### Why Autoload Works Here

1. **Clean namespace**: All properties in `Uniword::Properties`
2. **No circular deps**: Property classes are independent
3. **Lazy loading**: Properties only load when first accessed
4. **Consistent paths**: All files in `lib/uniword/properties/*.rb`

### Pattern to Follow

**For Every Property Container**:
```ruby
# BEFORE
require_relative '../../properties/some_property'

# AFTER (if property is in Properties module)
# No require_relative needed! Autoloaded via Uniword::Properties
```

**Exception**: Properties loading namespaces still need:
```ruby
require_relative '../ooxml/namespaces'  # KEEP THIS - needed at class definition
```

---

## Remember

- ✅ **Attributes BEFORE xml** (Pattern 0 - don't break this!)
- ✅ **Test after each change** (don't accumulate untested changes)
- ✅ **Zero regressions** (all 342+ tests must pass)
- ✅ **Document as you go** (update status tracker)

**Time Budget**: 3 hours total (90m + 90m + discussion/testing buffer)

**Ready to Begin!** 🚀