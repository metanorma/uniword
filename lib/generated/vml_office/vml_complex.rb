# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Complex VML property for advanced features
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:complex>
      class VmlComplex < Lutaml::Model::Serializable
          attribute :ext, String

          xml do
            root 'complex'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :ext
          end
      end
    end
  end
end
