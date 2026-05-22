# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class OptimizeForBrowser < Lutaml::Model::Serializable
      xml do
        element "optimizeForBrowser"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
