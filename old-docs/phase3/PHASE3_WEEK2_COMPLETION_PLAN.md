# Phase 3 Week 2 Completion Plan: 100% Theme Round-Trip

**Created**: November 30, 2024
**Objective**: Achieve 29/29 theme tests passing (100% round-trip fidelity)
**Strategy**: Model all remaining theme elements (`<fmtScheme>`, `<objectDefaults>`, `<extraClrSchemeLst>`, `<extLst>`)

## Current Status

**Passing**: 145/174 tests (83%)
- ✅ All basic functionality (load, serialize, structure, colors, fonts)
- ❌ Semantic XML equivalence (29/29 failing due to unmodeled elements)

**Root Cause**: Missing models for 4 DrawingML elements in theme1.xml

## Missing Elements Analysis

### 1. FormatScheme (`<fmtScheme>`)
Most complex element - defines fill styles, line styles, effect styles

**XML Structure**:
```xml
<fmtScheme name="Office">
  <fillStyleLst>
    <solidFill>...</solidFill>
    <gradFill>...</gradFill>
    <!-- More fills -->
  </fillStyleLst>
  <lnStyleLst>
    <ln>...</ln>
    <!-- More lines -->
  </lnStyleLst>
  <effectStyleLst>
    <effectStyle>...</effectStyle>
    <!-- More effects -->
  </effectStyleLst>
  <bgFillStyleLst>
    <solidFill>...</solidFill>
    <!-- Background fills -->
  </bgFillStyleLst>
</fmtScheme>
```

**Implementation**: FormatScheme class with nested style lists

### 2. ObjectDefaults (`<objectDefaults>`)
Defines default properties for shapes and text boxes

**XML Structure**:
```xml
<objectDefaults>
  <spDef>
    <spPr/>
    <bodyPr/>
    <lstStyle/>
    <style>...</style>
  </spDef>
  <lnDef>
    <spPr/>
    <bodyPr/>
    <lstStyle/>
    <style>...</style>
  </lnDef>
</objectDefaults>
```

**Implementation**: ObjectDefaults class with ShapeDefaults and LineDefaults

### 3. ExtraColorSchemeList (`<extraClrSchemeLst>`)
Additional color schemes (variants)

**XML Structure**:
```xml
<extraClrSchemeLst>
  <extraClrScheme>
    <clrScheme>...</clrScheme>
    <clrMap>...</clrMap>
  </extraClrScheme>
</extraClrSchemeLst>
```

**Implementation**: ExtraColorSchemeList class (usually empty, just container)

### 4. ExtensionList (`<extLst>`)
Office extensions and metadata

**XML Structure**:
```xml
<extLst>
  <ext uri="{05A4C25C-085E-4340-85A3-A5531E510DB2}">
    <themeFamily name="Wisp" id="..." vid="..."/>
  </ext>
</extLst>
```

**Implementation**: ExtensionList class with Extension items

## Implementation Plan

### Phase 1: Create Base Models (3 hours)

**Priority Order** (implement in this order for quickest test pass):

1. **ObjectDefaults** (30 min)
   - File: `lib/uniword/object_defaults.rb`
   - Simple container, can be empty
   - Gets us closer to XML equivalence

2. **ExtraColorSchemeList** (30 min)
   - File: `lib/uniword/extra_color_scheme_list.rb`
   - Simple container, usually empty
   - Quick win

3. **ExtensionList** (1 hour)
   - File: `lib/uniword/extension_list.rb`
   - File: `lib/uniword/extension.rb`
   - Needs Extension class for items
   - Preserve unknown extension types

4. **FormatScheme** (1 hour)
   - File: `lib/uniword/format_scheme.rb`
   - Most complex, but critical for fidelity
   - Initial implementation can be simple containers

### Phase 2: Integrate into Theme (30 min)

Update [`lib/uniword/theme.rb`](lib/uniword/theme.rb:49):
```ruby
class ThemeElements < Lutaml::Model::Serializable
  attribute :clr_scheme, ColorScheme
  attribute :font_scheme, FontScheme
  attribute :fmt_scheme, FormatScheme  # NEW
  
  xml do
    root 'themeElements'
    namespace Ooxml::Namespaces::DrawingML
    map_element 'clrScheme', to: :clr_scheme
    map_element 'fontScheme', to: :font_scheme
    map_element 'fmtScheme', to: :fmt_scheme  # NEW
  end
end

class Theme < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :theme_elements, ThemeElements
  attribute :object_defaults, ObjectDefaults  # NEW
  attribute :extra_clr_scheme_lst, ExtraColorSchemeList  # NEW
  attribute :ext_lst, ExtensionList  # NEW
  
  xml do
    root 'theme'
    namespace Ooxml::Namespaces::DrawingML
    map_attribute 'name', to: :name
    map_element 'themeElements', to: :theme_elements
    map_element 'objectDefaults', to: :object_defaults  # NEW
    map_element 'extraClrSchemeLst', to: :extra_clr_scheme_lst  # NEW
    map_element 'extLst', to: :ext_lst  # NEW
  end
end
```

### Phase 3: Test & Verify (30 min)

1. Run theme round-trip tests
2. Verify 29/29 semantic XML equivalence passing
3. Ensure no regressions in other 145 tests

### Phase 4: Documentation (1 hour)

1. Update README.adoc with theme architecture
2. Create docs/THEME_ARCHITECTURE.md
3. Archive old documentation to old-docs/

## Implementation Details

### FormatScheme Structure

**Simplified Initial Implementation**:
```ruby
# lib/uniword/format_scheme.rb
module Uniword
  class FormatScheme < Lutaml::Model::Serializable
    attribute :name, :string, default: -> { 'Office' }
    attribute :fill_style_lst, FillStyleList
    attribute :ln_style_lst, LineStyleList
    attribute :effect_style_lst, EffectStyleList
    attribute :bg_fill_style_lst, BackgroundFillStyleList
    
    xml do
      root 'fmtScheme'
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
  
  # Style list containers (can start as simple wrappers)
  class FillStyleList < Lutaml::Model::Serializable
    attribute :raw_xml, :string  # Preserve unknown elements
    
    xml do
      root 'fillStyleLst'
      namespace Ooxml::Namespaces::DrawingML
    end
  end
  
  # Similar for LineStyleList, EffectStyleList, BackgroundFillStyleList
end
```

### ObjectDefaults Structure

```ruby
# lib/uniword/object_defaults.rb
module Uniword
  class ObjectDefaults < Lutaml::Model::Serializable
    attribute :raw_xml, :string  # Preserve content
    
    xml do
      root 'objectDefaults'
      namespace Ooxml::Namespaces::DrawingML
    end
    
    def initialize(attributes = {})
      super
      @raw_xml ||= ''
    end
  end
end
```

### ExtraColorSchemeList Structure

```ruby
# lib/uniword/extra_color_scheme_list.rb
module Uniword
  class ExtraColorSchemeList < Lutaml::Model::Serializable
    attribute :raw_xml, :string
    
    xml do
      root 'extraClrSchemeLst'
      namespace Ooxml::Namespaces::DrawingML
    end
    
    def initialize(attributes = {})
      super
      @raw_xml ||= ''
    end
  end
end
```

### ExtensionList Structure

```ruby
# lib/uniword/extension_list.rb
module Uniword
  class Extension < Lutaml::Model::Serializable
    attribute :uri, :string
    attribute :raw_xml, :string  # Preserve extension content
    
    xml do
      root 'ext'
      namespace Ooxml::Namespaces::DrawingML
      map_attribute 'uri', to: :uri
    end
  end
  
  class ExtensionList < Lutaml::Model::Serializable
    attribute :extensions, Extension, collection: true
    
    xml do
      root 'extLst'
      namespace Ooxml::Namespaces::DrawingML
      map_element 'ext', to: :extensions
    end
    
    def initialize(attributes = {})
      super
      @extensions ||= []
    end
  end
end
```

## Timeline

**Total Time**: ~5 hours

- **Hour 1**: ObjectDefaults + ExtraColorSchemeList (quick wins)
- **Hour 2**: ExtensionList with Extension class
- **Hour 3**: FormatScheme with style list containers
- **Hour 4**: Integration into Theme + testing
- **Hour 5**: Documentation updates + archive old docs

**Completion**: End of Week 2 Day 6 (ahead of schedule!)

## Success Criteria

- [ ] All 4 missing elements modeled
- [ ] Theme class updated with new attributes
- [ ] 174/174 tests passing (100%)
- [ ] 29/29 themes achieve semantic XML equivalence
- [ ] No regressions in existing 168 StyleSet tests
- [ ] Documentation updated
- [ ] Old docs archived

## Next Steps After Completion

With 100% theme round-trip achieved:

1. **Week 3**: Document Elements (8 files)
   - Headers, Footers, Tables, Bibliography, etc.
   
2. **Week 4**: Comprehensive testing + documentation
   - 61/61 files complete
   - Performance optimization
   - Final documentation polish

## Notes

- Pattern 0 applies: Attributes BEFORE xml mappings
- Use `mixed_content` for elements with nested content
- Initialize with `||=` to preserve lutaml-model parsed values
- Prefer simple container classes initially, can enhance later
- Focus on round-trip fidelity, not full feature implementation