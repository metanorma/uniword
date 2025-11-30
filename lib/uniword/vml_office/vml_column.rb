# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module VmlOffice
      # Column settings for VML text layout
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:column>
      class VmlColumn < Lutaml::Model::Serializable
          attribute :count, String
          attribute :spacing, String

          xml do
            element 'column'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'count', to: :count
            map_attribute 'spacing', to: :spacing
          end
      end
    end
end
