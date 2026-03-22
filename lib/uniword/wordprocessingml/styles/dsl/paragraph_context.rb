# frozen_string_literal: true

module Uniword
  module Styles
    module DSL
      # Paragraph Context - DSL for paragraph building
      #
      # Responsibility: Provide DSL methods for building complex paragraphs
      # Single Responsibility: Paragraph text run creation with styles only
      #
      # This context is used within the StyleBuilder#paragraph method to provide
      # a fluent interface for adding text runs with different character styles.
      #
      # @example
      #   paragraph :body_text do |p|
      #     p.text "Normal text "
      #     p.text "bold text", :strong
      #     p.text " and "
      #     p.text "code", :code
      #   end
      class ParagraphContext
        # Initialize paragraph context
        #
        # @param paragraph [Paragraph] The paragraph to build
        # @param library [StyleLibrary] The style library for character styles
        def initialize(paragraph, library)
          @paragraph = paragraph
          @library = library
        end

        # Add styled text run to paragraph
        #
        # @param content [String] Text content
        # @param style_name [String, Symbol, nil] Optional character style name
        # @return [Run] The created run
        #
        # @example
        #   text "Normal text"
        #   text "Bold text", :strong
        #   text "Code text", :code
        def text(content, style_name = nil)
          run = Wordprocessingml::Run.new(text: content)

          if style_name
            style_def = @library.character_style(style_name)
            apply_run_style(run, style_def)
          end

          @paragraph.add_run(run)
          run
        end

        private

        # Apply run style definition to run
        #
        # @param run [Run] The run to style
        # @param style_def [CharacterStyleDefinition] The style definition
        # @return [void]
        def apply_run_style(run, style_def)
          resolved = style_def.resolve_inheritance(@library)

          return unless resolved&.any?

          run.properties = Wordprocessingml::RunProperties.new(**resolved)
        end
      end
    end
  end
end
