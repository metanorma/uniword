# docx-js Feature Coverage Analysis

**Date:** 2025-10-25
**Purpose:** Comprehensive audit of docx-js demo features to achieve 100% coverage in Uniword
**Total Demos Analyzed:** 94 demo files

---

## Executive Summary

**Current Coverage:** ~70% (estimated)
**Target:** 100% feature parity with docx-js
**Missing Features:** 14 major feature gaps identified

---

## ✅ Features Already Implemented

### Document Structure
- [x] **Headers & Footers** (`demo/8-header-footer.ts`)
  - Location: [`lib/uniword/header.rb`](../lib/uniword/header.rb), [`lib/uniword/footer.rb`](../lib/uniword/footer.rb)
  - Status: Fully implemented

- [x] **Sections** (`demo/16-multiple-sections.ts`)
  - Location: [`lib/uniword/section.rb`](../lib/uniword/section.rb), [`lib/uniword/section_properties.rb`](../lib/uniword/section_properties.rb)
  - Status: Basic implementation exists, needs enhancement for page properties

- [x] **Fields** (`demo/66-fields.ts`)
  - Location: [`lib/uniword/field.rb`](../lib/uniword/field.rb)
  - Status: Implemented

- [x] **Text Boxes** (`demo/94-texbox.ts`)
  - Location: [`lib/uniword/text_box.rb`](../lib/uniword/text_box.rb)
  - Status: Implemented

### Lists & Numbering
- [x] **Numbered Lists** (`demo/29-numbered-lists.ts`)
  - Location: [`lib/uniword/numbering_configuration.rb`](../lib/uniword/numbering_configuration.rb)
  - Status: Fully implemented

- [x] **Sequential Captions** (`demo/33-sequential-captions.ts`)
  - Location: Via numbering system
  - Status: Supported through numbering

### Styles
- [x] **Character Styles** (`demo/51-character-styles.ts`)
  - Location: [`lib/uniword/character_style.rb`](../lib/uniword/character_style.rb)
  - Status: Implemented

- [x] **Paragraph Styles** (`demo/2-declaritive-styles.ts`)
  - Location: [`lib/uniword/paragraph_style.rb`](../lib/uniword/paragraph_style.rb)
  - Status: Implemented

### Text Formatting
- [x] **Text Highlighting** (`demo/45-highlighting-text.ts`)
  - Location: [`lib/uniword/properties/run_properties.rb`](../lib/uniword/properties/run_properties.rb:58)
  - Attribute: `highlight`
  - Status: Implemented

- [x] **Small Caps & All Caps** (`demo/51-character-styles.ts`)
  - Location: [`lib/uniword/properties/run_properties.rb`](../lib/uniword/properties/run_properties.rb:64-67)
  - Attributes: `small_caps`, `caps`
  - Status: Implemented

### Comments & Revisions
- [x] **Comments** (`demo/73-comments.ts`)
  - Location: [`lib/uniword/comment.rb`](../lib/uniword/comment.rb), [`lib/uniword/comments_part.rb`](../lib/uniword/comments_part.rb)
  - Status: Fully implemented in v1.1

- [x] **Track Changes** (`demo/60-track-revisions.ts`)
  - Location: [`lib/uniword/tracked_changes.rb`](../lib/uniword/tracked_changes.rb), [`lib/uniword/revision.rb`](../lib/uniword/revision.rb)
  - Status: Fully implemented in v1.1

### References
- [x] **Bookmarks** (`demo/21-bookmarks.ts`)
  - Location: [`lib/uniword/bookmark.rb`](../lib/uniword/bookmark.rb)
  - Status: Implemented

- [x] **Footnotes** (`demo/17-footnotes.ts`)
  - Location: [`lib/uniword/footnote.rb`](../lib/uniword/footnote.rb)
  - Status: Implemented

- [x] **Endnotes** (standard OOXML)
  - Location: [`lib/uniword/endnote.rb`](../lib/uniword/endnote.rb)
  - Status: Implemented

---

## ❌ Missing Features (Priority Order)

### Priority 1: Page and Document Features (2 days)

#### 1.1 Page Borders (`demo/6-page-borders.ts`, `demo/71-page-borders-2.ts`)
**Status:** ❌ Not Implemented
**Complexity:** Medium
**Demo Code:**
```typescript
sections: [{
  properties: {
    page: {
      borders: {
        pageBorders: {
          display: "allPages",
          offsetFrom: "page",
        },
      },
    },
  },
}]
```

**Required Implementation:**
```ruby
# lib/uniword/section_properties.rb
class SectionProperties
  attr_accessor :page_borders  # PageBorders object
end

# lib/uniword/page_borders.rb
class PageBorders
  attr_accessor :top, :bottom, :left, :right
  attr_accessor :display, :offset_from  # allPages/firstPage, page/text
end

class PageBorder
  attr_accessor :style, :color, :width, :space
end
```

#### 1.2 Page Orientation & Sizes (`demo/7-landscape.ts`, `demo/65-page-sizes.ts`)
**Status:** ⚠️ Partial (need full implementation)
**Complexity:** Low
**Demo Code:**
```typescript
page: {
  size: {
    orientation: PageOrientation.LANDSCAPE,
    height: convertMillimetersToTwip(210),
    width: convertMillimetersToTwip(148),
  },
}
```

**Required Enhancement:**
```ruby
# Enhance lib/uniword/section_properties.rb
class SectionProperties
  attr_accessor :page_width, :page_height
  attr_accessor :page_orientation  # :portrait, :landscape

  PAGE_SIZES = {
    letter: { width: 12240, height: 15840 },  # Twips
    a4: { width: 11906, height: 16838 },
    a3: { width: 16838, height: 23811 },
    legal: { width: 12240, height: 20160 },
  }

  def set_page_size(size_name)
    size = PAGE_SIZES[size_name]
    self.page_width = size[:width]
    self.page_height = size[:height]
  end
end
```

#### 1.3 Multiple Column Layouts (`demo/44-multiple-columns.ts`, `demo/69-different-width-columns.ts`)
**Status:** ❌ Not Implemented
**Complexity:** Medium
**Demo Code:**
```typescript
column: {
  count: 2,
  space: 720,
  equalWidth: false,
  children: [
    new Column({ width: 2880, space: 720 }),
    new Column({ width: 5760 })
  ],
}
```

**Required Implementation:**
```ruby
# lib/uniword/column_configuration.rb
class ColumnConfiguration
  attr_accessor :count
  attr_accessor :equal_width
  attr_accessor :space  # Space between columns
  attr_accessor :columns  # Array of Column objects
end

class Column
  attr_accessor :width
  attr_accessor :space
end

# In SectionProperties:
attr_accessor :columns  # ColumnConfiguration
```

#### 1.4 Line Numbers (`demo/40-line-numbers.ts`, `demo/70-line-numbers-suppression.ts`)
**Status:** ❌ Not Implemented
**Complexity:** Low
**Demo Code:**
```typescript
lineNumbers: {
  countBy: 1,
  restart: LineNumberRestartFormat.CONTINUOUS,
}

// In paragraph:
suppressLineNumbers: true
```

**Required Implementation:**
```ruby
# In lib/uniword/section_properties.rb
class LineNumbering
  attr_accessor :count_by, :start, :restart
  # restart: :continuous, :new_page, :new_section
end

attr_accessor :line_numbering

# In lib/uniword/properties/paragraph_properties.rb
attribute :suppress_line_numbers, :boolean
```

---

### Priority 2: Paragraph Enhancements (1 day)

#### 2.1 Paragraph Borders (`demo/26-paragraph-borders.ts`, `demo/95-paragraph-style-with-shading-and-borders.ts`)
**Status:** ❌ Not Implemented
**Complexity:** Medium
**Demo Code:**
```typescript
border: {
  top: { color: "auto", space: 1, style: BorderStyle.SINGLE, size: 6 },
  bottom: { color: "auto", space: 1, style: BorderStyle.SINGLE, size: 6 },
  left: { ... },
  right: { ... },
  between: { ... },
}
```

**Required Implementation:**
```ruby
# lib/uniword/paragraph_border.rb
class ParagraphBorder
  attr_accessor :top, :bottom, :left, :right, :between
end

class BorderSide
  attr_accessor :style, :color, :width, :space

  STYLES = %i[
    single thick double dotted dashed
    dot_dash triple wave
  ]
end

# In lib/uniword/properties/paragraph_properties.rb
attribute :borders, ParagraphBorder
```

#### 2.2 Positional Tabs (`demo/84-positional-tabs.ts`, `demo/75-tab-stops.ts`)
**Status:** ❌ Not Implemented
**Complexity:** Low
**Demo Code:**
```typescript
new PositionalTab({
  alignment: PositionalTabAlignment.RIGHT,
  relativeTo: PositionalTabRelativeTo.MARGIN,
  leader: PositionalTabLeader.DOT,
})
```

**Required Implementation:**
```ruby
# lib/uniword/positional_tab.rb
class PositionalTab
  attr_accessor :alignment, :relative_to, :leader
  # alignment: :left, :center, :right, :decimal
  # relative_to: :margin, :indent, :page
  # leader: :none, :dot, :hyphen, :underscore
end

# lib/uniword/tab_stop.rb
class TabStop
  attr_accessor :position, :alignment, :leader
end

# In lib/uniword/properties/paragraph_properties.rb
attribute :tab_stops, Array[TabStop]
```

---

### Priority 3: Text and Run Features (1 day)

#### 3.1 Hyperlinks (`demo/35-hyperlinks.ts`)
**Status:** ❌ Not Implemented
**Complexity:** Medium
**Demo Code:**
```typescript
new ExternalHyperlink({
  children: [
    new TextRun({ text: "Anchor Text", style: "Hyperlink" }),
  ],
  link: "http://www.example.com",
})
```

**Required Implementation:**
```ruby
# lib/uniword/hyperlink.rb
class Hyperlink < Element
  attr_accessor :url, :text, :tooltip
  attr_accessor :anchor  # For internal links (bookmarks)
  attr_accessor :runs  # Array of Run objects

  def initialize(url:, text: nil, anchor: nil)
    @url = url
    @text = text
    @anchor = anchor
    @runs = []
  end
end

# In lib/uniword/paragraph.rb
def add_hyperlink(text, url:, **options)
  hyperlink = Hyperlink.new(url: url, text: text)
  run = Run.new
  run.add_text(text)
  apply_run_options(run, options)
  hyperlink.runs << run
  add_run(hyperlink)
  self
end
```

#### 3.2 Text Shading/Background (`demo/46-shading-text.ts`)
**Status:** ⚠️ Partial (have highlight, need shading patterns)
**Complexity:** Low
**Demo Code:**
```typescript
shading: {
  type: ShadingType.REVERSE_DIAGONAL_STRIPE,
  color: "00FFFF",
  fill: "FF0000",
}
```

**Required Enhancement:**
```ruby
# lib/uniword/shading.rb
class Shading
  attr_accessor :type, :color, :fill

  TYPES = %i[
    clear solid horizontal_stripe vertical_stripe
    diagonal_stripe reverse_diagonal_stripe
    diagonal_cross thick_horizontal_stripe
  ]
end

# In lib/uniword/properties/run_properties.rb
attribute :shading, Shading

# In lib/uniword/properties/paragraph_properties.rb
attribute :shading, Shading
```

#### 3.3 Character Spacing & Kerning
**Status:** ❌ Not Implemented
**Complexity:** Low

**Required Implementation:**
```ruby
# In lib/uniword/properties/run_properties.rb
attribute :spacing, :integer  # Character spacing in twips
attribute :kerning, :integer  # Kerning size threshold
attribute :position, :integer  # Raised/lowered position
```

---

### Priority 4: Advanced Document Features (1-2 days)

#### 4.1 Text Frames (`demo/61-text-frame.ts`)
**Status:** ❌ Not Implemented
**Complexity:** High
**Demo Code:**
```typescript
frame: {
  type: "absolute",
  position: { x: 1000, y: 3000 },
  width: 4000,
  height: 1000,
  anchor: {
    horizontal: FrameAnchorType.MARGIN,
    vertical: FrameAnchorType.MARGIN,
  },
}
```

**Required Implementation:**
```ruby
# lib/uniword/text_frame.rb
class TextFrame
  attr_accessor :type  # :absolute, :alignment
  attr_accessor :x, :y, :width, :height
  attr_accessor :horizontal_anchor, :vertical_anchor
  attr_accessor :horizontal_alignment, :vertical_alignment
  attr_accessor :wrap_text, :lock_anchor

  ANCHOR_TYPES = %i[margin page text column]
  ALIGNMENTS = %i[left center right top bottom inside outside]
end

# In lib/uniword/properties/paragraph_properties.rb
attribute :frame, TextFrame
```

#### 4.2 Base64 Image Support (`demo/23-base64-images.ts`)
**Status:** ⚠️ Likely supported, needs verification
**Complexity:** Low

**Verify/Enhance:**
```ruby
# In lib/uniword/image.rb
def self.from_base64(base64_data, **options)
  binary_data = Base64.decode64(base64_data)
  from_data(binary_data, **options)
end
```

#### 4.3 Table Border Enhancements (`demo/49-table-borders.ts`)
**Status:** ⚠️ Have TableBorder, verify completeness
**Complexity:** Low

**Verify:**
- [ ] All border styles supported
- [ ] Inside horizontal/vertical borders
- [ ] TableBorders.NONE convenience object

---

### Phase 3: Math Support (3-4 days) - DEFERRED

#### Math Equations (`demo/55-math.ts`)
**Status:** ❌ Not Implemented - Complex feature
**Complexity:** Very High
**Decision:** Defer to Phase 3 due to complexity

**Required (Future):**
- MathML/OMML support
- MathRun, MathFraction, MathRadical, MathSum, MathIntegral
- MathSuperScript, MathSubScript, MathFunction
- MathBrackets (round, square, curly, angled)

---

## Implementation Plan

### Week 1: Priority 1 & 2 Features (5-7 days)

**Day 1-2: Page & Document Features**
- [ ] Page borders implementation
- [ ] Page orientation & sizes
- [ ] Column layouts
- [ ] Line numbering

**Day 3: Paragraph Enhancements**
- [ ] Paragraph borders
- [ ] Positional tabs & tab stops

**Day 4: Text & Run Features**
- [ ] Hyperlinks (external & internal)
- [ ] Text shading patterns
- [ ] Character spacing & kerning

**Day 5-7: Advanced Features & Testing**
- [ ] Text frames
- [ ] Verify/enhance base64 images
- [ ] Verify/enhance table borders
- [ ] Comprehensive testing

---

## Testing Requirements

For each new feature, create:
1. **Unit tests** in `spec/uniword/`
2. **Integration tests** matching docx-js demos
3. **Round-trip tests** (create → save → load → verify)
4. **OOXML serialization tests**

### Test File Structure
```
spec/uniword/
  page_borders_spec.rb
  hyperlink_spec.rb
  text_frame_spec.rb
  paragraph_border_spec.rb
  positional_tab_spec.rb
  shading_spec.rb

spec/integration/
  docx_js_compat/
    page_borders_spec.rb
    hyperlinks_spec.rb
    # ... one per demo
```

---

## Success Criteria

- [ ] All 14 missing features implemented
- [ ] 100% of docx-js demos reproducible in Uniword
- [ ] Comprehensive test coverage (>95%)
- [ ] Documentation for each feature
- [ ] Examples in `examples/` directory
- [ ] No regression in existing features

---

## Dependencies

### Ruby Gems (already available)
- `lutaml-model` ~> 0.7 (serialization)
- `nokogiri` (XML parsing)
- `zip` (DOCX packaging)

### No New Dependencies Required
All features can be implemented with existing gem stack.

---

## Notes

1. **Immutability Pattern**: Properties classes use Value Object pattern - ensure this is maintained
2. **Lutaml::Model**: Use for all serializable classes
3. **Namespaces**: Follow OOXML namespace conventions
4. **Backward Compatibility**: Don't break existing API
5. **Documentation**: Each feature needs AsciiDoc documentation in README.adoc

---

## Next Steps

1. ✅ Complete this audit (DONE)
2. ⏭️ Begin Priority 1 implementation
3. ⏭️ Create demo compatibility tests
4. ⏭️ Update DEVELOPMENT_PLAN.md with progress

---

**Last Updated:** 2025-10-25
**Reviewer:** Kilo Code
**Status:** READY FOR IMPLEMENTATION