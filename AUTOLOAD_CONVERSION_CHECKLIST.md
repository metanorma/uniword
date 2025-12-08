# Autoload Conversion Checklist

## Wordprocessingml Session 3: Audit Results

### Files to Convert (10 files)

| File | require_relative Count | Dependencies |
|------|------------------------|--------------|
| level.rb | 2 | OOXML: paragraph_properties, run_properties |
| r_pr_default.rb | 1 | OOXML: run_properties |
| p_pr_default.rb | 1 | OOXML: paragraph_properties |
| table_cell_properties.rb | 3 | Properties: cell_width, cell_vertical_align, shading |
| run.rb | 1 | OOXML: run_properties |
| paragraph.rb | 2 | OOXML: paragraph_properties, run_properties |
| table.rb | 1 | OOXML: table_properties |
| structured_document_tag.rb | 1 | Top-level: structured_document_tag_properties |
| style.rb | 3 | OOXML: paragraph_properties, run_properties, table_properties |
| document_root.rb | 2 | OOXML: paragraph_properties, run_properties |

### Dependency Analysis

**All require_relative statements can be SAFELY REMOVED**:

1. **OOXML classes** (`../ooxml/wordprocessingml/*`):
   - These are in a separate module namespace
   - Will be loaded automatically when class constant is referenced
   - Examples: ParagraphProperties, RunProperties, TableProperties

2. **Properties classes** (`../properties/*`):
   - These are in the Properties module
   - Should have their own autoload system (or will be created)
   - Examples: CellWidth, CellVerticalAlign, Shading

3. **Top-level classes** (`../*`):
   - These should be in the main Uniword autoload system
   - Example: StructuredDocumentTagProperties

### Conversion Order (Dependency-First)

1. **Level 1** (No wordprocessingml deps): level.rb, r_pr_default.rb, p_pr_default.rb, table_cell_properties.rb
2. **Level 2** (Depends on Level 1): run.rb,  paragraph.rb, table.rb
3. **Level 3** (Depends on Level 2): structured_document_tag.rb, style.rb
4. **Level 4** (Depends on all): document_root.rb

### Expected Outcome

- 0-2 require_relative remaining (only if circular dependencies found)
- All files use namespace-qualified constant references
- Autoload handles deferred loading
- Baseline tests maintained: 258/258 (177 known failures)