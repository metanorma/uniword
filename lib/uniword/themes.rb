# frozen_string_literal: true

module Uniword
  module Themes
    # Friendly Theme Model (human-editable)
    autoload :Theme, "#{__dir__}/themes/theme"
    autoload :ColorScheme, "#{__dir__}/themes/theme"
    autoload :FontScheme, "#{__dir__}/themes/theme"

    # Theme loading from .thmx files
    autoload :ThemeLoader, "#{__dir__}/theme/theme_loader"
    autoload :ThemePackageReader, "#{__dir__}/theme/theme_package_reader"
    autoload :ThemeImporter, "#{__dir__}/themes/theme_importer"
    autoload :ThemeVariant, "#{__dir__}/theme/theme_variant"
    autoload :MediaFile, "#{__dir__}/theme/media_file"

    # Theme application to documents
    autoload :ThemeApplicator, "#{__dir__}/theme/theme_applicator"

    # Transformation between Friendly Theme and Word Theme
    autoload :ThemeTransformation, "#{__dir__}/themes/theme_transformation"
  end
end
