# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Edge properties
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:edge>
      class Edge < Lutaml::Model::Serializable
          attribute :color, String
          attribute :weight, String

          xml do
            root 'edge'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :color
            map_attribute 'true', to: :weight
          end
      end
    end
  end
end
