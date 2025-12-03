# Theme Round-Trip Implementation - Session Continuation Prompt

**Copy this entire section to start the next session**

---

## 🎯 Context

I'm continuing the Theme Round-Trip implementation for the Uniword gem. Phase 1 (Architecture Foundation) is **complete** - all 4 missing theme elements have been created and integrated. We're now in **Phase 2: DrawingML Element Completion**.

**Current Test Status**: 145/174 passing (83%)
**Target**: 174/174 passing (100%)

## 📋 What Was Accomplished

### Phase 1 Complete ✅ (5 hours, November 30, 2024)
- Created 4 missing theme elements: ObjectDefaults, ExtraColorSchemeList, Extension/ExtensionList, FormatScheme
- Integrated all elements into Theme class with proper hierarchy
- Fixed DrawingML type system (Integer/String → :integer/:string in 60+ files)
- Maintained pure model-driven architecture (no raw XML)

**Architecture is solid**. The remaining work is **systematic completion** of existing DrawingML element relationships.

## 🔧 Current Task: Complete DrawingML Element Child Relationships

The DrawingML classes in `lib/uniword/drawingml/` exist as **structural stubs** but need their child element relationships completed. The pattern is established; we just need to execute consistently.

## 📖 Reference Documents

Read these files to understand the full context:
1. `THEME_ROUNDTRIP_CONTINUATION_PLAN.md` - Complete implementation plan (448 lines)
2. `THEME_ROUNDTRIP_STATUS.md` - Detailed status tracker (343 lines)
3. `.kilocode/rules/memory-bank/context.md` - Project context

## 🚀 Immediate Next Actions (Start Here!)

### Priority 1: Complete SchemeColor (2 hours - HIGHEST IMPACT)

**File**: `lib/uniword/drawingml/scheme_color.rb`

**Current State**:
```ruby
class SchemeColor < Lutaml::Model::Serializable
  attribute :val, :string
  # Missing: 10 color modifiers
end
```

**What To Do**:
Add these attributes and mappings (all classes already exist in same directory):
```ruby
attribute :tint, Tint
attribute :shade, Shade
attribute :sat_mod, SaturationModulation
attribute :lum_mod, LuminanceModulation
attribute :alpha, Alpha
attribute :alpha_mod, AlphaModulation
attribute :alpha_off, AlphaOffset
attribute :hue, Hue
attribute :hue_mod, HueModulation
attribute :hue_off, HueOffset

xml do
  element 'schemeClr'
  namespace Uniword::Ooxml::Namespaces::DrawingML
  map_attribute 'val', to: :val
  map_element 'tint', to: :tint, render_nil: false
  map_element 'shade', to: :shade, render_nil: false
  map_element 'satMod', to: :sat_mod, render_nil: false
  map_element 'lumMod', to: :lum_mod, render_nil: false
  map_element 'alpha', to: :alpha, render_nil: false
  map_element 'alphaMod', to: :alpha_mod, render_nil: false
  map_element 'alphaOff', to: :alpha_off, render_nil: false
  map_element 'hue', to: :hue, render_nil: false
  map_element 'hueMod', to: :hue_mod, render_nil: false
  map_element 'hueOff', to: :hue_off, render_nil: false
end
```

**Test After**:
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb[1:2:4]
```

### Priority 2: Complete SolidFill (1 hour)

**File**: `lib/uniword/drawingml/solid_fill.rb`

**Add**:
```ruby
attribute :scheme_clr, SchemeColor
attribute :srgb_clr, SrgbColor

xml do
  element 'solidFill'
  namespace Uniword::Ooxml::Namespaces::DrawingML
  map_element 'schemeClr', to: :scheme_clr, render_nil: false
  map_element 'srgbClr', to: :srgb_clr, render_nil: false
end
```

### Priority 3: Fix FontScheme Empty Attributes (30 min)

**Files**: 
- `lib/uniword/drawingml/east_asian_font.rb`
- `lib/uniword/drawingml/complex_script_font.rb`

**Change**:
```ruby
# Remove from initialize():
@typeface ||= ''  # ❌ DELETE THIS

# Add to xml mapping:
map_attribute 'typeface', to: :typeface, render_nil: false  # ✅ ADD render_nil
```

This fixes `<ea typeface=""/>` → `<ea/>`.

## 🧪 Testing Strategy

### After Each Change:
```bash
# Quick test (one theme)
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb[1:2:4]

# Full test (all themes)
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress
```

### Expected Progress:
- After SchemeColor: ~155/174 passing (10+ more passing)
- After SolidFill: ~160/174 passing
- After FontScheme fix: ~165/174 passing

## 🗺️ Implementation Roadmap

### Day 1 (6 hours)
1. ✅ Hour 1-2: SchemeColor + modifiers
2. ✅ Hour 3: SolidFill colors
3. □ Hour 4-5: GradientFill + GradientStop
4. □ Hour 6: LineProperties basics

### Day 2 (6 hours)
5. □ Hour 1-2: Complete LineProperties
6. □ Hour 3-5: 3D Effect elements (scene3d, camera, etc.)
7. □ Hour 6: FontScheme fix

### Day 3 (4 hours)
8. □ Hour 1: Full test run + analysis
9. □ Hour 2-3: Debug remaining failures
10. □ Hour 4: Documentation + verification

## ⚠️ Critical Patterns to Follow

### Pattern 0: Attributes BEFORE XML (ALWAYS!)
```ruby
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # ← FIRST
  
  xml do                       # ← SECOND
    element 'myElement'
    map_element 'child', to: :my_attr
  end
end
```

### Pattern 1: render_nil for Optional Elements
```ruby
map_element 'optional', to: :optional_attr, render_nil: false
```

### Pattern 2: All Types Use Symbols
```ruby
attribute :name, :string   # ✅ Correct
attribute :count, :integer # ✅ Correct
attribute :obj, MyClass    # ✅ Correct for custom types
```

### Pattern 3: No Default Empty Strings
```ruby
def initialize
  super
  # DON'T: @typeface ||= ''
  # DO: Let lutaml-model handle nil/unset
end
```

## 💡 Tips for Success

### When Adding Child Elements:
1. Check if the child class exists in `lib/uniword/drawingml/`
2. Add attribute BEFORE xml block (Pattern 0!)
3. Add map_element with `render_nil: false`
4. Test immediately

### When Debugging:
1. Look at actual theme XML: `unzip -p references/word-package/office-themes/Badge.thmx theme/theme/theme1.xml`
2. Compare with our model structure
3. Add missing elements following the pattern

### When Stuck:
1. Re-read the continuation plan
2. Look at similar working elements (ColorScheme is a good example)
3. Run tests frequently to catch issues early

## 📊 Progress Tracking

Update `THEME_ROUNDTRIP_STATUS.md` after completing each task:
```markdown
#### Task 1.1: SchemeColor Modifiers (2 hours)
**Status**: ✅ Complete  # Change from ⏳ Pending

**Checklist**:
- [x] Add `tint` attribute and mapping  # Mark as done
...
```

## 🎯 Success Criteria

### You'll Know You're Done When:
- ✅ All 174 theme tests passing (100%)
- ✅ No regressions in StyleSet tests (168/168 still passing)
- ✅ All themes semantically equivalent to originals
- ✅ Following all patterns (Pattern 0, render_nil, etc.)
- ✅ Documentation updated

## 🆘 If You Need Help

### Common Issues:

**Issue**: "undefined method `cast' for class Integer"
**Solution**: Change `Integer` to `:integer` in attribute

**Issue**: Empty attributes serializing `<ea typeface=""/>`
**Solution**: Add `render_nil: false` and remove default empty string

**Issue**: Element not appearing in XML
**Solution**: Check Pattern 0 - attributes must be BEFORE xml block

## 📁 Key File Locations

```
lib/uniword/
├── theme.rb                    # Main Theme class (modified in Phase 1)
├── format_scheme.rb           # Created in Phase 1
├── extension.rb               # Created in Phase 1
└── drawingml/
    ├── scheme_color.rb        # ← START HERE (Priority 1)
    ├── solid_fill.rb         # ← NEXT (Priority 2)
    ├── gradient_fill.rb      # Priority 3
    ├── line_properties.rb    # Priority 4
    └── (60+ other files)     # All exist, need connections

spec/uniword/
└── theme_roundtrip_spec.rb   # 174 tests (145 passing currently)
```

## 🔄 Workflow

```bash
# 1. Start session
cd /Users/mulgogi/src/mn/uniword

# 2. Check current status
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress | grep -E "(examples|failures)"

# 3. Edit file
code lib/uniword/drawingml/scheme_color.rb

# 4. Make changes following patterns

# 5. Test
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb[1:2:4]

# 6. If passing, move to next file

# 7. Repeat until 174/174 passing
```

## 📦 Deliverables

When Phase 2 is complete, you should have:
1. All DrawingML element relationships complete
2. 174/174 tests passing
3. `THEME_ROUNDTRIP_STATUS.md` updated to 100%
4. Memory bank updated with completion status

---

## 🚀 START HERE

```bash
cd /Users/mulgogi/src/mn/uniword
code lib/uniword/drawingml/scheme_color.rb

# Follow the Priority 1 instructions above
# Test after each change
# Move systematically through priorities
```

Good luck! The foundation is solid, now just execute the plan. 🎯