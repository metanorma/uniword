# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Most Recently Used color list
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:colormru>
    class VmlColorMru < Lutaml::Model::Serializable
      attribute :ext, :string
      attribute :colors, :string

      xml do
        element 'colormru'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'ext', to: :ext
        map_attribute 'colors', to: :colors
      end
    end
  end
end
