# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Customxml
      # Flag indicating whether placeholder header is shown
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:showing_placeholder_header>
      class ShowingPlaceholderHeader < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'showing_placeholder_header'
            namespace Uniword::Ooxml::Namespaces::CustomXml

            map_attribute 'val', to: :val
          end
      end
    end
end
