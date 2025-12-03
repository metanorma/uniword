# Continue Session 5: DrawingML Expansion + Small Namespaces

## Context

You are continuing Uniword v2.0 development. Session 4 completed the DrawingML namespace foundation with 22 core elements. Now expand DrawingML and add small namespaces.

**Current Status**:
- Progress: 25% (187/760 elements, 3/30 namespaces)
- Completed: WordProcessingML (100), Math (65), DrawingML foundation (22)
- Infrastructure: SchemaLoader, ModelGenerator, autoload pattern - all working perfectly

## Session 5 Objectives

**Target**: Add 80+ elements (DrawingML expansion + 2 small namespaces)
**Duration**: 3 hours
**Expected Progress**: 25% → 35%

### Task 1: Expand DrawingML Schema (+70 elements)

**File**: `config/ooxml/schemas/drawingml.yml`

Add to existing 22 elements:

1. **Gradient Fills (10 elements)**:
   - `gsLst` (GradientStopList) - Container for gradient stops
   - `gs` (GradientStop) - Individual gradient stop with position and color
   - `lin` (LinearGradient) - Linear gradient properties (angle, scaled)
   - `path` (PathGradient) - Path gradient properties
   - `fillToRect` (FillToRect) - Fill to rectangle insets
   - `tileRect` (TileRect) - Tile rectangle
   - `gradFill` (GradientFill) - Gradient fill container
   - `pattFill` (PatternFill) - Pattern fill
   - `fgClr` (ForegroundColor) - Foreground color
   - `bgClr` (BackgroundColor) - Background color

2. **Effects (15 elements)**:
   - `effectLst` (EffectList) - Effect list container
   - `effectDag` (EffectContainer) - Effect DAG container
   - `glow` (Glow) - Glow effect
   - `innerShdw` (InnerShadow) - Inner shadow effect
   - `outerShdw` (OuterShadow) - Outer shadow effect
   - `prstShdw` (PresetShadow) - Preset shadow
   - `reflection` (Reflection) - Reflection effect
   - `softEdge` (SoftEdge) - Soft edge effect
   - `blur` (Blur) - Blur effect
   - `fillOverlay` (FillOverlay) - Fill overlay
   - `duotone` (Duotone) - Duotone effect
   - `alphaBiLevel` (AlphaBiLevel) - Alpha bi-level
   - `alphaModFix` (AlphaModulationFixed) - Fixed alpha modulation
   - `biLevel` (BiLevel) - Bi-level effect
   - `grayscl` (Grayscale) - Grayscale effect

3. **Color Transforms (20 elements)**:
   - `alpha` (Alpha) - Alpha transparency
   - `alphaOff` (AlphaOffset) - Alpha offset
   - `alphaMod` (AlphaModulation) - Alpha modulation
   - `hue` (Hue) - Hue value
   - `hueOff` (HueOffset) - Hue offset
   - `hueMod` (HueModulation) - Hue modulation
   - `sat` (Saturation) - Saturation
   - `satOff` (SaturationOffset) - Saturation offset
   - `satMod` (SaturationModulation) - Saturation modulation
   - `lum` (Luminance) - Luminance
   - `lumOff` (LuminanceOffset) - Luminance offset
   - `lumMod` (LuminanceModulation) - Luminance modulation
   - `red` (Red) - Red component
   - `redOff` (RedOffset) - Red offset
   - `redMod` (RedModulation) - Red modulation
   - `green` (Green) - Green component
   - `blue` (Blue) - Blue component
   - `gamma` (Gamma) - Gamma correction
   - `invGamma` (InverseGamma) - Inverse gamma
   - `tint` (Tint) - Tint
   - `shade` (Shade) - Shade

4. **Additional Shapes & Geometry (10 elements)**:
   - `prstGeom` (PresetGeometry) - Preset geometry shape
   - `custGeom` (CustomGeometry) - Custom geometry
   - `avLst` (AdjustValueList) - Adjustment value list
   - `gd` (GeometryGuide) - Geometry guide
   - `pathLst` (PathList) - Path list
   - `path` (Path) - Geometry path
   - `moveTo` (MoveTo) - Move to command
   - `lnTo` (LineTo) - Line to command
   - `arcTo` (ArcTo) - Arc to command
   - `close` (ClosePath) - Close path

5. **Text Properties (10 elements)**:
   - `lstStyle` (ListStyle) - List style
   - `defPPr` (DefaultParagraphProperties) - Default paragraph properties  
   - `lvl1pPr` through `lvl3pPr` (Level paragraph properties) - 3 elements
   - `pPr` (TextParagraphProperties) - Paragraph properties
   - `rPr` (TextCharacterProperties) - Character properties
   - `latin` (TextFont) - Latin font
   - `ea` (TextFont) - East Asian font
   - `cs` (TextFont) - Complex script font

6. **Line Properties (5 elements)**:
   - `prstDash` (PresetDash) - Preset dash pattern
   - `custDash` (CustomDash) - Custom dash
   - `ds` (DashStop) - Dash stop
   - `round` (LineJoinRound) - Round join
   - `miter` (LineJoinMiter) - Miter join

**Implementation Strategy**:
- Start with current 22 elements in `drawingml.yml`
- Add elements incrementally by category
- Keep each addition < 200 lines to avoid corruption
- Validate after each category addition

### Task 2: Create Picture Namespace (+10 elements)

**File**: `config/ooxml/schemas/picture.yml`

```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/drawingml/2006/picture'
  prefix: 'pic'
  description: 'Picture namespace for embedded images'

elements:
  pic:
    class_name: Picture
    description: 'Picture element'
    attributes:
      - name: nv_pic_pr
        type: NonVisualPictureProperties
        xml_name: nvPicPr
        required: true
        description: 'Non-visual picture properties'
      - name: blip_fill
        type: BlipFill
        xml_name: blipFill
        required: true
        description: 'Picture fill'
      - name: sp_pr
        type: ShapeProperties
        xml_name: spPr
        required: true
        description: 'Shape properties'
  
  # Add 9 more elements...
```

Elements to include:
1. `pic` - Picture element
2. `nvPicPr` - Non-visual picture properties
3. `cNvPicPr` - Non-visual picture drawing props
4. `picLocks` - Picture locks
5. `blipFill` - Picture fill (reference to DrawingML)
6. `blip` - Image reference
7. `srcRect` - Source rectangle
8. `stretch` - Stretch properties
9. `fillRect` - Fill rectangle
10. `tile` - Tile properties

### Task 3: Create Relationships Namespace (+5 elements)

**File**: `config/ooxml/schemas/relationships.yml`

```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
  prefix: 'r'
  description: 'Relationships namespace for document relationships'

elements:
  Relationships:
    class_name: Relationships
    description: 'Relationships root element'
    attributes:
      - name: relationships
        type: Relationship
        collection: true
        xml_name: Relationship
        description: 'Document relationships'
  
  Relationship:
    class_name: Relationship
    description: 'Single relationship'
    attributes:
      - name: id
        type: String
        xml_name: Id
        xml_attribute: true
        required: true
        description: 'Relationship ID'
      - name: type
        type: String
        xml_name: Type
        xml_attribute: true
        required: true
        description: 'Relationship type'
      - name: target
        type: String
        xml_name: Target
        xml_attribute: true
        required: true
        description: 'Target path'
  
  # Add 3 more elements as needed
```

### Task 4: Generate All Classes

Use the proven pattern:

```ruby
# Generate DrawingML (expanded)
require_relative 'lib/uniword/schema/model_generator'
gen = Uniword::Schema::ModelGenerator.new('drawingml')
results = gen.generate_all
puts "Generated #{results.size} DrawingML classes"

# Generate Picture
gen = Uniword::Schema::ModelGenerator.new('picture')
results = gen.generate_all
puts "Generated #{results.size} Picture classes"

# Generate Relationships
gen = Uniword::Schema::ModelGenerator.new('relationships')
results = gen.generate_all
puts "Generated #{results.size} Relationships classes"
```

### Task 5: Create Autoload Indices

**Pattern**: Follow `lib/generated/math.rb` and `lib/generated/drawingml.rb`

Create:
- `lib/generated/picture.rb` - Autoload index for Picture namespace
- `lib/generated/relationships.rb` - Autoload index for Relationships

### Task 6: Test Everything

```ruby
# Test autoload
require_relative 'lib/generated/drawingml'
require_relative 'lib/generated/picture'
require_relative 'lib/generated/relationships'

# Test classes load
puts Uniword::Generated::Drawingml::GradientFill
puts Uniword::Generated::Drawingml::Glow
puts Uniword::Generated::Picture::Picture
puts Uniword::Generated::Relationships::Relationship
```

### Task 7: Update Documentation

1. Update `V2.0_IMPLEMENTATION_STATUS.md`:
   - Progress: 25% → 35%
   - Elements: 187 → 267 (+80)
   - Namespaces: 3 → 5 (+2)

2. Create `SESSION_5_SUMMARY.md` with results

## Critical Reminders

1. **Pattern 0 Compliance**: ALWAYS declare attributes BEFORE xml blocks
2. **File Size Management**: Keep schema files < 500 lines, add incrementally
3. **Type Safety**: Use `String` for undefined types, `Integer` for numbers
4. **Validation**: Test autoload after each namespace
5. **Quality > Speed**: 100% compliance required

## Expected Deliverables

1. ✅ `drawingml.yml` expanded to 92 elements
2. ✅ `picture.yml` created (10 elements)
3. ✅ `relationships.yml` created (5 elements)
4. ✅ 85+ new classes generated
5. ✅ Autoload indices for Picture and Relationships
6. ✅ All tests passing
7. ✅ Documentation updated
8. ✅ SESSION_5_SUMMARY.md created

## Success Criteria

- [ ] DrawingML expanded with 70+ elements
- [ ] Picture namespace complete (10 elements)
- [ ] Relationships namespace complete (5 elements)
- [ ] All classes generated without errors
- [ ] Autoload working for all namespaces
- [ ] Pattern 0 compliance: 100%
- [ ] Zero syntax errors
- [ ] Progress: 35% overall

**Estimated Duration**: 3 hours
**Target Completion**: Day 4

Good luck with Session 5! 🚀