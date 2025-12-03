# Word Theme Technical Analysis

## Executive Summary

This document provides a detailed technical analysis of Word theme files (.thmx), their structure, the ISO 29500 (Office Open XML) specifications for themes, and how uniword should implement theme support to enable users to apply pre-built Office themes to generated documents.

## Understanding .thmx Files

### File Format

.thmx files are **ZIP archives** (not CAB files as initially suspected) that follow the Office Open XML package structure. They can be extracted using standard ZIP tools.

**Key Insight**: Since .thmx files are ZIP archives, uniword can leverage the existing [`ZipExtractor`](../lib/uniword/infrastructure/zip_extractor.rb:19) infrastructure without additional dependencies.

### Package Structure

A typical .thmx file contains:

```
Atlas.thmx/
├── [Content_Types].xml          # Package content types
├── _rels/
│   └── .rels                    # Package relationships
└── theme/
    ├── theme1.xml               # Main theme definition
    └── themeVariant/            # Optional variants directory
        ├── variant1.xml         # e.g., "fancy" variant
        ├── variant2.xml         # e.g., "simple" variant
        └── ...
```

### Content Types

From analysis of Office Theme .thmx files, the `[Content_Types].xml` defines:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Override PartName="/theme/theme1.xml"
            ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
</Types>
```

## Theme XML Structure (ISO 29500)

### Namespace

All theme elements use the DrawingML namespace:

```xml
xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
```

### Root Element: <a:theme>

```xml
<a:theme name="Atlas" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
  <a:themeElements>
    <!-- Color scheme -->
    <!-- Font scheme -->
    <!-- Format scheme (effects) -->
  </a:themeElements>
  <a:objectDefaults>
    <!-- Optional: Default object formatting -->
  </a:objectDefaults>
  <a:extraClrSchemeLst>
    <!-- Optional: Additional color schemes -->
  </a:extraClrSchemeLst>
</a:theme>
```

### Color Scheme Structure

The color scheme defines 12 standard theme colors as per ISO 29500-1:

```xml
<a:clrScheme name="Atlas">
  <!-- Dark colors (backgrounds) -->
  <a:dk1>
    <a:sysClr val="windowText" lastClr="000000"/>
  </a:dk1>
  <a:lt1>
    <a:sysClr val="window" lastClr="FFFFFF"/>
  </a:lt1>

  <!-- Accent colors (backgrounds) -->
  <a:dk2><a:srgbClr val="44546A"/></a:dk2>
  <a:lt2><a:srgbClr val="E7E6E6"/></a:lt2>

  <!-- Accent colors (theme colors) -->
  <a:accent1><a:srgbClr val="4472C4"/></a:accent1>
  <a:accent2><a:srgbClr val="ED7D31"/></a:accent2>
  <a:accent3><a:srgbClr val="A5A5A5"/></a:accent3>
  <a:accent4><a:srgbClr val="FFC000"/></a:accent4>
  <a:accent5><a:srgbClr val="5B9BD5"/></a:accent5>
  <a:accent6><a:srgbClr val="70AD47"/></a:accent6>

  <!-- Hyperlink colors -->
  <a:hlink><a:srgbClr val="0563C1"/></a:hlink>
  <a:folHlink><a:srgbClr val="954F72"/></a:folHlink>
</a:clrScheme>
```

#### Color Representation Types

Colors in themes can be represented in multiple ways:

1. **RGB Color** (`srgbClr`): Direct RGB value
   ```xml
   <a:srgbClr val="4472C4"/>
   ```

2. **System Color** (`sysClr`): Reference to system color with last known value
   ```xml
   <a:sysClr val="windowText" lastClr="000000"/>
   ```

3. **Scheme Color** (`schemeClr`): Reference to another theme color
   ```xml
   <a:schemeClr val="accent1"/>
   ```

4. **Preset Color** (`prstClr`): Named color
   ```xml
   <a:prstClr val="black"/>
   ```

#### Color Transformations

Colors can have transformations applied:

```xml
<a:srgbClr val="4472C4">
  <a:tint val="60000"/>      <!-- Lighten by 60% -->
  <a:shade val="50000"/>     <!-- Darken by 50% -->
  <a:satMod val="150000"/>   <!-- Increase saturation by 50% -->
</a:srgbClr>
```

### Font Scheme Structure

The font scheme defines major (headings) and minor (body) fonts for multiple scripts:

```xml
<a:fontScheme name="Atlas">
  <a:majorFont>
    <!-- Latin script (default) -->
    <a:latin typeface="Calibri Light" panose="020F0302020204030204"/>

    <!-- East Asian scripts -->
    <a:ea typeface=""/>

    <!-- Complex scripts (RTL languages) -->
    <a:cs typeface=""/>

    <!-- Script-specific fonts -->
    <a:font script="Jpan" typeface="游ゴシック Light"/>
    <a:font script="Hang" typeface="맑은 고딕"/>
    <a:font script="Hans" typeface="等线"/>
    <a:font script="Hant" typeface="新細明體"/>
    <a:font script="Arab" typeface="Times New Roman"/>
    <!-- ... more scripts -->
  </a:majorFont>

  <a:minorFont>
    <a:latin typeface="Calibri" panose="020F0502020204030204"/>
    <!-- Similar structure for minor fonts -->
  </a:minorFont>
</a:fontScheme>
```

#### Script Codes (ISO 15924)

Common script codes used in font schemes:

- `Jpan` - Japanese
- `Hang` - Korean (Hangul)
- `Hans` - Simplified Chinese
- `Hant` - Traditional Chinese
- `Arab` - Arabic
- `Hebr` - Hebrew
- `Thai` - Thai
- `Cyrl` - Cyrillic
- `Grek` - Greek
- `Latn` - Latin (default, not explicitly specified)

### Format Scheme (Effects)

The format scheme defines fill styles, line styles, and effect styles:

```xml
<a:fmtScheme name="Atlas">
  <a:fillStyleLst>
    <!-- Defines 3 background fills -->
    <a:solidFill>
      <a:schemeClr val="phClr"/>
    </a:solidFill>
    <a:gradFill rotWithShape="1">
      <!-- Gradient definition -->
    </a:gradFill>
    <a:gradFill rotWithShape="1">
      <!-- Another gradient -->
    </a:gradFill>
  </a:fillStyleLst>

  <a:lnStyleLst>
    <!-- Defines 3 line styles -->
    <a:ln w="9525" cap="flat" cmpd="sng" algn="ctr">
      <a:solidFill>
        <a:schemeClr val="phClr">
          <a:shade val="95000"/>
          <a:satMod val="105000"/>
        </a:schemeClr>
      </a:solidFill>
      <a:prstDash val="solid"/>
    </a:ln>
    <!-- More line styles -->
  </a:lnStyleLst>

  <a:effectStyleLst>
    <!-- Defines 3 effect styles (shadows, glows, reflections) -->
    <a:effectStyle>
      <a:effectLst>
        <a:outerShdw blurRad="40000" dist="20000" dir="5400000" rotWithShape="0">
          <a:srgbClr val="000000">
            <a:alpha val="38000"/>
          </a:srgbClr>
        </a:outerShdw>
      </a:effectLst>
    </a:effectStyle>
    <!-- More effect styles -->
  </a:effectStyleLst>

  <a:bgFillStyleLst>
    <!-- Background fills -->
  </a:bgFillStyleLst>
</a:fmtScheme>
```

## Theme Variants

### What are Theme Variants?

Theme variants are **style variations** of a base theme that modify how the theme is applied without changing the core color and font schemes. For example, the "Atlas" theme might have variants like:

- **Default**: Standard application
- **Fancy**: More decorative, with additional effects
- **Simple**: Minimal, clean look
- **Modern**: Contemporary styling

### Variant File Structure

Variant files are located in `theme/themeVariant/` and are named arbitrarily (e.g., `variant1.xml`, `variant2.xml`).

```xml
<a:themeVariant name="Fancy"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
  <!-- Variant-specific overrides -->
  <a:varClrScheme>
    <!-- Color overrides -->
  </a:varClrScheme>

  <a:fmtScheme>
    <!-- Format scheme overrides -->
  </a:fmtScheme>
</a:themeVariant>
```

### How Variants Work

1. **Base Theme**: Provides the foundation (colors, fonts, basic effects)
2. **Variant**: Overrides specific formatting aspects
3. **Application**: Word applies base theme + variant to create final appearance

## Theme Application in Word Documents

### Document-Theme Relationship

When a theme is applied to a Word document:

1. **Theme File Reference**: Document stores theme in `word/theme/theme1.xml`
2. **Style References**: Paragraph and character styles reference theme colors/fonts
3. **Direct Formatting**: Elements can directly reference theme colors

### Theme Color References in Styles

Example of a style using theme colors:

```xml
<w:style w:type="paragraph" w:styleId="Heading1">
  <w:name w:val="Heading 1"/>
  <w:rPr>
    <w:color w:val="accent1" w:themeColor="accent1"/>
    <w:sz w:val="32"/>
    <w:rFonts w:asciiTheme="majorHAnsi" w:eastAsiaTheme="majorEastAsia"/>
  </w:rPr>
</w:style>
```

Key attributes:
- `w:themeColor="accent1"` - References theme color
- `w:asciiTheme="majorHAnsi"` - References theme font (major font, Latin script)

### Theme Font References

Theme fonts are referenced using special attributes:

- `w:asciiTheme` - Theme font for ASCII characters
- `w:eastAsiaTheme` - Theme font for East Asian characters
- `w:hAnsiTheme` - Theme font for high ANSI characters
- `w:cstheme` - Theme font for complex scripts

Values:
- `majorHAnsi`, `majorEastAsia`, `majorBidi`, `majorAscii` - Major (heading) fonts
- `minorHAnsi`, `minorEastAsia`, `minorBidi`, `minorAscii` - Minor (body) fonts

## Mapping: .thmx File → Word Document

### Process Flow

```
1. User provides .thmx file path
        ↓
2. Extract .thmx ZIP archive
        ↓
3. Read theme/theme1.xml
        ↓
4. Parse theme definition (colors, fonts, effects)
        ↓
5. Read theme/themeVariant/*.xml (if variant specified)
        ↓
6. Apply variant overrides to base theme
        ↓
7. Create Theme model
        ↓
8. Update document styles to reference theme
        ↓
9. Write theme to word/theme/theme1.xml in output document
```

### Style Conversion Strategy

When applying a theme, uniword needs to:

1. **Update Built-in Styles**: Modify Heading 1, Heading 2, etc. to use theme colors/fonts
2. **Create Theme References**: Replace direct color values with theme color references
3. **Set Font References**: Replace direct font names with theme font references

Example conversion:

**Before (direct formatting):**
```xml
<w:rPr>
  <w:color w:val="4472C4"/>
  <w:rFonts w:ascii="Calibri Light"/>
</w:rPr>
```

**After (theme reference):**
```xml
<w:rPr>
  <w:color w:val="4472C4" w:themeColor="accent1"/>
  <w:rFonts w:asciiTheme="majorHAnsi"/>
</w:rPr>
```

## Reference Document Analysis

### File: namespace_demo_with_atlas_theme_variant_fancy.docx

This reference document provides a real example of:

1. **Theme Application**: How Atlas theme with "fancy" variant appears in a document
2. **Style Integration**: How document styles reference the theme
3. **Package Structure**: Proper OOXML package structure with theme

To analyze this document, uniword should:

```ruby
require 'uniword'

# Load reference document
doc = Uniword::Document.open('namespace_demo_with_atlas_theme_variant_fancy.docx')

# Extract theme information
theme = doc.theme
puts "Theme name: #{theme.name}"
puts "Color scheme: #{theme.color_scheme.name}"
puts "Colors:"
theme.color_scheme.colors.each do |name, value|
  puts "  #{name}: #{value}"
end

puts "\nFont scheme: #{theme.font_scheme.name}"
puts "Major font: #{theme.font_scheme.major_font}"
puts "Minor font: #{theme.font_scheme.minor_font}"

# Examine how styles reference theme
doc.styles_configuration.styles.each do |style|
  puts "\nStyle: #{style.name}"
  # Check for theme color references
  # Check for theme font references
end
```

## Implementation Considerations

### 1. Color Parsing Complexity

**Challenge**: Colors can be represented multiple ways (RGB, system, scheme, preset) with transformations.

**Solution**: Create a `ColorResolver` class that:
- Parses all color types
- Applies transformations (tint, shade, saturation)
- Resolves final RGB values
- Maintains theme references for round-trip

### 2. Font Scheme Complexity

**Challenge**: Font schemes support numerous scripts with fallback logic.

**Solution**:
- Store all script-specific fonts
- Provide getter methods for each script
- Use fallback to Latin fonts when specific script not defined
- Preserve all fonts in round-trip

### 3. Effect Scheme Support

**Challenge**: Effect schemes are complex with gradients, shadows, glows, reflections.

**Decision Points**:
- **Option A**: Full support (complex, time-consuming)
- **Option B**: Basic support (store/round-trip but don't apply)
- **Option C**: Minimal support (ignore effects initially)

**Recommendation**: Option B - Store effect schemes for round-trip fidelity but don't actively apply them to generated content initially. This allows themes to be loaded and re-saved without loss while deferring complex effect application.

### 4. Theme Variant Handling

**Challenge**: Variants can override any aspect of the theme.

**Solution**:
- Load base theme completely
- Parse variant as separate model
- Create `merge` operation that applies variant overrides
- Support multiple variants (user selects which to apply)

### 5. Style Update Strategy

**Challenge**: When applying theme to existing document, need to update styles appropriately.

**Options**:
1. **Replace Mode**: Replace all style formatting with theme references
2. **Merge Mode**: Add theme references while preserving custom formatting
3. **Selective Mode**: Only update styles that match theme defaults

**Recommendation**: Implement Merge Mode as default with option for Replace Mode. This preserves user customizations while enabling theme colors/fonts.

## Testing Strategy

### Unit Tests

1. **ThemePackageReader**
   - Extract .thmx file
   - Handle missing variant files
   - Validate package structure

2. **ThemeXmlParser**
   - Parse color scheme with all color types
   - Parse font scheme with multiple scripts
   - Parse effect scheme
   - Parse theme variants

3. **ColorResolver**
   - Resolve RGB colors
   - Apply color transformations
   - Handle system colors

4. **ThemeApplicator**
   - Apply theme to empty document
   - Apply theme to document with existing styles
   - Apply theme variant

### Integration Tests

1. **Round-trip Test**
   ```ruby
   # Load document with theme
   doc1 = Uniword::Document.open('themed_doc.docx')

   # Save and reload
   doc1.save('temp.docx')
   doc2 = Uniword::Document.open('temp.docx')

   # Verify theme preserved
   assert_equal doc1.theme.name, doc2.theme.name
   assert_equal doc1.theme.color_scheme.colors, doc2.theme.color_scheme.colors
   ```

2. **Theme Application Test**
   ```ruby
   # Create document
   doc = Uniword::Document.new
   doc.add_paragraph('Test')

   # Apply theme
   doc.apply_theme_file('Atlas.thmx', variant: 'fancy')

   # Verify theme applied
   assert_not_nil doc.theme
   assert_equal 'Atlas', doc.theme.name

   # Save and verify in Word
   doc.save('test_output.docx')
   ```

3. **Reference Document Comparison**
   ```ruby
   # Load reference
   reference = Uniword::Document.open('namespace_demo_with_atlas_theme_variant_fancy.docx')

   # Create new with same theme
   generated = Uniword::Document.new
   generated.apply_theme_file('Atlas.thmx', variant: 'fancy')

   # Compare themes
   assert_theme_equivalent(reference.theme, generated.theme)
   ```

## Performance Considerations

### Lazy Loading

For large theme files with many variants:

```ruby
class Theme
  def variants
    @variants ||= load_variants  # Load on first access
  end

  private

  def load_variants
    # Parse variant files only when needed
  end
end
```

### Caching

Cache parsed themes to avoid re-parsing:

```ruby
class ThemeRegistry
  @cache = {}

  def self.get(path)
    @cache[path] ||= ThemeLoader.new.load(path)
  end
end
```

### Memory Management

For documents with themes:
- Store only necessary theme data
- Use efficient color representation (integers vs strings)
- Clear cached data when theme changes

## Security Considerations

### ZIP Bomb Protection

.thmx files are ZIP archives and could potentially be malicious:

```ruby
class ThemePackageReader
  MAX_THEME_SIZE = 10 * 1024 * 1024  # 10 MB
  MAX_UNCOMPRESSED_RATIO = 100

  def extract(path)
    # Check file size
    raise SecurityError if File.size(path) > MAX_THEME_SIZE

    # Check compression ratio during extraction
    # Prevent ZIP bombs
  end
end
```

### XML Injection

Validate theme XML to prevent XXE attacks:

```ruby
class ThemeXmlParser
  def parse(xml)
    doc = Nokogiri::XML(xml) do |config|
      config.strict.nonet  # Disable network access
    end
    # ... parse
  end
end
```

## Conclusion

Implementing Word theme support in uniword is achievable using existing infrastructure:

1. **ZIP Extraction**: Leverage existing `ZipExtractor`
2. **XML Parsing**: Use existing Nokogiri-based parsing
3. **Model Extension**: Extend current `Theme` class
4. **Integration**: Minimal changes to serialization layer

The architecture outlined in this analysis provides:
- Full theme loading from .thmx files
- Theme variant support
- Round-trip fidelity
- Integration with existing document API
- CLI support for theme operations

Next steps: Begin implementation with Phase 1 (Theme Package Infrastructure).