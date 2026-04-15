# frozen_string_literal: true

require "lutaml/model"
module Uniword
  module Wordprocessingml
    # Width before wrapper
    # XML: <w:wBefore w:w="..." w:type="..."/>
    class WidthBefore < Lutaml::Model::Serializable
      attribute :width, :integer
      attribute :width_type, :string
      xml do
        element "wBefore"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "w", to: :width, render_nil: false
        map_attribute "type", to: :width_type, render_nil: false
      end
    end
  end
end
