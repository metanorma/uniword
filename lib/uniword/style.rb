# frozen_string_literal: true

require 'lutaml/model'
require_relative 'wordprocessingml/paragraph_properties'
require_relative 'wordprocessingml/run_properties'
require_relative 'wordprocessingml/table_properties'

module Uniword
  # Represents a style definition
  #
  # A style can be paragraph, character, table, or numbering type.
  # Styles contain formatting properties and can be based on other styles.
  class Style < Lutaml::Model::Serializable
    # Pattern 0: ATTRIBUTES FIRST, then XML mappings

    # Style type (paragraph, character, table, numbering)
    attribute :type, :string

    # Style ID (used for referencing)
    attribute :id, :string

    # Style name (display name)
    attribute :name, :string

    # Default style flag
    attribute :default, :boolean, default: -> { false }

    # Custom style flag
    attribute :custom, :boolean, default: -> { false }

    # Based on style ID
    attribute :based_on, :string

    # Next style ID (for paragraph styles)
    attribute :next_style, :string

    # Linked style ID (character style for paragraph style)
    attribute :linked_style, :string

    # UI priority
    attribute :ui_priority, :integer

    # Quick format flag
    attribute :quick_format, :boolean, default: -> { false }

    # Semi-hidden flag
    attribute :semi_hidden, :boolean, default: -> { false }

    # Unhide when used flag
    attribute :unhide_when_used, :boolean, default: -> { false }

    # Formatting properties
    attribute :paragraph_properties, Wordprocessingml::ParagraphProperties
    attribute :run_properties, Wordprocessingml::RunProperties
    attribute :table_properties, Wordprocessingml::TableProperties

    # XML mappings come AFTER attributes
    xml do
      element 'style'
      namespace Ooxml::Namespaces::WordProcessingML
      mixed_content

      # Attributes
      map_attribute 'type', to: :type
      map_attribute 'styleId', to: :id
      map_attribute 'default', to: :default
      map_attribute 'customStyle', to: :custom

      # Elements with w:val attribute
      map_element 'name', to: :name, render_nil: false do
        map_attribute 'val', to: :content
      end

      map_element 'basedOn', to: :based_on, render_nil: false do
        map_attribute 'val', to: :content
      end

      map_element 'next', to: :next_style, render_nil: false do
        map_attribute 'val', to: :content
      end

      map_element 'link', to: :linked_style, render_nil: false do
        map_attribute 'val', to: :content
      end

      map_element 'uiPriority', to: :ui_priority, render_nil: false do
        map_attribute 'val', to: :content
      end

      # Boolean elements (no attributes)
      map_element 'qFormat', to: :quick_format, render_nil: false
      map_element 'semiHidden', to: :semi_hidden, render_nil: false
      map_element 'unhideWhenUsed', to: :unhide_when_used, render_nil: false

      # Property containers
      map_element 'pPr', to: :paragraph_properties, render_nil: false
      map_element 'rPr', to: :run_properties, render_nil: false
      map_element 'tblPr', to: :table_properties, render_nil: false
    end

    # Initialize with defaults
    def initialize(attrs = {})
      super
      @default ||= false
      @custom ||= false
      @quick_format ||= false
      @semi_hidden ||= false
      @unhide_when_used ||= false
    end

    # Check if this is a paragraph style
    def paragraph_style?
      type == 'paragraph'
    end

    # Check if this is a character style
    def character_style?
      type == 'character'
    end

    # Check if this is a table style
    def table_style?
      type == 'table'
    end

    # Check if this is a numbering style
    def numbering_style?
      type == 'numbering'
    end

    # Get display name
    def display_name
      name || id
    end

    # Inspect
    def inspect
      "#<Uniword::Style id=#{id.inspect} type=#{type.inspect} name=#{name.inspect}>"
    end
  end
end
