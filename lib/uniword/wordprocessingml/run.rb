# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/wordprocessingml/run_properties'

module Uniword
  module Wordprocessingml
    # Text run - inline text with formatting
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:r>
    class Run < Lutaml::Model::Serializable
      attribute :properties, Uniword::Ooxml::WordProcessingML::RunProperties
      attribute :text, :string
      attribute :tab, Tab
      attribute :break, Break
      attribute :alternate_content, AlternateContent, default: nil

      xml do
        element 'r'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'rPr', to: :properties, render_nil: false
        map_element 't', to: :text, render_nil: false
        map_element 'tab', to: :tab, render_nil: false
        map_element 'br', to: :break, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
      end

      # Check if run is bold
      def bold?
        properties&.bold || false
      end

      # Check if run is italic
      def italic?
        properties&.italic || false
      end

      # Check if run is underlined
      def underline?
        properties&.underline && properties.underline != 'none'
      end

      # Set bold formatting
      def bold=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.bold = value
        self
      end

      # Set italic formatting
      def italic=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.italic = value
        self
      end

      # Set underline formatting
      def underline=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.underline = value == true ? 'single' : value.to_s
        self
      end

      # Set text color
      def color=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.color = value
        self
      end

      # Set font
      def font=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.font = value
        self
      end

      # Set font size in points
      def size=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.sz = value * 2
        self
      end

      # Set strike-through formatting
      def strike=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.strike = value
        self
      end

      # Set double-strike-through formatting
      def double_strike=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.double_strike = value
        self
      end

      # Set small caps formatting
      def small_caps=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.small_caps = value
        self
      end

      # Set all caps formatting
      def caps=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.caps = value
        self
      end

      # Set highlight color
      def highlight=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.highlight = value
        self
      end

      # Set vertical alignment (superscript/subscript)
      def vert_align=(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
        properties.vert_align = value
        self
      end
    end
  end
end
