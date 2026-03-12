# frozen_string_literal: true

module Uniword
  module Themes
    autoload :ThemeLoader, "#{__dir__}/theme/theme_loader"
    autoload :YamlThemeLoader, "#{__dir__}/themes/yaml_theme_loader"
    autoload :ThemeImporter, "#{__dir__}/themes/theme_importer"
  end
end
