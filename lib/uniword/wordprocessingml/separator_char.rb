# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class SeparatorChar < Lutaml::Model::Serializable
      xml do
        element "separator"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    class ContinuationSeparatorChar < Lutaml::Model::Serializable
      xml do
        element "continuationSeparator"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
