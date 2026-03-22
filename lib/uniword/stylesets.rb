# frozen_string_literal: true

module Uniword
  module Stylesets
    autoload :Package, "#{__dir__}/stylesets/package"
    autoload :YamlStyleSetLoader, "#{__dir__}/stylesets/yaml_styleset_loader"
    autoload :StyleSetImporter, "#{__dir__}/stylesets/styleset_importer"
  end
end

# Alias for backward compatibility
Uniword::StylesConfiguration = Uniword::Wordprocessingml::StylesConfiguration
