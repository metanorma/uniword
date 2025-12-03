# Docx-js Feature Parity Analysis

**Date**: 2025-10-25
**Uniword Version**: 1.1.0-dev
**Reference**: dolanmiu/docx (docx-js) library

## Executive Summary

Docx-js is primarily a **document creation library** (not reading/editing), focused on browser and Node.js environments. Uniword provides **70%+ feature parity** for document creation, with key gaps in:
- Math/equations (critical for v1.1)
- Paragraph borders
- Advanced text formatting (highlight, emphasis marks)
- Table shading and advanced borders

**Key Insight**: docx-js complements docx gem - docx gem focuses on reading/editing, docx-js on creation. Uniword aims to be a **superset of both**.

**Status Legend**:
- ✅ **Implemented** - Feature exists and works
- ⚠️ **Partial** - Feature partially implemented
- ❌ **Missing** - Feature not yet implemented
- 🎯 **Priority** - Should implement

---

## 1. Document Structure

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Sections | ✅ Multiple sections | ✅ Multiple sections | ✅ | - |
| Page size | ✅ Width/height | ✅ Via section properties | ✅ | - |
| Orientation | ✅ Portrait/Landscape | ✅ Via section properties | ✅ | - |
| Margins | ✅ Top/bottom/left/right | ✅ Via section properties | ✅ | - |
| Headers/Footers | ✅ Per section | ✅ Per section | ✅ | - |
| Page numbers | ✅ Fields support | ✅ Fields support | ✅ | - |
| Page borders | ✅ Full support | ❌ | ❌ | 🎯 **MEDIUM** |

---

## 2. Math/Equations (CRITICAL GAP)

docx-js has **comprehensive math support** via Office MathML components.

### Math Components in docx-js

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Math container | `Math` | ❌ | ❌ | 🎯 **CRITICAL** |
| Math runs | `MathRun` | ❌ | ❌ | 🎯 **CRITICAL** |
| Fractions | `MathFraction` | ❌ | ❌ | 🎯 **CRITICAL** |
| Radicals/Roots | `MathRadical` | ❌ | ❌ | 🎯 **CRITICAL** |
| Superscript | `MathSuperScript` | ❌ | ❌ | 🎯 **CRITICAL** |
| Subscript | `MathSubScript` | ❌ | ❌ | 🎯 **CRITICAL** |
| Sub-Superscript | `MathSubSuperScript` | ❌ | ❌ | 🎯 **CRITICAL** |
| Sum (Σ) | `MathSum` | ❌ | ❌ | 🎯 **HIGH** |
| Functions | `MathFunction` | ❌ | ❌ | 🎯 **HIGH** |
| Brackets | `MathSquareBrackets`, `MathRoundBrackets`, etc. | ❌ | ❌ | 🎯 **HIGH** |
| Limits | `MathLimitUpper`, `MathLimitLower` | ❌ | ❌ | 🎯 **MEDIUM** |

**Implementation Strategy**: Use **Plurimath** gem to convert LaTeX/MathML/AsciiMath to Office MathML.

```ruby
# Proposed API
equation = Uniword::Equation.new
equation.from_latex("\\frac{1}{2} + \\sqrt{x}")
# or
equation.from_mathml("<math><mfrac>...</mfrac></math>")
# or
equation.from_asciimath("1/2 + sqrt(x)")

para = Uniword::Paragraph.new
para.add_equation(equation)
```

---

## 3. Paragraph Features

### Basic Formatting

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Text content | ✅ | ✅ | ✅ | - |
| Alignment | ✅ | ✅ | ✅ | - |
| Spacing before/after | ✅ | ✅ | ✅ | - |
| Line spacing | ✅ | ✅ | ✅ | - |
| Indentation | ✅ | ✅ | ✅ | - |
| Keep next | ✅ | ✅ | ✅ | - |
| Keep lines together | ✅ | ✅ | ✅ | - |
| Page break before | ✅ | ✅ | ✅ | - |
| Widow control | ✅ | ⚠️ | ⚠️ | 🎯 **LOW** |

### Advanced Features

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| **Paragraph borders** | ✅ Top/bottom/left/right | ❌ | ❌ | 🎯 **HIGH** |
| Contextual spacing | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |
| Bullet/numbered lists | ✅ Comprehensive | ✅ Good support | ✅ | - |
| Numbering instances | ✅ Sequential | ⚠️ Basic | ⚠️ | 🎯 **MEDIUM** |
| Tab stops | ✅ | ✅ | ✅ | - |

**Implementation for Paragraph Borders**:
```ruby
class Uniword::Properties::ParagraphProperties
  attribute :borders, ParagraphBorders
end

class Uniword::ParagraphBorders < Lutaml::Model::Serializable
  attribute :top, Border
  attribute :bottom, Border
  attribute :left, Border
  attribute :right, Border
end
```

---

## 4. Text Run Features

### Basic Formatting

| Feature | docx-js | Uniword | Status | Notes |
|---------|---------|---------|--------|-------|
| Bold | ✅ | ✅ | ✅ | - |
| Italic | ✅ | ✅ | ✅ | - |
| Underline | ✅ Multiple styles | ✅ Multiple styles | ✅ | - |
| Font | ✅ | ✅ | ✅ | - |
| Size | ✅ | ✅ | ✅ | - |
| Color | ✅ | ✅ | ✅ | - |

### Advanced Formatting

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| **Highlighting** | ✅ Colors (yellow, green, etc.) | ❌ | ❌ | 🎯 **HIGH** |
| Strike-through | ✅ Single | ✅ | ✅ | - |
| **Double strike** | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |
| Superscript | ✅ | ✅ | ✅ | - |
| Subscript | ✅ | ✅ | ✅ | - |
| **Small caps** | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |
| **All caps** | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |
| **Emphasis mark** | ✅ | ❌ | ❌ | 🎯 **LOW** |
| **Shading** | ✅ Pattern/color/fill | ⚠️ Basic | ⚠️ | 🎯 **MEDIUM** |
| Vanish/SpecVanish | ✅ | ❌ | ❌ | 🎯 **LOW** |
| **Character spacing** | ✅ | ⚠️ Via properties | ⚠️ | 🎯 **LOW** |
| Text scaling | ✅ | ❌ | ❌ | 🎯 **LOW** |
| **Run borders** | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |

**Implementation for Highlighting**:
```ruby
class Uniword::Properties::RunProperties
  attribute :highlight, :string  # "yellow", "green", "cyan", etc.
end
```

**Implementation for Text Caps**:
```ruby
class Uniword::Properties::RunProperties
  attribute :small_caps, :boolean, default: -> { false }
  attribute :all_caps, :boolean, default: -> { false }
  attribute :double_strike, :boolean, default: -> { false }
end
```

---

## 5. Table Features

### Basic Structure

| Feature | docx-js | Uniword | Status | Notes |
|---------|---------|---------|--------|-------|
| Tables | ✅ | ✅ | ✅ | - |
| Rows | ✅ | ✅ | ✅ | - |
| Cells | ✅ | ✅ | ✅ | - |
| Nested tables | ✅ | ✅ | ✅ | - |

### Table Properties

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Width | ✅ DXA/Percentage/Auto | ✅ | ✅ | - |
| Indent | ✅ | ⚠️ | ⚠️ | 🎯 **LOW** |
| Alignment | ✅ | ✅ | ✅ | - |
| **Visual RTL** | ✅ | ❌ | ❌ | 🎯 **LOW** |
| Layout | ✅ Auto-fit | ⚠️ | ⚠️ | 🎯 **MEDIUM** |
| **Floating tables** | ✅ | ❌ | ❌ | 🎯 **LOW** |

### Row Properties

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Height | ✅ With rules | ⚠️ | ⚠️ | 🎯 **MEDIUM** |
| Can't split | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |
| Table header (repeat) | ✅ | ⚠️ | ⚠️ | 🎯 **MEDIUM** |

### Cell Properties

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Width | ✅ | ✅ | ✅ | - |
| **Shading** | ✅ Pattern/color/fill | ⚠️ Basic | ⚠️ | 🎯 **HIGH** |
| **Margins** | ✅ Top/bottom/left/right | ❌ | ❌ | 🎯 **HIGH** |
| **Vertical align** | ✅ Top/center/bottom | ❌ | ❌ | 🎯 **HIGH** |
| Row span | ✅ | ✅ | ✅ | - |
| Column span | ✅ | ✅ | ✅ | - |
| **Borders** | ✅ Comprehensive | ⚠️ Basic | ⚠️ | 🎯 **HIGH** |

**Implementation for Cell Features**:
```ruby
class Uniword::Properties::TableCellProperties
  attribute :shading, Shading
  attribute :margins, CellMargins
  attribute :vertical_align, :string  # "top", "center", "bottom"
end

class Uniword::CellMargins < Lutaml::Model::Serializable
  attribute :top, :integer
  attribute :bottom, :integer
  attribute :left, :integer
  attribute :right, :integer
end
```

---

## 6. Images

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Insert image | ✅ | ✅ | ✅ | - |
| **Image transformation** | ✅ Width/height | ⚠️ Basic | ⚠️ | 🎯 **MEDIUM** |
| Image scaling | ✅ | ⚠️ | ⚠️ | 🎯 **MEDIUM** |
| Image rotation | ✅ | ❌ | ❌ | 🎯 **LOW** |
| Floating images | ✅ | ❌ | ❌ | 🎯 **LOW** |
| Image in table | ✅ | ✅ | ✅ | - |

**Implementation**:
```ruby
class Uniword::Image
  attribute :transformation, ImageTransformation
end

class Uniword::ImageTransformation < Lutaml::Model::Serializable
  attribute :width, :integer   # in pixels or points
  attribute :height, :integer
  attribute :rotation, :integer  # degrees
end
```

---

## 7. Lists and Numbering

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Bullet lists | ✅ | ✅ | ✅ | - |
| Numbered lists | ✅ | ✅ | ✅ | - |
| Custom formats | ✅ Extensive | ✅ Good | ✅ | - |
| **Numbering instances** | ✅ Sequential/restart | ⚠️ | ⚠️ | 🎯 **MEDIUM** |
| **Start values** | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |
| Multi-level | ✅ | ✅ | ✅ | - |
| Custom indents | ✅ | ✅ | ✅ | - |

**Implementation for Sequential Numbering**:
```ruby
# docx-js allows:
numbering: {
  reference: "my-list",
  level: 0,
  instance: 2  # Restart numbering
}

# Uniword should support:
para.set_numbering(num_id: 1, level: 0, instance: 2)
```

---

## 8. Fields and Dynamic Content

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| Page numbers | ✅ | ✅ | ✅ | - |
| Date/time | ✅ | ✅ | ✅ | - |
| **Sequential identifiers** | ✅ For captions | ❌ | ❌ | 🎯 **MEDIUM** |
| Hyperlinks | ✅ | ✅ | ✅ | - |
| Bookmarks | ✅ | ✅ | ✅ | - |
| Cross-references | ✅ | ⚠️ | ⚠️ | 🎯 **LOW** |

---

## 9. Advanced Features

| Feature | docx-js | Uniword | Status | Priority |
|---------|---------|---------|--------|----------|
| **Text boxes** | ✅ | ❌ | ❌ | 🎯 **LOW** |
| **Text frames** | ✅ | ❌ | ❌ | 🎯 **LOW** |
| **Template documents** | ✅ Use existing docx | ⚠️ Via patcher | ⚠️ | 🎯 **MEDIUM** |
| Symbols | ✅ | ⚠️ | ⚠️ | 🎯 **LOW** |
| Table of contents | ✅ | ❌ | ❌ | 🎯 **MEDIUM** |
| Footnotes | ✅ | ✅ | ✅ | - |
| Endnotes | ✅ | ✅ | ✅ | - |
| Comments | ✅ | ✅ | ✅ | - |
| **Change tracking** | ✅ | ✅ | ✅ | - |

---

## 10. Features Uniword Has (Advantages)

| Feature | Uniword | docx-js | Advantage |
|---------|---------|---------|-----------|
| **Reading documents** | ✅ Full support | ❌ None | Major advantage |
| **Editing documents** | ✅ Full support | ⚠️ Via patcher | Major advantage |
| **MHTML support** | ✅ Read/Write | ❌ None | Unique feature |
| **Theme extraction** | ✅ Full support | ⚠️ Limited | Better integration |
| **Document validation** | ✅ Built-in validators | ❌ None | Quality assurance |
| **Type safety** | ✅ Lutaml::Model | ⚠️ TypeScript (in TS) | Robust in Ruby |

---

## 11. Implementation Priority

### Phase 3: Equations (CRITICAL - Already Planned)
1. ✅ Math container and components
2. ✅ Integration with Plurimath gem
3. ✅ LaTeX input support
4. ✅ MathML input support
5. ✅ AsciiMath input support
6. ✅ Display vs inline equations

**Estimated Effort**: 3-4 days

### Phase 5: Enhanced Tables (HIGH PRIORITY)
1. ✅ Cell shading with patterns
2. ✅ Cell margins (top/bottom/left/right)
3. ✅ Vertical alignment in cells
4. ✅ Comprehensive border styles
5. ✅ Row height with rules
6. ✅ Can't split rows
7. ✅ Table header (repeat on pages)

**Estimated Effort**: 2-3 days

### Additional Features (MEDIUM PRIORITY)
1. ✅ Paragraph borders (top/bottom/left/right)
2. ✅ Text highlighting (colors)
3. ✅ Small caps / All caps
4. ✅ Double strike-through
5. ✅ Run borders
6. ✅ Image transformation
7. ✅ Numbering instances
8. ✅ Contextual spacing

**Estimated Effort**: 2-3 days

### Nice-to-Have Features (LOW PRIORITY)
1. ⚠️ Text boxes
2. ⚠️ Text frames
3. ⚠️ Table of contents
4. ⚠️ Floating tables
5. ⚠️ Page borders
6. ⚠️ Sequential identifiers for captions
7. ⚠️ Template document support

**Estimated Effort**: 3-5 days

---

## 12. API Comparison

### docx-js (Creation-Focused)

```typescript
const doc = new Document({
  sections: [{
    children: [
      new Paragraph({
        text: "Hello",
        border: {
          top: { color: "auto", size: 6, style: BorderStyle.SINGLE }
        }
      }),
      new Math({
        children: [
          new MathFraction({
            numerator: [new MathRun("1")],
            denominator: [new MathRun("2")]
          })
        ]
      })
    ]
  }]
});
```

### Uniword (Read/Write-Focused with Builder)

```ruby
doc = Uniword::Document.new

# Current API
para = Uniword::Paragraph.new
para.add_text("Hello")
doc.add_element(para)

# Proposed enhanced API for parity
para = Uniword::Paragraph.new
para.add_text("Hello")
para.set_border(top: { color: "auto", size: 6, style: "single" })
doc.add_element(para)

# Equation support (to add)
equation = Uniword::Equation.new
equation.from_latex("\\frac{1}{2}")
para.add_equation(equation)
```

---

## 13. Compatibility Test Plan

Create test suite at `spec/compatibility/docx_js_features_spec.rb`:

```ruby
describe 'docx-js Feature Compatibility' do
  describe 'Math/Equations' do
    it "supports math fractions" do
      eq = Uniword::Equation.new
      eq.from_latex("\\frac{1}{2}")

      para = Uniword::Paragraph.new
      para.add_equation(eq)

      expect(para.equations.count).to eq(1)
    end

    it "supports radicals/square roots" do
      eq = Uniword::Equation.new
      eq.from_latex("\\sqrt{x}")

      expect(eq.to_mathml).to include("msqrt")
    end
  end

  describe 'Paragraph borders' do
    it "supports top and bottom borders" do
      para = Uniword::Paragraph.new
      para.set_border(
        top: { color: "auto", size: 6, style: "single" },
        bottom: { color: "auto", size: 6, style: "single" }
      )

      expect(para.properties.borders.top).not_to be_nil
      expect(para.properties.borders.bottom).not_to be_nil
    end
  end

  describe 'Text highlighting' do
    it "supports text highlighting colors" do
      run = Uniword::Run.new(text: "Highlighted")
      run.properties = Uniword::Properties::RunProperties.new(
        highlight: "yellow"
      )

      expect(run.properties.highlight).to eq("yellow")
    end
  end

  describe 'Table cell features' do
    it "supports cell vertical alignment" do
      cell = Uniword::TableCell.new
      cell.properties = Uniword::Properties::TableCellProperties.new(
        vertical_align: "center"
      )

      expect(cell.properties.vertical_align).to eq("center")
    end

    it "supports cell margins" do
      cell = Uniword::TableCell.new
      cell.properties.margins = Uniword::CellMargins.new(
        top: 100, bottom: 100, left: 100, right: 100
      )

      expect(cell.properties.margins.top).to eq(100)
    end
  end

  describe 'Image transformation' do
    it "supports image width and height" do
      image = Uniword::Image.new
      image.transformation = Uniword::ImageTransformation.new(
        width: 250, height: 250
      )

      expect(image.transformation.width).to eq(250)
    end
  end
end
```

---

## 14. Conclusion

**Uniword already provides 70%+ of docx-js creation capabilities**, with these key advantages:

✅ **Reading & Editing**: Full document reading/editing (docx-js can't read)
✅ **MHTML Support**: Additional format support
✅ **Comments & Track Changes**: Already implemented
✅ **Type Safety**: Robust model-based architecture

**To achieve 90%+ compatibility**, implement:

### Critical (Phase 3 - Planned)
1. Math/Equations with Plurimath integration

### High Priority (Phase 5 - Planned)
2. Enhanced table features (shading, margins, vertical align)
3. Comprehensive border support

### Medium Priority (Post v1.1)
4. Paragraph borders
5. Text highlighting and advanced formatting
6. Image transformation
7. Numbering instances

**Estimated Total Effort**: 7-10 days for 90% parity

**Result**: Uniword becomes the **most comprehensive Ruby Word library**, combining:
- **docx gem's** reading/editing capabilities
- **docx-js's** creation features
- **Unique features** (MHTML, themes, validators)