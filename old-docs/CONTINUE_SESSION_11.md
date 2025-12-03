# Continue Session 11: PresentationML Namespace

## Context

You are continuing Uniword v2.0 development. Session 10 completed Chart namespace with 70 elements. The project is now at 80.5% completion (612/760 elements, 16/30 namespaces).

**Current Status**:
- Progress: 80.5% (612/760 elements, 16/30 namespaces)
- Completed: WordProcessingML (100), Math (65), DrawingML (92), Picture (10), Relationships (5), WP Drawing (27), Content Types (3), VML (15), Office (40), VML Office (25), Document Properties (20), Word 2010 (25), Word 2013 (20), Word 2016 (15), SpreadsheetML (83), Chart (70)
- Infrastructure: SchemaLoader, ModelGenerator, autoload pattern - all working perfectly
- Velocity: ~35 elements/hour (maintained high velocity!)

## Session 11 Objectives

**Target**: Add 50 elements (PresentationML: p:)
**Duration**: 3-4 hours
**Expected Progress**: 80.5% → 87.1%

### Task 1: Create PresentationML Schema (+50 elements)

**File**: `config/ooxml/schemas/presentationml.yml`

PresentationML namespace (p:) provides PowerPoint presentation integration for embedding slides in Word documents.

**Namespace**:
```yaml
namespace:
  uri: 'http://schemas.openxmlformats.org/presentationml/2006/main'
  prefix: 'p'
  description: 'PresentationML - PowerPoint presentation structure and formatting'
```

**Key Element Groups** (50 total):

#### 1. Presentation Structure (10 elements)
- `presentation` - Presentation root element
- `sldMasterIdLst` - Slide master ID list
- `sldIdLst` - Slide ID list
- `notesMasterIdLst` - Notes master ID list
- `handoutMasterIdLst` - Handout master ID list
- `sldSz` - Slide size
- `notesSz` - Notes page size
- `defaultTextStyle` - Default text style
- `colorMap` - Color map
- `embeddedFont` - Embedded font

#### 2. Slide Elements (15 elements)
- `sld` - Slide
- `sldLayout` - Slide layout
- `sldMaster` - Slide master
- `notes` - Notes slide
- `handoutMaster` - Handout master
- `cSld` - Common slide data
- `spTree` - Shape tree
- `sp` - Shape
- `pic` - Picture
- `graphicFrame` - Graphic frame
- `grpSp` - Group shape
- `cxnSp` - Connection shape
- `nvSpPr` - Non-visual shape properties
- `spPr` - Shape properties
- `txBody` - Text body

#### 3. Text & Formatting (10 elements)
- `txBody` - Text body
- `bodyPr` - Body properties
- `lstStyle` - List style
- `p` - Paragraph
- `r` - Run
- `br` - Break
- `fld` - Field
- `endParaRPr` - End paragraph run properties
- `pPr` - Paragraph properties
- `rPr` - Run properties

#### 4. Animations & Transitions (8 elements)
- `timing` - Timing
- `tnLst` - Time node list
- `par` - Parallel time node
- `seq` - Sequence time node
- `cTn` - Common time node
- `stCondLst` - Start conditions list
- `endCondLst` - End conditions list
- `transition` - Slide transition

#### 5. Media & Content (7 elements)
- `pic` - Picture reference
- `video` - Video
- `audio` - Audio
- `oleObj` - OLE object
- `embed` - Embedded object
- `extLst` - Extension list
- `ext` - Extension

**Schema Structure Example**:
```yaml
elements:
  presentation:
    class_name: Presentation
    description: 'Presentation root element'
    attributes:
      - name: sld_master_id_lst
        type: SlideM

asterIdList
        xml_name: sldMasterIdLst
        description: 'Slide master ID list'
      - name: sld_id_lst
        type: SlideIdList
        xml_name: sldIdLst
        required: true
        description: 'Slide ID list'
      - name: sld_sz
        type: SlideSize
        xml_name: sldSz
        required: true
        description: 'Slide size'
      - name: notes_sz
        type: NotesSize
        xml_name: notesSz
        required: true
        description: 'Notes page size'
      - name: default_text_style
        type: String
        xml_name: defaultTextStyle
        description: 'Default text style'
  
  sld:
    class_name: Slide
    description: 'Presentation slide'
    attributes:
      - name: c_sld
        type: CommonSlideData
        xml_name: cSld
        required: true
        description: 'Common slide data'
      - name: clr_map_ovr
        type: String
        xml_name: clrMapOvr
        description: 'Color map override'
      - name: transition
        type: Transition
        xml_name: transition
        description: 'Slide transition'
      - name: timing
        type: Timing
        xml_name: timing
        description: 'Slide timing'
      - name: show_master_sp
        type: String
        xml_name: showMasterSp
        xml_attribute: true
        description: 'Show master shapes flag'
```

### Task 2: Generate Classes

Use proven generation pattern:

```ruby
require_relative 'lib/uniword/schema/model_generator'

gen = Uniword::Schema::ModelGenerator.new('presentationml')
results = gen.generate_all
puts "Generated #{results.size} PresentationML classes"
```

### Task 3: Create Autoload Index

**File**: `lib/generated/presentationml.rb`

Pattern:
```ruby
module Uniword
  module Generated
    module Presentationml
      autoload :Presentation, File.expand_path('presentationml/presentation', __dir__)
      autoload :Slide, File.expand_path('presentationml/slide', __dir__)
      # ... 48 more autoloads
    end
  end
end
```

### Task 4: Test Everything

Create `test_session11_autoload.rb`:
```ruby
require_relative 'lib/generated/presentationml'

puts "Testing PresentationML namespace (p:)..."
sample_classes = [
  Uniword::Generated::Presentationml::Presentation,
  Uniword::Generated::Presentationml::Slide,
  Uniword::Generated::Presentationml::SlideLayout,
  Uniword::Generated::Presentationml::SlideMaster,
  Uniword::Generated::Presentationml::CommonSlideData,
  Uniword::Generated::Presentationml::ShapeTree,
  Uniword::Generated::Presentationml::Shape
]
puts "✅ Loaded #{sample_classes.size} sample classes"
```

### Task 5: Update Documentation

1. Update `docs/V2.0_IMPLEMENTATION_STATUS.md`:
   - Progress: 80.5% → 87.1%
   - Elements: 612 → 662 (+50)
   - Namespaces: 16 → 17 (+1)

2. Create `SESSION_11_SUMMARY.md`

3. Move Session 10 docs to `old-docs/`:
   - `SESSION_10_SUMMARY.md`
   - `generate_session10_classes.rb`
   - `test_session10_autoload.rb`
   - `fix_chart_schema.rb`

## Critical Reminders

1. **Pattern 0 Compliance**: ALWAYS declare attributes BEFORE xml blocks
2. **Type Consistency**: Use `:string` and `:integer` (symbols) for primitives
3. **Collections**: Use `collection: true` for arrays
4. **Cross-Namespace**: Use `String` type for cross-namespace references
5. **Namespace URI**: Use exact OpenXML namespace URI
6. **Testing**: Verify autoload after generation

## Expected Deliverables

1. ✅ `presentationml.yml` created (50 elements)
2. ✅ 50+ new classes generated
3. ✅ Autoload index created
4. ✅ All tests passing
5. ✅ Documentation updated
6. ✅ SESSION_11_SUMMARY.md created

## Success Criteria

- [ ] PresentationML namespace complete (50 elements)
- [ ] All classes generated without errors
- [ ] Autoload working correctly
- [ ] Pattern 0 compliance: 100%
- [ ] Zero syntax errors
- [ ] Progress: 87.1% overall (662/760 elements)

## Architecture Notes

### PresentationML Integration Strategy

PresentationML namespace is critical for:
1. **PowerPoint Integration**: Embed slides in Word documents
2. **Slide Structure**: Complete slide hierarchy (masters, layouts, slides)
3. **Shapes & Graphics**: Visual elements on slides
4. **Animations**: Slide transitions and animations
5. **Media Support**: Video, audio, embedded objects

### Namespace Dependencies

```
PresentationML (p:) relies on:
- DrawingML (a:) - for graphic elements
- Relationships (r:) - for linking slides
- Office (o:) - for OLE objects
```

### Key Design Decisions

1. **Slide Hierarchy**: Master → Layout → Slide
2. **Shape Model**: Consistent with DrawingML
3. **Text Model**: Paragraph and run structure
4. **Animation Model**: Time nodes and sequences
5. **Media Model**: Embedded and linked content

## Phase 2 Progress Tracker

### Completed (662/760 = 87.1% after Session 11)
- ✅ Sessions 1-10: 612 elements
- 🎯 Session 11: PresentationML (50 elements)

### Remaining After Session 11 (98/760 = 12.9% remaining)
High priority:
- Custom XML (cxml:): 30 elements
- Bibliography (b:): 25 elements
- Remaining 12 namespaces: 43 elements

**Timeline**: 1-2 more sessions to complete Phase 2

## Performance Target

With velocity of 35+ elements/hour:
- Session 11: 50 elements → 3-4 hours
- Remaining: ~100 elements → 2 sessions
- Phase 2 completion: Day 6 (3 days ahead of schedule!)

## Next Session Preview

### Session 12: Custom XML + Bibliography
- **Target**: ~55 elements (cxml: + b: namespaces)
- **Focus**: Custom XML parts and bibliography/citations
- **Expected Progress**: 87.1% → 94.3%

Good luck with Session 11! 🚀