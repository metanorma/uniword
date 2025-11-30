# frozen_string_literal: true

require 'lutaml/model'
require_relative 'spacing'
require_relative 'indentation'
require_relative 'alignment'
require_relative 'style_reference'
require_relative 'outline_level'
require_relative 'numbering_id'
require_relative 'numbering_level'
require_relative 'borders'
require_relative 'tabs'
require_relative 'shading'

module Uniword
  module Properties
    # Paragraph formatting properties
    #
    # Represents w:pPr element containing paragraph-level formatting.
    # Used in StyleSets and document paragraph elements.
    class ParagraphProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Simple element wrapper objects
      attribute :style, StyleReference
      attribute :alignment, Alignment
      attribute :outline_level, OutlineLevel
      attribute :numbering_id, NumberingId
      attribute :numbering_level, NumberingLevel

      # Complex spacing object
      attribute :spacing, Spacing

      # Complex indentation object
      attribute :indentation, Indentation

      # Complex borders object
      attribute :borders, Borders

      # Complex tabs object
      attribute :tabs, Tabs

      # Complex shading object
      attribute :shading, Shading

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
      attribute :num_id, :string
      attribute :ilvl, :integer  # Numbering level (0-8)

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
        namespace Ooxml::Namespaces::WordProcessingML
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
        map_element 'pageBreakBefore', to: :page_break_before, render_nil: false, render_default: false
        map_element 'widowControl', to: :widow_control, render_nil: false, render_default: false

        # Spacing options (only render if true)
        map_element 'contextualSpacing', to: :contextual_spacing, render_nil: false, render_default: false
        map_element 'suppressLineNumbers', to: :suppress_line_numbers, render_nil: false, render_default: false

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
    end
  end
end