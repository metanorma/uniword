# TODO Index — Active Work Items

## Test Suite Status (2026-04-03)
**3157 examples, 0 failures, 82 pending**

## Categories

| # | Category | Priority | Status |
|---|----------|----------|--------|
| 1 | OOXML Model Gaps | HIGH | Mostly Complete |
| 2 | MHT/DOCX Transformation | MEDIUM | Tests Pass (107 examples) |
| 3 | Custom Getters/Setters Cleanup | HIGH | COMPLETE |
| 4 | respond_to? Replacement | MEDIUM | BooleanElement Checks Done |
| 5 | Namespace Refactoring | LOW | Partially Done |
| 6 | Author Metadata | LOW | Not Started |

---

## 1. OOXML Model Gaps (HIGH)

Missing OOXML element models that cause pending tests or data loss.

| Item | File | Status |
|------|------|--------|
| `attribute_form_default` fix | `TODO.oop-spec/01-attribute-form-default.md` | NOT STARTED |
| SDT `multiLine` attribute | `TODO.oop-spec/05-sdt-multiLine-attribute.md` | NOT STARTED |
| Anchor `anchorId`/`editId` | `TODO.oop-spec/07-anchor-id-edit-id.md` | DONE |
| Blip `r:` namespace | `TODO.oop-spec/03-theme-blip-namespace.md` | VERIFIED (tests pass) |
| ThemeFamily `thm15:` namespace | `TODO.oop-spec/04-theme-thm15-namespace.md` | VERIFIED (tests pass) |

### Pending Tests Caused
- 8 pending: "canon gem be_xml_equivalent_to matcher has bug" (XML namespace issues)
- 5 pending: "Run hyperlink= setter removed in Builder API migration"
- 5 pending: "Uniword.from_html not yet implemented"
- 4 pending: "MHTML roundtrip does not preserve table structure"
- 4 pending: "Image dimension control not yet fully implemented"
- 4 pending: "Document#sections not yet available in Builder API migration"
- 3 pending: "Page size configuration not yet implemented"
- 3 pending: "Line spacing not yet implemented"
- 3 pending: "Footnote positioning not yet implemented"
- 2 pending: "Partial borders not yet implemented"
- 2 pending: "Page orientation not yet implemented"
- 2 pending: "HtmlSerializer not yet implemented"

---

## 2. MHT/DOCX Transformation (MEDIUM)

**Tracked in**: `TODO.mhtwork.md`

### DOCX -> MHT (remaining)
- [ ] VML behavior styles in `<!--[if !mso]>` conditional
- [ ] `o:CustomDocumentProperties` (AssetID, etc.)
- [ ] SDT attribute preservation (ShowingPlcHdr, Temporary, DocPart, Text, ID)
- [ ] SDT content from mixed_content
- [ ] External hyperlink: relationship ID -> URL resolution
- [ ] TOC field codes preservation
- [ ] Table cell paragraphs with inline SDTs
- [ ] Image parts in MIME structure (base64)
- [ ] Theme/colorschememapping binary parts
- [ ] Header/Footer MIME parts
- [ ] filelist.xml generation

### MHT -> DOCX (remaining)
- [ ] Map CSS classes to OOXML styles (MsoHeading1-6, MsoToc1-9, etc.)
- [ ] Parse conditional comments for field codes
- [ ] Create OOXML Table of Contents
- [ ] Complete metadata fields (Revision, TotalTime, Pages, Words)
- [ ] Table cell paragraphs with proper styles

### Round-Trip Tests
- [ ] Write MHT -> DOCX content matching spec
- [ ] Write round-trip content matching spec
- 100 transformation examples passing (36 DOCX->MHT, 32 MHT->DOCX, 34 content matching)

---

## 3. Custom Getters/Setters Cleanup (HIGH) — COMPLETE

Remove custom getters/setters that shadow lutaml-model in properties classes.

**Tracked in**: `TODO.plans/builder-document-api.md`, `TODO.plans/boolean-properties.md`

### FIXED (2026-04-03)
- `document_root.rb`: Removed `app_properties`, `core_properties`, `bookmarks` from attr_accessor, added attr_writer
- `section_properties.rb`: Removed unused `page_size=` setter
- `run.rb`: Removed custom `text=` setter, added `Text.cast` for proper String→Text conversion via lutaml-model's type system
- `text.rb`: Added `self.cast(value)` class method to handle String→Text conversion

### Solution: Text.cast

The key insight was that lutaml-model's attribute system calls `cast_value()` when assigning attributes. By defining `Text.cast(value)` to handle String→Text conversion, the framework now handles conversion automatically without custom setters:

```ruby
# Before: Custom setter (shadowed lutaml-model, caused warning)
def text=(value)
  @text = create_text_object(value.to_s)
end

# After: lutaml-model handles conversion via Text.cast
# Text.cast converts String → Text automatically when attribute is assigned
```

### Warnings Fixed
- All "method redefined" warnings from our code are now eliminated

---

## 4. respond_to? Replacement (MEDIUM) — BooleanElement Checks DONE

**~217 occurrences** across ~40 files in lib/. Most are valid duck-typing interface checks.

### BooleanElement Checks (DONE 2026-04-03)
Replaced `respond_to?(:value)` with `is_a?(BooleanElement)` in:
- `wordprocessingml/run_properties.rb` ✓
- `wordprocessingml/style.rb` ✓

### Remaining respond_to? Uses
These are valid duck-typing checks for interface availability (e.g., `respond_to?(:runs)`, `respond_to?(:paragraphs)`), not BooleanElement-specific.

---

## 5. Namespace Refactoring (LOW) — COMPLETED

All 6 phases of the classname/namespace audit are complete:
- Phase 1: 8 duplicate DrawingML root-level files removed
- Phase 2: VML namespace fixed (uses `module Vml`)
- Phase 3: No WordProcessingML root-level duplicates remain
- Phase 4: `Properties::` module placement is intentional
- Phase 5: Remaining `require_relative` in math/ are correct (shared constants)

**Deleted**: `TODO.classname-audit.md`, `TODO/TODO.refactor-part-4-of-6`

---

## 6. Author Metadata (LOW)

**Tracked in**: `TODO.author-metadata.md`

### Requirements (not yet implemented)
- Personal info: name, initials, company, address, city, state, zip, country, phone, email
- Document properties: Title, Subject, Author, Manager, Company, Category, Keywords, Comments
- Custom fields: Checked by, Client, Department, Document number, etc.
- Custom field types: Text, Date, Number, Yes/No
- Page setup: size, orientation, margins, layout, grid

---

## Completed Items (2026-04-02)

- Builder API (20 phases) — `TODO.builder.md` DELETED
- OOXML round-trrip (settings, styles, numbering, document) — `TODO/word-versions/` DELETED
- ContentTypes namespace bug — `TODO.lutaml-model-contenttypes-namespace.md` DELETED
- Legacy code removal (compat shims, deprecated attrs, aliases) — all completed
- TOC glossary round-trrip — fixed with BooleanValSetter value_set_for + spec_friendly Canon profile
- Theme transformation — `TODO.themes/` DELETED
- MHTML architecture separation — `TODO/TODO.mhtml-architecture` DELETED
- Spec fixes — `TODO.fix-spec.md` DELETED (0 failures now)
- Refactoring Parts 1-3, 5-6 — `TODO/TODO.refactor-part-{1,2,3,5,6}-of-6` DELETED
- Classname audit Phase 1 (duplicate DrawingML removal) — completed
