# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Color MRU list
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:colormru>
    class ColorMru < Lutaml::Model::Serializable
      attribute :ext, :string
      attribute :colors, :string

      xml do
        element 'colormru'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'ext', to: :ext
        map_attribute 'colors', to: :colors
      end
    end
  end
end
