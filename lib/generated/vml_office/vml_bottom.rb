# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Bottom offset for VML elements
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:bottom>
      class VmlBottom < Lutaml::Model::Serializable
          attribute :value, String
          attribute :units, String

          xml do
            root 'bottom'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :value
            map_attribute 'true', to: :units
          end
      end
    end
  end
end
