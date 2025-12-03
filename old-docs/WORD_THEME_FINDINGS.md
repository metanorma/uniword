# Word Theme Analysis Findings

## Critical Discovery: .thmx Files Are PowerPoint Theme Packages

### Analysis Results

Running the analysis script on `Atlas.thmx` revealed that:

1. **.thmx files are PowerPoint theme packages**, not Word-specific themes
2. They contain slide layouts, slide masters, and presentations
3. The actual theme definition is nested at `theme/theme/theme1.xml` (not `theme/theme1.xml`)
4. Variants are complete presentation packages, not simple XML overrides

### File Structure (Actual)

```
Atlas.thmx/
├── [Content_Types].xml
├── _rels/.rels
├── docProps/
│   └── thumbnail.jpeg
├── theme/                           # PowerPoint presentation structure
│   ├── presentation.xml
│   ├── slideLayouts/                # Slide layout definitions
│   │   └── slideLayout*.xml
│   ├── slideMasters/                # Slide master definitions
│   │   └── slideMaster1.xml
│   └── theme/                       # ACTUAL THEME IS HERE
│       ├── theme1.xml               # ← The theme we need for Word
│       ├── themeManager.xml
│       └── *.jpeg (thumbnails)
└── themeVariants/                   # Theme variant packages
    ├── themeVariantManager.xml
    ├── variant1/                    # Complete presentation package
    │   ├── theme/theme/theme1.xml   # Variant theme
    │   └── ... (full PP structure)
    ├── variant2/
    ├── variant3/
    ├── variant4/
    ├── variant5/
    ├── variant6/
    └── variant7/                    # Atlas has 7 variants!
```

### Variant Discovery

Atlas.thmx contains **7 variants** (variant1 through variant7), not named "fancy" or anything descriptive:

- `themeVariants/variant1/`
- `themeVariants/variant2/`
- `themeVariants/variant3/`
- `themeVariants/variant4/`
- `themeVariants/variant5/`
- `themeVariants/variant6/`
- `themeVariants/variant7/`

### The "Fancy" Variant Mystery

The reference document is named `namespace_demo_with_atlas_theme_variant_fancy.docx`, but:

1. **No "fancy" in the .thmx file** - variants are just numbered
2. **No variant reference in document's theme XML** - the embedded theme is just "Atlas"
3. **"Fancy" is a display name** - Word must store variant selection elsewhere

### Where is the Variant Reference?

The variant selection is **NOT** in:
- ❌ `word/theme/theme1.xml` - contains base theme only
- ❌ Theme XML root attributes

The variant selection **MUST BE** in:
- ✅ `word/settings.xml` - document settings
- ✅ `word/styles.xml` - style definitions that use variant-specific formatting
- ✅ Or it's just the theme itself that was copied with variant applied

### Implications for uniword

1. **For loading .thmx files:**
   - Extract `theme/theme/theme1.xml` (not `theme/theme1.xml`)
   - Extract variant themes from `themeVariants/variant*/theme/theme/theme1.xml`
   - Variant numbering is 1-based

2. **For variant names:**
   - Variants are numbered in .thmx (variant1, variant2, etc.)
   - Display names like "fancy" are metadata (need to find where)
   - `themeVariantManager.xml` might contain the mapping

3. **For applying to Word documents:**
   - Take base theme from `theme/theme/theme1.xml`
   - If variant specified, take variant theme from `themeVariants/variant{N}/theme/theme/theme1.xml`
   - Embed result in `word/theme/theme1.xml`

## Updated Architecture

### Corrected Theme Package Structure

```ruby
class ThemePackageReader
  def extract(path)
    # Extract ZIP
    files = extract_zip(path)

    # Get base theme (CORRECTED PATH)
    base_theme_xml = files['theme/theme/theme1.xml']

    # Get variants (CORRECTED PATH)
    variants = {}
    files.each do |path, content|
      if path =~ %r{^themeVariants/variant(\d+)/theme/theme/theme1\.xml$}
        variant_number = $1
        variants["variant#{variant_number}"] = content
      end
    end

    { base: base_theme_xml, variants: variants }
  end
end
```

### Variant Manager XML

The file `themeVariants/themeVariantManager.xml` likely contains variant metadata.
Need to parse this to get display names.

Example structure (hypothesis):
```xml
<themeVariantManager>
  <variant id="variant1" name="Simple" />
  <variant id="variant2" name="Fancy" />
  <variant id="variant3" name="Modern" />
  <!-- etc -->
</themeVariantManager>
```

## Testing Strategy (Updated)

### Test 1: Extract Base Theme

```ruby
reader = ThemePackageReader.new
theme_data = reader.extract('Atlas.thmx')

# Verify paths
puts "Base theme size: #{theme_data[:base].bytesize}"
puts "Variants found: #{theme_data[:variants].keys.join(', ')}"
# Expected: variant1, variant2, variant3, variant4, variant5, variant6, variant7
```

### Test 2: Parse Variant Manager

```ruby
manager_xml = files['themeVariants/themeVariantManager.xml']
# Parse to get variant display names
# Map variant1 => "Simple", variant2 => "Fancy", etc.
```

### Test 3: Apply Variant to Document

Since we don't know which variant is "fancy", we need to:
1. Extract all variant themes
2. Compare with reference document theme
3. Find which variant matches

Or:
1. Just support numeric variant selection: `variant: 2`
2. Add display name support later

## Recommendations

### Phase 1: Basic Support (No Variants)

1. Extract `theme/theme/theme1.xml` from .thmx
2. Apply to Word document as `word/theme/theme1.xml`
3. Ignore variants initially

```ruby
doc = Uniword::Document.new
doc.apply_theme_file('Atlas.thmx')  # No variant
doc.save('output.docx')
```

### Phase 2: Numeric Variant Support

1. Extract base theme and all variants
2. Support numeric variant selection

```ruby
doc.apply_theme_file('Atlas.thmx', variant: 2)
# Applies variant2 theme
```

### Phase 3: Named Variant Support

1. Parse `themeVariantManager.xml`
2. Build name-to-number mapping
3. Support both numeric and named variants

```ruby
doc.apply_theme_file('Atlas.thmx', variant: 'fancy')
# Looks up "fancy" => variant2, applies variant2 theme
```

## Next Steps

1. ✅ Update architecture documents with corrected paths
2. ✅ Create simplified implementation focusing on base theme first
3. ⬜ Investigate `themeVariantManager.xml` structure
4. ⬜ Determine how Word stores variant selection in documents
5. ⬜ Test with multiple .thmx files to validate structure

## Questions to Answer

1. **How does Word know which variant to display as "fancy"?**
   - Check themeVariantManager.xml
   - Check if Word has built-in mappings

2. **How does a document remember its variant selection?**
   - word/settings.xml?
   - word/styles.xml?
   - Or is the variant theme just embedded directly?

3. **Are all .thmx files structured the same way?**
   - Test with Office Theme.thmx
   - Test with other themes (Badge, Berlin, etc.)