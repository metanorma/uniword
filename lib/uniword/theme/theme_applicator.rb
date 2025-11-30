# frozen_string_literal: true

module Uniword
  module Themes
    # Applies themes to documents
    #
    # Handles the application of theme objects to Word documents,
    # ensuring proper theme integration.
    #
    # @example Apply theme to document
    #   applicator = ThemeApplicator.new
    #   applicator.apply(theme, document)
    class ThemeApplicator
      # Apply theme to document
      #
      # Sets the document's theme, which will be serialized
      # to word/theme/theme1.xml when the document is saved.
      #
      # @param theme [Theme] Theme to apply
      # @param document [Document] Target document
      # @return [void]
      def apply(theme, document)
        # Set document theme
        # The theme will be serialized when document is saved
        document.theme = theme.dup

        # Future enhancement: Update existing styles to reference theme colors/fonts
        # For now, just setting the theme is sufficient for basic support
      end
    end
  end
end
