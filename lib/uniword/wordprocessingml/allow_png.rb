# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class AllowPng < Lutaml::Model::Serializable
      xml do
        element "allowPNG"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end
  end
end
