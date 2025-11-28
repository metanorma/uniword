# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Regrouping settings
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:regroup>
      class VmlRegroup < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            root 'regroup'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
