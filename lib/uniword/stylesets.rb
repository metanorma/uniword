# frozen_string_literal: true

module Uniword
  module Stylesets
    autoload :Package, "#{__dir__}/stylesets/package"
    autoload :YamlStyleSetLoader, "#{__dir__}/stylesets/yaml_styleset_loader"
  end
end
