# Phase 3: Full Round-Trip Implementation Plan

**Objective**: Achieve 100% round-trip fidelity for ALL reference files in `references/word-package/`

**Status**: Phase 2 Complete (24/24 StyleSet .dotx files) ✅  
**Target**: 61 files total (32 .dotx + 29 .thmx)

## Current State (November 29, 2024)

### ✅ Complete (24 files)
- **style-sets/**: 12 .dotx files ✅
- **quick-styles/**: 12 .dotx files ✅
- **Tests**: 168/168 passing
- **Properties Working**: 10 (alignment, font size, color, spacing, indentation, run fonts, style refs, outline level, booleans)

### ⏳ Partial (29 files)
- **office-themes/**: 29 .thmx files (can load, but not full round-trip)
- **Theme Support**: Load from .thmx ✅, Round-trip ⏳

### ❌ Not Started (8 files)
- **document-elements/**: 8 .dotx files (no support)

## Architecture Principles

### 1. Model-Based File Types (NEW)

Each file type MUST be a proper model class with clear responsibilities:

```ruby
# File Type Hierarchy (OOP Architecture)
PackageFile (abstract)
├── DotxPackage < PackageFile
│   ├── StyleSetPackage < DotxPackage
│   ├── DocumentElementPackage < DotxPackage
│   └── QuickStylePackage < DotxPackage
└── ThmxPackage < PackageFile
    └── ThemePackage < ThmxPackage
```

**Responsibilities**:
- **PackageFile**: ZIP extraction, file listing, metadata
- **DotxPackage**: Word template structure (word/styles.xml, word/document.xml)
- **StyleSetPackage**: Styles-focused .dotx (word/styles.xml primary)
- **DocumentElementPackage**: Elements-focused .dotx (headers, footers, etc.)
- **ThmxPackage**: Theme structure (theme/theme1.xml)
- **ThemePackage**: Office theme data model

### 2. Separation of Concerns

**Current Problem**: Classes mix concerns (e.g., StyleSet handles both data model and file loading)

**Solution**: Separate into layers
```
┌─────────────────────────────────┐
│   Models (Domain Layer)         │  <- Theme, StyleSet, Style
├─────────────────────────────────┤
│   Packages (File Layer)         │  <- ThmxPackage, DotxPackage
├─────────────────────────────────┤
│   Loaders (Parsing Layer)       │  <- ThemeLoader, StyleSetLoader
├─────────────────────────────────┤
│   Writers (Serialization Layer) │  <- ThemeWriter, StyleSetWriter
└─────────────────────────────────┘
```

### 3. MECE Package Structure

Each package type has distinct, non-overlapping responsibilities:
- **StyleSetPackage**: Contains style definitions only
- **DocumentElementPackage**: Contains document elements (headers, footers, equations, etc.)
- **ThemePackage**: Contains theme data (colors, fonts)

## Implementation Phases

### Phase 3.1: Property Expansion (Week 1) ⏳

**Goal**: Expand property coverage from 10 to 25+ properties

**Priority Order** (by impact on round-trip fidelity):

#### Simple Element Properties (15 properties, ~2 days)
Each follows the proven pattern (namespaced custom type + wrapper class):

1. **Underline** - `<w:u w:val="single"/>` ✅ DONE
2. **Highlight** - `<w:highlight w:val="yellow"/>` 
3. **VerticalAlign** - `<w:vertAlign w:val="superscript"/>`
4. **Position** - `<w:position w:val="5"/>`
5. **CharacterSpacing** - `<w:spacing w:val="20"/>`
6. **Kerning** - `<w:kern w:val="20"/>`
7. **WidthScale** - `<w:w w:val="150"/>`
8. **EmphasisMark** - `<w:em w:val="dot"/>`
9. **NumberingId** - `<w:numId w:val="1"/>`
10. **NumberingLevel** - `<w:ilvl w:val="0"/>`
11. **KeepNext** - `<w:keepNext/>` (boolean)
12. **KeepLines** - `<w:keepLines/>` (boolean)
13. **PageBreakBefore** - `<w:pageBreakBefore/>` (boolean)
14. **WidowControl** - `<w:widowControl/>` (boolean)
15. **ContextualSpacing** - `<w:contextualSpacing/>` (boolean)

**Implementation Pattern** (10 mins each):
```ruby
# 1. Create lib/uniword/properties/highlight.rb
class HighlightValue < Lutaml::Model::Type::String
  xml_namespace Ooxml::Namespaces::WordProcessingML
end

class Highlight < Lutaml::Model::Serializable
  attribute :value, HighlightValue
  xml do
    element 'highlight'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'val', to: :value
  end
end

# 2. Update run_properties.rb
attribute :highlight, Highlight
map_element 'highlight', to: :highlight, render_nil: false

# 3. Update parser
props.highlight = Properties::Highlight.new(value: highlight['w:val'])
```

#### Complex Properties (5 properties, ~3 days)

1. **Borders** (ParagraphBorder class)
   - `<w:pBdr><w:top/><w:bottom/><w:left/><w:right/></w:pBdr>`
   - 4 border sides, each with style, size, color

2. **Tabs** (TabStops class)
   - `<w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs>`
   - Array of tab stop positions

3. **Shading** (Shading class)
   - `<w:shd w:val="clear" w:color="auto" w:fill="FFFF00"/>`
   - Background fill with pattern

4. **Language** (Language class)
   - `<w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/>`
   - Multi-language support

5. **TextEffects** (TextEffect class)
   - `<w:textFill>`, `<w:textOutline>`, `<w:glow>`
   - Modern Word 2010+ effects

**Expected Outcome**:
- Property coverage: 10 → 25+ properties
- Round-trip accuracy: 85% → 95%
- All 24 StyleSet .dotx files serialize with >95% fidelity

### Phase 3.2: Package Architecture (Week 2)

**Goal**: Create proper model classes for all package types

#### Step 1: Base Package Classes (2 days)

```ruby
# lib/uniword/packages/package_file.rb
class PackageFile < Lutaml::Model::Serializable
  attribute :path, :string
  attribute :entries, :string, collection: true  # ZIP entries
  
  # Abstract methods (implement in subclasses)
  def extract
    raise NotImplementedError
  end
  
  def package
    raise NotImplementedError
  end
end

# lib/uniword/packages/dotx_package.rb
class DotxPackage < PackageFile
  attribute :styles_xml, :string
  attribute :document_xml, :string
  attribute :relationships, Relationships
  attribute :content_types, ContentTypes
  
  def extract
    # ZIP extraction logic
  end
  
  def to_dotx(path)
    # Package back to .dotx
  end
end

# lib/uniword/packages/thmx_package.rb
class ThmxPackage < PackageFile
  attribute :theme_xml, :string
  attribute :relationships, Relationships
  
  def extract
    # ZIP extraction logic
  end
  
  def to_thmx(path)
    # Package back to .thmx
  end
end
```

#### Step 2: Specialized Package Classes (2 days)

```ruby
# lib/uniword/packages/styleset_package.rb
class StyleSetPackage < DotxPackage
  attribute :styleset, StyleSet
  
  def self.from_file(path)
    pkg = new(path: path)
    pkg.extract
    pkg.load_styleset
    pkg
  end
  
  def load_styleset
    xml = read_entry('word/styles.xml')
    @styleset = StyleSetXmlParser.new.parse(xml)
  end
  
  def save_to_file(path)
    update_styles_xml(@styleset.to_xml)
    package_to_dotx(path)
  end
end

# lib/uniword/packages/theme_package.rb
class ThemePackage < ThmxPackage
  attribute :theme, Theme
  
  def self.from_file(path)
    pkg = new(path: path)
    pkg.extract
    pkg.load_theme
    pkg
  end
  
  def load_theme
    xml = read_entry('theme/theme1.xml')
    @theme = Theme.from_xml(xml)
  end
  
  def save_to_file(path)
    update_theme_xml(@theme.to_xml)
    package_to_thmx(path)
  end
end

# lib/uniword/packages/document_element_package.rb
class DocumentElementPackage < DotxPackage
  attribute :elements, Element, collection: true
  attribute :headers, Header, collection: true
  attribute :footers, Footer, collection: true
  
  def self.from_file(path)
    pkg = new(path: path)
    pkg.extract
    pkg.load_elements
    pkg
  end
end
```

**Expected Outcome**:
- Clean separation: Models ≠ Packages ≠ Loaders
- Each file type is a proper class
- Easy to extend for new package types

### Phase 3.3: Theme Round-Trip (Week 2)

**Goal**: Complete theme round-trip for 29 .thmx files

#### Current State Analysis
```ruby
# What works (Phase 1)
theme = Theme.from_thmx('Atlas.thmx')  # ✅ Load
theme.color_scheme  # ✅ Access colors
theme.font_scheme   # ✅ Access fonts

# What doesn't work
theme.to_thmx('output.thmx')  # ❌ No serialization
```

#### Implementation Steps (3 days)

1. **Theme Serialization** (1 day)
   - Implement `Theme#to_xml` (already lutaml-model)
   - Implement `ThemePackage#to_thmx` (package back to ZIP)
   - Handle relationships and content types

2. **Theme Round-Trip Tests** (1 day)
   ```ruby
   # spec/uniword/theme_roundtrip_spec.rb
   describe 'Theme Round-Trip Fidelity' do
     Dir.glob('references/word-package/office-themes/*.thmx').each do |theme_file|
       it "round-trips #{File.basename(theme_file)}" do
         original = ThemePackage.from_file(theme_file)
         
         # Save to temp
         temp_path = "tmp/#{File.basename(theme_file)}"
         original.save_to_file(temp_path)
         
         # Reload
         reparsed = ThemePackage.from_file(temp_path)
         
         # Compare
         expect(reparsed.theme.color_scheme).to eq(original.theme.color_scheme)
         expect(reparsed.theme.font_scheme).to eq(original.theme.font_scheme)
       end
     end
   end
   ```

3. **Theme Validation** (1 day)
   - Ensure all 29 themes round-trip perfectly
   - Handle theme variants (fancy, classic)
   - Preserve unknown XML elements

**Expected Outcome**:
- 29/29 theme .thmx files round-trip ✅
- Tests: 29 examples, 0 failures
- Theme coverage: 100%

### Phase 3.4: Document Elements Support (Week 3)

**Goal**: Add support for 8 document-elements .dotx files

#### Analysis of Document Elements

**Files** (8 total):
1. Bibliographies.dotx - Citation styles
2. Headers.dotx - Header templates
3. Footers.dotx - Footer templates
4. Table of Contents.dotx - TOC styles
5. Watermarks.dotx - Watermark graphics
6. Tables.dotx - Table styles
7. Equations.dotx - Math equation styles
8. Cover Pages.dotx - Cover page templates

**Architecture**:
```ruby
# lib/uniword/document_elements/
├── bibliography.rb        # Citation/bibliography
├── header_template.rb     # Header building blocks
├── footer_template.rb     # Footer building blocks
├── toc_style.rb          # TOC formatting
├── watermark.rb          # Watermark graphics
├── table_template.rb     # Table quick styles
├── equation_style.rb     # Equation formatting
└── cover_page.rb         # Cover page layouts
```

#### Implementation Steps (5 days)

1. **Header/Footer Support** (2 days)
   - Parse header/footer XML from .dotx
   - Model: HeaderDefinition, FooterDefinition
   - Round-trip test

2. **Table Elements** (1 day)
   - Parse table styles
   - Model: TableTemplate with borders, shading
   - Round-trip test

3. **Other Elements** (2 days)
   - Bibliography: CitationStyle model
   - TOC: TocStyle model
   - Watermark: WatermarkGraphic model
   - Equation: EquationStyle model (OMML)
   - Cover Page: CoverPageLayout model

**Expected Outcome**:
- 8/8 document-element .dotx files load ✅
- Basic round-trip (may not be 100% on first pass)
- Foundation for future enhancement

### Phase 3.5: Comprehensive Testing (Week 4)

**Goal**: 100% round-trip fidelity for all 61 files

#### Test Suite Structure

```ruby
# spec/uniword/comprehensive_roundtrip_spec.rb
RSpec.describe 'Comprehensive Round-Trip Fidelity' do
  
  describe 'StyleSets' do
    context 'style-sets/' do
      # 12 .dotx files
    end
    
    context 'quick-styles/' do
      # 12 .dotx files
    end
  end
  
  describe 'Themes' do
    # 29 .thmx files
  end
  
  describe 'Document Elements' do
    # 8 .dotx files
  end
  
  after(:all) do
    puts "\n#{'='*60}"
    puts "Comprehensive Round-Trip Summary"
    puts "#{'='*60}"
    puts "Total files tested: 61"
    puts "  - StyleSets (.dotx): 24"
    puts "  - Themes (.thmx): 29"
    puts "  - Document Elements (.dotx): 8"
    puts "#{'='*60}"
  end
end
```

#### Success Criteria

**Level 1: Basic Round-Trip** (Target: 100%)
- File loads without error
- File serializes without error
- Reloaded file has same structure

**Level 2: Property Preservation** (Target: 95%)
- All implemented properties round-trip exactly
- Unknown properties preserved (stored as raw XML)

**Level 3: Binary Equivalence** (Target: 80%)
- Generated .dotx/.thmx files are identical or semantically equivalent
- Use Canon gem for XML comparison

## Implementation Timeline

### Week 1: Property Expansion
- **Days 1-2**: Simple element properties (15 properties)
- **Days 3-5**: Complex properties (5 properties)
- **Outcome**: 25+ properties, 95% StyleSet fidelity

### Week 2: Architecture & Themes
- **Days 1-2**: Package architecture (base classes)
- **Days 3-5**: Theme round-trip (29 .thmx files)
- **Outcome**: Clean architecture, 29/29 themes ✅

### Week 3: Document Elements
- **Days 1-2**: Header/Footer support
- **Day 3**: Table elements
- **Days 4-5**: Other elements
- **Outcome**: 8/8 element files loading

### Week 4: Testing & Polish
- **Days 1-2**: Comprehensive test suite
- **Days 3-4**: Fix failing tests
- **Day 5**: Documentation update
- **Outcome**: 61/61 files round-trip ✅

## Technical Debt to Address

### 1. YAML Bundle Deserialization
**Problem**: Bundled YAML files use flat attributes (incompatible with new wrapper classes)

**Solution**: 
- Option A: Update YAML files to use wrapper format
- Option B: Add compatibility layer in YAML loader
- Option C: Deprecate YAML bundles (use .dotx/.thmx directly)

**Recommendation**: Option C - Use native Office files

### 2. Raw XML Storage
**Problem**: Some classes store raw XML (violates model-driven architecture)

**Solution**: Model ALL elements (no raw XML storage)
- Unknown elements → UnknownElement class
- Preserve in round-trip via proper modeling

### 3. Namespace Handling
**Current**: Mix of inline namespaces and namespace classes
**Target**: 100% namespace classes (no inline strings)

## Files to Create

### New Property Files (20+ files)
```
lib/uniword/properties/
├── underline.rb ✅
├── highlight.rb
├── vertical_align.rb
├── position.rb
├── character_spacing.rb
├── kerning.rb
├── width_scale.rb
├── emphasis_mark.rb
├── numbering_id.rb
├── numbering_level.rb
├── paragraph_border.rb
├── tab_stops.rb
├── shading.rb
├── language.rb
└── text_effect.rb
```

### New Package Files (8 files)
```
lib/uniword/packages/
├── package_file.rb (abstract)
├── dotx_package.rb
├── thmx_package.rb
├── styleset_package.rb
├── theme_package.rb
├── document_element_package.rb
└── quick_style_package.rb
```

### New Document Element Files (8 files)
```
lib/uniword/document_elements/
├── bibliography.rb
├── header_template.rb
├── footer_template.rb
├── toc_style.rb
├── watermark.rb
├── table_template.rb
├── equation_style.rb
└── cover_page.rb
```

### New Test Files (3 files)
```
spec/uniword/
├── theme_roundtrip_spec.rb
├── document_element_roundtrip_spec.rb
└── comprehensive_roundtrip_spec.rb
```

## Documentation Updates

### README.adoc Updates
- Add comprehensive round-trip section
- Document all 25+ properties
- Add examples for each package type

### New Documentation
```
docs/
├── COMPREHENSIVE_ROUNDTRIP.md
├── PACKAGE_ARCHITECTURE.md
├── PROPERTY_IMPLEMENTATION_GUIDE.md
└── TESTING_STRATEGY.md
```

### Archive Old Docs
```
old-docs/
├── PHASE2_*.md (move completed phase docs)
├── NAMESPACE_*.md (if superseded)
└── *_SESSION*.md (temporary session docs)
```

## Success Metrics

### Quantitative
- ✅ 61/61 files load successfully (100%)
- ✅ 61/61 files round-trip without errors (100%)
- ✅ 25+ properties serialize correctly
- ✅ >95% property preservation in round-trip
- ✅ <500ms average round-trip time per file

### Qualitative
- Clean, MECE architecture (no overlapping responsibilities)
- 100% model-based (no raw XML storage)
- Extensible (easy to add new properties/packages)
- Well-tested (>90% code coverage)
- Well-documented (clear examples for each feature)

## Risk Mitigation

### Risk 1: Property Complexity
**Mitigation**: Implement in priority order (simple first, complex last)

### Risk 2: Unknown OOXML Elements
**Mitigation**: Preserve as UnknownElement objects in round-trip

### Risk 3: Performance
**Mitigation**: Lazy loading, streaming for large files

### Risk 4: Binary Equivalence
**Mitigation**: Use semantic XML comparison (Canon gem), not byte comparison

## Next Steps

1. Review and approve this plan
2. Start Week 1: Property Expansion (Highlight property next)
3. Update memory bank with plan
4. Track progress daily

## References

- Phase 2 Summary: `PHASE2_CONTINUATION_PLAN.md`
- Pattern Guide: `docs/CORRECTED_PROPERTY_SERIALIZATION_PATTERN.md`
- Memory Bank: `.kilocode/rules/memory-bank/`
- Test Files: `references/word-package/`