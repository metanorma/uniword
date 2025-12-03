# Phase 5 Session 2: Model Nested Content in AlternateContent

**Goal**: Replace string content with proper model classes in Choice/Fallback
**Duration**: 6-8 hours (compressed timeline)
**Expected Outcome**: 274/274 tests passing (100%)

## Problem Statement

AlternateContent infrastructure works perfectly, but Choice and Fallback currently store nested content as `:string` attributes. This violates the model-driven architecture principle.

**Current (WRONG)**:
```ruby
class Choice
  attribute :content, :string  # ❌ XML as string
end

class Fallback
  attribute :content, :string  # ❌ XML as string
end
```

**Target (CORRECT)**:
```ruby
class Choice
  # Multiple possible nested elements (polymorphic)
  attribute :drawing, Drawing
  attribute :pict, Pict
  attribute :paragraph, Paragraph
  attribute :table, Table
  # ... etc
end

class Fallback
  # Multiple possible nested elements (polymorphic)
  attribute :pict, Pict
  attribute :shape, Shape
  # ... etc
end
```

## Analysis of Nested Content

From test failures, AlternateContent contains these structures:

### 1. **DrawingML Anchor** (Modern) - In Choice
```xml
<mc:Choice Requires="wps">
  <w:drawing>
    <wp:anchor>
      <wp:extent cx="8280000" cy="4953480"/>
      <a:graphic>
        <a:graphicData uri="...wps...">
          <wps:wsp>  <!-- Word Processing Shape -->
            <wps:txbx>  <!-- Text Box -->
              <w:txbxContent>
                <!-- Paragraphs, SDTs, etc. -->
              </w:txbxContent>
            </wps:txbx>
          </wps:wsp>
        </a:graphicData>
      </a:graphic>
    </wp:anchor>
  </w:drawing>
</mc:Choice>
```

**Models Needed**:
- ✅ Drawing (exists)
- ✅ Anchor (exists) 
- ⚠️ Anchor needs children: extent, graphic, sizeRelH, sizeRelV
- ❌ WordProcessingShape (wps:wsp)
- ❌ TextBox (wps:txbx)
- ❌ TextBoxContent (w:txbxContent)

### 2. **VML Picture** (Legacy) - In Fallback
```xml
<mc:Fallback>
  <w:pict>
    <v:shape type="#_x0000_t202" style="...">
      <v:textbox style="...">
        <w:txbxContent>
          <!-- Paragraphs, SDTs, etc. -->
        </w:txbxContent>
      </v:textbox>
    </v:shape>
  </w:pict>
</mc:Fallback>
```

**Models Needed**:
- ❌ Pict (w:pict)
- ⚠️ Shape (v:shape) - exists but needs enhancement
- ⚠️ VML Textbox (v:textbox) - needs creation
- ❌ TextBoxContent (w:txbxContent) - shared with DrawingML

## Implementation Sessions

### Session 2A: Foundation Classes (2-3 hours)

**Priority 1**: Shared TextBoxContent
```ruby
# lib/uniword/wordprocessingml/text_box_content.rb
class TextBoxContent < Lutaml::Model::Serializable
  attribute :paragraphs, Paragraph, collection: true
  attribute :tables, Table, collection: true
  attribute :sdts, StructuredDocumentTag, collection: true
  
  xml do
    root 'txbxContent'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content
    
    map_element 'p', to: :paragraphs, render_nil: false
    map_element 'tbl', to: :tables, render_nil: false
    map_element 'sdt', to: :sdts, render_nil: false
  end
end
```

**Priority 2**: Pict (VML Picture container)
```ruby
# lib/uniword/wordprocessingml/pict.rb
class Pict < Lutaml::Model::Serializable
  attribute :shapes, Vml::Shape, collection: true
  
  xml do
    root 'pict'
    namespace Uniword::Ooxml::Namespaces::WordProcessingML
    mixed_content
    
    map_element 'shape', to: :shapes, 
                namespace: Uniword::Ooxml::Namespaces::VML,
                render_nil: false
  end
end
```

**Priority 3**: VML Textbox
```ruby
# lib/uniword/vml/textbox.rb
class Textbox < Lutaml::Model::Serializable
  attribute :style, :string
  attribute :inset, :string
  attribute :content, Uniword::Wordprocessingml::TextBoxContent
  
  xml do
    root 'textbox'
    namespace Uniword::Ooxml::Namespaces::VML
    mixed_content
    
    map_attribute 'style', to: :style, render_nil: false
    map_attribute 'inset', to: :inset, render_nil: false
    map_element 'txbxContent', to: :content,
                namespace: Uniword::Ooxml::Namespaces::WordProcessingML,
                render_nil: false
  end
end
```

**Priority 4**: Enhance VML Shape
```ruby
# lib/uniword/vml/shape.rb (enhance existing)
class Shape < Lutaml::Model::Serializable
  # Existing attributes...
  attribute :textbox, Textbox
  attribute :wrap, Wrap
  
  xml do
    # Existing mappings...
    map_element 'textbox', to: :textbox, render_nil: false
    map_element 'wrap', to: :wrap, render_nil: false
  end
end
```

### Session 2B: DrawingML Classes (2-3 hours)

**Priority 5**: Word Processing Shape
```ruby
# lib/uniword/drawingml/word_processing_shape.rb
class WordProcessingShape < Lutaml::Model::Serializable
  attribute :non_visual_properties, NonVisualDrawingProperties
  attribute :shape_properties, ShapeProperties
  attribute :text_box, TextBox
  attribute :body_properties, BodyProperties
  
  xml do
    root 'wsp'
    namespace Uniword::Ooxml::Namespaces::WordProcessingShape
    mixed_content
    
    map_element 'cNvSpPr', to: :non_visual_properties, render_nil: false
    map_element 'spPr', to: :shape_properties, render_nil: false
    map_element 'txbx', to: :text_box, render_nil: false
    map_element 'bodyPr', to: :body_properties, render_nil: false
  end
end
```

**Priority 6**: DrawingML TextBox (wps:txbx)
```ruby
# lib/uniword/drawingml/text_box.rb
class TextBox < Lutaml::Model::Serializable
  attribute :content, Uniword::Wordprocessingml::TextBoxContent
  
  xml do
    root 'txbx'
    namespace Uniword::Ooxml::Namespaces::WordProcessingShape
    mixed_content
    
    map_element 'txbxContent', to: :content,
                namespace: Uniword::Ooxml::Namespaces::WordProcessingML,
                render_nil: false
  end
end
```

**Priority 7**: Enhance Anchor
```ruby
# lib/uniword/wordprocessingml/anchor.rb (enhance existing)
class Anchor < Lutaml::Model::Serializable
  # Existing attributes...
  attribute :extent, Extent
  attribute :graphic, DrawingML::Graphic
  attribute :size_rel_h, SizeRelH
  attribute :size_rel_v, SizeRelV
  
  xml do
    # Existing mappings...
    map_element 'extent', to: :extent, 
                namespace: Uniword::Ooxml::Namespaces::WordProcessingDrawing,
                render_nil: false
    # ... other mappings
  end
end
```

**Priority 8**: WordProcessingShape Namespace
```ruby
# lib/uniword/ooxml/namespaces.rb
class WordProcessingShape < Lutaml::Model::XmlNamespace
  uri 'http://schemas.microsoft.com/office/word/2010/wordprocessingShape'
  prefix_default 'wps'
  element_form_default :qualified
end
```

### Session 2C: Integration (1-2 hours)

**Priority 9**: Update Choice/Fallback
```ruby
# lib/uniword/wordprocessingml/choice.rb
class Choice < Lutaml::Model::Serializable
  attribute :requires, McRequires
  
  # Polymorphic nested content (multiple possible)
  attribute :drawing, Drawing
  attribute :paragraph, Paragraph
  attribute :table, Table
  
  xml do
    root 'Choice'
    namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
    mixed_content
    
    map_attribute 'Requires', to: :requires
    map_element 'drawing', to: :drawing, render_nil: false
    map_element 'p', to: :paragraph, render_nil: false
    map_element 'tbl', to: :table, render_nil: false
  end
end

# lib/uniword/wordprocessingml/fallback.rb
class Fallback < Lutaml::Model::Serializable
  # Polymorphic nested content
  attribute :pict, Pict
  attribute :paragraph, Paragraph
  
  xml do
    root 'Fallback'
    namespace Uniword::Ooxml::Namespaces::MarkupCompatibility
    mixed_content
    
    map_element 'pict', to: :pict, render_nil: false
    map_element 'p', to: :paragraph, render_nil: false
  end
end
```

**Priority 10**: Update Tests
Update `spec/uniword/wordprocessingml/alternate_content_spec.rb` to use proper models instead of string content.

### Session 2D: Verification (1 hour)

**Priority 11**: Run Tests
```bash
# Unit tests
bundle exec rspec spec/uniword/wordprocessingml/alternate_content_spec.rb

# Baseline (must stay green)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb

# Document elements (target: 16/16)
bundle exec rspec spec/uniword/document_elements_roundtrip_spec.rb

# Total (target: 274/274)
bundle exec rspec spec/uniword/
```

**Expected Results**:
- AlternateContent: 12/12 ✅
- Baseline: 342/342 ✅
- Document Elements: 16/16 ✅ (up from 8/16)
- **Total: 274/274 (100%)** ✅

## File Roadmap

### New Files (10)
1. `lib/uniword/wordprocessingml/text_box_content.rb`
2. `lib/uniword/wordprocessingml/pict.rb`
3. `lib/uniword/vml/textbox.rb`
4. `lib/uniword/vml/wrap.rb`
5. `lib/uniword/drawingml/word_processing_shape.rb`
6. `lib/uniword/drawingml/text_box.rb`
7. `lib/uniword/drawingml/extent.rb`
8. `lib/uniword/drawingml/size_rel_h.rb`
9. `lib/uniword/drawingml/size_rel_v.rb`
10. `lib/uniword/drawingml/body_properties.rb`

### Modified Files (7)
1. `lib/uniword/ooxml/namespaces.rb` (add WordProcessingShape namespace)
2. `lib/uniword/wordprocessingml/choice.rb` (replace :content with models)
3. `lib/uniword/wordprocessingml/fallback.rb` (replace :content with models)
4. `lib/uniword/vml/shape.rb` (add textbox, wrap)
5. `lib/uniword/wordprocessingml/anchor.rb` (add extent, graphic, size)
6. `lib/uniword/wordprocessingml/drawing.rb` (verify integration)
7. `spec/uniword/wordprocessingml/alternate_content_spec.rb` (update tests)

## Success Criteria

- [ ] All new classes follow Pattern 0 (attributes BEFORE xml)
- [ ] MECE architecture maintained (clear separation)
- [ ] Model-driven (ZERO :string attributes for XML content)
- [ ] Polymorphic content handling (multiple possible nested elements)
- [ ] Zero baseline regressions (342/342 maintained)
- [ ] All document element tests passing (16/16)
- [ ] **Total: 274/274 tests passing (100%)**

##Key Principles

1. **Model-Driven**: Every XML element is a proper class, NO string storage
2. **Polymorphic**: Choice/Fallback can contain multiple types of nested content
3. **Reusability**: TextBoxContent shared between VML and DrawingML
4. **Namespaces**: Proper namespace handling for cross-namespace elements
5. **Pattern 0**: ALWAYS attributes before xml blocks

## Timeline

**Session 2A**: Foundation (2-3h) → Priorities 1-4 complete
**Session 2B**: DrawingML (2-3h) → Priorities 5-8 complete  
**Session 2C**: Integration (1-2h) → Priorities 9-10 complete
**Session 2D**: Verification (1h) → Priority 11, 274/274 achieved ✅

**Total**: 6-9 hours (compressed from typical 12-15h)

## Next Steps

1. Read this plan thoroughly
2. Start with Session 2A (Foundation Classes)
3. Test after each class creation
4. Maintain zero baseline regressions
5. Achieve 274/274 (100%) target

See: `PHASE5_SESSION2_PROMPT.md` for detailed start instructions