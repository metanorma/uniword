# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML adjustment handle for shape manipulation
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:h>
    class Handle < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :position, :string
      attribute :polar, :string
      attribute :map, :string
      attribute :invx, :string
      attribute :invy, :string
      attribute :switch, :string
      attribute :xrange, :string
      attribute :yrange, :string
      attribute :radiusrange, :string

      xml do
        element "h"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "position", to: :position, render_nil: false
        map_attribute "polar", to: :polar, render_nil: false
        map_attribute "map", to: :map, render_nil: false
        map_attribute "invx", to: :invx, render_nil: false
        map_attribute "invy", to: :invy, render_nil: false
        map_attribute "switch", to: :switch, render_nil: false
        map_attribute "xrange", to: :xrange, render_nil: false
        map_attribute "yrange", to: :yrange, render_nil: false
        map_attribute "radiusrange", to: :radiusrange, render_nil: false
      end
    end
  end
end
