# Continue Round-Trip Work - Session Prompt

## Context

You are working on Uniword v1.0, a Ruby library for Word documents. The infrastructure is complete (28/28 integration tests passing) but **v1.0 CANNOT be released** until we achieve 100% round-trip fidelity for:

- **29 .thmx theme files** in `references/word-package/office-themes/`
- **12 .dotx StyleSet files** in `references/word-package/style-sets/`
- **9 .dotx document element files** in `references/word-package/document-elements/`

**Total**: 50 files must round-trip perfectly.

## Current State

**What's Working** ✅:
- Document creation and manipulation
- Basic formatting (bold, italic, size, font, color)
- OOXML infrastructure ([Content_Types].xml, .rels)
- 28/28 integration tests passing
- 760 OOXML elements generated from schemas

**What's Broken** 🔴:
- **Theme serialization**: Names preserved but ColorScheme/FontScheme don't serialize to XML
- **StyleSet properties**: Only 30-40% of properties parsed/serialized
- **Document elements**: Headers, footers, equations, etc. not tested for round-trip

## Your Mission: Phase 1 - Theme Round-Trip

**Goal**: Make all 29 .thmx files round-trip with 100% XML similarity except for cosmetic whitespaces.

The DOTX files are Word Template files that are ZIP archives containing XML files.

The THMX .thmx files are also ZIP archives containing theme XML files.

### Step 1: Fix Theme XML Serialization (2 hours)

**Problem**: The Theme model has incomplete lutaml-model XML mappings.

**Current state** (checking with test):
```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec ruby -c "lib/uniword/theme.rb"
```

**Files to fix**:

1. **`lib/uniword/theme.rb`** - Main theme class
   - 🚨 **CRITICAL RULE**: Attributes MUST be declared BEFORE xml block!
   - Add `themeElements` wrapper
   - Add `clrScheme` (color scheme) mapping
   - Add `fontScheme` (font scheme) mapping

2. **`lib/uniword/color_scheme.rb`** - 12 theme colors
   - Must serialize all 12 colors: dk1, lt1, dk2, lt2, accent1-6, hlink, folHlink
   - Support both sysClr and srgbClr color types

3. **`lib/uniword/font_scheme.rb`** - Major/minor fonts
   - majorFont with latin, ea, cs scripts
   - minorFont with latin, ea, cs scripts

**Example fix** (for theme.rb):
```ruby
class DrawingMl::Namespace < Lutaml::Model::XmlNamespace
  uri 'http://schemas.openxmlformats.org/drawingml/2006/main'
  prefix_default 'a'
end

class ThemeElements < Lutaml::Model::Serializable
  attribute :color_scheme, ColorScheme
  attribute :font_scheme, FontScheme

  xml do
    element 'themeElements'
    namespace DrawingMl::Namespace

    map_element 'clrScheme', to: :color_scheme
    map_element 'fontScheme', to: :font_scheme
  end
end

class Theme < Lutaml::Model::Serializable
  # ATTRIBUTES FIRST! (Pattern 0)
  attribute :name, :string
  attribute :color_scheme, ColorScheme
  attribute :font_scheme, FontScheme
  attribute :theme_elements, ThemeElements, collection: true

  # XML mappings AFTER attributes
  xml do
    element 'theme'
    namespace DrawingMl::Namespace
    map_attribute 'name', to: :name

    # Add themeElements wrapper
    map_element 'themeElements', to: :theme_elements
  end
end
```

### Step 2: Create Theme Round-Trip Test (1 hour)

Create `spec/uniword/theme_roundtrip_spec.rb`:

```ruby
require 'spec_helper'
require 'canon'

RSpec.describe "Theme Round-Trip Fidelity" do
  let(:themes_dir) { 'references/word-package/office-themes' }
  let(:temp_dir) { 'tmp/theme_roundtrip' }

  before(:all) do
    FileUtils.mkdir_p('tmp/theme_roundtrip')
  end

  Dir.glob('references/word-package/office-themes/*.thmx').each do |theme_file|
    describe File.basename(theme_file) do
      it "round-trips successfully" do
        # Load theme
        theme1 = Uniword::Themes::ThemeLoader.new.load(theme_file)

        # Save to temp
        temp_file = File.join(temp_dir, File.basename(theme_file))
        # TODO: Implement theme.save(path)

        # Load again
        theme2 = Uniword::Themes::ThemeLoader.new.load(temp_file)

        # Compare
        expect(theme2.name).to eq(theme1.name)
        expect(theme2.color_scheme).to_not be_nil
        expect(theme2.font_scheme).to_not be_nil

        # Color scheme comparison
        if theme1.color_scheme
          expect(theme2.color_scheme.colors.keys).to match_array(theme1.color_scheme.colors.keys)
        end

        # Font scheme comparison
        if theme1.font_scheme
          expect(theme2.font_scheme.major_font).to eq(theme1.font_scheme.major_font)
          expect(theme2.font_scheme.minor_font).to eq(theme1.font_scheme.minor_font)
        end
      end
    end
  end
end
```

Run with:
```bash
bundle exec rspec spec/uniword/theme_roundtrip_spec.rb -fd
```

### Step 3: Fix Until All Pass (1 hour)

**Process**:
1. Run test
2. Note which theme fails
3. Check what's missing in XML
4. Add missing attribute/mapping
5. Run test again
6. Repeat until 29/29 pass

**Debugging**:
```bash
# Extract and view theme XML
unzip -p <theme.thmx> theme/theme1.xml | xmllint --format -

# Compare original vs saved
diff <(unzip -p original.thmx theme/theme1.xml) \
     <(unzip -p saved.thmx theme/theme1.xml)
```

## Success Criteria for Session 1

By end of session:
- [ ] `lib/uniword/theme.rb` has complete XML mappings
- [ ] `lib/uniword/color_scheme.rb` serializes all 12 colors
- [ ] `lib/uniword/font_scheme.rb` serializes major/minor fonts
- [ ] `spec/uniword/theme_roundtrip_spec.rb` created
- [ ] **29/29 .thmx files pass round-trip test**

## After Session 1

Update `ROUNDTRIP_IMPLEMENTATION_STATUS.md`:
- Mark Phase 1 as ✅ Complete
- Update test counts (29/29)
- Note any issues found

Then move to Session 2 (StyleSet round-trip).

## Reference Documents

- **Plan**: `ROUNDTRIP_COMPLETION_PLAN.md` - Full 4-phase plan
- **Status**: `ROUNDTRIP_IMPLEMENTATION_STATUS.md` - Current progress tracker
- **This file**: Continuation prompt for next session

## Critical Architecture Principles

### Pattern 0: Lutaml-Model Attributes FIRST
```ruby
# ✅ CORRECT
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # FIRST

  xml do
    map_element 'elem', to: :my_attr  # AFTER
  end
end

# ❌ WRONG - Will NOT serialize!
class MyClass < Lutaml::Model::Serializable
  xml do
    map_element 'elem', to: :my_attr
  end
  attribute :my_attr, MyType  # Too late!
end
```

### MECE Architecture
- Each class has ONE responsibility
- No overlap between classes
- Complete coverage of OOXML spec

### Test-Driven
- Write test FIRST
- Fix until test passes
- Don't move forward until passing

## Commands to Start

```bash
cd /Users/mulgogi/src/mn/uniword

# Check current state
bundle exec rspec spec/uniword/v2_integration_spec.rb  # Should be 28/28

# Start Phase 1
# 1. Edit lib/uniword/theme.rb
# 2. Edit lib/uniword/color_scheme.rb
# 3. Edit lib/uniword/font_scheme.rb
# 4. Create spec/uniword/theme_roundtrip_spec.rb
# 5. Run tests

bundle exec rspec spec/uniword/theme_roundtrip_spec.rb -fd
```

## Questions to Ask

Before starting, verify:
1. Are all memory bank files read? (Check `.kilocode/rules/memory-bank/`)
2. Do you understand the Pattern 0 requirement? (Attributes before XML)
3. Do you have access to the 29 .thmx files in `references/`?

## Expected Timeline

- **Hours 1-2**: Fix Theme, ColorScheme, FontScheme classes
- **Hour 3**: Create round-trip test
- **Hour 4**: Debug and fix until 29/29 pass

**Total**: 4 hours to complete Phase 1

---

**Ready to start? Begin with**: `lib/uniword/theme.rb`