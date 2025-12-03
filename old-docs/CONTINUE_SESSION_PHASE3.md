# Continue Session: Phase 3 Implementation

**Date**: November 28, 2024  
**Current Progress**: 10% of Phase 3 complete  
**Architecture**: Direct v2.0 Generated Classes (No backward compatibility)

## Context

Uniword v2.0 uses **schema-driven architecture** with 760 elements across 22 namespaces generated from YAML schemas via lutaml-model. Phase 2 (schema generation) is 100% complete.

**Critical Architectural Decision**: 
- **No v1/v2 split needed** - gem not yet released
- **Generated classes ARE the API** - no adapter layer
- **Extensions add convenience methods** to generated classes

## Current Status

### ✅ Complete
- Phase 2: All 760 elements generated across 22 namespaces
- Generated classes with lutaml-model serialization/deserialization
- YAML schema definitions in `config/ooxml/schemas/`

### 🔄 In Progress (10%)
- Created continuation plan: [`PHASE_3_CONTINUATION_PLAN.md`](PHASE_3_CONTINUATION_PLAN.md)
- Created status tracker: [`PHASE_3_IMPLEMENTATION_STATUS.md`](PHASE_3_IMPLEMENTATION_STATUS.md)
- Initial adapter code created (will be deleted - wrong approach)

### ⏳ To Do (90%)
- Archive v1.x code
- Delete adapter approach
- Create extension modules for generated classes
- Add rich API methods to extensions
- Update format handlers
- Write comprehensive tests
- Update documentation

## Immediate Next Steps

### Step 1: Archive v1.x Code (30 minutes)

```bash
# Create archive directory
mkdir -p archive/v1

# Move old v1.x model classes
mv lib/uniword/document.rb archive/v1/
mv lib/uniword/body.rb archive/v1/
mv lib/uniword/paragraph.rb archive/v1/
mv lib/uniword/run.rb archive/v1/
mv lib/uniword/table.rb archive/v1/
mv lib/uniword/element.rb archive/v1/
mv lib/uniword/text_element.rb archive/v1/
mv lib/uniword/properties/ archive/v1/

# Delete wrong adapter approach
rm -rf lib/uniword/v2/

# Move temporary docs
mkdir -p old-docs
mv docs/v2.0/TASK_1_1_INTEGRATION_STATUS.md old-docs/
```

### Step 2: Create Extension Modules (4 hours)

**Strategy**: Add convenience methods to generated classes without modifying generated code.

#### Document Extensions

Create `lib/uniword/extensions/document_extensions.rb`:

```ruby
# frozen_string_literal: true

module Uniword
  module Generated
    module Wordprocessingml
      class DocumentRoot
        # Add paragraph with optional text and formatting
        #
        # @param text [String, nil] Optional text content
        # @param options [Hash] Formatting options (bold, italic, style, etc.)
        # @return [Paragraph] The created paragraph
        def add_paragraph(text = nil, **options)
          para = Paragraph.new
          
          # Add text if provided
          if text
            run = Run.new(text: text)
            
            # Apply run formatting from options
            if options.any?
              run_props = RunProperties.new
              run_props.bold = true if options[:bold]
              run_props.italic = true if options[:italic]
              run_props.underline = options[:underline] if options[:underline]
              run_props.color = options[:color] if options[:color]
              run_props.size = options[:size] * 2 if options[:size] # half-points
              run_props.font = options[:font] if options[:font]
              run.properties = run_props
            end
            
            para.runs << run
          end
          
          # Apply paragraph formatting from options
          if options[:style] || options[:alignment]
            para_props = ParagraphProperties.new
            para_props.style = options[:style] if options[:style]
            para_props.alignment = options[:alignment] if options[:alignment]
            para.properties = para_props
          end
          
          # Ensure body exists
          self.body ||= Body.new
          
          # Add paragraph to body
          body.paragraphs << para
          para
        end
        
        # Save document to file
        #
        # @param path [String] Output file path
        # @param format [Symbol] Format (:docx, :mhtml)
        def save(path, format: :auto)
          require_relative '../../document_writer'
          writer = DocumentWriter.new(self)
          writer.save(path, format: format)
        end
        
        # Get all paragraph text
        #
        # @return [String] Combined text from all paragraphs
        def text
          return '' unless body && body.paragraphs
          body.paragraphs.map { |p| p.text }.join("\n")
        end
        
        # Get all paragraphs (convenience accessor)
        #
        # @return [Array<Paragraph>] All paragraphs in document
        def paragraphs
          body&.paragraphs || []
        end
        
        # Get all tables (convenience accessor)
        #
        # @return [Array<Table>] All tables in document
        def tables
          body&.tables || []
        end
      end
    end
  end
end
```

#### Paragraph Extensions

Create `lib/uniword/extensions/paragraph_extensions.rb`:

```ruby
# frozen_string_literal: true

module Uniword
  module Generated
    module Wordprocessingml
      class Paragraph
        # Add text run to paragraph
        #
        # @param text [String] Text content
        # @param options [Hash] Formatting options
        # @return [Run] The created run
        def add_text(text, **options)
          run = Run.new(text: text)
          
          if options.any?
            run_props = RunProperties.new
            run_props.bold = true if options[:bold]
            run_props.italic = true if options[:italic]
            run_props.underline = options[:underline] if options[:underline]
            run_props.color = options[:color] if options[:color]
            run_props.size = options[:size] * 2 if options[:size]
            run_props.font = options[:font] if options[:font]
            run.properties = run_props
          end
          
          self.runs ||= []
          runs << run
          run
        end
        
        # Get paragraph text
        #
        # @return [String] Combined text from all runs
        def text
          return '' unless runs
          runs.map { |r| r.text.to_s }.join
        end
        
        # Check if paragraph is empty
        #
        # @return [Boolean] true if no runs or all runs empty
        def empty?
          !runs || runs.empty? || runs.all? { |r| r.text.to_s.empty? }
        end
        
        # Set paragraph alignment (fluent interface)
        #
        # @param alignment [String, Symbol] Alignment value
        # @return [self] For method chaining
        def align(alignment)
          self.properties ||= ParagraphProperties.new
          properties.alignment = alignment.to_s
          self
        end
        
        # Set paragraph style
        #
        # @param style_name [String] Style name or ID
        # @return [self] For method chaining
        def set_style(style_name)
          self.properties ||= ParagraphProperties.new
          properties.style = style_name
          self
        end
      end
    end
  end
end
```

#### Run Extensions

Create `lib/uniword/extensions/run_extensions.rb`:

```ruby
# frozen_string_literal: true

module Uniword
  module Generated
    module Wordprocessingml
      class Run
        # Check if run is bold
        #
        # @return [Boolean] true if bold
        def bold?
          properties&.bold || false
        end
        
        # Check if run is italic
        #
        # @return [Boolean] true if italic
        def italic?
          properties&.italic || false
        end
        
        # Check if run is underlined
        #
        # @return [Boolean] true if underlined
        def underline?
          properties&.underline && properties.underline != 'none'
        end
        
        # Set bold formatting
        #
        # @param value [Boolean] true for bold
        def bold=(value)
          self.properties ||= RunProperties.new
          properties.bold = value
        end
        
        # Set italic formatting
        #
        # @param value [Boolean] true for italic
        def italic=(value)
          self.properties ||= RunProperties.new
          properties.italic = value
        end
        
        # Set text color
        #
        # @param value [String] Hex color (e.g., 'FF0000')
        def color=(value)
          self.properties ||= RunProperties.new
          properties.color = value
        end
        
        # Set font
        #
        # @param value [String] Font name
        def font=(value)
          self.properties ||= RunProperties.new
          properties.font = value
        end
        
        # Set font size in points
        #
        # @param value [Integer] Size in points
        def size=(value)
          self.properties ||= RunProperties.new
          properties.size = value * 2  # Convert to half-points
        end
      end
    end
  end
end
```

### Step 3: Update Public API (1 hour)

Update `lib/uniword.rb`:

```ruby
# frozen_string_literal: true

require 'lutaml/model'

# Load generated classes
require_relative 'generated/wordprocessingml'

# Load extensions
require_relative 'uniword/extensions/document_extensions'
require_relative 'uniword/extensions/paragraph_extensions'
require_relative 'uniword/extensions/run_extensions'

module Uniword
  # Version
  VERSION = '2.0.0'
  
  # Re-export generated classes as primary API
  Document = Generated::Wordprocessingml::DocumentRoot
  Paragraph = Generated::Wordprocessingml::Paragraph
  Run = Generated::Wordprocessingml::Run
  Body = Generated::Wordprocessingml::Body
  Table = Generated::Wordprocessingml::Table
  
  # Properties
  ParagraphProperties = Generated::Wordprocessingml::ParagraphProperties
  RunProperties = Generated::Wordprocessingml::RunProperties
  
  # Class methods for convenience
  class << self
    # Create a new document
    #
    # @return [Document] New document instance
    def new
      Document.new
    end
    
    # Load document from file
    #
    # @param path [String] File path
    # @return [Document] Loaded document
    def load(path)
      require_relative 'uniword/document_factory'
      DocumentFactory.from_file(path)
    end
    
    alias_method :open, :load
  end
end
```

### Step 4: Update Format Handlers (2 hours)

Key changes:
- Remove old serialization code
- Use `document.to_xml()` from generated classes
- Use `DocumentRoot.from_xml(xml)` for parsing

### Step 5: Write Tests (12 hours)

Focus on:
- Generated class functionality
- Extension methods
- Round-trip fidelity
- Performance benchmarks

### Step 6: Update Documentation (6 hours)

Update `README.adoc` with v2.0 examples showing generated classes + extensions.

## Key Principles

1. **Never modify generated classes directly** - always use extensions
2. **Schema is source of truth** - if schema changes, regenerate classes
3. **Extensions are optional** - generated classes work standalone for serialization
4. **Rich API via extensions** - add Ruby convenience methods
5. **Perfect round-trip** - lutaml-model handles XML serialization/deserialization

## Files to Track

### To Delete/Archive
- `lib/uniword/document.rb` → `archive/v1/`
- `lib/uniword/body.rb` → `archive/v1/`
- `lib/uniword/paragraph.rb` → `archive/v1/`
- `lib/uniword/run.rb` → `archive/v1/`
- `lib/uniword/v2/` → DELETE entirely

### To Create
- `lib/uniword/extensions/document_extensions.rb`
- `lib/uniword/extensions/paragraph_extensions.rb`
- `lib/uniword/extensions/run_extensions.rb`
- `lib/uniword/extensions/properties_extensions.rb`

### To Update
- `lib/uniword.rb` - Re-export generated classes
- `lib/uniword/formats/docx_handler.rb` - Use generated classes
- `lib/uniword/document_factory.rb` - Use generated classes
- `lib/uniword/document_writer.rb` - Use generated classes
- `README.adoc` - Update examples and documentation

## Success Criteria

- [ ] v1 code archived
- [ ] Adapters deleted
- [ ] Extensions created with rich API
- [ ] Public API exports generated classes
- [ ] Format handlers use generated classes
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Ready for v2.0.0 release

## References

- Continuation Plan: [`PHASE_3_CONTINUATION_PLAN.md`](PHASE_3_CONTINUATION_PLAN.md)
- Status Tracker: [`PHASE_3_IMPLEMENTATION_STATUS.md`](PHASE_3_IMPLEMENTATION_STATUS.md)
- Generated Classes: `lib/generated/wordprocessingml/`
- Schemas: `config/ooxml/schemas/`

---

**Remember**: Generated classes ARE the model. Extensions add convenience. No v1/v2 split. Clean and simple architecture.