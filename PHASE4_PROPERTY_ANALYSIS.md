# Phase 4: Property Analysis Report
**Date**: December 2, 2024
**Status**: Analysis Complete ✅

## Test Status Summary
- **Content Types**: 8/8 (100%) ✅
- **Glossary Round-Trip**: 0/8 (0%) ❌
- **Total**: 8/16 (50%)

## Root Cause Confirmed
Phase 3 Week 3 Session 2 discovery was correct: The Glossary infrastructure is COMPLETE. All failures are due to missing Wordprocessingml property support, NOT Glossary issues.

## Detailed Property Gaps

### 1. Table Properties (tblPr)

**Current**: Empty element `<tblPr/>`

**Required**:
```xml
<w:tblPr>
  <w:tblW w:w="5000" w:type="pct"/>
  <w:shd w:val="clear" w:color="auto" w:fill="5B9BD5" w:themeFill="accent1"/>
  <w:tblCellMar>
    <w:left w:w="115" w:type="dxa"/>
    <w:right w:w="115" w:type="dxa"/>
  </w:tblCellMar>
  <w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/>
</w:tblPr>
```

**Missing Items**:
1. `TableWidth` - w, type attributes (e.g., w="5000", type="pct")
2. Enhanced `Shading` - themeFill attribute (e.g., themeFill="accent1")
3. `TableCellMargin` - top/bottom/left/right with w, type attributes
4. `TableLook` - val, firstRow, lastRow, firstColumn, lastColumn, noHBand, noVBand attributes

### 2. Grid Column Properties

**Current**: `<w:gridCol/>` (no attributes)

**Required**: `<w:gridCol w:w="4680"/>`

**Missing**: w attribute for column width

### 3. Cell Properties (tcPr)

**Current**: Incomplete
```xml
<w:tcPr>
  <w:shd w:val="clear" w:color="auto" w:fill="5B9BD5"/>
</w:tcPr>
```

**Required**:
```xml
<w:tcPr>
  <w:tcW w:w="2500" w:type="pct"/>
  <w:shd w:val="clear" w:color="auto" w:fill="5B9BD5" w:themeFill="accent1"/>
  <w:vAlign w:val="center"/>
</w:tcPr>
```

**Missing Items**:
1. `CellWidth` (tcW) - w, type attributes
2. Enhanced `Shading` - themeFill attribute
3. `VerticalAlign` (vAlign) - val attribute (top/center/bottom)

### 4. Run Properties (rPr)

**Current**: Basic properties only

**Required**:
```xml
<w:rPr>
  <w:caps/>
  <w:color w:val="FFFFFF" w:themeColor="background1"/>
  <w:sz w:val="18"/>
  <w:szCs w:val="18"/>
  <w:noProof/>
</w:rPr>
```

**Missing Items**:
1. `caps` - All capitals boolean flag
2. Enhanced `color` - themeColor attribute
3. `szCs` - Complex script size (companion to sz)
4. `noProof` - No spell/grammar check boolean flag

### 5. Structured Document Tag Properties (sdtPr)

**Current**: Almost entirely missing

**Required**:
```xml
<w:sdtPr>
  <w:rPr>
    <w:caps/>
    <w:color w:val="FFFFFF" w:themeColor="background1"/>
    <w:sz w:val="18"/>
    <w:szCs w:val="18"/>
  </w:rPr>
  <w:alias w:val="Title"/>
  <w:tag w:val=""/>
  <w:id w:val="-578829839"/>
  <w:placeholder>
    <w:docPart w:val="2374E6070D0544809B47FED1B62F98DC"/>
  </w:placeholder>
  <w:showingPlcHdr/>
  <w:dataBinding w:prefixMappings="xmlns:ns0='http://purl.org/dc/elements/1.1/' xmlns:ns1='http://schemas.openxmlformats.org/package/2006/metadata/core-properties' " 
                 w:xpath="/ns1:coreProperties[1]/ns0:title[1]" 
                 w:storeItemID="{6C3C8BC8-F283-45AE-878A-BAB7291924A1}"/>
  <w:text/>
</w:sdtPr>
```

**Missing Items**:
1. `Id` - Unique integer ID
2. `Alias` - Display name
3. `Tag` - Developer tag (can be empty)
4. `Placeholder` - References docPart
5. `ShowingPlcHdr` - Boolean flag
6. `DataBinding` - xpath, storeItemID, prefixMappings attributes  
7. `Text` - Text control type flag
8. `Appearance` - Visual appearance mode (hidden/tags/boundingBox)
9. `DocPartObject` - Building block reference (for complex placeholders)

## Priority Order

Based on test impact analysis:

### High Priority (affects all 8 tests)
1. **Table Width** - Every test has tables
2. **Cell Width** - Every test has table cells
3. **Vertical Align** - Every test has styled cells
4. **Shading themeFill** - Every test uses themed colors

### Medium Priority (affects 6/8 tests)
5. **Table Cell Margins** - Most tests use margins
6. **Table Look** - Most tests use conditional formatting
7. **Run Caps** - Many tests use all capitals
8. **Run NoProof** - Many tests disable proofing

### Lower Priority (affects 3/8 tests)
9. **SDT Properties** - Only Cover Pages, Bibliographies, TOC use SDTs heavily

## Implementation Strategy

Follow the proven Pattern 0 from Phase 3:

```ruby
# Step 1: Create wrapper class
class TableWidth < Lutaml::Model::Serializable
  attribute :w, :integer        # ✅ Attribute FIRST
  attribute :type, :string
  
  xml do
    root 'tblW'
    namespace Ooxml::Namespaces::WordProcessingML
    map_attribute 'w', to: :w
    map_attribute 'type', to: :type
  end
end

# Step 2: Use in container
class TableProperties
  attribute :table_width, TableWidth  # ✅ Add to TableProperties
  
  xml do
    # ... existing mappings ...
    map_element 'tblW', to: :table_width, render_nil: false
  end
end

# Step 3: Parse in parser
def parse_table_properties(node)
  # ... existing parsing ...
  if (tbl_w = node.at_xpath('w:tblW', NAMESPACES))
    props.table_width = TableWidth.new(
      w: tbl_w['w:w']&.to_i,
      type: tbl_w['w:type']
    )
  end
end
```

## Files to Create (15 new files)

### Table Properties (4 files)
1. `lib/uniword/properties/table_width.rb`
2. `lib/uniword/properties/table_cell_margin.rb`
3. `lib/uniword/properties/margin.rb` (helper for top/bottom/left/right)
4. `lib/uniword/properties/table_look.rb`

### Cell Properties (2 files)
5. `lib/uniword/properties/cell_width.rb`
6. `lib/uniword/properties/cell_vertical_align.rb`

### Grid Column (1 file)
7. `lib/uniword/table_grid_column.rb`

### SDT Properties (8 files)
8. `lib/uniword/sdt/id.rb`
9. `lib/uniword/sdt/alias.rb`
10. `lib/uniword/sdt/tag.rb`
11. `lib/uniword/sdt/placeholder.rb`
12. `lib/uniword/sdt/showing_placeholder_header.rb`
13. `lib/uniword/sdt/data_binding.rb`
14. `lib/uniword/sdt/text.rb`
15. `lib/uniword/sdt/appearance.rb`

## Files to Modify (7 files)

1. `lib/uniword/properties/table_properties.rb` - Add 4 new properties
2. `lib/uniword/properties/table_cell_properties.rb` - Add 2 new properties
3. `lib/uniword/properties/shading.rb` - Add themeFill attribute
4. `lib/uniword/properties/color_value.rb` - Add themeColor attribute
5. `lib/uniword/properties/run_properties.rb` - Add caps, noProof, ensure szCs
6. `lib/uniword/structured_document_tag_properties.rb` - Add all SDT properties
7. `lib/uniword/table_grid_column.rb` - Add w attribute

## Estimated Time Breakdown

- Table Width: 30 min ✅
- Shading Enhancement: 20 min ✅
- Table Cell Margins: 45 min ⏳
- Table Look: 30 min ⏳
- Cell Width: 20 min ⏳
- Cell Vertical Align: 20 min ⏳
- Run Caps/NoProof: 30 min ⏳
- Color Enhancement: 20 min ⏳
- Complex Script Size: 15 min ⏳
- SDT Properties: 2.5 hours ⏳

**Total**: 5-6 hours (realistic estimate)

## Success Criteria

1. ✅ All 27 property gaps identified
2. ✅ Implementation strategy defined
3. ✅ File structure planned
4. ⏳ All properties implemented following Pattern 0
5. ⏳ Tests passing: 16/16 (100%)
6. ⏳ Zero regressions: 342/342 baseline maintained

## Next Steps

Start with high-priority items in this order:
1. Table Width (impacts 8/8 tests)
2. Shading themeFill (impacts 8/8 tests)
3. Cell Width (impacts 8/8 tests)
4. Cell Vertical Align (impacts 8/8 tests)
5. Then continue with medium/lower priority items

**Status**: Ready to begin implementation ✅