# frozen_string_literal: true

require "lutaml/model"
require_relative "../vml_office"

module Uniword
  module Wordprocessingml
    class HdrShapeDefaults < Lutaml::Model::Serializable
      attribute :shape_defaults, Uniword::VmlOffice::VmlShapeDefaults

      xml do
        element "hdrShapeDefaults"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "shapedefaults", to: :shape_defaults, render_nil: false
      end
    end
  end
end
