# frozen_string_literal: true

module Uniword
  module Themes
    # Friendly Theme Model (human-editable)
    autoload :Theme, "#{__dir__}/themes/theme"
    autoload :ColorScheme, "#{__dir__}/themes/theme"
    autoload :FontScheme, "#{__dir__}/themes/theme"

    # Transformation between Friendly Theme and Word Theme
    autoload :ThemeTransformation, "#{__dir__}/themes/theme_transformation"

    # Theme loading from .thmx files
    autoload :ThemeLoader, "#{__dir__}/theme/theme_loader"
    autoload :ThemeImporter, "#{__dir__}/themes/theme_importer"
    autoload :ThemeVariant, "#{__dir__}/theme/theme_variant"

    # Theme application to documents
    autoload :ThemeApplicator, "#{__dir__}/theme/theme_applicator"
  end
end
