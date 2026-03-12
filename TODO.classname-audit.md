# TODO: Classname and Namespace Audit

This document tracks the comprehensive audit and fixes needed for namespace consistency
in the Uniword codebase. Each class must be in the correct Ruby namespace based on its
XML namespace declaration.

## Audit Date: 2024-03-09 (Updated)

## Summary of Issues

| Category | Issue Count | Severity | Status |
|----------|-------------|----------|--------|
| Duplicate DrawingML Classes | 8 file pairs | HIGH | Pending |
| VML Namespace Mismatch | 19 files | MEDIUM | Pending |
| WordProcessingML in Root | 8+ files | MEDIUM | Pending |
| Properties Module Mismatch | ~30 files | LOW | Pending (may be intentional) |
| Remaining require_relative | 1 file | LOW | Pending |

---

## Phase 1: Remove Duplicate DrawingML Classes (HIGH PRIORITY)

**Problem:** Classes exist in BOTH `lib/uniword/*.rb` (root namespace) AND
`lib/uniword/drawingml/*.rb` (proper namespace). Both declare `DrawingML` XML namespace.

**Strategy:** Remove root-level duplicates, keep only `Uniword::Drawingml::*` versions.
The aliases in `lib/uniword.rb` already map root names to Drawingml namespace.

### Tasks

- [ ] 1.1 Delete `lib/uniword/theme.rb` (duplicate of `lib/uniword/drawingml/theme.rb`)
- [ ] 1.2 Delete `lib/uniword/color_scheme.rb` (duplicate of `lib/uniword/drawingml/color_scheme.rb`)
- [ ] 1.3 Delete `lib/uniword/format_scheme.rb` (duplicate of `lib/uniword/drawingml/format_scheme.rb`)
- [ ] 1.4 Delete `lib/uniword/font_scheme.rb` (duplicate of `lib/uniword/drawingml/font_scheme.rb`)
- [ ] 1.5 Delete `lib/uniword/extension_list.rb` (duplicate of `lib/uniword/drawingml/extension_list.rb`)
- [ ] 1.6 Delete `lib/uniword/extension.rb` (duplicate of `lib/uniword/drawingml/extension.rb`)
- [ ] 1.7 Delete `lib/uniword/object_defaults.rb` (duplicate of `lib/uniword/drawingml/object_defaults.rb`)
- [ ] 1.8 Delete `lib/uniword/extra_color_scheme_list.rb` (duplicate of `lib/uniword/drawingml/extra_color_scheme_list.rb`)
- [ ] 1.9 Run tests after each deletion to verify no breakage
- [ ] 1.10 Update `lib/uniword.rb` if any autoload paths need adjustment

### Files to Delete (after verification)

```
lib/uniword/theme.rb
lib/uniword/color_scheme.rb
lib/uniword/format_scheme.rb
lib/uniword/font_scheme.rb
lib/uniword/extension_list.rb
lib/uniword/extension.rb
lib/uniword/object_defaults.rb
lib/uniword/extra_color_scheme_list.rb
```

---

## Phase 2: Fix VML Namespace (MEDIUM PRIORITY)

**Problem:** VML classes are in `Uniword::Generated::Vml` but should be in `Uniword::Vml`.

**Strategy:** Change module declaration from `module Generated; module Vml` to `module Vml`.

### Tasks

- [ ] 2.1 Update `lib/uniword/vml.rb` to use `Uniword::Vml` instead of `Uniword::Generated::Vml`
- [ ] 2.2 Update all VML class files:

Files to update (remove `module Generated` wrapper):
- [ ] 2.2.1 `lib/uniword/vml/shape.rb`
- [ ] 2.2.2 `lib/uniword/vml/oval.rb`
- [ ] 2.2.3 `lib/uniword/vml/fill.rb`
- [ ] 2.2.4 `lib/uniword/vml/stroke.rb`
- [ ] 2.2.5 `lib/uniword/vml/textbox.rb`
- [ ] 2.2.6 `lib/uniword/vml/wrap.rb`
- [ ] 2.2.7 `lib/uniword/vml/handle.rb`
- [ ] 2.2.8 `lib/uniword/vml/handles.rb`
- [ ] 2.2.9 `lib/uniword/vml/formula.rb`
- [ ] 2.2.10 `lib/uniword/vml/formulas.rb`
- [ ] 2.2.11 `lib/uniword/vml/group.rb`
- [ ] 2.2.12 `lib/uniword/vml/line.rb`
- [ ] 2.2.13 `lib/uniword/vml/imagedata.rb`
- [ ] 2.2.14 `lib/uniword/vml/rect.rb`
- [ ] 2.2.15 `lib/uniword/vml/polyline.rb`
- [ ] 2.2.16 `lib/uniword/vml/curve.rb`
- [ ] 2.2.17 `lib/uniword/vml/path.rb`
- [ ] 2.2.18 `lib/uniword/vml/shapetype.rb`

- [ ] 2.3 Search for any references to `Uniword::Generated::Vml` and update to `Uniword::Vml`
- [ ] 2.4 Run tests to verify VML classes work correctly

---

## Phase 3: Consolidate WordProcessingML Classes (MEDIUM PRIORITY)

**Problem:** Some classes using `WordProcessingML` XML namespace are in root `Uniword`
module instead of `Uniword::Wordprocessingml`.

**Strategy:** Evaluate each case. Either:
A) Move to proper namespace and update references
B) Document as intentional convenience wrapper

### Tasks

- [ ] 3.1 Audit each root-level WordProcessingML class:
  - [ ] 3.1.1 `lib/uniword/style.rb` - Has duplicate in `wordprocessingml/style.rb`
  - [ ] 3.1.2 `lib/uniword/table_cell.rb` - Has duplicate in `wordprocessingml/table_cell.rb`
  - [ ] 3.1.3 `lib/uniword/table_row.rb` - Has duplicate in `wordprocessingml/table_row.rb`
  - [ ] 3.1.4 `lib/uniword/comment.rb` - Check for duplicate
  - [ ] 3.1.5 `lib/uniword/comment_range.rb` - Check for duplicate
  - [ ] 3.1.6 `lib/uniword/image.rb` - Check for duplicate
  - [ ] 3.1.7 `lib/uniword/comments_part.rb` - Check for duplicate
  - [ ] 3.1.8 `lib/uniword/styles_configuration.rb` - Check for duplicate

- [ ] 3.2 For duplicates, decide:
  - Delete root version if wordprocessingml version is complete
  - Or merge functionality and keep single version

- [ ] 3.3 Update autoloads and aliases in `lib/uniword.rb`

---

## Phase 4: Evaluate Properties Module Design (LOW PRIORITY)

**Problem:** Properties classes use `WordProcessingML` XML namespace but are in
`Uniword::Properties` module, not `Uniword::Wordprocessingml`.

**Decision Required:** Is this intentional architectural design or inconsistency?

### Tasks

- [ ] 4.1 Document architectural decision for `Uniword::Properties` module
- [ ] 4.2 If intentional, add documentation explaining:
  - Properties module provides higher-level abstractions
  - XML namespace doesn't always map to Ruby namespace by design
- [ ] 4.3 If unintentional, create plan to move to `Wordprocessingml::Properties`

### Properties Files (for reference)

```
lib/uniword/properties/underline.rb
lib/uniword/properties/vertical_align.rb
lib/uniword/properties/alignment.rb
lib/uniword/properties/border.rb
lib/uniword/properties/borders.rb
lib/uniword/properties/character_spacing.rb
lib/uniword/properties/color_value.rb
lib/uniword/properties/emphasis_mark.rb
lib/uniword/properties/font_size.rb
lib/uniword/properties/highlight.rb
lib/uniword/properties/kerning.rb
lib/uniword/properties/language.rb
lib/uniword/properties/margin.rb
lib/uniword/properties/numbering_id.rb
lib/uniword/properties/numbering_level.rb
lib/uniword/properties/outline_level.rb
lib/uniword/properties/position.rb
lib/uniword/properties/shading.rb
lib/uniword/properties/style_reference.rb
lib/uniword/properties/tab_stop.rb
lib/uniword/properties/table_cell_margin.rb
lib/uniword/properties/table_look.rb
lib/uniword/properties/table_width.rb
lib/uniword/properties/tabs.rb
lib/uniword/properties/text_fill.rb
lib/uniword/properties/text_outline.rb
lib/uniword/properties/width_scale.rb
lib/uniword/properties/cell_vertical_align.rb
lib/uniword/properties/cell_width.rb
```

---

## Phase 5: Convert Remaining require_relative (LOW PRIORITY)

**Problem:** One file still uses `require_relative` instead of autoload.

### Tasks

- [ ] 5.1 Analyze `lib/uniword/wordprocessingml/structured_document_tag_properties.rb`
  - Currently has: `require_relative '../sdt'`
  - Reason: "Sdt namespace MUST be eager-loaded because we use bare Sdt:: constants"
  - Evaluate if autoload can work with fully-qualified `Uniword::Sdt::` references

- [ ] 5.2 If possible, change from:
  ```ruby
  require_relative '../sdt'
  attribute :id, Sdt::Id
  ```
  To:
  ```ruby
  attribute :id, Uniword::Sdt::Id  # Uses autoload correctly
  ```

- [ ] 5.3 Test that autoload triggers correctly for SDT classes

---

## Phase 6: Namespace Consistency Verification (FINAL)

### Tasks

- [ ] 6.1 Run full test suite after all changes
- [ ] 6.2 Verify autoload works for all classes
- [ ] 6.3 Check that no `require_relative` remains except where documented as necessary
- [ ] 6.4 Update this document with final status
- [ ] 6.5 Remove this file or move to `old-docs/` after completion

---

## Progress Tracking

| Phase | Status | Completion Date |
|-------|--------|-----------------|
| Phase 1: Duplicate DrawingML | Not Started | - |
| Phase 2: VML Namespace | Not Started | - |
| Phase 3: WordProcessingML Consolidation | Not Started | - |
| Phase 4: Properties Design | Not Started | - |
| Phase 5: require_relative | Not Started | - |
| Phase 6: Verification | Not Started | - |

---

## Notes

### Namespace Mapping Reference

| XML Namespace | Prefix | Expected Ruby Module |
|---------------|--------|---------------------|
| WordProcessingML | w: | `Uniword::Wordprocessingml` |
| DrawingML | a: | `Uniword::Drawingml` |
| MathML | m: | `Uniword::Math` |
| VML | v: | `Uniword::Vml` |
| WordProcessingDrawing | wp: | `Uniword::WpDrawing` |
| Relationships | r: | `Uniword::Ooxml::Relationships` |
| Bibliography | b: | `Uniword::Bibliography` |
| ExtendedProperties | app: | `Uniword::DocumentProperties` |
| DocumentVariables | dv: | `Uniword::DocumentVariables` |
| CustomXml | cxml: | `Uniword::Customxml` |
| SharedTypes | st: | `Uniword::SharedTypes` |

### Ruby Naming Convention

1. Module names use `CamelCase`
2. Directory names use `snake_case`
3. File `lib/uniword/drawingml/theme.rb` → class `Uniword::Drawingml::Theme`
4. File `lib/uniword/wordprocessingml/paragraph.rb` → class `Uniword::Wordprocessingml::Paragraph`

---

## Execution Log

| Date | Action | Result |
|------|--------|--------|
| 2024-03-08 | Created initial audit document | Analysis started |
| 2024-03-09 | Comprehensive audit via agent | Found 4 major categories of issues |
| 2024-03-09 | Updated TODO with detailed findings | Ready for implementation |
