# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Column settings for VML text layout
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:column>
      class VmlColumn < Lutaml::Model::Serializable
          attribute :count, String
          attribute :spacing, String

          xml do
            root 'column'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :count
            map_attribute 'true', to: :spacing
          end
      end
    end
  end
end
