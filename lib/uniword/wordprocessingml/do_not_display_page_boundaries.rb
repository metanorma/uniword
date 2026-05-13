# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class DoNotDisplayPageBoundaries < Lutaml::Model::Serializable
      xml do
        element "doNotDisplayPageBoundaries"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
