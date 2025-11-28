# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Color MRU list
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:colormru>
      class ColorMru < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :colors, String

          xml do
            root 'colormru'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :ext
            map_attribute 'true', to: :colors
          end
      end
    end
  end
end
