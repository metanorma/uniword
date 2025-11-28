# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Text wrap block settings
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:wrapblock>
      class VmlWrapBlock < Lutaml::Model::Serializable
          attribute :type, String
          attribute :side, String

          xml do
            root 'wrapblock'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :side
          end
      end
    end
  end
end
