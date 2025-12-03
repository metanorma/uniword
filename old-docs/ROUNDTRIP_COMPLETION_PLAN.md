# Uniword Complete Round-Trip Fidelity Plan

## Mission

Achieve 100% round-trip fidelity for all reference files:
- StyleSets (12 .dotx files)
- Office Themes (29 .thmx files + 23 color + 25 font XML)
- Document Elements (9 .dotx template files)

**Deadline**: Compressed timeline - complete in 3-4 focused sessions

## Current State (Session End: Nov 28, 2024)

### ✅ Infrastructure Complete
- [Content_Types].xml generation working
- Relationship files (.rels) generation working
- ZIP packaging working
- 28/28 integration tests passing

### ⚠️ Incomplete Round-Trip
- Theme names preserved but color/font schemes not serializing
- StyleSet structure incomplete (missing property mappings)
- Document elements not tested

## Phase 1: Theme Complete Round-Trip (Session 1 - 4 hours)

### Goal
Load any .thmx file → Save → Load → Verify 100% equivalence

### Tasks

#### 1.1 Fix Theme Serialization (2 hours)
**Problem**: Theme model has incomplete lutaml-model XML mappings

**Files to Fix**:
- `lib/uniword/theme.rb` - Add complete XML mappings for ColorScheme, FontScheme
- `lib/uniword/color_scheme.rb` - Ensure all 12 theme colors serialize
- `lib/uniword/font_scheme.rb` - Ensure major/minor fonts serialize

**Implementation**:
```ruby
# lib/uniword/theme.rb
class Theme < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :color_scheme, ColorScheme  # FIRST
  attribute :font_scheme, FontScheme    # FIRST
  
  xml do
    root 'theme'
    namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
    map_attribute 'name', to: :name
    map_element 'themeElements', to: :theme_elements do
      map_element 'clrScheme', to: :color_scheme
      map_element 'fontScheme', to: :font_scheme
    end
  end
end
```

**Success Criteria**:
- Load `references/word-package/office-themes/*.thmx`
- Save to temp file
- Load again
- XML comparison: 95%+ similarity (allowing formatting differences)
- All 12 theme colors preserved
- Major/Minor fonts preserved

#### 1.2 Theme Round-Trip Tests (1 hour)
Create `spec/uniword/theme_roundtrip_spec.rb`:
- Test all 29 .thmx files
- Verify color scheme preservation  
- Verify font scheme preservation
- Verify theme variants work

#### 1.3 Theme Variant Support (1 hour)
Ensure theme variants (variant1, variant2, etc.) round-trip correctly.

**Files**:
- `lib/uniword/theme/theme_variant.rb`
- Test with themes that have multiple variants

## Phase 2: StyleSet Complete Round-Trip (Session 2 - 4 hours)

### Goal
Load any .dotx StyleSet → Save → Load → Verify 100% style preservation

### Tasks

#### 2.1 Complete Style Property Mappings (2.5 hours)
**Problem**: StyleSetXmlParser only parses ~30% of properties

**Files to Fix**:
- `lib/uniword/stylesets/styleset_xml_parser.rb` - Complete all property parsing
- `lib/uniword/properties/paragraph_properties.rb` - Add missing attributes
- `lib/uniword/properties/run_properties.rb` - Add missing attributes
- `lib/uniword/properties/table_properties.rb` - Add missing attributes

**Missing Properties to Add**:

*Paragraph*:
- Line spacing rules (exact, atLeast, auto)
- Widow/orphan control
- Keep with next
- Keep lines together
- Page break before
- Contextual spacing
- Mirror indents
- Text direction
- Outline level

*Run*:
- Text effects (glow, reflection, shadow)
- Ligatures
- Number formatting
- East Asian typography
- Complex script support

*Table*:
- Cell margins
- Cell spacing
- Conditional formatting
- Preferred widths
- Table positioning
- Text wrapping

**Implementation Strategy**:
1. Parse one .dotx style completely
2. Compare original vs saved XML
3. Add missing elements one by one
4. Test after each addition

#### 2.2 StyleSet Serialization (1 hour)
Ensure `StyleSet.to_xml()` produces valid Word-compatible XML

**Files**:
- `lib/uniword/styleset.rb` - Add XML serialization
- `lib/uniword/style.rb` - Ensure complete XML output

#### 2.3 StyleSet Round-Trip Tests (0.5 hours)
Create `spec/uniword/styleset_complete_roundtrip_spec.rb`:
- Test all 12 .dotx files  
- Verify every style preserved
- Verify all properties match

## Phase 3: Document Element Round-Trip (Session 3 - 3 hours)

### Goal
Handle all document element types (tables, headers, footers, equations, etc.)

### Tasks

#### 3.1 Missing Element Support (2 hours)
**Elements to Add**:
- Headers (different for first/odd/even pages)
- Footers (different for first/odd/even pages)
- Watermarks
- Cover pages
- Table of contents
- Bibliographies
- Equations (MathML/OMML)

**Files**:
- `lib/generated/wordprocessingml/` - Ensure generated classes exist
- `lib/uniword/extensions/` - Add convenience methods

#### 3.2 Element Round-Trip Tests (1 hour)
Create `spec/uniword/document_elements_roundtrip_spec.rb`:
- Test each .dotx template
- Verify all elements preserved

## Phase 4: Comprehensive Round-Trip Suite (Session 4 - 2 hours)

### Goal
100% pass rate on all reference files

### Tasks

#### 4.1 Create Master Round-Trip Test (1 hour)
`spec/uniword/complete_roundtrip_spec.rb`:

```ruby
RSpec.describe "Complete Round-Trip Fidelity" do
  describe "StyleSets" do
    Dir.glob('references/word-package/style-sets/*.dotx').each do |file|
      it "round-trips #{File.basename(file)}" do
        # Load → Save → Load → Compare
      end
    end
  end
  
  describe "Themes" do
    Dir.glob('references/word-package/office-themes/*.thmx').each do |file|
      it "round-trips #{File.basename(file)}" do
        # Load → Save → Load → Compare
      end
    end
  end
  
  describe "Document Elements" do
    Dir.glob('references/word-package/document-elements/*.dotx').each do |file|
      it "round-trips #{File.basename(file)}" do
        # Load → Save → Load → Compare
      end
    end
  end
end
```

#### 4.2 Fix All Failures (1 hour)
Iterate until 100% pass rate.

## Success Criteria

### Must Pass Before v1.0 Release

- [ ] **All 29 .thmx files** round-trip with 95%+ XML similarity
- [ ] **All 12 .dotx StyleSet files** round-trip with 95%+ XML similarity
- [ ] **All 9 .dotx document element files** round-trip with 95%+ XML similarity
- [ ] **Color schemes** preserved (all 12 colors)
- [ ] **Font schemes** preserved (major/minor fonts)
- [ ] **Style properties** preserved (paragraph, run, table)
- [ ] **Document structure** preserved (headers, footers, tables, etc.)
- [ ] **Round-trip tests** at 100% pass rate

### Release Blockers

If any of above fail, v1.0 cannot be released.

## Implementation Principles

### 1. Architecture First
- Fix lutaml-model attribute declarations (ALWAYS attributes before xml block)
- Use complete XML namespace mappings
- Follow OOXML specification exactly

### 2. Test-Driven
- Write round-trip test FIRST
- Fix until test passes
- Move to next element

### 3. Incremental
- Fix one property type at a time
- Test after each fix
- Don't move forward until current test passes

### 4. Complete Coverage
- NO partial implementations
- Every OOXML element must have corresponding lutaml-model class
- Generated classes ARE the API

## Timeline Estimate

- **Phase 1 (Themes)**: 4 hours → Theme round-trip complete
- **Phase 2 (StyleSets)**: 4 hours → StyleSet round-trip complete  
- **Phase 3 (Elements)**: 3 hours → Document elements complete
- **Phase 4 (Integration)**: 2 hours → 100% pass rate

**Total**: 13 hours (compressed to 3-4 focused sessions)

## Next Session Start

```bash
cd /Users/mulgogi/src/mn/uniword

# Session 1: Theme Round-Trip
# 1. Fix lib/uniword/theme.rb XML mappings
# 2. Fix lib/uniword/color_scheme.rb
# 3. Fix lib/uniword/font_scheme.rb
# 4. Create spec/uniword/theme_roundtrip_spec.rb
# 5. Test against all 29 .thmx files
# 6. Fix until 100% pass rate

bundle exec rspec spec/uniword/theme_roundtrip_spec.rb
```

## Critical Files Reference

### Theme Files
- `lib/uniword/theme.rb`
- `lib/uniword/color_scheme.rb`
- `lib/uniword/font_scheme.rb`
- `lib/uniword/themes/yaml_theme_loader.rb`
- `lib/uniword/theme/theme_loader.rb`

### StyleSet Files
- `lib/uniword/styleset.rb`
- `lib/uniword/style.rb`
- `lib/uniword/stylesets/styleset_xml_parser.rb`
- `lib/uniword/properties/*.rb`

### Test Files  
- `spec/uniword/theme_roundtrip_spec.rb`
- `spec/uniword/styleset_complete_roundtrip_spec.rb`
- `spec/uniword/document_elements_roundtrip_spec.rb`
- `spec/uniword/complete_roundtrip_spec.rb`