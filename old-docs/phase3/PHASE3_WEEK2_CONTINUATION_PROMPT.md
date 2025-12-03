# Phase 3 Week 2 Continuation: Complete Theme Round-Trip

**Session Start**: Continue from November 30, 2024
**Context**: Package architecture complete, 145/174 tests passing (83%)
**Objective**: Achieve 29/29 theme tests passing (100% round-trip fidelity)

## Quick Status

**Completed** ✅:
- Package architecture (5 classes, 821 lines)
- Theme serialization (ColorScheme, FontScheme working)
- 145/174 tests passing

**Remaining**: 29 failing tests - ALL semantic XML equivalence
**Root Cause**: Missing 4 theme elements not yet modeled

## What to Implement

Model these 4 DrawingML elements for 100% theme fidelity:

1. **ObjectDefaults** (`<objectDefaults/>`) - Shape/line defaults
2. **ExtraColorSchemeList** (`<extraClrSchemeLst/>`) - Color scheme variants
3. **ExtensionList** (`<extLst>`) - Office extensions/metadata
4. **FormatScheme** (`<fmtScheme>`) - Fill/line/effect styles

## Implementation Order (5 hours total)

### Hour 1: Quick Wins

**Step 1: ObjectDefaults** (30 min)
```bash
# Create lib/uniword/object_defaults.rb
```

Simple container class:
```ruby
module Uniword
  class ObjectDefaults < Lutaml::Model::Serializable
    attribute :content, :string

    xml do
      element 'objectDefaults'
      namespace DrawingMLNamespace
      map_content to: :content
    end
  end
end
```

**Step 2: ExtraColorSchemeList** (30 min)
```bash
# Create lib/uniword/extra_color_scheme_list.rb
```

Simple container (usually empty):
```ruby
module Uniword
  class ExtraColorSchemeList < Lutaml::Model::Serializable
    attribute :content, :string

    xml do
      element 'extraClrSchemeLst'
      map_content to: :raw_content
    end
  end
end
```

### Hour 2: Extensions

**Step 3: ExtensionList** (1 hour)
```bash
# Create lib/uniword/extension.rb
# Create lib/uniword/extension_list.rb
```

Extension class:
```ruby
module Uniword
  class Extension < Lutaml::Model::Serializable
    attribute :uri, :string
    attribute :raw_content, :string

    xml do
      element 'ext'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'uri', to: :uri
      map_content to: :raw_content
    end
  end

  class ExtensionList < Lutaml::Model::Serializable
    attribute :extensions, Extension, collection: true

    xml do
      element 'extLst'
      namespace Ooxml::Namespaces::DrawingML
      map_element 'ext', to: :extensions
    end
  end
end
```

### Hour 3: FormatScheme

**Step 4: FormatScheme** (1 hour)
```bash
# Create lib/uniword/format_scheme.rb
```

Format scheme with style lists:
```ruby
module Uniword
  # Style list containers
  class FillStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'fillStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end
  end

  class LineStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'lnStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end
  end

  class EffectStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'effectStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end
  end

  class BackgroundFillStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'bgFillStyleLst'
      namespace Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end
  end

  class FormatScheme < Lutaml::Model::Serializable
    attribute :name, :string, default: -> { 'Office' }
    attribute :fill_style_lst, FillStyleList
    attribute :ln_style_lst, LineStyleList
    attribute :effect_style_lst, EffectStyleList
    attribute :bg_fill_style_lst, BackgroundFillStyleList

    xml do
      element 'fmtScheme'
      namespace Ooxml::Namespaces::DrawingML

      map_attribute 'name', to: :name
      map_element 'fillStyleLst', to: :fill_style_lst
      map_element 'lnStyleLst', to: :ln_style_lst
      map_element 'effectStyleLst', to: :effect_style_lst
      map_element 'bgFillStyleLst', to: :bg_fill_style_lst
    end

    def initialize(attributes = {})
      super
      @fill_style_lst ||= FillStyleList.new
      @ln_style_lst ||= LineStyleList.new
      @effect_style_lst ||= EffectStyleList.new
      @bg_fill_style_lst ||= BackgroundFillStyleList.new
    end
  end
end
```

### Hour 4: Integration

**Step 5: Update Theme** (30 min)

Edit [`lib/uniword/theme.rb`](lib/uniword/theme.rb:8):

```ruby
require_relative 'object_defaults'
require_relative 'extra_color_scheme_list'
require_relative 'extension_list'
require_relative 'format_scheme'

class ThemeElements < Lutaml::Model::Serializable
  # Existing
  attribute :clr_scheme, ColorScheme
  attribute :font_scheme, FontScheme

  # NEW - add this
  attribute :fmt_scheme, FormatScheme

  xml do
    element 'themeElements'
    namespace Ooxml::Namespaces::DrawingML

    map_element 'clrScheme', to: :clr_scheme
    map_element 'fontScheme', to: :font_scheme
    map_element 'fmtScheme', to: :fmt_scheme  # NEW
  end

  def initialize(attributes = {})
    super
    @clr_scheme ||= ColorScheme.new
    @font_scheme ||= FontScheme.new
    @fmt_scheme ||= FormatScheme.new  # NEW
  end
end

class Theme < Lutaml::Model::Serializable
  # Existing
  attribute :name, :string, default: -> { 'Office Theme' }
  attribute :theme_elements, ThemeElements

  # NEW - add these 3
  attribute :object_defaults, ObjectDefaults
  attribute :extra_clr_scheme_lst, ExtraColorSchemeList
  attribute :ext_lst, ExtensionList

  xml do
    element 'theme'
    namespace Ooxml::Namespaces::DrawingML

    map_attribute 'name', to: :name
    map_element 'themeElements', to: :theme_elements
    map_element 'objectDefaults', to: :object_defaults          # NEW
    map_element 'extraClrSchemeLst', to: :extra_clr_scheme_lst  # NEW
    map_element 'extLst', to: :ext_lst                          # NEW
  end

  def initialize(attributes = {})
    super
    @theme_elements ||= ThemeElements.new
    @object_defaults ||= ObjectDefaults.new        # NEW
    @extra_clr_scheme_lst ||= ExtraColorSchemeList.new  # NEW
    @ext_lst ||= ExtensionList.new                # NEW
    # ... rest of existing code
  end
end
```

**Step 6: Test** (30 min)
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb
# Expected: 174/174 passing (100%)
```

### Hour 5: Documentation

**Step 7: Update Status** (30 min)
```bash
# Update PHASE3_IMPLEMENTATION_STATUS.md
# Update .kilocode/rules/memory-bank/context.md
```

**Step 8: Archive Old Docs** (30 min)
```bash
mkdir -p old-docs/phase2 old-docs/phase3
mv PHASE2_*.md old-docs/phase2/
mv PHASE3_SESSION*.md old-docs/phase3/
mv NAMESPACE_*.md old-docs/
```

## Critical Rules (Pattern 0)

**🚨 ALWAYS:**
1. Attributes BEFORE xml mappings
2. Use `||=` in initialize (not `=`)
3. Use `mixed_content` for nested elements
4. One namespace per element level
5. Check with `map_content` for raw XML preservation

## Verification Commands

```bash
# Check all tests
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format documentation

# Confirm StyleSet tests still pass
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb --format progress

# Total test count
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 342 examples (168 StyleSet + 174 Theme), 0 failures
```

## Success Criteria

- [ ] 4 new model files created
- [ ] Theme.rb updated with 3 new attributes
- [ ] ThemeElements updated with 1 new attribute
- [ ] 174/174 theme tests passing
- [ ] 168/168 styleset tests still passing
- [ ] Total: 342/342 tests passing (100%)
- [ ] Status tracker updated
- [ ] Old docs archived

## Expected Output

```
Theme Round-Trip
  Atlas
    loads theme successfully ✓
    serializes theme to valid XML ✓
    round-trips theme preserving structure ✓
    round-trips theme XML semantically equivalent ✓  # Was failing, now passing!
    preserves color scheme colors ✓
    preserves font scheme fonts ✓
  [... 28 more themes, all 6 tests passing ...]

============================================================
Theme Round-Trip Summary
============================================================
Total Themes tested: 29
All tests PASSING! ✅
============================================================

Finished in X seconds
174 examples, 0 failures
```

## After Completion

You will have:
- ✅ 24/24 StyleSets (100%)
- ✅ 29/29 Themes (100%)
- ✅ 53/61 files complete (87%)
- ✅ Package architecture foundation
- ✅ 342/342 tests passing

**Next**: Week 3 - Document Elements (8 files)

## Files to Read

Before starting, read these for context:
1. `PHASE3_WEEK2_COMPLETION_PLAN.md` (detailed implementation plan)
2. `.kilocode/rules/memory-bank/context.md` (current status)
3. `lib/uniword/theme.rb` (Theme class to update)
4. `lib/uniword/color_scheme.rb` (example of DrawingML patterns)

## Start Command

```bash
cd /Users/mulgogi/src/mn/uniword

# Verify current state
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 145/174 passing

# Begin implementation with Hour 1: ObjectDefaults
# Create lib/uniword/object_defaults.rb
```

Good luck! Focus on Pattern 0 compliance and clean separation of concerns. You've got this! 🚀