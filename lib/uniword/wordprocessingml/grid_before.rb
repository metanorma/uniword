# frozen_string_literal: true

require "lutaml/model"
module Uniword
  module Wordprocessingml
    # Grid before wrapper
    # XML: <w:gridBefore w:val="..."/>
    class GridBefore < Lutaml::Model::Serializable
      attribute :value, :integer
      xml do
        element "gridBefore"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :value, render_nil: false
      end
    end
  end
end
