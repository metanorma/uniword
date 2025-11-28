# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Extension for complex VML properties
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:complexExtension>
      class VmlComplexExtension < Lutaml::Model::Serializable
          attribute :type, String
          attribute :data, String

          xml do
            root 'complexExtension'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :data
          end
      end
    end
  end
end
