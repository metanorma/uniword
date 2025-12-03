# Phase 5 Session 2B: DrawingML Classes - START HERE

**Goal**: Create DrawingML classes to replace :string content in AlternateContent
**Duration**: 2-3 hours (compressed timeline)
**Status**: Ready to begin
**Prerequisite**: Session 2A Complete ✅ (Foundation classes created)

## Context

Session 2A successfully created foundation classes with zero regressions:
- ✅ TextBoxContent (shared container for VML/DrawingML)
- ✅ Pict (VML picture container)
- ✅ VML Textbox and Wrap
- ✅ Enhanced VML Shape
- ✅ Baseline: 258/258 tests passing

**Current Problem**: Choice and Fallback still store nested content as `:string`.

**The Solution**: Create DrawingML classes so we can model ALL content properly.

## Implementation Strategy

We'll create 9 DrawingML classes in 5 tasks:

1. **Core Drawing Classes** (4 files, 60 min)
2. **Inline Class** (1 file + autoloads, 45 min)
3. **Anchor Class** (1 file, 30 min)
4. **Graphic Classes** (3 files, 45 min)
5. **Testing** (30 min)

## Task 1: Core Drawing Classes (60 min) - START HERE

### 1.1 Create Drawing Container (15 min)

**File**: `lib/uniword/wordprocessingml/drawing.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Drawing container
    # Contains either Inline (inline with text) or Anchor (positioned/floating)
    class Drawing < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :inline, WpDrawing::Inline
      attribute :anchor, WpDrawing::Anchor

      xml do
        root 'drawing'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'inline', to: :inline, render_nil: false
        map_element 'anchor', to: :anchor, render_nil: false
      end
    end
  end
end
```

**Note**: WpDrawing is the module namespace for WordProcessingDrawing classes.

### 1.2 Create Extent (10 min)

**File**: `lib/uniword/wp_drawing/extent.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Extent - Size of drawing object
    # Dimensions in EMUs (English Metric Units)
    class Extent < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :cx, :integer  # Width
      attribute :cy, :integer  # Height

      xml do
        root 'extent'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'cx', to: :cx, render_nil: false
        map_attribute 'cy', to: :cy, render_nil: false
      end
    end
  end
end
```

### 1.3 Create DocProperties (15 min)

**File**: `lib/uniword/wp_drawing/doc_properties.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Document Properties for drawing objects
    class DocProperties < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :id, :string
      attribute :name, :string
      attribute :descr, :string
      attribute :hidden, :string

      xml do
        root 'docPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'id', to: :id, render_nil: false
        map_attribute 'name', to: :name, render_nil: false
        map_attribute 'descr', to: :descr, render_nil: false
        map_attribute 'hidden', to: :hidden, render_nil: false
      end
    end
  end
end
```

### 1.4 Create NonVisualDrawingProps (20 min)

**File**: `lib/uniword/wp_drawing/non_visual_drawing_props.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Non-Visual Drawing Properties
    # Contains locking and other non-visual settings
    class NonVisualDrawingProps < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      # Currently minimal - locks will be added when needed

      xml do
        root 'cNvGraphicFramePr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content
      end
    end
  end
end
```

**After Task 1**: Run verification test to ensure no regressions.

## Task 2: Inline Class (45 min)

### 2.1 Create Inline Container (30 min)

**File**: `lib/uniword/wp_drawing/inline.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Inline drawing object
    # Flows with text, no positioning
    class Inline < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :dist_t, :integer  # Distance from text - top
      attribute :dist_b, :integer  # Distance from text - bottom
      attribute :dist_l, :integer  # Distance from text - left
      attribute :dist_r, :integer  # Distance from text - right
      attribute :extent, Extent
      attribute :doc_properties, DocProperties
      attribute :non_visual_props, NonVisualDrawingProps
      attribute :graphic, Drawingml::Graphic

      xml do
        root 'inline'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'distT', to: :dist_t, render_nil: false
        map_attribute 'distB', to: :dist_b, render_nil: false
        map_attribute 'distL', to: :dist_l, render_nil: false
        map_attribute 'distR', to: :dist_r, render_nil: false
        map_element 'extent', to: :extent, render_nil: false
        map_element 'docPr', to: :doc_properties, render_nil: false
        map_element 'cNvGraphicFramePr', to: :non_visual_props, render_nil: false
        map_element 'graphic', to: :graphic, render_nil: false
      end
    end
  end
end
```

### 2.2 Add Autoloads (15 min)

**Check if exists**: `lib/uniword/wp_drawing.rb`

If it doesn't exist, create:
```ruby
# frozen_string_literal: true

# WordProcessing Drawing namespace (wp:)
# Used for inline and anchored images

module Uniword
  module WpDrawing
    autoload :Extent, 'uniword/wp_drawing/extent'
    autoload :DocProperties, 'uniword/wp_drawing/doc_properties'
    autoload :NonVisualDrawingProps, 'uniword/wp_drawing/non_visual_drawing_props'
    autoload :Inline, 'uniword/wp_drawing/inline'
    autoload :Anchor, 'uniword/wp_drawing/anchor'
  end
end
```

If it exists, add the autoloads.

**Also update**: `lib/uniword.rb` to require `wp_drawing`:
```ruby
require_relative 'uniword/wp_drawing'
```

## Task 3: Anchor Class (30 min)

**File**: `lib/uniword/wp_drawing/anchor.rb`

**Implementation**: Similar to Inline but with additional positioning attributes.

```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Anchor drawing object
    # Positioned/floating, not inline with text
    class Anchor < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      # Distance attributes (same as Inline)
      attribute :dist_t, :integer
      attribute :dist_b, :integer
      attribute :dist_l, :integer
      attribute :dist_r, :integer
      
      # Positioning attributes (unique to Anchor)
      attribute :simple_pos, :string
      attribute :relative_height, :integer
      attribute :behind_doc, :string
      attribute :locked, :string
      attribute :layout_in_cell, :string
      attribute :allow_overlap, :string
      
      # Child elements (same as Inline)
      attribute :extent, Extent
      attribute :doc_properties, DocProperties
      attribute :non_visual_props, NonVisualDrawingProps
      attribute :graphic, Drawingml::Graphic

      xml do
        root 'anchor'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        # Distance attributes
        map_attribute 'distT', to: :dist_t, render_nil: false
        map_attribute 'distB', to: :dist_b, render_nil: false
        map_attribute 'distL', to: :dist_l, render_nil: false
        map_attribute 'distR', to: :dist_r, render_nil: false
        
        # Positioning attributes
        map_attribute 'simplePos', to: :simple_pos, render_nil: false
        map_attribute 'relativeHeight', to: :relative_height, render_nil: false
        map_attribute 'behindDoc', to: :behind_doc, render_nil: false
        map_attribute 'locked', to: :locked, render_nil: false
        map_attribute 'layoutInCell', to: :layout_in_cell, render_nil: false
        map_attribute 'allowOverlap', to: :allow_overlap, render_nil: false
        
        # Child elements
        map_element 'extent', to: :extent, render_nil: false
        map_element 'docPr', to: :doc_properties, render_nil: false
        map_element 'cNvGraphicFramePr', to: :non_visual_props, render_nil: false
        map_element 'graphic', to: :graphic, render_nil: false
      end
    end
  end
end
```

## Task 4: Graphic Classes (45 min)

### 4.1 Create Graphic (15 min)

**File**: `lib/uniword/drawingml/graphic.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Graphic container
    # Contains GraphicData with the actual picture/shape
    class Graphic < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :graphic_data, GraphicData

      xml do
        root 'graphic'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'graphicData', to: :graphic_data, render_nil: false
      end
    end
  end
end
```

### 4.2 Create GraphicData (15 min)

**File**: `lib/uniword/drawingml/graphic_data.rb`

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Graphic Data container
    # Contains URI and picture reference
    class GraphicData < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :uri, :string
      attribute :picture, :string  # Will be enhanced to Picture class later

      xml do
        root 'graphicData'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_attribute 'uri', to: :uri, render_nil: false
        map_element 'pic', to: :picture, render_nil: false
      end
    end
  end
end
```

**Note**: Picture will remain :string for now. We'll enhance it in a future session if needed.

### 4.3 Add Autoloads

**Update**: `lib/uniword/drawingml.rb` to add:
```ruby
autoload :Graphic, 'uniword/drawingml/graphic'
autoload :GraphicData, 'uniword/drawingml/graphic_data'
```

## Task 5: Testing (30 min)

### 5.1 Quick Unit Test

```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec ruby -e "require './lib/uniword'; \
  drawing = Uniword::Wordprocessingml::Drawing.new; \
  puts 'Drawing class loads: PASS'"
```

### 5.2 Baseline Verification (CRITICAL)

```bash
cd /Users/mulgogi/src/mn/uniword
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb \
                   --format progress
```

**MUST**: 258/258 still passing ✅

## Session 2B Success Criteria

- [ ] 9 DrawingML classes created
- [ ] All classes follow Pattern 0 (attributes BEFORE xml)
- [ ] All classes are model-driven (NO :string except GraphicData.picture)
- [ ] Autoloads added to wp_drawing.rb and drawingml.rb
- [ ] Baseline tests: 258/258 still passing ✅

## Critical Reminders

1. ⚠️ **ALWAYS use `bundle exec` with Ruby commands!**
2. 🚨 **Pattern 0**: Attributes BEFORE xml (ALWAYS)
3. 🏗️ **Model-Driven**: NO :string for XML content (except temporary GraphicData.picture)
4. 🔧 **Namespace**: Each class defines its own
5. 📦 **Mixed Content**: Use `mixed_content` for elements with nested content
6. ✨ **Render Nil**: Use `render_nil: false` for optional elements
7. ✅ **Zero Regressions**: Baseline must stay at 258/258

## After Session 2B Complete

Proceed to:
- **Session 2C**: Integration (replace :string in Choice/Fallback)
- **Session 2D**: Verification (test round-trip, achieve 274/274)

## Reference Documents

- [`PHASE5_SESSION2B_PLAN.md`](PHASE5_SESSION2B_PLAN.md) - Full session plan
- [`PHASE5_SESSION2B_STATUS.md`](PHASE5_SESSION2B_STATUS.md) - Status tracker
- [`PHASE5_SESSION2A_COMPLETE.md`](PHASE5_SESSION2A_COMPLETE.md) - Session 2A summary
- [`PHASE5_SESSION2_PLAN.md`](PHASE5_SESSION2_PLAN.md) - Overall Session 2 timeline

Good luck! Remember: **MODEL ALL THE CONTENT!!!** 🎯