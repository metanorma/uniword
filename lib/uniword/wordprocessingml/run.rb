# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Text run - inline text with formatting
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:r>
    class Run < Lutaml::Model::Serializable
      attribute :properties, RunProperties
      attribute :text, Text
      attribute :tab, Tab
      attribute :break, Break
      attribute :drawings, Drawing, collection: true, initialize_empty: true
      attribute :pictures, Picture, collection: true, initialize_empty: true
      attribute :alternate_content, AlternateContent, default: nil
      attribute :footnote_reference, FootnoteReference
      attribute :endnote_reference, EndnoteReference

      # Revision tracking attributes
      attribute :rsid_r, :string          # Revision ID for run
      attribute :rsid_r_pr, :string       # Revision ID for run properties

      xml do
        element 'r'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'rsidR', to: :rsid_r, render_nil: false
        map_attribute 'rsidRPr', to: :rsid_r_pr, render_nil: false

        map_element 'rPr', to: :properties, render_nil: false
        map_element 't', to: :text, render_nil: false
        map_element 'tab', to: :tab, render_nil: false
        map_element 'br', to: :break, render_nil: false
        map_element 'drawing', to: :drawings, render_nil: false
        map_element 'pict', to: :pictures, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
        map_element 'footnoteReference', to: :footnote_reference, render_nil: false
        map_element 'endnoteReference', to: :endnote_reference, render_nil: false
      end

      # Initialize with text normalization
      # Converts string text to Text object for proper OOXML serialization
      def initialize(attrs = {})
        # Normalize text: convert String to Text object
        if attrs[:text].is_a?(String)
          attrs[:text] = create_text_object(attrs[:text])
        end
        super
      end

      # Set text content (converts String to Text object)
      #
      # @param value [String, Text] Text value
      def text=(value)
        @text = if value.is_a?(Text)
                  value
                elsif value.nil?
                  nil
                else
                  create_text_object(value.to_s)
                end
      end

      # Accept a visitor (Visitor pattern)
      #
      # @param visitor [BaseVisitor] The visitor to accept
      # @return [void]
      def accept(visitor)
        visitor.visit_run(self)
      end

      # Substitute text in run
      #
      # @param pattern [Regexp, String] Pattern to match
      # @param replacement [String] Replacement text
      # @return [self] For method chaining
      def substitute(pattern, replacement)
        return self unless text

        self.text = text.to_s.gsub(pattern, replacement)
        self
      end

      # Substitute with block
      #
      # @param pattern [Regexp, String] Pattern to match
      # @yield [MatchData] Block receives match data object
      # @return [self] For method chaining
      def substitute_with_block(pattern, &block)
        return self unless text

        self.text = text.to_s.gsub(pattern) do |_match_str|
          block.call(Regexp.last_match)
        end
        self
      end

      # Custom inspect for readable output
      #
      # @return [String] Human-readable representation
      def inspect
        text_preview = text.to_s
        if text_preview.length > 40
          text_preview = "#{text_preview[0, 37]}..."
        end

        flags = []
        if properties&.bold&.value == true
          flags << 'bold'
        end
        if properties&.italic&.value == true
          flags << 'italic'
        end
        if flags.any?
          "#<#{self.class} text=\"#{text_preview}\", #{flags.join(', ')}>"
        else
          "#<#{self.class} text=\"#{text_preview}\">"
        end
      end

      private

      # Create Text object with xml:space="preserve" when needed
      def create_text_object(string)
        text_obj = Text.new(content: string)
        if string.start_with?(' ') || string.end_with?(' ') || string.include?("\t")
          text_obj.xml_space = 'preserve'
        end
        text_obj
      end
    end
  end
end
