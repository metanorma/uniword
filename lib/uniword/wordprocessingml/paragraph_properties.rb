# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Paragraph formatting properties
    #
    # Represents w:pPr element containing paragraph-level formatting.
    # Used in StyleSets and document paragraph elements.
    class ParagraphProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Simple element wrapper objects
      attribute :style, Properties::StyleReference
      attribute :alignment, Properties::Alignment
      attribute :outline_level, Properties::OutlineLevel
      attribute :numbering_id, Properties::NumberingId
      attribute :numbering_level, Properties::NumberingLevel

      # Complex spacing object
      attribute :spacing, Properties::Spacing

      # Complex indentation object
      attribute :indentation, Properties::Indentation

      # Complex borders object
      attribute :borders, Properties::Borders

      # Complex tabs object
      attribute :tabs, Properties::Tabs

      # Complex shading object
      attribute :shading, Properties::Shading

      # Flat spacing attributes (for parser compatibility)
      attribute :spacing_before, :integer
      attribute :spacing_after, :integer
      attribute :line_spacing, :float
      attribute :line_rule, :string

      # Flat indentation attributes (for parser compatibility)
      attribute :indent_left, :integer
      attribute :indent_right, :integer
      attribute :indent_first_line, :integer

      # Numbering
      attribute :num_id, :integer
      attribute :ilvl, :integer # Numbering level (0-8)

      # Keep together options
      attribute :keep_next, :boolean, default: -> { false }
      attribute :keep_lines, :boolean, default: -> { false }
      attribute :page_break_before, :boolean, default: -> { false }
      attribute :widow_control, :boolean, default: -> { true }

      # Spacing options
      attribute :contextual_spacing, :boolean, default: -> { false }
      attribute :suppress_line_numbers, :boolean, default: -> { false }

      # Bidirectional text
      attribute :bidirectional, :boolean, default: -> { false }

      # Shading (background color)
      attribute :shading_fill, :string      # RGB hex color
      attribute :shading_color, :string     # Pattern color
      attribute :shading_type, :string      # clear, solid, etc.

      # XML mappings come AFTER attributes
      xml do
        element 'pPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Style reference (wrapper object)
        map_element 'pStyle', to: :style, render_nil: false

        # Alignment (wrapper object)
        map_element 'jc', to: :alignment, render_nil: false

        # Spacing (complex object - WORKS)
        map_element 'spacing', to: :spacing, render_nil: false

        # Indentation (complex object)
        map_element 'ind', to: :indentation, render_nil: false

        # Outline level (wrapper object)
        map_element 'outlineLvl', to: :outline_level, render_nil: false

        # Numbering (wrapper objects - inside w:numPr parent element)
        map_element 'numId', to: :numbering_id, render_nil: false
        map_element 'ilvl', to: :numbering_level, render_nil: false

        # Keep options (only render if true)
        map_element 'keepNext', to: :keep_next, render_nil: false, render_default: false
        map_element 'keepLines', to: :keep_lines, render_nil: false, render_default: false
        map_element 'pageBreakBefore', to: :page_break_before, render_nil: false,
                                       render_default: false
        map_element 'widowControl', to: :widow_control, render_nil: false, render_default: false

        # Spacing options (only render if true)
        map_element 'contextualSpacing', to: :contextual_spacing, render_nil: false,
                                         render_default: false
        map_element 'suppressLineNumbers', to: :suppress_line_numbers, render_nil: false,
                                           render_default: false

        # Bidirectional (only render if true)
        map_element 'bidi', to: :bidirectional, render_nil: false, render_default: false

        # Borders (complex object)
        map_element 'pBdr', to: :borders, render_nil: false

        # Tabs (complex object - collection)
        map_element 'tabs', to: :tabs, render_nil: false

        # Shading (complex object)
        map_element 'shd', to: :shading, render_nil: false
      end

      # Initialize with defaults
      def initialize(attrs = {})
        super
        @keep_next ||= false
        @keep_lines ||= false
        @page_break_before ||= false
        @widow_control = true if @widow_control.nil?
        @contextual_spacing ||= false
        @suppress_line_numbers ||= false
        @bidirectional ||= false
      end

      # Alias for tabs (API compatibility)
      #
      # @return [Properties::Tabs, nil] The tab stops collection
      def tab_stops
        tabs
      end

      # Setter for tab_stops (API compatibility)
      #
      # @param value [Properties::Tabs, Array] Tab stops collection or array
      # @return [Properties::Tabs] The tab stops collection
      def tab_stops=(value)
        case value
        when Properties::Tabs
          self.tabs = value
        when Array
          self.tabs ||= Properties::Tabs.new
          tabs.tab_stops = value
        else
          self.tabs = value
        end
      end

      # Get section properties
      #
      # @return [SectionProperties, nil] Section properties if present
      attr_accessor :section_properties

      # Set section properties
      #
      # @param value [SectionProperties] Section properties

      # Set left indent (alias for indentation.left)
      #
      # @param value [Integer] Left indent in twips
      # @return [self] For method chaining
      def left_indent=(value)
        self.indentation ||= Properties::Indentation.new
        indentation.left = value
        self
      end

      # Get alignment value (returns string directly for API compatibility)
      # Overrides lutaml-model accessor to return string value
      #
      # @return [String, nil] Alignment value (left, center, right, both)
      def alignment
        val = @alignment
        return nil if val.nil?

        # Handle both wrapper object and primitive value
        val = val.value if val.respond_to?(:value)
        val.to_s
      end

      # Set alignment value (accepts string or Alignment object for API compatibility)
      #
      # @param value [String, Properties::Alignment] Alignment value or object
      # @return [self] For method chaining
      def alignment=(value)
        case value
        when Properties::Alignment
          @alignment = value
        when String
          @alignment ||= Properties::Alignment.new
          @alignment.value = value
        when nil
          @alignment = nil
        else
          @alignment = value
        end
        self
      end

      # Get alignment value (alias for backward compatibility)
      #
      # @return [String, nil] Alignment value (left, center, right, both)
      def alignment_value
        val = @alignment
        return nil if val.nil?

        val = val.value if val.respond_to?(:value)
        val.to_s
      end

      # Set alignment value (alias for backward compatibility)
      #
      # @param value [String] Alignment value
      # @return [self] For method chaining
      def alignment_value=(value)
        self.alignment = value
        self
      end
    end
  end
end
