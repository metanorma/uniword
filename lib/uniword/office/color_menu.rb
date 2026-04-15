# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Color menu
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:colormenu>
    class ColorMenu < Lutaml::Model::Serializable
      attribute :ext, :string
      attribute :colors, :string

      xml do
        element "colormenu"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "ext", to: :ext
        map_attribute "colors", to: :colors
      end
    end
  end
end
