# Phase 5 Session 2B: DrawingML Classes - STATUS

**Goal**: Create DrawingML classes to model nested content
**Duration**: 2-3 hours
**Started**: Not yet
**Status**: Ready to begin

## Progress Overview

| Task | Duration | Status | Files | Tests |
|------|----------|--------|-------|-------|
| Task 1: Core Drawing Classes | 60 min | ⏳ Pending | 0/4 | - |
| Task 2: Inline Class | 45 min | ⏳ Pending | 0/1 | - |
| Task 3: Anchor Class | 30 min | ⏳ Pending | 0/1 | - |
| Task 4: Graphic Classes | 45 min | ⏳ Pending | 0/3 | - |
| Task 5: Testing | 30 min | ⏳ Pending | - | 0/0 |
| **Total** | **3.5 hours** | **0%** | **0/9** | **258/258** |

## Task 1: Core Drawing Classes (60 min) ⏳

### 1.1 Create Drawing Container (15 min) ⏳
- [ ] Create `lib/uniword/wordprocessingml/drawing.rb`
- [ ] Add inline, anchor attributes
- [ ] Add xml mapping with WordProcessingML namespace
- [ ] Verify Pattern 0 compliance

### 1.2 Create Extent (10 min) ⏳
- [ ] Create `lib/uniword/wp_drawing/extent.rb`
- [ ] Add cx, cy attributes (:integer)
- [ ] Add xml mapping with WordProcessingDrawing namespace
- [ ] Verify Pattern 0 compliance

### 1.3 Create DocProperties (15 min) ⏳
- [ ] Create `lib/uniword/wp_drawing/doc_properties.rb`
- [ ] Add id, name, descr attributes
- [ ] Add xml mapping with WordProcessingDrawing namespace
- [ ] Verify Pattern 0 compliance

### 1.4 Create NonVisualDrawingProps (20 min) ⏳
- [ ] Create `lib/uniword/wp_drawing/non_visual_drawing_props.rb`
- [ ] Add basic structure (locks future)
- [ ] Add xml mapping with WordProcessingDrawing namespace
- [ ] Verify Pattern 0 compliance

## Task 2: Inline Class (45 min) ⏳

### 2.1 Create Inline Container (30 min) ⏳
- [ ] Create `lib/uniword/wp_drawing/inline.rb`
- [ ] Add distance attributes (distT, distB, distL, distR)
- [ ] Add extent, doc_properties, non_visual_props, graphic
- [ ] Add xml mapping with WordProcessingDrawing namespace
- [ ] Verify Pattern 0 compliance

### 2.2 Add Autoloads (15 min) ⏳
- [ ] Update `lib/uniword/wp_drawing.rb` with autoloads
- [ ] Verify all classes auto-load correctly

## Task 3: Anchor Class (30 min) ⏳

### 3.1 Create Anchor Container (30 min) ⏳
- [ ] Create `lib/uniword/wp_drawing/anchor.rb`
- [ ] Add all Inline attributes
- [ ] Add positioning attributes (positionH, positionV, etc.)
- [ ] Add xml mapping with WordProcessingDrawing namespace
- [ ] Verify Pattern 0 compliance

## Task 4: Graphic Classes (45 min) ⏳

### 4.1 Create Graphic (15 min) ⏳
- [ ] Create `lib/uniword/drawingml/graphic.rb`
- [ ] Add graphic_data attribute
- [ ] Add xml mapping with DrawingML namespace
- [ ] Verify Pattern 0 compliance

### 4.2 Create GraphicData (15 min) ⏳
- [ ] Create `lib/uniword/drawingml/graphic_data.rb`
- [ ] Add uri, picture attributes
- [ ] Add xml mapping with DrawingML namespace
- [ ] Verify Pattern 0 compliance

### 4.3 Create/Enhance Picture (15 min) ⏳
- [ ] Check if `lib/uniword/drawingml/picture.rb` exists
- [ ] Create or enhance Picture class
- [ ] Add xml mapping with Picture namespace
- [ ] Verify Pattern 0 compliance

## Task 5: Testing (30 min) ⏳

### 5.1 Unit Tests (15 min) ⏳
- [ ] Test Drawing instantiation
- [ ] Test Inline with all attributes
- [ ] Test XML serialization

### 5.2 Integration Test (15 min) ⏳
- [ ] Create complete Drawing → Inline → Graphic chain
- [ ] Verify namespace handling
- [ ] Test round-trip if applicable

### 5.3 Baseline Verification ⏳
- [ ] Run baseline tests: `bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb spec/uniword/theme_roundtrip_spec.rb`
- [ ] Verify: 258/258 still passing ✅

## Files to Create

### WordProcessingML (1 file)
- [ ] `lib/uniword/wordprocessingml/drawing.rb`

### WP Drawing (5 files)
- [ ] `lib/uniword/wp_drawing/extent.rb`
- [ ] `lib/uniword/wp_drawing/doc_properties.rb`
- [ ] `lib/uniword/wp_drawing/non_visual_drawing_props.rb`
- [ ] `lib/uniword/wp_drawing/inline.rb`
- [ ] `lib/uniword/wp_drawing/anchor.rb`

### DrawingML (3 files)
- [ ] `lib/uniword/drawingml/graphic.rb`
- [ ] `lib/uniword/drawingml/graphic_data.rb`
- [ ] `lib/uniword/drawingml/picture.rb` (or enhance existing)

### Autoloads (1 file)
- [ ] Update `lib/uniword/wp_drawing.rb`

## Test Results

### Current Baseline
- StyleSet Round-Trip: 12/12 ✅
- Theme Round-Trip: 29/29 ✅
- **Total: 258/258 (100%)** ✅

### After Session 2B (Expected)
- StyleSet Round-Trip: 12/12 ✅
- Theme Round-Trip: 29/29 ✅
- **Total: 258/258 (100%)** ✅
- **No regressions allowed!**

## Architecture Quality Checklist

### Pattern 0 Compliance
- [ ] All classes: Attributes BEFORE xml blocks
- [ ] No violations in any file

### Model-Driven Architecture
- [ ] NO :string storage for XML content
- [ ] All nested content is proper model classes
- [ ] Drawing contains Inline/Anchor (not :string)
- [ ] Inline contains Extent, DocProperties, etc. (not :string)

### MECE Design
- [ ] Each class has single responsibility
- [ ] No overlapping concerns
- [ ] Clear separation between WP Drawing and DrawingML

### Namespace Handling
- [ ] Each class defines its own namespace
- [ ] Correct namespace used (WordProcessingML, WordProcessingDrawing, DrawingML, Picture)
- [ ] No namespace conflicts

### Optional Elements
- [ ] All optional elements use render_nil: false
- [ ] All optional attributes use render_nil: false

## Critical Reminders

1. ⚠️ **ALWAYS use `bundle exec` with Ruby commands!**
2. 🚨 **Pattern 0**: Attributes BEFORE xml (ALWAYS)
3. 🏗️ **Model-Driven**: NO :string for XML content
4. 🔧 **Namespace**: Each class defines its own
5. 📦 **Mixed Content**: Use for elements with nested content
6. ✨ **Render Nil**: Use for optional elements
7. ✅ **Zero Regressions**: Baseline must stay at 258/258

## Next Session

After Session 2B completion:
- **Session 2C**: Integration (1-2 hours)
  - Replace :string in Choice/Fallback with Drawing/Pict
  - Test AlternateContent with proper models
  - Verify round-trip improvements

## Session 2A Summary (Completed ✅)

- Duration: 45 minutes (vs 2-3 hours estimated)
- Files Created: 3 (TextBoxContent, Pict, Wrap)
- Files Enhanced: 3 (VML Textbox, Shape, vml.rb)
- Tests: 258/258 passing ✅
- Architecture: 100% Pattern 0, Model-driven, MECE ✅