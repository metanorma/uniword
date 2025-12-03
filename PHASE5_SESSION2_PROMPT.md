# Phase 5 Session 2: Model Nested Content - START HERE

**Goal**: Replace string content with proper model classes to achieve 274/274 tests (100%)
**Duration**: 6-8 hours
**Status**: Ready to begin Session 2A (Foundation Classes)

## Context from Session 1

AlternateContent infrastructure was successfully implemented:
- ✅ AlternateContent, Choice, Fallback classes created
- ✅ Integrated into Paragraph, Run, Table, SdtContent
- ✅ 12/12 unit tests passing
- ✅ 342/342 baseline tests still passing (zero regressions)
- ⚠️ 266/274 total tests (97.1%)

**The Problem**: Choice and Fallback store nested content as `:string` instead of proper model classes. This violates model-driven architecture.

**The Solution**: Model ALL nested content as proper classes following these principles:
1. **Model-Driven**: Every XML element is a class, NO string storage
2. **Polymorphic**: Elements can contain multiple types (not just one)
3. **Reusable**: Shared classes like TextBoxContent
4. **Pattern 0**: Attributes BEFORE xml blocks (ALWAYS)

## Current State

```ruby
# ❌ WRONG (Current)
class Choice
  attribute :content, :string  # Stores XML as string
end

# ✅ CORRECT (Target)
class Choice
  attribute :drawing, Drawing
  attribute :pict, Pict
  attribute :paragraph, Paragraph
  # Multiple possible nested elements
end
```

## Session 2A: Foundation Classes (Start Here)

**Duration**: 2-3 hours
**Goal**: Create 4 foundation classes that are shared/reused

### Task 1: Create TextBoxContent (30 min)

**File**: `lib/uniword/wordprocessingml/text_box_content.rb`

**Why**: Shared by both VML (legacy) and DrawingML (modern) text boxes.

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Text box content container
    # Shared by VML and DrawingML text boxes
    class TextBoxContent < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
      attribute :tables, Table, collection: true, default: -> { [] }
      attribute :sdts, StructuredDocumentTag, collection: true, default: -> { [] }

      xml do
        root 'txbxContent'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'p', to: :paragraphs, render_nil: false
        map_element 'tbl', to: :tables, render_nil: false
        map_element 'sdt', to: :sdts, render_nil: false
      end
    end
  end
end
```

**Verification**:
```bash
# Should autoload via wordprocessingml.rb
ruby -e "require './lib/uniword'; puts Uniword::Wordprocessingml::TextBoxContent"
```

### Task 2: Create Pict (VML Picture Container) (20 min)

**File**: `lib/uniword/wordprocessingml/pict.rb`

**Why**: Container for VML shapes in Fallback elements.

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # VML Picture container
    # Used in AlternateContent Fallback for legacy compatibility
    class Pict < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :shapes, Vml::Shape, collection: true, default: -> { [] }

      xml do
        root 'pict'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'shape', to: :shapes, render_nil: false
      end
    end
  end
end
```

**Note**: VML elements don't need explicit namespace in map_element because Shape class defines its own namespace.

### Task 3: Create VML Textbox (45 min)

**File**: `lib/uniword/vml/textbox.rb`

**Why**: VML text box that contains TextBoxContent.

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML Textbox element
    # Contains WordprocessingML TextBoxContent
    class Textbox < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :style, :string
      attribute :inset, :string
      attribute :content, Uniword::Wordprocessingml::TextBoxContent

      xml do
        root 'textbox'
        namespace Uniword::Ooxml::Namespaces::VML
        mixed_content

        map_attribute 'style', to: :style, render_nil: false
        map_attribute 'inset', to: :inset, render_nil: false
        map_element 'txbxContent', to: :content, render_nil: false
      end
    end
  end
end
```

**Add Autoload**: `lib/uniword/vml.rb`
```ruby
autoload :Textbox, 'uniword/vml/textbox'
```

### Task 4: Create VML Wrap (15 min)

**File**: `lib/uniword/vml/wrap.rb`

**Why**: VML wrap element for shape positioning.

**Implementation**:
```ruby
# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML Wrap element
    # Defines text wrapping around shape
    class Wrap < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :anchorx, :string
      attribute :anchory, :string

      xml do
        root 'wrap'
        namespace Uniword::Ooxml::Namespaces::VML
        mixed_content

        map_attribute 'anchorx', to: :anchorx, render_nil: false
        map_attribute 'anchory', to: :anchory, render_nil: false
      end
    end
  end
end
```

**Add Autoload**: `lib/uniword/vml.rb`
```ruby
autoload :Wrap, 'uniword/vml/wrap'
```

### Task 5: Enhance VML Shape (30 min)

**File**: `lib/uniword/vml/shape.rb` (MODIFY existing)

**What**: Add textbox and wrap attributes.

**Read first**: Check existing Shape implementation.

**Add these attributes and mappings**:
```ruby
# Add to existing attributes:
attribute :textbox, Textbox, default: nil
attribute :wrap, Wrap, default: nil

# Add to existing xml mappings:
map_element 'textbox', to: :textbox, render_nil: false
map_element 'wrap', to: :wrap, render_nil: false
```

### Task 6: Test Foundation Classes (30 min)

Create basic tests to verify each class works:

```bash
cd /Users/mulgogi/src/mn/uniword

# Test 1: TextBoxContent
ruby -e "require './lib/uniword'; \
  content = Uniword::Wordprocessingml::TextBoxContent.new; \
  para = Uniword::Wordprocessingml::Paragraph.new; \
  content.paragraphs << para; \
  puts content.to_xml"

# Test 2: Pict  
ruby -e "require './lib/uniword'; \
  pict = Uniword::Wordprocessingml::Pict.new; \
  puts pict.to_xml"

# Test 3: VML Textbox
ruby -e "require './lib/uniword'; \
  tb = Uniword::Vml::Textbox.new(style: 'test'); \
  puts tb.to_xml"

# Run baseline tests (MUST stay green)
bundle exec rspec spec/uniword/styleset_roundtrip_spec.rb \
                   spec/uniword/theme_roundtrip_spec.rb
```

**Expected**: All tests still passing, no regressions.

## Session 2A Success Criteria

- [ ] TextBoxContent class created and tested
- [ ] Pict class created and tested
- [ ] VML Textbox class created and tested
- [ ] VML Wrap class created and tested
- [ ] VML Shape enhanced with textbox/wrap
- [ ] All classes follow Pattern 0
- [ ] Baseline tests: 342/342 still passing ✅

## After Session 2A Complete

Proceed to Session 2B (DrawingML Classes) as documented in `PHASE5_SESSION2_PLAN.md`.

**Timeline**:
- Session 2A: 2-3 hours (Foundation) → You are here
- Session 2B: 2-3 hours (DrawingML)
- Session 2C: 1-2 hours (Integration)
- Session 2D: 1 hour (Verification)
- **Total**: 274/274 tests (100%) ✅

## Critical Reminders

1. **Pattern 0**: Attributes BEFORE xml blocks (ALWAYS)
2. **Model-Driven**: NO :string for XML content
3. **Namespace**: Each class defines its own namespace
4. **Mixed Content**: Use `mixed_content` for elements with nested content
5. **Render Nil**: Use `render_nil: false` for optional elements
6. **Zero Regressions**: Baseline must stay at 342/342

## Troubleshooting

**Issue**: Namespace not found
**Solution**: Check `lib/uniword/ooxml/namespaces.rb` has the namespace class

**Issue**: Class not autoloading
**Solution**: Check module file (`lib/uniword/wordprocessingml.rb` or `lib/uniword/vml.rb`) has autoload

**Issue**: Tests failing
**Solution**: Verify Pattern 0 - attributes MUST be before xml block

**Issue**: Baseline regression
**Solution**: DO NOT PROCEED. Fix regression first. The architecture must be correct.

## Ready to Start?

1. Read `PHASE5_SESSION2_PLAN.md` for full context
2. Read `PHASE5_SESSION1_COMPLETE.md` for what was accomplished
3. Start with Task 1: Create TextBoxContent
4. Work through Tasks 2-6 sequentially
5. Test after each task
6. Proceed to Session 2B when complete

Good luck! Remember: **MODEL ALL THE CONTENT!!!** 🎯