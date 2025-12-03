# Phase 5 Session 2B: DrawingML Classes - PLAN

**Goal**: Create DrawingML classes to replace :string content in Choice/Fallback
**Duration**: 2-3 hours (compressed timeline)
**Status**: Ready to begin
**Prerequisite**: Session 2A Complete ✅

## Context

Session 2A successfully created foundation classes:
- ✅ TextBoxContent (shared by VML/DrawingML)
- ✅ Pict (VML picture container)
- ✅ VML Textbox and Wrap
- ✅ Enhanced VML Shape

**Current Problem**: Choice and Fallback still store :string content instead of proper DrawingML models.

**The Goal**: Create DrawingML classes so we can replace:
```ruby
# ❌ WRONG (Current)
class Choice
  attribute :content, :string
end

# ✅ CORRECT (Target)
class Choice
  attribute :drawing, Drawing
end
```

## DrawingML Class Hierarchy

```
Drawing (w:drawing)
├── Inline (wp:inline) - Inline with text
│   ├── Extent (wp:extent) - Size
│   ├── DocProperties (wp:docPr) - Properties
│   ├── NonVisualDrawingProps (wp:cNvGraphicFramePr) - Non-visual props
│   └── Graphic (a:graphic) - The actual graphic
│       └── GraphicData (a:graphicData)
│           └── Picture (pic:pic)
│               ├── NonVisualPictureProperties (pic:nvPicPr)
│               └── BlipFill (pic:blipFill)
│                   └── Blip (a:blip)
│
└── Anchor (wp:anchor) - Positioned/floating
    ├── Same structure as Inline
    └── Additional positioning attributes
```

## Session 2B Task Breakdown

### Task 1: Create Core Drawing Classes (60 min)

**1.1 Create Drawing Container (15 min)**
- File: `lib/uniword/wordprocessingml/drawing.rb`
- Attributes: inline, anchor (both optional)
- Namespace: WordProcessingML

**1.2 Create Extent (10 min)**
- File: `lib/uniword/wp_drawing/extent.rb`
- Attributes: cx (width), cy (height) - both :integer
- Namespace: WordProcessingDrawing

**1.3 Create DocProperties (15 min)**
- File: `lib/uniword/wp_drawing/doc_properties.rb`
- Attributes: id, name, descr (all :string)
- Namespace: WordProcessingDrawing

**1.4 Create NonVisualDrawingProps (20 min)**
- File: `lib/uniword/wp_drawing/non_visual_drawing_props.rb`
- Attributes: locks (future)
- Namespace: WordProcessingDrawing

### Task 2: Create Inline Class (45 min)

**2.1 Create Inline Container (30 min)**
- File: `lib/uniword/wp_drawing/inline.rb`
- Attributes:
  - distT, distB, distL, distR (:integer) - distances
  - extent (Extent)
  - doc_properties (DocProperties)
  - non_visual_props (NonVisualDrawingProps)
  - graphic (Graphic)
- Namespace: WordProcessingDrawing

**2.2 Add Autoloads (15 min)**
- Update `lib/uniword/wp_drawing.rb` with autoloads

### Task 3: Create Anchor Class (30 min)

**3.1 Create Anchor Container (30 min)**
- File: `lib/uniword/wp_drawing/anchor.rb`
- Attributes: Same as Inline PLUS:
  - positionH, positionV (positioning)
  - simplePos (boolean)
  - relativeHeight (:integer)
  - allowOverlap (boolean)
  - layoutInCell (boolean)
- Namespace: WordProcessingDrawing

### Task 4: Create Graphic Classes (45 min)

**4.1 Create Graphic (15 min)**
- File: `lib/uniword/drawingml/graphic.rb`
- Attributes: graphic_data (GraphicData)
- Namespace: DrawingML

**4.2 Create GraphicData (15 min)**
- File: `lib/uniword/drawingml/graphic_data.rb`
- Attributes: uri (:string), picture (Picture)
- Namespace: DrawingML

**4.3 Create Picture Reference (15 min)**
- File: `lib/uniword/drawingml/picture.rb` (if not exists)
- Or enhance existing Picture class
- Namespace: Picture namespace

### Task 5: Test DrawingML Classes (30 min)

**5.1 Unit Tests (15 min)**
```bash
bundle exec ruby -e "require './lib/uniword'; \
  drawing = Uniword::Wordprocessingml::Drawing.new; \
  puts drawing.to_xml"
```

**5.2 Integration Test (15 min)**
- Create Drawing with Inline
- Verify XML serialization
- Test namespace handling

**5.3 Baseline Verification**
```bash
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb
```
**MUST**: 258/258 still passing ✅

## Session 2B Success Criteria

- [ ] Drawing class created
- [ ] Extent, DocProperties, NonVisualDrawingProps created
- [ ] Inline class created with all attributes
- [ ] Anchor class created with positioning
- [ ] Graphic and GraphicData created
- [ ] All classes follow Pattern 0 (attributes BEFORE xml)
- [ ] All classes are model-driven (NO :string content)
- [ ] Baseline tests: 258/258 still passing ✅
- [ ] Ready for Session 2C (Integration)

## Implementation Guidelines

### Pattern 0 (CRITICAL)
```ruby
# ✅ CORRECT - Attributes BEFORE xml
class MyClass < Lutaml::Model::Serializable
  attribute :my_attr, MyType  # FIRST
  
  xml do
    root 'elementName'
    namespace Uniword::Ooxml::Namespaces::NamespaceName
    map_element 'elem', to: :my_attr
  end
end
```

### Namespace Patterns

**WordProcessingML** (w:):
```ruby
namespace Uniword::Ooxml::Namespaces::WordProcessingML
```

**WordProcessingDrawing** (wp:):
```ruby
namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
```

**DrawingML** (a:):
```ruby
namespace Uniword::Ooxml::Namespaces::DrawingML
```

**Picture** (pic:):
```ruby
namespace Uniword::Ooxml::Namespaces::Picture
```

### Mixed Content
Use for elements with nested content:
```ruby
xml do
  root 'elementName'
  namespace ...
  mixed_content  # Add this!
end
```

### Optional Elements
Use render_nil: false:
```ruby
map_element 'elem', to: :attr, render_nil: false
map_attribute 'attr', to: :attr, render_nil: false
```

### Collection Attributes
Use collection: true for arrays:
```ruby
attribute :items, Item, collection: true, default: -> { [] }
```

## Critical Reminders

1. **ALWAYS use `bundle exec` with Ruby commands!**
2. **Pattern 0**: Attributes BEFORE xml (ALWAYS)
3. **Model-Driven**: NO :string for XML content
4. **Namespace**: Each class defines its own
5. **Mixed Content**: Use for elements with nested content
6. **Render Nil**: Use for optional elements
7. **Zero Regressions**: Baseline must stay at 258/258

## After Session 2B

Proceed to:
- **Session 2C**: Integration (replace :string in Choice/Fallback)
- **Session 2D**: Verification (test round-trip, achieve 274/274)

## Timeline

- Session 2A: ✅ 45 minutes (COMPLETE)
- Session 2B: ⏳ 2-3 hours (Current)
- Session 2C: ⏳ 1-2 hours
- Session 2D: ⏳ 1 hour
- **Total**: 274/274 tests (100%) ✅

## Reference Documents

- `PHASE5_SESSION2A_COMPLETE.md` - Session 2A summary
- `PHASE5_SESSION2_PLAN.md` - Overall Session 2 plan
- `PHASE5_SESSION1_COMPLETE.md` - AlternateContent infrastructure
- Memory Bank: `.kilocode/rules/memory-bank/architecture.md`