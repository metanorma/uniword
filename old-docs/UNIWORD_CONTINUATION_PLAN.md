# Uniword Development Continuation Plan

**Created**: November 30, 2024
**Current Status**: Namespace refactoring complete, ready for Phase 3 Week 2
**Test Status**: 174 examples, 145 passing, 29 failing (expected)

## Immediate Next Task: Theme Round-Trip Implementation

### Objective
Achieve 100% theme round-trip fidelity by implementing 4 missing DrawingML elements.

### Current State
- ✅ 145/174 tests passing (83%)
- ❌ 29 theme semantic XML equivalence tests failing
- **Root Cause**: Missing 4 DrawingML elements in Theme model

### Required Implementation (5 hours total)

#### Hour 1: ObjectDefaults + ExtraColorSchemeList (Quick Wins)

**1. Create `lib/uniword/object_defaults.rb`** (30 min)
```ruby
module Uniword
  class ObjectDefaults < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'objectDefaults'
      namespace Uniword::Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end

    def initialize(attributes = {})
      super
      @raw_content ||= ''
    end
  end
end
```

**2. Create `lib/uniword/extra_color_scheme_list.rb`** (30 min)
```ruby
module Uniword
  class ExtraColorSchemeList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'extraClrSchemeLst'
      namespace Uniword::Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end

    def initialize(attributes = {})
      super
      @raw_content ||= ''
    end
  end
end
```

#### Hour 2: ExtensionList + Extension (1 hour)

**1. Create `lib/uniword/extension.rb`**
```ruby
module Uniword
  class Extension < Lutaml::Model::Serializable
    attribute :uri, :string
    attribute :raw_content, :string

    xml do
      element 'ext'
      namespace Uniword::Ooxml::Namespaces::DrawingML
      map_attribute 'uri', to: :uri
      map_content to: :raw_content
    end

    def initialize(attributes = {})
      super
      @uri ||= ''
      @raw_content ||= ''
    end
  end
end
```

**2. Create `lib/uniword/extension_list.rb`**
```ruby
module Uniword
  class ExtensionList < Lutaml::Model::Serializable
    attribute :extensions, Extension, collection: true

    xml do
      element 'extLst'
      namespace Uniword::Ooxml::Namespaces::DrawingML
      map_element 'ext', to: :extensions
    end

    def initialize(attributes = {})
      super
      @extensions ||= []
    end
  end
end
```

#### Hour 3: FormatScheme (1 hour)

**Create `lib/uniword/format_scheme.rb`** with style list containers:
```ruby
module Uniword
  class FillStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'fillStyleLst'
      namespace Uniword::Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end
  end

  class LineStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'lnStyleLst'
      namespace Uniword::Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end
  end

  class EffectStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'effectStyleLst'
      namespace Uniword::Ooxml::Namespaces::DrawingML
      map_content to: :raw_content
    end
  end

  class BackgroundFillStyleList < Lutaml::Model::Serializable
    attribute :raw_content, :string

    xml do
      element 'bgFillStyleLst'
      namespace Uniword::Ooxml::Namespaces::DrawingML
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
      namespace Uniword::Ooxml::Namespaces::DrawingML
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

#### Hour 4: Integration into Theme (1 hour)

**Update `lib/uniword/theme.rb`:**

1. Add requires at top:
```ruby
require_relative 'object_defaults'
require_relative 'extra_color_scheme_list'
require_relative 'extension'
require_relative 'extension_list'
require_relative 'format_scheme'
```

2. Update `ThemeElements`:
```ruby
class ThemeElements < Lutaml::Model::Serializable
  attribute :clr_scheme, ColorScheme
  attribute :font_scheme, FontScheme
  attribute :fmt_scheme, FormatScheme  # NEW

  xml do
    element 'themeElements'
    namespace Uniword::Ooxml::Namespaces::DrawingML
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
```

3. Update `Theme`:
```ruby
class Theme < Lutaml::Model::Serializable
  attribute :name, :string, default: -> { 'Office Theme' }
  attribute :theme_elements, ThemeElements
  attribute :object_defaults, ObjectDefaults          # NEW
  attribute :extra_clr_scheme_lst, ExtraColorSchemeList  # NEW
  attribute :ext_lst, ExtensionList                   # NEW

  xml do
    element 'theme'
    namespace Uniword::Ooxml::Namespaces::DrawingML
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
    # ... rest
  end
end
```

4. Test:
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format progress
# Expected: 174/174 passing!
```

#### Hour 5: Documentation (1 hour)

1. Update implementation status tracker
2. Archive old planning docs to `old-docs/phase3/`
3. Update README.adoc if needed

### Success Criteria
- [ ] 174/174 theme tests passing (100%)
- [ ] All 29 themes achieve semantic XML equivalence
- [ ] No regressions in StyleSet tests (168/168 still passing)
- [ ] Total: 342/342 tests passing

## Critical Implementation Rules (Pattern 0)

**YOU MUST FOLLOW THESE RULES:**

1. ✅ **Attributes BEFORE xml mappings** (lutaml-model requirement)
2. ✅ Use `||=` in initialize (preserves lutaml-model values)
3. ✅ Use `mixed_content` for nested elements
4. ✅ ONE namespace per element level
5. ✅ Use `map_content` for raw XML preservation

**Example:**
```ruby
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # ← FIRST

  xml do                       # ← SECOND
    element 'myElement'
    namespace Uniword::Ooxml::Namespaces::DrawingML
    map_element 'child', to: :my_attr
  end
end
```

## Testing Commands

```bash
# Run theme tests
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb --format documentation

# Run all tests
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb --format progress

# Expected after completion:
# 342 examples (168 StyleSet + 174 Theme), 0 failures
```

## Architecture Notes

### Current Status
- ✅ Namespace refactoring complete (`Generated::` removed)
- ✅ Extensions merged into class files
- ✅ 756 generated classes under `lib/uniword/`
- ✅ Clean, flat namespace: `Uniword::Wordprocessingml::*`

### Maintained Principles
- **Object-Oriented**: Every file type is a class
- **MECE**: Mutually Exclusive, Collectively Exhaustive
- **Separation of Concerns**: Models ≠ Packages ≠ Serializers
- **Single Responsibility**: Each class has one job
- **Open/Closed**: Extensible without modification

## Future Work (Post-Theme)

### Week 3: Document Elements (8 files)
- Headers/Footers
- Tables (complex structures)
- Bibliography/TOC
- Watermarks/Equations
- Cover Pages

### Week 4: Final Testing & Documentation
- Comprehensive test suite (all 61 reference files)
- Performance optimization
- Update all documentation
- Prepare for v2.0 release

## Files to Read Before Starting

1. `UNIWORD_NAMESPACE_REFACTORING_COMPLETE.md` - What was just accomplished
2. `.kilocode/rules/memory-bank/context.md` - Current project context
3. `.kilocode/rules/memory-bank/architecture.md` - System architecture
4. `lib/uniword/theme.rb` - Theme class to update
5. `lib/uniword/color_scheme.rb` - Example DrawingML pattern

## Critical Paths

### Theme Model Files
- `lib/uniword/theme.rb` - Main theme class
- `lib/uniword/color_scheme.rb` - Color definitions
- `lib/uniword/font_scheme.rb` - Font definitions
- `lib/uniword/ooxml/theme_package.rb` - Package handling

### Reference Files
- `references/word-package/office-themes/*.thmx` - 29 theme files to support

## Contact & Support

If you encounter issues:
1. Check Pattern 0 compliance (attributes before xml)
2. Verify namespace is `Uniword::Ooxml::Namespaces::DrawingML`
3. Run tests after each change
4. Read error messages carefully (they're usually precise)

## Summary

You are picking up right after a major namespace refactoring. The codebase is clean, tests are passing at expected levels (145/174), and you're ready to implement the final 4 theme elements to achieve 100% round-trip fidelity.

**Estimated time to complete theme round-trip: 5 hours**
**Current blockers: None**
**Prerequisites: All green ✅**

Good luck! 🚀