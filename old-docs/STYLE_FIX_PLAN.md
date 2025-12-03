# Style Issues Fix Plan

## Executive Summary

The generated document `examples/demo_formal_integral.docx` has multiple style-related issues. Analysis reveals that the root cause is **the Style model lacks formatting property storage and serialization**. Our Style class only stores metadata (id, type, name) but not actual OOXML formatting properties (font size, alignment, colors, spacing, etc.).

**Issues Found:** 6 critical issues
**Root Cause:** Incomplete Style model implementation
**Impact:** Styles have no visual effect; documents rely on direct formatting

---

## Issue 1: Missing Date Style

### Root Cause
The Date style does not exist in the Formal StyleSet YAML file (`data/stylesets/formal.yml`).

### Current Behavior
- **Broken Doc:** Missing Date style (line 235 of analysis)
- **Proper Doc:** Has Date style (line 595)
- **StyleSet:** Missing Date style (line 936)
- Line 19 of demo script uses `style: 'Date'` but style doesn't exist
- Falls back to Normal style with manual italic formatting

### Expected Behavior
The Date style should be included in the Formal StyleSet with appropriate formatting properties.

### Fix Location
- **File:** `data/stylesets/formal.yml`
- **Lines:** Add after line 250

### Fix Approach
Add Date style definition to `formal.yml`:

```yaml
- id: Date
  type: paragraph
  name: Date
  based_on: Normal
  next_style: Normal
  linked_style: DateChar
  quick_format: true
- id: DateChar
  type: character
  name: Date Char
  custom: true
  based_on: DefaultParagraphFont
  linked_style: Date
```

**Note:** This only adds the style definition. Properties must be added separately (see Issue 2).

---

## Issue 2: Style Model Lacks Formatting Properties

### Root Cause
The [`Style`](lib/uniword/style.rb:10) class only stores metadata:
- Lines 41-68: Only id, type, name, default, custom, based_on, next_style, linked_style, ui_priority, quick_format
- **Missing:** Paragraph properties (alignment, spacing, indentation)
- **Missing:** Character properties (font, size, bold, italic, color)
- **Missing:** Run properties storage and serialization

### Current Behavior
Styles exist but have no formatting effect. Examples from analysis:

**Title Style (lines 100-102 vs 398-407):**
- **Broken:** Has NO font size, NO alignment, NO colors
- **Proper:** Font Size 44, Alignment center, Color #134163, Spacing Before 500, After 300

**Subtitle Style (lines 104-106 vs 408-415):**
- **Broken:** Has NO font size, NO alignment
- **Proper:** Font Size 18, Alignment center, Spacing After 560

**Heading1 Style (lines 21-28 vs 329-336):**
- **Broken:** Font Size 32, Font Calibri, Bold (generic defaults)
- **Proper:** Font Size 28, Alignment center, Color #134163 (theme-based), Spacing Before 400

### Expected Behavior
Style objects should store and serialize all OOXML formatting properties:

```ruby
# Paragraph properties
- alignment (w:jc/@w:val)
- spacing_before (w:spacing/@w:before)
- spacing_after (w:spacing/@w:after)
- line_spacing (w:spacing/@w:line)
- indentation (w:ind)

# Character/Run properties
- font_name (w:rFonts/@w:ascii)
- font_size (w:sz/@w:val)
- bold (w:b)
- italic (w:i)
- color (w:color/@w:val or @w:themeColor)
- underline (w:u)
```

### Fix Location
- **File:** [`lib/uniword/style.rb`](lib/uniword/style.rb:1)
- **Lines:** 40-68 (add new attributes)
- **Lines:** 93-114 (modify `effective_properties` and `own_properties`)

### Fix Approach

#### Step 1: Extend Style Model

Add formatting properties to Style class:

```ruby
# Paragraph formatting properties
attribute :alignment, :string  # left, center, right, both
attribute :spacing_before, :integer  # in twips (1/1440 inch)
attribute :spacing_after, :integer
attribute :line_spacing, :integer
attribute :line_spacing_rule, :string  # auto, exact, atLeast

# Character/Run formatting properties
attribute :font_name, :string
attribute :font_size, :integer  # in half-points (22 = 11pt)
attribute :bold, :boolean
attribute :italic, :boolean
attribute :color, :string  # hex color or theme reference
attribute :theme_color, :string  # accent1, dk1, etc.

# Additional paragraph properties
attribute :indentation_left, :integer
attribute :indentation_right, :integer
attribute :indentation_first_line, :integer
```

#### Step 2: Update YAML Serialization

Add to yaml block (line 27-38):

```ruby
yaml do
  # ... existing mappings ...
  map 'alignment', to: :alignment
  map 'spacing_before', to: :spacing_before
  map 'spacing_after', to: :spacing_after
  map 'line_spacing', to: :line_spacing
  map 'font_name', to: :font_name
  map 'font_size', to: :font_size
  map 'bold', to: :bold
  map 'italic', to: :italic
  map 'color', to: :color
  map 'theme_color', to: :theme_color
end
```

#### Step 3: Update own_properties Method

```ruby
def own_properties
  props = {}

  # Paragraph properties
  props[:alignment] = alignment if alignment
  props[:spacing_before] = spacing_before if spacing_before
  props[:spacing_after] = spacing_after if spacing_after
  props[:line_spacing] = line_spacing if line_spacing

  # Character properties
  props[:font_name] = font_name if font_name
  props[:font_size] = font_size if font_size
  props[:bold] = bold unless bold.nil?
  props[:italic] = italic unless italic.nil?
  props[:color] = color if color
  props[:theme_color] = theme_color if theme_color

  props
end
```

---

## Issue 3: StyleSet YAML Files Missing Properties

### Root Cause
The StyleSet YAML files in `data/stylesets/` only store metadata, not formatting properties.

Looking at `data/stylesets/formal.yml`:
- Lines 11-23 (Heading1): Only has id, type, name, based_on, linked_style
- **Missing:** Font size, alignment, color, spacing from actual Formal.dotx StyleSet

### Current Behavior
StyleSets load successfully but provide no visual formatting because properties are missing.

### Expected Behavior
YAML files should include all formatting properties extracted from .dotx files.

### Fix Location
- **Files:** All files in `data/stylesets/`
- **Primary:** [`data/stylesets/formal.yml`](data/stylesets/formal.yml:1)

### Fix Approach

#### Step 1: Re-import StyleSets with Properties

Update `bin/import_stylesets.rb` (needs to be created or existing import tool) to extract and save formatting properties:

```ruby
# For each style in .dotx:
style_data = {
  'id' => style_id,
  'type' => type,
  'name' => name,
  # Add formatting properties
  'alignment' => extract_alignment(style),
  'spacing_before' => extract_spacing_before(style),
  'spacing_after' => extract_spacing_after(style),
  'font_size' => extract_font_size(style),
  'color' => extract_color(style),
  # ... etc
}
```

#### Step 2: Update formal.yml

After re-import, `data/stylesets/formal.yml` should look like:

```yaml
- id: Title
  type: paragraph
  name: Title
  based_on: Normal
  next_style: Normal
  linked_style: TitleChar
  quick_format: true
  alignment: center
  spacing_before: 500
  spacing_after: 300
  line_spacing: 240
  font_size: 44
  theme_color: accent2  # Maps to theme colors

- id: Subtitle
  type: paragraph
  name: Subtitle
  based_on: Normal
  next_style: Normal
  linked_style: SubtitleChar
  quick_format: true
  alignment: center
  spacing_after: 560
  line_spacing: 240
  font_size: 18
```

---

## Issue 4: Style Properties Not Written to Document XML

### Root Cause
When styles are applied to a document, their formatting properties are not serialized to `word/styles.xml`.

Current serialization only writes metadata. From analysis (lines 100-127 of broken doc):
- Title, Subtitle, and other styles have NO properties in the XML
- Only id, name, basedOn are written

### Current Behavior
Styles are referenced by paragraphs but provide no formatting because the style definitions in `word/styles.xml` are empty.

### Expected Behavior
Style definitions should contain complete `<w:pPr>` and `<w:rPr>` sections with all formatting properties.

### Fix Location
- **File:** Style serialization code (likely in document serialization)
- **Need to locate:** Where Style objects are serialized to XML

### Fix Approach

#### Step 1: Add XML Serialization to Style

Update [`lib/uniword/style.rb`](lib/uniword/style.rb:14) XML mapping:

```ruby
xml do
  root 'style'
  namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

  # ... existing mappings ...

  # Paragraph properties container
  map_element 'pPr', to: :paragraph_properties,
    prefix: 'w',
    namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

  # Run properties container
  map_element 'rPr', to: :run_properties,
    prefix: 'w',
    namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
end
```

#### Step 2: Create Property Objects

Define ParagraphProperties and RunProperties classes to hold and serialize formatting:

```ruby
class ParagraphProperties < Lutaml::Model::Serializable
  xml do
    root 'pPr'
    namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

    map_element 'jc', to: :alignment
    map_element 'spacing', to: :spacing
    map_element 'ind', to: :indentation
  end

  attribute :alignment, AlignmentType
  attribute :spacing, SpacingType
  attribute :indentation, IndentationType
end
```

#### Step 3: Generate Property Objects from Attributes

Add method to Style:

```ruby
def paragraph_properties
  return nil unless paragraph_style?

  props = ParagraphProperties.new
  props.alignment = AlignmentType.new(val: alignment) if alignment
  props.spacing = SpacingType.new(
    before: spacing_before,
    after: spacing_after,
    line: line_spacing
  ) if spacing_before || spacing_after || line_spacing

  props
end

def run_properties
  props = RunProperties.new
  props.fonts = FontsType.new(ascii: font_name) if font_name
  props.size = SizeType.new(val: font_size) if font_size
  props.bold = BooleanType.new if bold
  props.italic = BooleanType.new if italic
  props.color = ColorType.new(val: color, theme_color: theme_color) if color || theme_color

  props
end
```

---

## Issue 5: Paragraph Style Application Uses Direct Formatting

### Root Cause
Because styles lack properties, the code compensates with direct formatting.

From analysis (lines 246-269):
- **Paragraph 1 (Title):** Style reference exists BUT Direct Alignment: center added
- **Paragraph 2 (Subtitle):** Style reference exists BUT Direct Alignment: center added
- **Paragraph 3:** No style, Direct Alignment + Run italic formatting

### Current Behavior
Documents use a mix of style references AND direct formatting, defeating the purpose of styles.

### Expected Behavior
Style reference alone should provide all formatting; no direct formatting needed.

### Fix Location
- **File:** Paragraph/Run creation code
- **Likely:** Builder DSL implementation

### Fix Approach

Once Issues 2-4 are fixed (styles have properties and serialize correctly), remove direct formatting workarounds. The style reference alone will provide formatting.

**No code changes needed** - this is a consequence of fixing Issues 2-4.

---

## Issue 6: Missing ListBullet Style in StyleSet

### Root Cause
The Formal StyleSet YAML doesn't include the ListBullet style, but the proper document has it.

From analysis:
- Line 987: Proper doc has ListBullet style
- Line 936: StyleSet missing Date style
- Not in `data/stylesets/formal.yml`

### Current Behavior
Bullet lists cannot use proper styling; manual bullet characters used (line 70-74 of demo).

### Expected Behavior
StyleSet should include ListBullet style for proper list formatting.

### Fix Location
- **File:** [`data/stylesets/formal.yml`](data/stylesets/formal.yml:250)

### Fix Approach

Add to formal.yml:

```yaml
- id: ListBullet
  type: paragraph
  name: List Bullet
  based_on: Normal
  next_style: ListBullet
  quick_format: true
  # Properties to be added after Issue 2/3 fixes
```

---

## Implementation Priority

### Phase 1: Core Infrastructure (Issues 2, 4)
1. Extend Style model with formatting properties
2. Implement property serialization to XML
3. Test style roundtrip: load .dotx → save → verify XML

**Reason:** Without this foundation, other fixes have no effect.

### Phase 2: Data Layer (Issues 3, 1, 6)
1. Update StyleSet importer to extract properties from .dotx
2. Re-import all StyleSets with complete properties
3. Add missing Date and ListBullet styles

**Reason:** Requires Phase 1 to be complete for property extraction to work.

### Phase 3: Cleanup (Issue 5)
1. Remove direct formatting workarounds
2. Verify demo script produces correct output
3. Document style usage patterns

**Reason:** Automatic once Phases 1-2 complete.

---

## Verification Steps

After all fixes:

1. **Run Analysis Again:**
   ```bash
   ruby analyze_style_comparison.rb > style_comparison_fixed.txt
   ```

2. **Compare Style Definitions:**
   - Broken vs Proper: Should show matching properties
   - Title: Font Size 44, Alignment center, etc.
   - Subtitle: Font Size 18, Alignment center, etc.

3. **Check Document Structure:**
   - No direct formatting in paragraphs 1-4
   - Style references provide all formatting
   - Date style successfully applied

4. **Visual Verification:**
   - Open in Microsoft Word
   - Title should be large, centered, colored
   - Subtitle should be medium, centered
   - Date should be italic
   - All through style definitions, not direct formatting

---

## Estimated Effort

- **Issue 2 (Style Model):** 4-6 hours
  - Define properties: 1 hour
  - Implement serialization: 2-3 hours
  - Test roundtrip: 1-2 hours

- **Issue 4 (XML Serialization):** 3-4 hours
  - Property objects: 2 hours
  - Integration testing: 1-2 hours

- **Issue 3 (Re-import StyleSets):** 2-3 hours
  - Update importer: 1 hour
  - Re-import all: 1 hour
  - Verify: 1 hour

- **Issues 1, 6 (Missing Styles):** 30 minutes
  - Add to YAML: 15 min
  - Test: 15 min

- **Issue 5 (Cleanup):** 1 hour
  - Remove workarounds: 30 min
  - Test: 30 min

**Total:** 11-15 hours

---

## Dependencies

```
Issue 2 (Style Model with Properties)
    ↓
Issue 4 (XML Serialization)
    ↓
Issue 3 (StyleSet Re-import)
    ↓
Issues 1, 6 (Missing Styles)
    ↓
Issue 5 (Remove Direct Formatting)
```

All issues depend on completing Issue 2 first.

---

## Related Files

### Core Implementation
- [`lib/uniword/style.rb`](lib/uniword/style.rb:1) - Style model
- [`lib/uniword/styleset.rb`](lib/uniword/styleset.rb:1) - StyleSet model
- [`lib/uniword/stylesets/yaml_styleset_loader.rb`](lib/uniword/stylesets/yaml_styleset_loader.rb:1) - YAML loader

### Data Files
- [`data/stylesets/formal.yml`](data/stylesets/formal.yml:1) - Formal StyleSet data
- All files in `data/stylesets/` - Other StyleSets

### Test/Demo Files
- [`examples/demo_formal_integral.rb`](examples/demo_formal_integral.rb:1) - Demo script
- `analyze_style_comparison.rb` - Analysis tool

### Reference Files
- `examples/demo_formal_integral.docx` - Broken output
- `examples/demo_formal_integral_proper.docx` - Correct reference
- `references/word-package/style-sets/Formal.dotx` - Source StyleSet