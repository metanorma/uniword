# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Dimensions for slides in the presentation
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:sld_sz>
    class SlideSize < Lutaml::Model::Serializable
      attribute :cx, :integer
      attribute :cy, :integer
      attribute :type, :string

      xml do
        element "sld_sz"
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute "cx", to: :cx
        map_attribute "cy", to: :cy
        map_attribute "type", to: :type
      end
    end
  end
end
